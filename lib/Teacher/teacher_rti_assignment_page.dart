import 'dart:async';
import 'package:date_field/date_field.dart';
import 'package:field_suggestion/field_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';
import 'package:rti/Model/Authentication/application_state.dart';
import 'package:rti/Model/Authentication/authentication.dart';
import 'package:rti/rti_assigner_button.dart';
import 'package:rti/rti_assignment.dart';
import 'package:rti/Student/student.dart';
import '../Model/constants.dart';

class TeacherRTIAssignmentPage extends StatefulWidget {
  const TeacherRTIAssignmentPage({Key? key}) : super(key: key);
  @override
  _TeacherRTIAssignmentPageState createState() =>
      _TeacherRTIAssignmentPageState();
}

class _TeacherRTIAssignmentPageState extends State<TeacherRTIAssignmentPage> {
  final _formKey =
      GlobalKey<FormState>(debugLabel: '_TeacherRTIAssignmentPageState');
  final nameTextController = TextEditingController();
  final standardsTextController = TextEditingController();
  final _subjectTextController = TextEditingController();
  DateTime _startDate = DateTime.now();
  late DateTime _endDate = _startDate.add(const Duration(days: 14));

  final nameBoxController = BoxController();
  final standardsBoxController = BoxController();
  final _subjectBoxController = BoxController();
  late Student _selectedStudent;

  ButtonState stateTextWithIcon = ButtonState.idle;

  List<Student> studentSuggestions = Constants.studentTestList;
  List<String> standardSuggestions = [
    "dividing polynomials",
    "comparing epochs",
    "analyzing motivation"
  ];
  final List<String> _subjectSuggestions =
      (Constants.subjects.map((e) => e.name).toList());
  RTIAssignment? assignment;

  Widget buildTextWithIcon() {
    return ProgressButton.icon(iconedButtons: {
      ButtonState.idle: IconedButton(
          text: "Assign",
          icon: const Icon(Icons.send, color: Colors.white),
          color: Colors.red.shade900),
      ButtonState.loading:
          IconedButton(text: "Loading", color: Colors.red.shade900),
      ButtonState.fail: IconedButton(
          text: "Failed",
          icon: const Icon(Icons.cancel, color: Colors.white),
          color: Colors.red.shade300),
      ButtonState.success: IconedButton(
          text: "Assigned",
          icon: const Icon(
            Icons.check_circle,
            color: Colors.white,
          ),
          color: Colors.green.shade400)
    }, onPressed: onPressedIconWithText, state: stateTextWithIcon);
  }

  _assign() async {
    if (_formKey.currentState!.validate()) {
      var standard = standardsTextController.text;
      //there must be a student in the selected student field, so unwrap the optional value.
      var student = _selectedStudent;
      var subject = _subjectTextController.text;
      var newAssignment = RTIAssignment(
          standard: standard,
          student: student,
          subject: subject,
          startDate: _startDate,
          endDate: _endDate);
      assignment = newAssignment;
      Constants.assignments.add(newAssignment);

      print('Student: ${student.getName()}');
    }
  }

  void onPressedIconWithText() async {
    switch (stateTextWithIcon) {
      case ButtonState.idle:
        stateTextWithIcon = ButtonState.loading;

        //assigning happens here.....
        await _assign();
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            stateTextWithIcon = ButtonState.success;
          });
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            stateTextWithIcon = ButtonState.idle;
          });
        });
        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        stateTextWithIcon = ButtonState.idle;
        break;
      case ButtonState.fail:
        stateTextWithIcon = ButtonState.idle;
        break;
    }
    setState(() {
      stateTextWithIcon = stateTextWithIcon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nameBoxController.close!();
        standardsBoxController.close!();
        _subjectBoxController.close!();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Teacher RTI Assignment")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                    // child: Text("start typing your student's name."),
                  ),

                  // Usage with custom class suggestions.
                  FieldSuggestion(
                    wSlideAnimation: true,
                    fieldDecoration: const InputDecoration(
                      hintText: 'Name', // optional
                    ),
                    // If you're using list which includes a class,
                    // Don't forget to add a search by property.
                    // Or use [customSearch] property to implement custom searching functionality.
                    //
                    // customSearch: (item, input) {
                    //   return item.getName().toString().contains(input);
                    // },

                    // The field suggestion needs toJson mehtod inside your model right?
                    searchBy: const ['name'],
                    // If you're using default suggestion item widgets
                    // then title will be searchBy property's first value.
                    boxController: nameBoxController,
                    textController: nameTextController,
                    suggestionList: studentSuggestions,
                    itemStyle: const SuggestionItemStyle(
                      backgroundColor: Color(0xff000000),
                      leading: Icon(Icons.person),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                          color: Color(0x99d599D5),
                        ),
                      ],
                    ),
                    onItemSelected: (value) {
                      _selectedStudent = Constants.studentTestList.firstWhere(
                          (element) => element.getCode() == value['id']);
                      // The field suggestion needs toJson mehtod inside your model right?
                      // So that's mean it converts your model to json.
                      // Then the output has to be JSON (Map). So now we can get our value's email.
                      print(value['name']);
                    },
                  ),
                  FieldSuggestion(
                    wSlideAnimation: true,
                    fieldDecoration: const InputDecoration(
                      hintText: 'Standard', // optional
                    ),
                    // If you're using list which includes a class,
                    // Don't forget to add a search by property.
                    // Or use [customSearch] property to implement custom searching functionality.
                    //
                    // customSearch: (item, input) {
                    //   return item.getName().toString().contains(input);
                    // },

                    // The field suggestion needs toJson mehtod inside your model right?
                    searchBy: const ['standard'],
                    // If you're using default suggestion item widgets
                    // then title will be searchBy property's first value.
                    boxController: standardsBoxController,
                    textController: standardsTextController,
                    suggestionList: standardSuggestions,
                    itemStyle: const SuggestionItemStyle(
                      backgroundColor: Color(0xff000000),
                      leading: Icon(Icons.work),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                          color: Color(0xffD5D5D5),
                        ),
                      ],
                    ),
                    onItemSelected: (value) {
                      // The field suggestion needs toJson mehtod inside your model right?
                      // So that's mean it converts your model to json.
                      // Then the output has to be JSON (Map). So now we can get our value's email.
                      print(value);
                    },
                  ),
                  FieldSuggestion(
                    wSlideAnimation: true,
                    fieldDecoration: const InputDecoration(
                      hintText: 'Subject', // optional
                    ),
                    // If you're using list which includes a class,
                    // Don't forget to add a search by property.
                    // Or use [customSearch] property to implement custom searching functionality.
                    //
                    // customSearch: (item, input) {
                    //   return item.getName().toString().contains(input);
                    // },

                    // The field suggestion needs toJson mehtod inside your model right?
                    searchBy: const ['subject'],
                    // If you're using default suggestion item widgets
                    // then title will be searchBy property's first value.
                    boxController: _subjectBoxController,
                    textController: _subjectTextController,
                    suggestionList: _subjectSuggestions,
                    itemStyle: const SuggestionItemStyle(
                      backgroundColor: Color(0xff000000),
                      leading: Icon(Icons.work),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                          color: Color(0xffD5D5D5),
                        ),
                      ],
                    ),
                    onItemSelected: (value) {
                      // The field suggestion needs toJson mehtod inside your model right?
                      // So that's mean it converts your model to json.
                      // Then the output has to be JSON (Map). So now we can get our value's email.
                      print(value);
                    },
                  ),
                  const SizedBox(height: 50),
                  DateTimeFormField(
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.black45),
                      errorStyle: TextStyle(color: Colors.redAccent),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                      labelText: 'Start date',
                    ),
                    mode: DateTimeFieldPickerMode.date,
                    autovalidateMode: AutovalidateMode.always,
                    validator: (e) =>
                        (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                    onDateSelected: (DateTime value) {
                      print(value);
                      _startDate = value;
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  DateTimeFormField(
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Colors.black45),
                      errorStyle: TextStyle(color: Colors.redAccent),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                      labelText: 'End Date',
                    ),
                    mode: DateTimeFieldPickerMode.date,
                    autovalidateMode: AutovalidateMode.always,
                    validator: (e) =>
                        (e?.day ?? 0) == 1 ? 'Please not the first day' : null,
                    onDateSelected: (DateTime value) {
                      print(value);
                      _endDate = value;
                    },
                  ),
                  const SizedBox(
                    height: 50,
                    // child: Text("start typing your student's name."),
                  ),

                  SizedBox(
                    height: 50,
                    child: buildTextWithIcon(),
                  ),
                  Consumer<ApplicationState>(
                    builder: (context, appState, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (appState.loginState ==
                            ApplicationLoginState.loggedIn) ...[
                          // RtIAssignmentList(
                          //   addAssignment: (assignment) =>
                          //       appState.addAssignmentToList(assignment),
                          //   assignments: appState.guestBookMessages,
                          // ),
                          // RTIAssignerButton(
                          //   addMessage: (assignment) =>
                          //       appState.addAssignmentToList(assignment),
                          //   assignment: assignment,
                          // ),
                          // buildTextWithIcon()
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
