class SignupResponse {
  bool? success;
  String? userId;

  SignupResponse({this.success, this.userId});

  SignupResponse.fromJson(json) {
    success = json['success'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['user_id'] = this.userId;
    return data;
  }
}