class SignupFormResponse {
  bool? success;
  List<SignupFormData>? data;

  SignupFormResponse({this.success, this.data});

  SignupFormResponse.fromJson(json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <SignupFormData>[];
      json['data'].forEach((v) {
        data!.add(new SignupFormData.fromJson(v));
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

class SignupFormData {
  String? sId;
  String? type;
  Region? region;
  bool? isActive;
  bool? isDeleted;

  SignupFormData({this.sId, this.type, this.region, this.isActive, this.isDeleted});

  SignupFormData.fromJson(json) {
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
  EN? eN;
  EN? dE;

  Region({this.eN, this.dE});

  Region.fromJson(Map<String, dynamic> json) {
    eN = json['EN'] != null ? new EN.fromJson(json['EN']) : null;
    dE = json['DE'] != null ? new EN.fromJson(json['DE']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.eN != null) {
      data['EN'] = this.eN!.toJson();
    }
    if (this.dE != null) {
      data['DE'] = this.dE!.toJson();
    }
    return data;
  }
}

class EN {
  String? title;
  List<Question>? question;

  EN({this.title, this.question});

  EN.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['question'] != null) {
      question = <Question>[];
      json['question'].forEach((v) {
        question!.add(new Question.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    if (this.question != null) {
      data['question'] = this.question!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Question {
  String? id;
  String? text;
  Answer? answer;

  Question({this.id, this.text, this.answer});

  Question.fromJson(json) {
    id = json['id'];
    text = json['text'];
    answer =
    json['answer'] != null ? new Answer.fromJson(json['answer']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    if (this.answer != null) {
      data['answer'] = this.answer!.toJson();
    }
    return data;
  }
}

class Answer {
  String? type;
  List<String>? options;

  Answer({this.type, this.options});

  Answer.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['options'] = this.options;
    return data;
  }
}