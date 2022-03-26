/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'package:rti/Student/student.dart';
import 'package:xid/xid.dart';

class Parent extends Comparable {
  late Xid _id;
  late String name;
  late List<Student> children;
  List<String> codeList = [];

  Parent({required String name}) {
    _id = Xid();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Parent && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  @override
  int compareTo(other) {
    return _id.hashCode.compareTo(other.hashCode);
  }
}
