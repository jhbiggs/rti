/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:com.mindframe.rti/RTIAssignment/rti_assignment.dart';
import 'package:com.mindframe.rti/widgets.dart';

class RTIAssignerButton extends StatefulWidget {
  RTIAssignerButton({Key? key, required this.addMessage, this.assignment})
      : super(key: key);
  final FutureOr<void> Function(RTIAssignment message) addMessage;
  RTIAssignment? assignment;
  @override
  _RTIAssignerButtonState createState() => _RTIAssignerButtonState();
}

class _RTIAssignerButtonState extends State<RTIAssignerButton> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RTIAssignerButton');
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            const SizedBox(width: 8),
            StyledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    widget.assignment != null) {
                  await widget.addMessage(widget.assignment!);
                  _controller.clear();
                }
              },
              child: Row(
                children: const [
                  Icon(Icons.send),
                  SizedBox(width: 4),
                  Text('SEND'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
