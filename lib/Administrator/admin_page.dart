/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
// import 'dart:convert';

// import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
// import 'package:flutter/services.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Row(
            children:  [
               const Spacer(),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Column(
                   children:  [
                     const Spacer(),
                     IconButton(
                        icon: const Icon(Icons.settings), 
                        onPressed: () async { await Navigator.of(context).pushNamed('/settings'); },
                        ),
                     const Spacer(),
                   ],
                 ),
               ),
            ],
          ),
          title: const Text('Administrator/Office'),
        ),
        backgroundColor: Colors.grey[200],
        body: const Center(
          child: SizedBox(
            width: 400,
            child: Card(
              child: AdminForm(),
            ),
          ),
        ));
  }
}

class AdminForm extends StatefulWidget {
  const AdminForm({Key? key}) : super(key: key);

  @override
  _AdminFormState createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // String? _fileName;
  // String? _saveAsFileName;
  // List<PlatformFile>? _paths;
  // String? _directoryPath;
  // String? _extension;
  // bool _isLoading = false;
  // bool _userAborted = false;
  // bool _multiPick = false;
  // FileType _pickingType = FileType.any;
  // TextEditingController _controller = TextEditingController();
  // final _assignmentsSheetController = TextEditingController();

  final List<List<String>> _adminCards = [
    ['Subjects', '/groups'],
    ['Teachers', '/teachers'],
    // ['Subjects', '/subjects'],
    ['All Students\' Assignments', '/students'],
    // ['RTI Assignments', '/rti_assignments'],
    // ['Choose your source...', '/file_picker'],
    // ['Easy File Picker', '/easy_file_picker']
  ];

  @override
  void initState() {
    super.initState();
    // _controller.addListener(() => _extension = _controller.text);
  }

  void _goToPage(String page) {
    Navigator.of(context).pushNamed(page);
  }

  // void _resetState() {
  //   if (!mounted) {
  //     return;
  //   }
  //   setState(() {
  //     _isLoading = true;
  //     _directoryPath = null;
  //     _fileName = null;
  //     _paths = null;
  //     _saveAsFileName = null;
  //     _userAborted = false;
  //   });
  // }

  // void _pickFiles() async {
  //   _resetState();
  //   try {
  //     _directoryPath = null;
  //     _paths = (await FilePicker.platform.pickFiles(
  //       type: _pickingType,
  //       allowMultiple: _multiPick,
  //       onFileLoading: (FilePickerStatus status) => print(status),
  //       allowedExtensions: (_extension?.isNotEmpty ?? false)
  //           ? _extension?.replaceAll(' ', '').split(',')
  //           : null,
  //     ))
  //         ?.files;
  //     print(_paths!.first.toString());
  //     PlatformFile myFile = _paths!.first;
  //     print(utf8.decode(myFile.bytes!));
  //   } on PlatformException catch (e) {
  //     _logException('Unsupported operation' + e.toString());
  //   } catch (e) {
  //     _logException(e.toString());
  //   }
  //   if (!mounted) return;
  //   setState(() {
  //     _isLoading = false;
  //     _fileName = _paths != null
  //         ? _paths!.map((e) => e.name).toString()
  //         : 'File will go here...';
  //     _userAborted = _paths == null;
  //   });
  // }

  // void _logException(String message) {
  //   print(message);
  //   _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  //   _scaffoldMessengerKey.currentState?.showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _adminCards.length,
      itemBuilder: (context, index) {
        return Card(
            elevation: 5,
            child: ListTile(
              title: Text(_adminCards.elementAt(index).elementAt(0)),
              onTap: () {
                _goToPage(_adminCards.elementAt(index).elementAt(1));
              },
            ));
      },
      //
    );
  }
}
