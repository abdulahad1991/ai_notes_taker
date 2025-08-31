class CreateNoteResponse {
  bool? success;
  CreateNoteData? data;

  CreateNoteResponse({this.success, this.data});

  CreateNoteResponse.fromJson(json) {
    success = json['success'];
    data = json['data'] != null ? new CreateNoteData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CreateNoteData {
  String? id;
  String? title;
  String? text;

  CreateNoteData({this.id, this.title, this.text});

  CreateNoteData.fromJson(json) {
    id = json['id'];
    title = json['title'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['text'] = this.text;
    return data;
  }
}