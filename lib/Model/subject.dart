/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
enum Subject {
  // art,
  // business,
  // creditRecovery,
  english,
  // fACS,
  // industrialTech,
  math,
  // music,
  // pE,
  // science,
  // specialEd,
  // socialStudies,
  none
}

extension SubjectExtension on Subject {
  Map<String, dynamic> toJson() => {'name': name};

  static List<String> get names {
    var tempArray = <String>[];
    for (Subject subject in Subject.values) {
      tempArray.add(subject.name);
    }
    return tempArray;
  }

  String get name {
    switch (this) {
      // case Subject.art:
      //   return "Art";
      // case Subject.business:
      //   return "Business";
      // case Subject.creditRecovery:
      //   return "Credit Recovery";
      case Subject.english:
        return "English";
      // case Subject.fACS:
      //   return "FACS";
      // case Subject.industrialTech:
      //   return "Industrial Tech";
      case Subject.math:
        return "Math";
      // case Subject.music:
      //   return "Music";
      // case Subject.pE:
      //   return "P.E.";
      // case Subject.science:
      //   return "Science";
      // case Subject.socialStudies:
      //   return "Social Studies";
      // case Subject.specialEd:
      //   return "Special Education";
      case Subject.none:
        return "Another subject";
      default:
        return "No Subject Assigned";
    }
  }
}
