import 'dart:io';
import 'package:flutter/material.dart';
import '../models/store_config_model.dart';
import '../repositories/product_repository.dart';

class StoreConfigController extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  bool _isLoading = false;
  bool _isDisposed = false;

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  bool get isLoading => _isLoading;

  Stream<StoreConfigModel> get storeConfigStream => _repository.getStoreConfig();

  Future<void> updateConfig({
    required StoreConfigModel currentConfig,
    String? storeName,
    String? storeDescription,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? facebookUrl,
    String? instagramUrl,
    String? twitterUrl,
    double? deliveryCharge,
    double? freeDeliveryThreshold,
    bool? enableCOD,
    File? newLogoFile,
  }) async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      String logoUrl = currentConfig.logoUrl;

      if (newLogoFile != null) {
        logoUrl = await _repository.uploadStoreLogo(newLogoFile);
      }

      final updatedConfig = StoreConfigModel(
        logoUrl: logoUrl,
        bannerUrl: currentConfig.bannerUrl, // preserve existing
        storeName: storeName ?? currentConfig.storeName,
        storeDescription: storeDescription ?? currentConfig.storeDescription,
        contactEmail: contactEmail ?? currentConfig.contactEmail,
        contactPhone: contactPhone ?? currentConfig.contactPhone,
        address: address ?? currentConfig.address,
        facebookUrl: facebookUrl ?? currentConfig.facebookUrl,
        instagramUrl: instagramUrl ?? currentConfig.instagramUrl,
        twitterUrl: twitterUrl ?? currentConfig.twitterUrl,
        deliveryCharge: deliveryCharge ?? currentConfig.deliveryCharge,
        freeDeliveryThreshold: freeDeliveryThreshold ?? currentConfig.freeDeliveryThreshold,
        enableCOD: enableCOD ?? currentConfig.enableCOD,
      );

      await _repository.updateStoreConfig(updatedConfig);
    } catch (e) {
      debugPrint("Error updating store config: $e");
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
