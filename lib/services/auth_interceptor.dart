import 'package:dio/dio.dart';

import '../../app/app.locator.dart';
import 'app_auth_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    var userToken = locator<AppAuthService>().loginData;
    if (userToken != null) {
      print("JWT TOKEN--->>>>>${userToken.user?.token}");
      options.headers['Authorization'] = "Bearer ${userToken.user?.token}";
    }

    return handler.next(options);
  }
}
