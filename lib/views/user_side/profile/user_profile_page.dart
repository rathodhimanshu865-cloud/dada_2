import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dada_2/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileUpdated), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.updateFailed(e.toString())), backgroundColor: Colors.redAccent));
      }
    }
  }

  void _showChangePasswordDialog() {
    final l10n = AppLocalizations.of(context)!;
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changePassword),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: InputDecoration(hintText: l10n.enterNewPassword),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (passCtrl.text.length < 8) return;
              try {
                await Provider.of<AuthController>(context, listen: false).changePassword(passCtrl.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.passwordChangedSuccess), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorWithDetails(e.toString())), backgroundColor: Colors.redAccent));
              }
            },
            child: Text(l10n.update),
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
    final l10n = AppLocalizations.of(context)!;

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
                        Expanded(child: OutlinedButton(onPressed: () => setState(() => _isEditing = false), child: Text(l10n.cancel))),
                        const SizedBox(width: 20),
                        Expanded(child: ElevatedButton(onPressed: auth.isLoading ? null : _saveProfile, style: ElevatedButton.styleFrom(backgroundColor: primaryTeal), child: Text(l10n.saveChanges))),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildSettingsTile(Icons.lock_outline, l10n.changePassword, _showChangePasswordDialog),
                        const SizedBox(height: 12),
                        _buildSettingsTile(Icons.logout, l10n.logoutFromAccount, () async {
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
    final l10n = AppLocalizations.of(context)!;
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
            label: Text(l10n.editProfile),
          ),
      ],
    );
  }

  Widget _buildProfileFields() {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoLabel(l10n.personalInformation),
        const SizedBox(height: 16),
        _buildTextField(_nameCtrl, l10n.fullNameLabel, Icons.person_outline, enabled: _isEditing),
        const SizedBox(height: 16),
        _buildTextField(_phoneCtrl, l10n.mobileWhatsAppLabel, Icons.phone_outlined, enabled: _isEditing),
        const SizedBox(height: 32),
        _infoLabel(l10n.shippingAddress),
        const SizedBox(height: 16),
        _buildTextField(_addressCtrl, l10n.streetAddress, Icons.location_on_outlined, enabled: _isEditing, maxLines: 2),
        const SizedBox(height: 16),
        if (isMobile) ...[
          _buildTextField(_cityCtrl, l10n.cityLabel, null, enabled: _isEditing),
          const SizedBox(height: 16),
          _buildTextField(_stateCtrl, l10n.stateLabel, null, enabled: _isEditing),
        ] else
          Row(
            children: [
              Expanded(child: _buildTextField(_cityCtrl, l10n.cityLabel, null, enabled: _isEditing)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField(_stateCtrl, l10n.stateLabel, null, enabled: _isEditing)),
            ],
          ),
        const SizedBox(height: 16),
        _buildTextField(_pinCtrl, l10n.pincodeLabel, null, enabled: _isEditing),
      ],
    );
  }

  Widget _infoLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1));
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData? icon, {bool enabled = true, int maxLines = 1}) {
    final l10n = AppLocalizations.of(context)!;
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
      validator: (v) => v == null || v.isEmpty ? l10n.requiredField : null,
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
