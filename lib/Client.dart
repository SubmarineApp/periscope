import 'package:openapi_dart_common/openapi.dart';
import 'package:backend_api/api.dart';

class Client {
  ApiClient _apiClient;

  Client() {
    _apiClient = ApiClient(
      apiClientDelegate: LocalApiClient(),
    );
  }
}
