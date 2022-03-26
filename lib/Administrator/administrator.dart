/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'package:uuid/uuid.dart';

class Administrator {
  late String name;
  late Uuid id;
  Administrator(this.name) {
    id = const Uuid();
  }
}
