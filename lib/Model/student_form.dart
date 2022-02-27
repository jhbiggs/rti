// student form is a data class to store data fields from a google sheet

class StudentForm {
  String name;
  String subject;
  String id;
  String teacher;
  String standard;

  StudentForm(this.name, this.subject, this.id, this.teacher, this.standard);

  factory StudentForm.fromJson(dynamic json) {
    return StudentForm('${json['name']}', '${json['subject']}', '${json['id']}',
        '${json['teacher']}', '${json['standard']}');
  }

  // method to make get parameters
  Map toJson() => {
        'name': name,
        'subject': subject,
        'id': id,
      };
}
