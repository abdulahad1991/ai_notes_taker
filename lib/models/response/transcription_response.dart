class TranscriptionResponse {
  List<Data>? data;

  TranscriptionResponse({this.data});

  TranscriptionResponse.fromJson(json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  Id? iId;
  Id? user;
  String? filename;
  String? transcription;
  int? fileSize;
  bool? isReminder;
  Id? reminderId;
  bool? isActive;
  bool? isComplete;
  bool? isDeleted;
  CreatedAt? createdAt;
  CreatedAt? updatedAt;
  Reminder? reminder;

  Data(
      {this.iId,
        this.user,
        this.filename,
        this.transcription,
        this.fileSize,
        this.isReminder,
        this.reminderId,
        this.isActive,
        this.isComplete,
        this.isDeleted,
        this.createdAt,
        this.updatedAt,
        this.reminder});

  Data.fromJson(json) {
    iId = json['_id'] != null ? new Id.fromJson(json['_id']) : null;
    user = json['user'] != null ? new Id.fromJson(json['user']) : null;
    filename = json['filename'];
    transcription = json['transcription'];
    fileSize = json['file_size'];
    isReminder = json['is_reminder'];
    reminderId = json['reminder_id'] != null
        ? new Id.fromJson(json['reminder_id'])
        : null;
    isActive = json['is_active'];
    isComplete = json['is_complete'];
    isDeleted = json['is_deleted'];
    createdAt = json['created_at'] != null
        ? new CreatedAt.fromJson(json['created_at'])
        : null;
    updatedAt = json['updated_at'] != null
        ? new CreatedAt.fromJson(json['updated_at'])
        : null;
    reminder = json['reminder'] != null
        ? new Reminder.fromJson(json['reminder'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.iId != null) {
      data['_id'] = this.iId!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['filename'] = this.filename;
    data['transcription'] = this.transcription;
    data['file_size'] = this.fileSize;
    data['is_reminder'] = this.isReminder;
    if (this.reminderId != null) {
      data['reminder_id'] = this.reminderId!.toJson();
    }
    data['is_active'] = this.isActive;
    data['is_complete'] = this.isComplete;
    data['is_deleted'] = this.isDeleted;
    if (this.createdAt != null) {
      data['created_at'] = this.createdAt!.toJson();
    }
    if (this.updatedAt != null) {
      data['updated_at'] = this.updatedAt!.toJson();
    }
    if (this.reminder != null) {
      data['reminder'] = this.reminder!.toJson();
    }
    return data;
  }
}

class Id {
  String? oid;

  Id({this.oid});

  Id.fromJson(Map<String, dynamic> json) {
    oid = json['$oid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$oid'] = this.oid;
    return data;
  }
}

class CreatedAt {
  String? date;

  CreatedAt({this.date});

  CreatedAt.fromJson(Map<String, dynamic> json) {
    date = json['$date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$date'] = this.date;
    return data;
  }
}

class Reminder {
  Id? iId;
  Id? user;
  CreatedAt? runTime;
  String? message;
  String? title;
  CreatedAt? userCurrentDatetime;
  bool? isDelivered;
  CreatedAt? createdAt;
  CreatedAt? updatedAt;

  Reminder(
      {this.iId,
        this.user,
        this.runTime,
        this.message,
        this.title,
        this.userCurrentDatetime,
        this.isDelivered,
        this.createdAt,
        this.updatedAt});

  Reminder.fromJson(Map<String, dynamic> json) {
    iId = json['_id'] != null ? new Id.fromJson(json['_id']) : null;
    user = json['user'] != null ? new Id.fromJson(json['user']) : null;
    runTime = json['run_time'] != null
        ? new CreatedAt.fromJson(json['run_time'])
        : null;
    message = json['text'];
    title = json['title'];
    userCurrentDatetime = json['user_current_datetime'] != null
        ? new CreatedAt.fromJson(json['user_current_datetime'])
        : null;
    isDelivered = json['is_delivered'];
    createdAt = json['created_at'] != null
        ? new CreatedAt.fromJson(json['created_at'])
        : null;
    updatedAt = json['updated_at'] != null
        ? new CreatedAt.fromJson(json['updated_at'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.iId != null) {
      data['_id'] = this.iId!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.runTime != null) {
      data['run_time'] = this.runTime!.toJson();
    }
    data['message'] = this.message;
    if (this.userCurrentDatetime != null) {
      data['user_current_datetime'] = this.userCurrentDatetime!.toJson();
    }
    data['is_delivered'] = this.isDelivered;
    if (this.createdAt != null) {
      data['created_at'] = this.createdAt!.toJson();
    }
    if (this.updatedAt != null) {
      data['updated_at'] = this.updatedAt!.toJson();
    }
    return data;
  }
}