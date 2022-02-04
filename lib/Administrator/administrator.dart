import 'package:uuid/uuid.dart';

class Administrator {
  late String name;
  late Uuid id;
  Administrator(this.name) {
    id = const Uuid();
  }
}
