import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/store_config_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/store_config_model.dart';
import '../../utils/app_typography.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryTeal = const Color(0xFF0F4C5C);

  late TextEditingController _storeNameController;
  late TextEditingController _storeDescController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _deliveryChargeController;
  late TextEditingController _freeDeliveryController;
  bool _enableCOD = true;
  File? _newLogoFile;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController();
    _storeDescController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _facebookController = TextEditingController();
    _instagramController = TextEditingController();
    _twitterController = TextEditingController();
    _deliveryChargeController = TextEditingController();
    _freeDeliveryController = TextEditingController();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _deliveryChargeController.dispose();
    _freeDeliveryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newLogoFile = File(pickedFile.path);
      });
    }
  }

  void _populateControllers(StoreConfigModel config) {
    if (_storeNameController.text.isEmpty && config.storeName.isNotEmpty) {
      _storeNameController.text = config.storeName;
      _storeDescController.text = config.storeDescription;
      _emailController.text = config.contactEmail;
      _phoneController.text = config.contactPhone;
      _addressController.text = config.address;
      _facebookController.text = config.facebookUrl;
      _instagramController.text = config.instagramUrl;
      _twitterController.text = config.twitterUrl;
      _deliveryChargeController.text = config.deliveryCharge.toString();
      _freeDeliveryController.text = config.freeDeliveryThreshold.toString();
      _enableCOD = config.enableCOD;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<StoreConfigController>(context);

    return StreamBuilder<StoreConfigModel>(
      stream: controller.storeConfigStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _storeNameController.text.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final config = snapshot.data ?? StoreConfigModel();
        _populateControllers(config);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.storeSettings, 
                style: AppTypography.headingStyle(context, fontSize: 28, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 10),
              Text(AppLocalizations.of(context)!.manageAppConfig, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(AppLocalizations.of(context)!.generalInfoBranding),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _newLogoFile != null 
                                    ? FileImage(_newLogoFile!) as ImageProvider
                                    : (config.logoUrl.isNotEmpty ? NetworkImage(config.logoUrl) : null),
                                child: (_newLogoFile == null && config.logoUrl.isEmpty)
                                    ? const Icon(Icons.store, size: 40, color: Colors.grey)
                                    : null,
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.upload),
                                label: Text(AppLocalizations.of(context)!.uploadNewLogo),
                                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(AppLocalizations.of(context)!.storeName, _storeNameController),
                          const SizedBox(height: 16),
                          _buildTextField(AppLocalizations.of(context)!.storeDescription, _storeDescController, maxLines: 3),
                        ],
                      ),
                    ),

                    _buildSectionTitle(AppLocalizations.of(context)!.contactInformation),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildTextField(AppLocalizations.of(context)!.emailAddressLabel, _emailController),
                          const SizedBox(height: 16),
                          _buildTextField(AppLocalizations.of(context)!.phoneLabel, _phoneController),
                          const SizedBox(height: 16),
                          _buildTextField(AppLocalizations.of(context)!.physicalAddress, _addressController, maxLines: 2),
                        ],
                      ),
                    ),

                    _buildSectionTitle(AppLocalizations.of(context)!.socialLinks),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildTextField(AppLocalizations.of(context)!.facebookUrl, _facebookController),
                          const SizedBox(height: 16),
                          _buildTextField(AppLocalizations.of(context)!.instagramUrl, _instagramController),
                          const SizedBox(height: 16),
                          _buildTextField(AppLocalizations.of(context)!.twitterUrl, _twitterController),
                        ],
                      ),
                    ),

                    _buildSectionTitle(AppLocalizations.of(context)!.deliverySettings),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildTextField(AppLocalizations.of(context)!.standardDeliveryChargeRs, _deliveryChargeController, isNumber: true),
                          const SizedBox(height: 16),
                          _buildTextField(AppLocalizations.of(context)!.freeDeliveryThresholdRs, _freeDeliveryController, isNumber: true),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: Text(AppLocalizations.of(context)!.enableCod),
                            value: _enableCOD,
                            activeColor: primaryTeal,
                            onChanged: (val) {
                              setState(() {
                                _enableCOD = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            await controller.updateConfig(
                              currentConfig: config,
                              storeName: _storeNameController.text,
                              storeDescription: _storeDescController.text,
                              contactEmail: _emailController.text,
                              contactPhone: _phoneController.text,
                              address: _addressController.text,
                              facebookUrl: _facebookController.text,
                              instagramUrl: _instagramController.text,
                              twitterUrl: _twitterController.text,
                              deliveryCharge: double.tryParse(_deliveryChargeController.text),
                              freeDeliveryThreshold: double.tryParse(_freeDeliveryController.text),
                              enableCOD: _enableCOD,
                              newLogoFile: _newLogoFile,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.settingsSaved)));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white),
                        child: controller.isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(AppLocalizations.of(context)!.saveChanges, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildTextField(String label, TextEditingController textController, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: textController,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
