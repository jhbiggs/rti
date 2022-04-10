/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'package:com.mindframe.rti/Parent/parent.dart';
import 'package:com.mindframe.rti/Student/student.dart';

import 'package:com.mindframe.rti/Model/constants.dart';

class Children {
  static List<Student> of({Parent? parent}) {
    //return list of parent's students
    //go through the list of students and spit out the children of a given parent
//list of students whose codes match the codes in the parent's codelist
    List<Student> parennt2 = [];
    for (var parentCode in parent!.codeList) {
      parennt2.addAll(Constants.studentTestList
          .where((element) => element.getCode() == parentCode));
    }

    return parennt2;
  }
}
