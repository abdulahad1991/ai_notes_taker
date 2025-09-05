class SubscriptionFormResponse {
  bool? success;
  List<Data>? data;

  SubscriptionFormResponse({this.success, this.data});

  SubscriptionFormResponse.fromJson(json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
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

class Data {
  String? sId;
  String? type;
  Region? region;
  bool? isActive;
  bool? isDeleted;

  Data({this.sId, this.type, this.region, this.isActive, this.isDeleted});

  Data.fromJson(json) {
    sId = json['_id'];
    type = json['type'];
    region =
    json['region'] != null ? new Region.fromJson(json['region']) : null;
    isActive = json['is_active'];
    isDeleted = json['is_deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['type'] = this.type;
    if (this.region != null) {
      data['region'] = this.region!.toJson();
    }
    data['is_active'] = this.isActive;
    data['is_deleted'] = this.isDeleted;
    return data;
  }
}

class Region {
  List<EN>? eN;
  List<EN>? dE;

  Region({this.eN, this.dE});

  Region.fromJson(json) {
    if (json['EN'] != null) {
      eN = <EN>[];
      json['EN'].forEach((v) {
        eN!.add(new EN.fromJson(v));
      });
    }
    if (json['DE'] != null) {
      dE = <EN>[];
      json['DE'].forEach((v) {
        dE!.add(new EN.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.eN != null) {
      data['EN'] = this.eN!.map((v) => v.toJson()).toList();
    }
    if (this.dE != null) {
      data['DE'] = this.dE!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EN {
  String? title;
  List<String>? bullets;

  EN({this.title, this.bullets});

  EN.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    bullets = json['bullets'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['bullets'] = this.bullets;
    return data;
  }
}