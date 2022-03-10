import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../Model/student_form.dart';

/* FormController is a class which saves StudentForm in Google Sheets using
an HTTP GET request on Google App Script Web URL, then parses the response and sends
the result */
class FormController {
  // Google App Script Web URL
  static Uri uRL = Uri.parse(
      "https://script.google.com/macros/s/AKfycbxlJzEbfI-XnZKRH1FNW7g8IS_y10sS3Eey-H34VydMG7Tty_0Fobcvk_SJ5267GEk/exec");

  // Success status message
  static const STATUS_SUCCESS = "SUCCESS";

  /* Async function loads student from endpoint URL and returns List. */
  Future<List<StudentForm>> getStudentList() async {
    return await http.get(uRL).then((response) {
      var jsonStudent = [];
      try {
        // print(response.body);
        jsonStudent = convert.jsonDecode(response.body) as List;
        print(jsonStudent);
      } catch (e) {
        print("ERROR!! $e");
      }
      return jsonStudent.map((json) => StudentForm.fromJson(json)).toList();
    });
  }

  void submitForm(
      StudentForm feedbackForm, void Function(String) callback) async {
    try {
      await http.post(uRL, body: feedbackForm.toJson()).then((response) async {
        if (response.statusCode == 302) {
          var url2 = response.headers['location'];
          await http.get(Uri.parse(url2!)).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print(e);
    }
  }
}
