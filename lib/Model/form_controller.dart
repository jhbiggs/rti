import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../Model/student_form.dart';

/* FormController is a class which saves StudentForm in Google Sheets using
an HTTP GET request on Google App Script Web URL, then parses the response and sends
the result */
class FormController {
  // Google App Script Web URL
  static const String rawUri =
      "https://script.google.com/macros/s/AKfycbwk50odIPxlP1qtlqkiRydfw-zUwoI9bI0PI9B_UUQlRpi3Ld7QJ_nteJ6-WCksQ4s/exec";
  static Uri uRL = Uri.parse(rawUri);

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
      await http
          .post(uRL, body: convert.jsonEncode(feedbackForm.toJson()))
          .then((response) async {
        if (response.statusCode == 302) {
          var url = Uri.parse(response.headers['location']!);
          await http.get(url).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print('your error is ${e.toString()}');
    }
  }
}
