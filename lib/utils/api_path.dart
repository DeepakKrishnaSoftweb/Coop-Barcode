abstract final class ApiPath {
  ApiPath._();

  // BaseURL
  static const String baseUrl = 'https://coop-discounts.com/';
  //static const String baseUrl = 'http://coopdiscerp923492dj2j.ddnsgeek.com:8070/';

  // Image BaseURL
  static String imageBaseUrl(String image) => '$baseUrl$image';

  // Session Login
  static const String sessionLogin = 'web/session/authenticate';

  // Product
  static const String product = 'api/bcp-product-template';
}
