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
