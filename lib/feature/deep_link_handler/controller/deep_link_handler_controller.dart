import '../../../core/data/service/deep_link_service.dart';

class DeepLinkHandlerController {
  DeepLinkHandlerController({DeepLinkService? service})
    : _service = service ?? DeepLinkService();

  final DeepLinkService _service;

  String explain(String path) {
    return 'Incoming link routed to: $path';
  }

  Future<String?> resolve(String url) {
    return _service.handleIncomingLink(url);
  }
}
