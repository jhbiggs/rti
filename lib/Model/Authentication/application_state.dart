import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rti/Firebase/firebase_options.dart';
import 'package:rti/Model/role.dart';
import 'package:rti/Model/subject.dart';
import 'package:rti/RTIAssignment/rti_assignment.dart';
import 'package:rti/Student/student.dart';
import '../constants.dart';
import 'authentication.dart';
import 'package:collection/collection.dart';

class ApplicationState extends ChangeNotifier {
  var isTeacher = false;

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

  void _getMessages(Future<IdTokenResult> tokenResult) async {
    String teacherSubject = "";
    await tokenResult.then((result) => {
          if (result.claims != null)
            {
              isTeacher = result.claims!['teacher'] ?? false,
              teacherSubject = result.claims!['subject'] ?? 'no subject'
            }
        });
    if (isTeacher) {
      _guestBookSubscription = FirebaseFirestore.instance
          .collection('assignments')
          .where('subject', isEqualTo: teacherSubject)
          .orderBy('start_date', descending: true)
          // .limit(30)
          .snapshots()
          .listen((snapshot) {
        _guestBookMessages = [];
        for (final document in snapshot.docs) {
          _guestBookMessages.add(RTIAssignment(
            // endDate: (document.data()['end_date'] as DateTime),
            standard: document.data()['standard'] as String,
            startDate: DateTime.now(), // (document.data()['start_date']),
            student: Student(name: document.data()['student_name']),
            subject: document.data()['subject'] as String,
            teacher: document.data()['name'] as String,
          ));
        }
      });
    } else {
      _guestBookSubscription = FirebaseFirestore.instance
          .collection('assignments')
          .orderBy('start_date', descending: true)
          // .limit(30)
          .snapshots()
          .listen((snapshot) {
        _guestBookMessages = [];
        for (final document in snapshot.docs) {
          _guestBookMessages.add(RTIAssignment(
            // endDate: (document.data()['end_date'] as DateTime),
            standard: document.data()['standard'] as String,
            startDate: DateTime.now(), // (document.data()['start_date']),
            student: Student(name: document.data()['student_name']),
            subject: document.data()['subject'] as String,
            teacher: document.data()['name'] as String,
          ));
        }
      });
    }
  }

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
                  teacherSubject = result.claims!['subject'] ?? 'no subject'
                }
            });
        _loginState = ApplicationLoginState.loggedIn;
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
                    student: Student(name: document.data()['student_name']),
                    subject: document.data()['subject'],
                    startDate: DateTime.now()),
              );
            }

            // _getMessages(resultForClaims);
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

  void signInWithEmailAndPassword(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
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
      }
      if (result.claims != null &&
          result.claims!['admin'] != null &&
          result.claims!['admin'] == true) {
        UserData.role = Role.administrator;
      }
      FirebaseFunctions functions = FirebaseFunctions.instance;

      HttpsCallable groupSetupFirestoreFunction =
          functions.httpsCallable('setUpGroups');
      await groupSetupFirestoreFunction();
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _loginState = ApplicationLoginState.emailAddress;
    UserData.role = Role.none;
    notifyListeners();
  }

  void registerAccount(
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
