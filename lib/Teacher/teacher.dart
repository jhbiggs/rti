/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'package:rti/Model/subject.dart';
import 'package:uuid/uuid.dart';

class Teacher {
  late String name;
  late Subject subject;
  late Uuid id;
  Teacher(this.name, this.subject) {
    id = const Uuid();
  }
}
