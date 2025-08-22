class CreateNoteTextResponse {
  bool? success;
  String? title;
  String? text;

  CreateNoteTextResponse({this.success, this.title, this.text});

  CreateNoteTextResponse.fromJson(json) {
    success = json['success'];
    title = json['title'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['title'] = this.title;
    data['text'] = this.text;
    return data;
  }
}