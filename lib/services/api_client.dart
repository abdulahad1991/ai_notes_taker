import 'dart:io';

import 'package:dio/dio.dart';

import '../../app/app.locator.dart';
import 'app_auth_service.dart';

class ApiClient {
  Dio? _dio;

  final authService = locator<AppAuthService>();
  final List<Interceptor>? interceptors;

  ApiClient(Dio dio, {this.interceptors}) {
    _dio = dio;
    final customHeaders = <String, dynamic>{};
    customHeaders['Content-Type'] = 'application/json';
    customHeaders['Accept'] = 'application/json';
    _dio!
      ..options.baseUrl = "http://voice-pad-backend-fastapi.vercel.app/"
      // ..options.connectTimeout = _defaultConnectTimeout
      // ..options.receiveTimeout = _defaultReceiveTimeout
      ..httpClientAdapter
      ..options.headers = customHeaders;

    // Add 401 response interceptor
    _dio?.interceptors.add(InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (error.response?.statusCode == 401) {
          // Clear auth data and navigate to login
          authService.resetAuthData();
          // AppNavService.loginViewClearStack();
          return handler.next(error);
        }
        return handler.next(error);
      },
    ));

    // Add custom interceptors if any
    if (interceptors?.isNotEmpty ?? false) {
      _dio?.interceptors.addAll(interceptors!);
    }
  }

  Future<dynamic> getReq(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      print("QUERY PARAMS ========>>>>>> $queryParameters");
      var response = await _dio?.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      print("RESPONSE========>>>>>> $response");
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on DioException catch (e) {
      print("DioException--> ${e.toString()}");
      throw FormatException(
          e.response?.data['message'] ?? "Unable to connect to server");
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw const FormatException();
    }
  }

  Future<dynamic> getReqSimple(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio?.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      print("RESPONSE========>>>>>> $response");
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on DioException catch (e) {
      print("DioException--> ${e.toString()}");
      throw FormatException(e.response?.data['message'] ?? "An error occurred");
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> postReq(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      print("REQUEST--> ${data.toString()}");
      var response = await _dio?.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      print("RESPONSE--> ${response!.data.toString()}");
      return response;
    } on SocketException catch (e) {
      print("SocketException--> ${e.toString()}");
      throw SocketException(e.toString());
    } on FormatException catch (e) {
      print("FormatException--> ${e.toString()}");
      throw const FormatException("Unable to process the data");
    } on DioException catch (e) {
      print("DioException--> ${e.toString()}");
      throw const FormatException("Unable to process the data");
    } catch (e) {
      print("CATCH EXCEPTION--> ${e.toString()}");
      rethrow;
    }
  }

  Future<dynamic> postReqSimple(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    print("REQUEST--> ${data.toString()}");
    try {
      var response = await _dio?.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      print("RESPONSE========>>>>>> $response");
      return response;
    } on SocketException catch (e) {
      print("SocketException--> ${e.toString()}");
      throw SocketException(e.toString());
    } on FormatException catch (e) {
      print("FormatException--> ${e.toString()}");
      throw const FormatException("Unable to process the data");
    } on DioException catch (e) {
      print("DioException--> ${e.toString()}");
      throw FormatException(e.response?.data['message'] ?? "An error occurred");
    } catch (e) {
      print("CATCH EXCEPTION--> ${e.toString()}");
      rethrow;
    }
  }

  Future<dynamic> patchReq(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio?.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> putReq(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      var response = await _dio?.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteReq(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      var response = await _dio?.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      rethrow;
    }
  }
}
