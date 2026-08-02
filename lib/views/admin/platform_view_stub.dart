// Stub implementation for mobile/desktop
class PlatformViewRegistryStub {
  void registerViewFactory(String viewId, dynamic Function(int) factory) {}
}

final platformViewRegistry = PlatformViewRegistryStub();
