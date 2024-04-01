import 'package:jwt_decode/jwt_decode.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiData {
  static String _apiUrl = '';
  static String get apiUrl => _apiUrl;
  static set apiUrl(String url) {
    _apiUrl = url;
    _storeUrl();
  }

  static String? _authToken;
  static String? get authToken => _authToken;
  static set authToken(String? token) {
    _authToken = token;
    _storeToken();
  }

  static bool isTokenValid() {
    if (authToken == null || authToken == '') {
      return false;
    } else {
      return !Jwt.isExpired(authToken!);
    }
  }

  static void initalize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? url = prefs.getString('apiUrl');
    _apiUrl = url ?? 'http://localhost:8080/api/v1';

    final String? token = prefs.getString('token');
    if (token != null && !Jwt.isExpired(token)) {
      _authToken = token;
    }
    Logger().i('ApiData initialized with url: $_apiUrl');
  }

  static void _storeUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiUrl', _apiUrl);
  }

  static void _storeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _authToken ?? '');
  }

  Exception exceptionUnauthorized() {
    return Exception('user not authorized');
  }
}
