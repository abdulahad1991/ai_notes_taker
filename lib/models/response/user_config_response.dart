class UserConfigResponse {
  bool? success;
  List<UserConfigData>? data;

  UserConfigResponse({this.success, this.data});

  UserConfigResponse.fromJson( json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <UserConfigData>[];
      json['data'].forEach((v) {
        data!.add(new UserConfigData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserConfigData {
  String? sId;
  String? user;
  String? type;
  Tier? tier;

  UserConfigData({this.sId, this.user, this.type, this.tier});

  UserConfigData.fromJson(json) {
    sId = json['_id'];
    user = json['user'];
    type = json['type'];
    tier = json['tier'] != null ? new Tier.fromJson(json['tier']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['type'] = this.type;
    if (this.tier != null) {
      data['tier'] = this.tier!.toJson();
    }
    return data;
  }
}

class Tier {
  Free? free;
  Premium? premium;

  Tier({this.free, this.premium});

  Tier.fromJson(json) {
    free = json['free'] != null ? new Free.fromJson(json['free']) : null;
    premium =
    json['premium'] != null ? new Premium.fromJson(json['premium']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.free != null) {
      data['free'] = this.free!.toJson();
    }
    if (this.premium != null) {
      data['premium'] = this.premium!.toJson();
    }
    return data;
  }
}

class Free {
  int? notes;
  int? reminders;

  Free({this.notes, this.reminders});

  Free.fromJson( json) {
    notes = json['notes'];
    reminders = json['reminders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notes'] = this.notes;
    data['reminders'] = this.reminders;
    return data;
  }
}

class Premium {
  int? notes;
  int? reminders;
  String? startDate;
  String? endDate;

  Premium({this.notes, this.reminders, this.startDate, this.endDate});

  Premium.fromJson(json) {
    notes = json['notes'];
    reminders = json['reminders'];
    startDate = json['startDate'];
    endDate = json['endDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notes'] = this.notes;
    data['reminders'] = this.reminders;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    return data;
  }
}