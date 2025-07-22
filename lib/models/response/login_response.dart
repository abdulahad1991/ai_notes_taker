class LoginResponse {
  bool? success;
  User? user;

  LoginResponse({this.success, this.user});

  LoginResponse.fromJson(json) {
    success = json['success'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? dob;
  String? email;
  String? firstName;
  String? lastName;
  String? token;
  int? userType;

  User(
      {this.dob,
        this.email,
        this.firstName,
        this.lastName,
        this.token,
        this.userType});

  User.fromJson(json) {
    dob = json['dob'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    token = json['token'];
    userType = json['user_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dob'] = this.dob;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['token'] = this.token;
    data['user_type'] = this.userType;
    return data;
  }
}