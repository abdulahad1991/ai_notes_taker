class NotesResponse {
  List<Data>? data;

  NotesResponse({this.data});

  NotesResponse.fromJson(json) {
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
  String? sId;
  String? user;
  String? filename;
  String? title;
  String? text;
  int? fileSize;
  int? isVoice;
  int? is_pin;
  bool? isActive;
  bool? isComplete;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.sId,
        this.user,
        this.filename,
        this.title,
        this.text,
        this.fileSize,
        this.isVoice,
        this.is_pin,
        this.isActive,
        this.isComplete,
        this.isDeleted,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(json) {
    sId = json['_id'];
    user = json['user'];
    filename = json['filename'];
    title = json['title'];
    text = json['text'];
    fileSize = json['file_size'];
    isVoice = json['is_voice'];
    is_pin = json['is_pin'];
    isActive = json['is_active'];
    isComplete = json['is_complete'];
    isDeleted = json['is_deleted'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['filename'] = this.filename;
    data['title'] = this.title;
    data['text'] = this.text;
    data['file_size'] = this.fileSize;
    data['is_voice'] = this.isVoice;
    data['is_active'] = this.isActive;
    data['is_complete'] = this.isComplete;
    data['is_deleted'] = this.isDeleted;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
