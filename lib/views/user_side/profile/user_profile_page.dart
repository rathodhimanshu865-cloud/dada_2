import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../models/user_model.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/homepage_controller.dart';
import '../../../utils/app_typography.dart';
import '../sections/product_cart_layout.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _pinCtrl;
  
  bool _isEditing = false;
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color accentGold = const Color(0xFFC89A5B);

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthController>(context, listen: false).userModel;
    _nameCtrl = TextEditingController(text: user?.name);
    _phoneCtrl = TextEditingController(text: user?.phone);
    _addressCtrl = TextEditingController(text: user?.address);
    _cityCtrl = TextEditingController(text: user?.city);
    _stateCtrl = TextEditingController(text: user?.state);
    _pinCtrl = TextEditingController(text: user?.pincode);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (pickedFile != null) {
      if (mounted) {
        await Provider.of<AuthController>(context, listen: false).updateProfileImage(File(pickedFile.path));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      await Provider.of<AuthController>(context, listen: false).updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        pincode: _pinCtrl.text.trim(),
      );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.redAccent));
      }
    }
  }

  void _showChangePasswordDialog() {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter new secure password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              if (passCtrl.text.length < 8) return;
              try {
                await Provider.of<AuthController>(context, listen: false).changePassword(passCtrl.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Changed Successfully!'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
              }
            },
            child: const Text('UPDATE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final homeController = Provider.of<HomePageController>(context, listen: false);
    final user = auth.userModel;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ProductCartLayout(
      controller: homeController,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileHeader(user, auth.isLoading),
                  const SizedBox(height: 40),
                  _buildProfileFields(),
                  const SizedBox(height: 40),
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => setState(() => _isEditing = false), child: const Text('CANCEL'))),
                        const SizedBox(width: 20),
                        Expanded(child: ElevatedButton(onPressed: auth.isLoading ? null : _saveProfile, style: ElevatedButton.styleFrom(backgroundColor: primaryTeal), child: const Text('SAVE CHANGES'))),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildSettingsTile(Icons.lock_outline, 'Change Password', _showChangePasswordDialog),
                        const SizedBox(height: 12),
                        _buildSettingsTile(Icons.logout, 'Logout from Account', () async {
                          await auth.logout();
                          if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }, isDestructive: true),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user, bool loading) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentGold, width: 3),
                image: user.profileImage.isNotEmpty
                    ? DecorationImage(image: NetworkImage(user.profileImage), fit: BoxFit.cover)
                    : null,
              ),
              child: user.profileImage.isEmpty
                  ? Icon(Icons.person, size: 60, color: Colors.grey.shade300)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: loading ? null : _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle),
                  child: loading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(user.name, style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(user.email, style: TextStyle(color: Colors.grey.shade500)),
        const SizedBox(height: 20),
        if (!_isEditing)
          OutlinedButton.icon(
            onPressed: () => setState(() => _isEditing = true),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('EDIT PROFILE'),
          ),
      ],
    );
  }

  Widget _buildProfileFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoLabel('PERSONAL INFORMATION'),
        const SizedBox(height: 16),
        _buildTextField(_nameCtrl, 'Full Name', Icons.person_outline, enabled: _isEditing),
        const SizedBox(height: 16),
        _buildTextField(_phoneCtrl, 'Phone / WhatsApp', Icons.phone_outlined, enabled: _isEditing),
        const SizedBox(height: 32),
        _infoLabel('SHIPPING ADDRESS'),
        const SizedBox(height: 16),
        _buildTextField(_addressCtrl, 'Street Address', Icons.location_on_outlined, enabled: _isEditing, maxLines: 2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(_cityCtrl, 'City', null, enabled: _isEditing)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(_stateCtrl, 'State', null, enabled: _isEditing)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(_pinCtrl, 'Pincode', null, enabled: _isEditing),
      ],
    );
  }

  Widget _infoLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1));
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData? icon, {bool enabled = true, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        filled: !enabled,
        fillColor: enabled ? Colors.transparent : Colors.grey.shade50,
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.black87),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDestructive ? Colors.redAccent : Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
    );
  }
}
