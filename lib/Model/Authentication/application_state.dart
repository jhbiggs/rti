import 'dart:async';
import 'dart:io';
import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rti/Firebase/firebase_options.dart';
import 'package:rti/Model/form_controller.dart';
import 'package:rti/Model/role.dart';
import 'package:rti/Model/subject.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';
import 'package:rti/Student/student.dart';
import '../constants.dart';
import '../student_form.dart';
import 'authentication.dart';
import 'package:collection/collection.dart';

class ApplicationState extends ChangeNotifier {
  var isTeacher = false;
  var isAdmin = false;

  ApplicationState() {
    init();
  }
  Future<DocumentReference> addAssignmentToList(RTIAssignment assignment) {
    if (_loginState != ApplicationLoginState.loggedIn) {
      throw Exception('Must be logged in');
    }
    return FirebaseFirestore.instance
        .collection('assignments')
        .add(<String, dynamic>{
      'teacher': assignment.teacher,
      'standard': assignment.standard,
      'subject': assignment.subject,
      'student_name': assignment.student.getName(),
      'start_date': DateTime.now().millisecondsSinceEpoch,
      'end_date': assignment.endDate!.millisecondsSinceEpoch,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid
    });
  }

  void _connectToFirebaseEmulator() {
    FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
    FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
    FirebaseFunctions.instance.useFunctionsEmulator("localhost", 5001);
  }

// here is where the Google sheets transfer happens
  List<StudentForm> _students = [];
  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _connectToFirebaseEmulator();
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        var resultForClaims = user.getIdTokenResult();
        String teacherSubject = "";
        await resultForClaims.then((result) => {
              if (result.claims != null)
                {
                  isTeacher = result.claims!['teacher'] ?? false,
                  teacherSubject = result.claims!['subject'] ?? 'no subject',
                  isAdmin = result.claims!['admin'] ?? false,
                }
            });
        _loginState = ApplicationLoginState.loggedIn;
        FormController().getStudentList().then((students) => {
              _students = students,
              for (StudentForm student in _students)
                {
                  print(student.name),

                  FirebaseFirestore.instance
                      .collection('assignments')
                      .add(<String, dynamic>{
                    'teacher': student.teacher,
                    'standard': student.standard,
                    'subject': student.subject,
                    'student_name': student.name,
                    'start_date': DateTime.now().millisecondsSinceEpoch,
                    'end_date': DateTime.now().add(const Duration(days: 14)),
                    'timestamp': DateTime.now().millisecondsSinceEpoch,
                    'name': FirebaseAuth.instance.currentUser!.displayName,
                    'userId': FirebaseAuth.instance.currentUser!.uid
                  })
                  //TODO: load the Google Sheets rows into the Firebase table
                }
            });

        if (isTeacher) {
          _guestBookSubscription = FirebaseFirestore.instance
              .collection('assignments')
              .where('subject', isEqualTo: teacherSubject)
              .orderBy('timestamp', descending: true)
              .snapshots()
              .listen((snapshot) {
            _guestBookMessages = [];
            for (final document in snapshot.docs) {
              _guestBookMessages.add(
                RTIAssignment(
                    standard: document.data()['standard'],
                    student: Student(
                        name: document.data()['student_name'],
                        accessCode: ''), //TODO:implement getting access code
                    subject: document.data()['subject'],
                    teacher: document.data()['teacher'],
                    startDate: DateTime.now()),
              );
            }
            notifyListeners();
          });
        }
        if (isAdmin) {
          //get the list of all assignments
          _guestBookSubscription = FirebaseFirestore.instance
              .collection('assignments')
              .orderBy('timestamp', descending: true)
              .snapshots()
              .listen((snapshot) {
            _guestBookMessages = [];
            for (final document in snapshot.docs) {
              _guestBookMessages.add(
                RTIAssignment(
                    standard: document.data()['standard'],
                    student: Student(
                        name: document.data()['student_name'],
                        accessCode: ''), //TODO:implement getting access code
                    subject: document.data()['subject'],
                    teacher: document.data()['teacher'],
                    startDate: DateTime.now()),
              );
            }
            notifyListeners();
          });
        }
      } else {
        _loginState = ApplicationLoginState.loggedOut;
        // Add from here
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        // to here.
      }
      notifyListeners();
    });
  }

  ApplicationLoginState _loginState = ApplicationLoginState.loggedOut;
  ApplicationLoginState get loginState => _loginState;

  String? _email;
  String? get email => _email;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<RTIAssignment> _guestBookMessages = [];
  List<RTIAssignment> get guestBookMessages => _guestBookMessages;

  void startLoginFlow() {
    _loginState = ApplicationLoginState.emailAddress;
    notifyListeners();
  }

  void verifyEmail(
    String email,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      var methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        _loginState = ApplicationLoginState.password;
      } else {
        _loginState = ApplicationLoginState.register;
      }
      _email = email;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

//duplicate method, need a way to consolidate into the main method's
//identical version
  void _pushRelevantPage(BuildContext context) async {
    print("going into application state userdata switch");
    switch (UserData.role) {
      case Role.student:
        await Navigator.of(context).pushNamed('/student');
        break;
      case Role.teacher:
        await Navigator.of(context).pushNamed('/teacher');
        break;
      case Role.administrator:
        await Navigator.of(context).pushNamed('/admin');
        break;
      case Role.parent:
        await Navigator.of(context).pushNamed('/parent');
        break;
      // }
      case Role.none:
        // TODO: Handle this case.
        break;
    }
  }

  void signInWithEmailAndPassword(
      String email,
      String password,
      void Function(FirebaseAuthException e) errorCallback,
      BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final thisUser = FirebaseAuth.instance.currentUser!;
      final result = await thisUser.getIdTokenResult();

      //the && operator will fail if the claims result is null
      if (result.claims != null && result.claims!['teacher'] != null) {
        UserData.subject = Subject.values.firstWhere((element) =>
            const CaseInsensitiveEquality()
                .equals(element.name, ((result.claims!['subject'] as String))));
        UserData.role = Role.teacher;
        print(UserData.role.toString());
        _pushRelevantPage(context);
      }
      if (result.claims != null &&
          result.claims!['admin'] != null &&
          result.claims!['admin'] == true) {
        UserData.role = Role.administrator;
        _pushRelevantPage(context);
      }
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    UserData.role = Role.none;
    notifyListeners();
  }

  void registerAccountGeneral(
      String email,
      String displayName,
      Role role,
      Subject subject,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      //Firebase auth function creates user, then adds display name
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);

      //server-side function call to add admin
      //todo:make sure to check privilege!
      FirebaseFunctions functions = FirebaseFunctions.instance;
      switch (role) {
        case Role.administrator:
          UserData.role = Role.administrator;
          HttpsCallable callable = functions.httpsCallable('addAdmin');
          final results = await callable()
              .then((value) => {FirebaseAuth.instance.currentUser!.reload()});
          return;
        case Role.parent:
          UserData.role = Role.parent;
          break;
        case Role.student:
          UserData.role = Role.student;
          break;
        case Role.teacher:
          UserData.role = Role.teacher;
          HttpsCallable callable = functions.httpsCallable('addTeacher');
          final results =
              await callable(<String, dynamic>{'result': 'it worked'});
          HttpsCallable callableSetSubject =
              functions.httpsCallable('addSubject');
          callableSetSubject.call(<String, dynamic>{'subject': subject.name});
          UserData.teacher = true;
          UserData.subject = subject;
          print("YOur subject is: ${subject.name}");
          // print("did it work you might ask? ${results.data['result']}");
          break;
        case Role.none:
          // TODO: Handle this case.
          break;
      }
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    _loginState = ApplicationLoginState.loggedOut;
    // UserData.administrator = false;
    // UserData.teacher = false;
    // UserData.subject = null;
  }
}
