import 'dart:io';

import 'package:ai_notes_taker/models/response/login_response.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';

class ApiService {
  ApiClient? _apiClient;

  ApiService() {
    var dio = Dio();
    _apiClient = ApiClient(dio, interceptors: [AuthInterceptor()]);
  }

  /*Future<dynamic> fetchQRToken() async {
    try {
      var response = await _apiClient?.getReq("raast_qr_token");
      return QRTokenResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }*/

  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    try {
      var response = await _apiClient?.postReq("user/login", data: {
        "email": email,
        "password": password,
      });
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> signup({
    required String first_name,
    required String last_name,
    required String email,
    required String password,
  }) async {
    try {
      var response = await _apiClient?.postReq("user/signup", data: {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "password": password,
        "dob": "1991-01-28",
      });
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
