class AppConfig {
  AppConfig._();

  static const apiBaseUrl = 'http://localhost:3000';
  static const androidEmulatorApiBaseUrl = 'http://10.0.2.2:3000';
  static const apiDocsUrl = '$apiBaseUrl/docs';
  static const apiOpenApiJsonUrl = '$apiBaseUrl/docs-json';
  static const connectTimeoutMs = 15000;
  static const receiveTimeoutMs = 15000;
}
