class TranscribeResponse {
  String? createdAt;
  String? documentId;
  String? filename;
  bool? success;
  String? transcription;

  TranscribeResponse(
      {this.createdAt,
        this.documentId,
        this.filename,
        this.success,
        this.transcription});

  TranscribeResponse.fromJson(json) {
    createdAt = json['created_at'];
    documentId = json['document_id'];
    filename = json['filename'];
    success = json['success'];
    transcription = json['transcription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['created_at'] = this.createdAt;
    data['document_id'] = this.documentId;
    data['filename'] = this.filename;
    data['success'] = this.success;
    data['transcription'] = this.transcription;
    return data;
  }
}