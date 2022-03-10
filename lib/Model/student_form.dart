// student form is a data class to store data fields from a google sheet

class StudentForm {
  String name;
  String subject;
  String assignment;
  String? teacher;
  String standard;

  StudentForm(this.name, this.subject, this.standard, this.assignment);

  factory StudentForm.fromJson(dynamic json) {
    return StudentForm('${json['name']}', '${json['subject']}',
        '${json['standard']}', '${json['assignment']}');
  }

  // method to make get parameters
  Map toJson() => {
        'name': name,
        'subject': subject,
        'standard': standard,
        'assignment': assignment,
      };
}
