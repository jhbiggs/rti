/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'dart:async';

import 'package:field_suggestion/field_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:com.mindframe.rti/RTIAssignment/rti_assignment.dart';
import 'package:com.mindframe.rti/widgets.dart';

import '../Administrator/student_assignment_screen.dart';
import '../Model/form_controller.dart';
import '../Model/student_form.dart';
import '../Student/student.dart';
import '../Model/constants.dart';

class RtIAssignmentMessage {
  RtIAssignmentMessage({required this.teacherName, required this.objective});
  final String teacherName;
  final String objective;
  // final String subject;
  // final String standard;
}

class RtIAssignmentList extends StatefulWidget {
  const RtIAssignmentList(
      {Key? key, required this.addAssignment, required this.assignments})
      : super(key: key);
  final FutureOr<void> Function(RTIAssignment assignment) addAssignment;
  final List<RTIAssignment> assignments;

  @override
  _RtIAssignmentListState createState() => _RtIAssignmentListState();
}

class _RtIAssignmentListState extends State<RtIAssignmentList> {
  final _subjectTextController = TextEditingController();
  final _standardTextController = TextEditingController();
  final _nameBoxController = BoxController();
  final _nameTextController = TextEditingController();
  final _assignmentTextController = TextEditingController();
  final _studentSuggestions = Constants.studentTestList;
  final _subjectBoxController = BoxController();
  final _subjectSuggestions = Constants.subjects;
  late Student _selectedStudent;

  void _pushStudentAssignmentPage(RTIAssignment assignment) {
    /* The student assignment page shows the assignment from the Google
    Sheet.  Currently the column heading on the Google sheet is "missing 
    assignment" and the field contains a description or a link to another 
    Google Doc assignment. The relevant information is contained within
    the RTIAssignment object. */

    Navigator.pushNamed(context, StudentAssignmentScreen.routeName,
        arguments: assignment);
  }

  void _submitForm() {
    // Validate returns true if the form is valid, or false
    // otherwise.
    // if (_formKey.currentState!.validate()) {
    // If the form is valid, proceed.
    StudentForm feedbackForm = StudentForm(
        _nameTextController.text,
        _subjectTextController.text,
        _standardTextController.text,
        _assignmentTextController.text);

    FormController formController = FormController();

    _showSnackbar("Submitting Assignment");

    // Submit 'feedbackForm' and save it in Google Sheets.
    formController.submitForm(feedbackForm, (String response) {
      print("Response: $response");
      if (response == FormController.STATUS_SUCCESS) {
        // Feedback is saved succesfully in Google Sheets.
        _showSnackbar("Assignment Submitted");
      } else {
        // Error Occurred while saving data in Google Sheets.
        _showSnackbar("Error Occurred!");
      }
    });
    // }
  }

  // Method to show snackbar with 'message'.
  _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
          child: Header("Assign a student?"),
        ),
        Row(
          children: [
            Expanded(
              child: StyledButton(
                  child: Row(children: [
                    Expanded(
                      child: FieldSuggestion(
                        wSlideAnimation: true,
                        fieldDecoration: const InputDecoration(
                          hintText: 'Subject', // optional
                        ),
                        boxController: _subjectBoxController,
                        textController: _subjectTextController,
                        suggestionList: _subjectSuggestions,
                        itemStyle: const SuggestionItemStyle(
                          backgroundColor: Color(0xff000000),
                          // leading: Icon(Icons.person),
                          // borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1,
                              spreadRadius: 1,
                              offset: Offset(0, 2),
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                        onItemSelected: (value) {
                          print(value);
                        },
                      ),
                    ),
                  ]),
                  onPressed: () {}),
            ),
          ],
        ),
        StyledButton(
            onPressed: () {},
            child: TextFormField(
              controller: _standardTextController,
              decoration: const InputDecoration(
                hintText: 'Standard',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'enter your message and continue';
                }
                return null;
              },
            )),
        StyledButton(
          onPressed: () {},
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: _assignmentTextController,
                decoration: const InputDecoration(
                  hintText: 'Assignment',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter your message and continue';
                  }
                  return null;
                },
              )),
            ],
          ),
        ),
        StyledButton(
            child: Row(children: [
              Expanded(
                child: FieldSuggestion(
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
                  boxController: _nameBoxController,
                  textController: _nameTextController,
                  suggestionList: _studentSuggestions,
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
                    // print(value['name']);
                  },
                ),
              ),
              const Icon(Icons.send),
              const SizedBox(width: 8),
              const Text('SEND')
            ]),
            onPressed: () async {
              _submitForm();
              // await widget.addAssignment(RTIAssignment(
              //     /*TODO: get the teacher name from the userInfo and add it to the assignment
              //   Must have a model on the server checking the number of students already
              //   in the class.*/
              //     student: _selectedStudent,
              //     subject: _subjectTextController.text,
              //     standard: _standardTextController.text,
              //     assignmentName: _assignmentTextController.text,
              //     startDate: DateTime.now()));
              _subjectTextController.clear();
              _nameTextController.clear();
              _standardTextController.clear();
              _assignmentTextController.clear();
            }),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Header("Your List"),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.assignments.length,
          itemBuilder: (context, index) =>
              // Card(
              //       elevation: 5,
              //       child:
              ListTile(
            isThreeLine: true,
            title: Text(
                '${widget.assignments.elementAt(index).student.getName()} needs help in '
                ' ${widget.assignments.elementAt(index).subject} with '
                '${widget.assignments.elementAt(index).standard}'),
            subtitle: Text(
                'The assignment is: ${widget.assignments.elementAt(index).assignmentName} and will continue from ${DateFormat.MMMMEEEEd().format(widget.assignments.elementAt(index).startDate)} '
                'until ${DateFormat.MMMMEEEEd().format(widget.assignments.elementAt(index).endDate!)}'),
            onTap: () {
              _pushStudentAssignmentPage(widget.assignments.elementAt(index));
            },
          ),
          // )
        ),
      ],
    );
  }
}
