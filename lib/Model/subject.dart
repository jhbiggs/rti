enum Subject {
  art,
  business,
  creditRecovery,
  english,
  fACS,
  industrialTech,
  math,
  music,
  pE,
  science,
  specialEd,
  socialStudies
}

extension SubjectExtension on Subject {
  String get name {
    switch (this) {
      case Subject.art:
        return "Art";
      case Subject.business:
        return "Business";
      case Subject.creditRecovery:
        return "Credit Recovery";
      case Subject.english:
        return "English";
      case Subject.fACS:
        return "FACS";
      case Subject.industrialTech:
        return "Industrial Tech";
      case Subject.math:
        return "Math";
      case Subject.music:
        return "Music";
      case Subject.pE:
        return "P.E.";
      case Subject.science:
        return "Science";
      case Subject.socialStudies:
        return "Social Studies";
      case Subject.specialEd:
        return "Special Education";
    }
  }
}
