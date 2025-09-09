import 'dart:io';

import 'package:ai_notes_taker/models/response/base_response.dart';
import 'package:ai_notes_taker/models/response/login_response.dart';
import 'package:ai_notes_taker/models/response/signup_form_response.dart';
import 'package:ai_notes_taker/models/response/subscription_form_response.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/response/create_note_response.dart';
import '../models/response/create_note_text_response.dart';
import '../models/response/notes_response.dart';
import '../models/response/transcribe_response.dart';
import '../models/response/transcription_response.dart';
import '../models/response/user_config_response.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';

class ApiService {
  ApiClient? _apiClient;

  ApiService() {
    var dio = Dio();
    _apiClient = ApiClient(dio, interceptors: [AuthInterceptor()]);
  }

  Future<dynamic> login({
    required String email,
    required String password,
    required String fcm_token,
    String? region,
    String? country,
    String? offset,
    String? timezone,
  }) async {
    try {
      Map<String, dynamic> loginData = {
        "email": email,
        "password": password,
        "fcm_token": fcm_token,
      };

      // Add region data if available
      if (region != null) loginData["region"] = region;
      if (country != null) loginData["country"] = country;
      if (timezone != null) loginData["timezone"] = timezone;
      if (offset != null) loginData["offset"] = offset;

      var response = await _apiClient?.postReq("user/login", data: loginData);
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
    String? offset,
    String? timezone,
  }) async {
    try {
      var response = await _apiClient?.postReq("user/signup", data: {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "password": password,
        "dob": "1991-01-28",
        "offset": offset,
        "timezone": timezone,
      });
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> transcribe({
    required File file,
    required int is_reminder,
    required String user_current_datetime,
    required String offset,
  }) async {
    try {
      String? fileExt = file.path.split('.').last.toLowerCase();
      String mimeType =
          fileExt == 'wav' ? 'audio/wav' : 'application/octet-stream';
      MultipartFile? multipartFile;
      multipartFile = await MultipartFile.fromFile(
        file.path.toString(),
        contentType: MediaType.parse(mimeType),
        filename: file.path.split('/').last,
      );

      Map<String, dynamic> dataMap = {
        "file": multipartFile,
        "is_reminder": 1,
        "user_current_datetime": user_current_datetime,
        "offset": offset,
      };

      FormData formData = FormData.fromMap(dataMap);

      var response = await _apiClient?.postReq("transcribe", data: formData);
      return TranscribeResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getReminders(int page) async {
    try {
      var response =
          await _apiClient?.getReq("reminders?skip=${page}&limit=40");
      return TranscriptionResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getNotes(int page) async {
    try {
      var response = await _apiClient?.getReq("notes?skip=${page}&limit=40");
      return NotesResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateUser({
    required String fcm_token,
  }) async {
    try {
      var response = await _apiClient?.putReq("user/update", data: {
        "updatePayload": {
          "fcm_token": fcm_token,
        }
      });
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> reminderVoice({
    required File file,
    required int is_reminder,
    required String user_current_datetime,
    required String offset,
  }) async {
    try {
      String? fileExt = file.path.split('.').last.toLowerCase();
      String mimeType =
          fileExt == 'wav' ? 'audio/wav' : 'application/octet-stream';
      MultipartFile? multipartFile;
      multipartFile = await MultipartFile.fromFile(
        file.path.toString(),
        contentType: MediaType.parse(mimeType),
        filename: file.path.split('/').last,
      );

      Map<String, dynamic> dataMap = {
        "file": multipartFile,
        "user_current_datetime": user_current_datetime,
      };

      FormData formData = FormData.fromMap(dataMap);

      var response =
          await _apiClient?.postReq("reminder/voice", data: formData);
      return TranscribeResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> noteVoice({
    required File file,
    required int is_reminder,
    required String user_current_datetime,
    required String offset,
    String? title,
  }) async {
    try {
      String? fileExt = file.path.split('.').last.toLowerCase();
      String mimeType =
          fileExt == 'wav' ? 'audio/wav' : 'application/octet-stream';
      MultipartFile? multipartFile;
      multipartFile = await MultipartFile.fromFile(
        file.path.toString(),
        contentType: MediaType.parse(mimeType),
        filename: file.path.split('/').last,
      );

      Map<String, dynamic> dataMap = {
        "file": multipartFile,
        // "is_reminder": 1,
        "user_current_datetime": user_current_datetime,
        // "offset": offset,
      };

      if (title != null && title.isNotEmpty) {
        dataMap["title"] = title;
      }

      FormData formData = FormData.fromMap(dataMap);

      var response = await _apiClient?.postReq("note/voice", data: formData);
      return CreateNoteResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete({
    required String context_id,
    required String context,
  }) async {
    try {
      var response = await _apiClient?.deleteReq("delete", data: {
        "context_id": context_id,
        "context": context,
      });
      return BaseResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createNoteText({
    required String title,
    required String text,
  }) async {
    try {
      var response = await _apiClient?.postReq("note/text", data: {
        "title": title,
        "text": text,
      });
      return CreateNoteResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createReminderText({
    required String title,
    required String reminder_time,
    required String description,
  }) async {
    try {
      var response = await _apiClient?.postReq("reminder/text", data: {
        "title": title,
        "reminder_time": reminder_time,
        "text": description,
        "user_current_datetime": DateTime.now().toUtc().toIso8601String(),
      });
      return CreateNoteTextResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> editNoteText({
    required String id,
    required String title,
    required String text,
    required int is_pin,
  }) async {
    try {
      var response = await _apiClient?.putReq("update/${id}", data: {
        "context": "note",
        "updatePayload": {
          "title": title,
          "text": text,
          "is_pin": is_pin == 1 ? true : false,
        },
      });
      return BaseResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> pinNote({
    required String id,
    required int is_pin,
  }) async {
    try {
      var response = await _apiClient?.putReq("update/${id}", data: {
        "context": "note",
        "updatePayload": {
          "is_pin": is_pin == 1 ? true : false,
        },
      });
      return BaseResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> editReminderText({
    required String id,
    required String title,
    required String text,
    required String dateTime,
  }) async {
    try {
      var response = await _apiClient?.putReq("update/${id}", data: {
        "context": "reminder",
        "updatePayload": {
          "title": title,
          "text": text,
          "run_time": dateTime,
        },
      });
      return BaseResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateInfoForm({
    required String key,
    required String value,
  }) async {
    try {
      var response = await _apiClient?.putReq("user/update", data: {
        "updatePayload": {
          key: value,
          "post_signup_form_submitted": true,
        }
      });
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> searchNotes({
    required String query,
    int page = 0,
    int limit = 40,
  }) async {
    try {
      var response = await _apiClient?.getReq(
          "notes/search?query=${Uri.encodeComponent(query)}&skip=${page}&limit=${limit}");
      return NotesResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getPaymentForm() async {
    try {
      var response = await _apiClient?.getReq("form/get?form_type=payment");
      return SubscriptionFormResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getSignUpForm() async {
    try {
      var response = await _apiClient?.getReq("form/get?form_type=post_signup");
      return SignupFormResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getUserConfig() async {
    try {
      var response = await _apiClient?.getReq("user/config");
      return UserConfigResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
