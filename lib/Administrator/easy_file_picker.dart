import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/io_client.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../Model/Authentication/application_state.dart';
import '../Model/Authentication/authentication.dart';
import '../google_http_client.dart';

class EasyFilePicker extends StatefulWidget {
  const EasyFilePicker({required this.title}) : super();
  final String title;
  @override
  _EasyFilePickerState createState() => _EasyFilePickerState();
}

class _EasyFilePickerState extends State<EasyFilePicker> {
  // final storage = FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.appdata']);
  late GoogleSignInAccount googleSignInAccount;
  late ga.FileList list;
  var signedIn = true;

  @override
  void initState() {
    super.initState();
    list = ga.FileList();
  }

  _uploadFileToGoogleDrive() async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    ga.File fileToUpload = ga.File();
    var file = await FilePicker.platform.pickFiles();
    fileToUpload.parents = ["appDataFolder"];
    fileToUpload.name = path.basename(file?.paths.first ?? "nothing");
    var response = await drive.files.create(
      fileToUpload,
      // uploadMedia: ga.Media(file!, file.lengthSync()),
    );
    print(response);
    _listGoogleDriveFiles();
  }

  Future<void> _listGoogleDriveFiles() async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    drive.files.list(spaces: 'appDataFolder').then((value) {
      setState(() {
        list = value;
      });
      for (var i = 0; i < list.files!.length; i++) {
        print("Id: ${list.files![i].id} File Name:${list.files![i].name}");
      }
    });
  }

  Future<void> _downloadGoogleDriveFile(String fName, String gdID) async {
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    ga.Media? file = (await drive.files
        .get(gdID, downloadOptions: ga.DownloadOptions.fullMedia)) as ga.Media?;
    print(file!.stream);

    // final directory = await getExternalStorageDirectory();
    // print(directory.path);
    // final saveFile = File(
    //     '${directory.path}/${DateTime.now().millisecondsSinceEpoch}$fName');
    // List<int> dataStore = [];
    // file.stream.listen((data) {
    //   print("DataReceived: ${data.length}");
    //   dataStore.insertAll(dataStore.length, data);
    // }, onDone: () {
    //   print("Task Done");
    //   saveFile.writeAsBytes(dataStore);
    //   print("File saved at ${saveFile.path}");
    // }, onError: (error) {
    //   print("Some Error");
    // });
  }

  List<Widget> generateFilesWidget() {
    List<Widget> listItem = [];
    if (list != null) {
      for (var i = 0; i < list.files!.length; i++) {
        listItem.add(Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.05,
              child: Text('${i + 1}'),
            ),
            Expanded(
              child: Text(list.files![i].name ?? "nothing2"),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: FlatButton(
                child: Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.indigo,
                onPressed: () {
                  _downloadGoogleDriveFile(list.files![i].name ?? "nothing3",
                      list.files![i].id ?? "nothing4");
                },
              ),
            ),
          ],
        ));
      }
    }
    return listItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (signedIn
                ? FlatButton(
                    child: Text('Upload File to Google Drive'),
                    onPressed: _uploadFileToGoogleDrive,
                    color: Colors.green,
                  )
                : Container()),
            (signedIn
                ? FlatButton(
                    child: Text('List Google Drive Files'),
                    onPressed: _listGoogleDriveFiles,
                    color: Colors.green,
                  )
                : Container()),
            (signedIn
                ? Expanded(
                    flex: 10,
                    child: Column(
                      children: generateFilesWidget(),
                    ),
                  )
                : Container()),
            (signedIn
                ? FlatButton(
                    child: Text('Google Logout'),
                    onPressed: () {},
                    color: Colors.green,
                  )
                : FlatButton(
                    child: Text('Google Login'),
                    onPressed: () {
                      ApplicationState.signInWithGoogle(context: context);
                    },
                    color: Colors.red,
                  )),
            Consumer<ApplicationState>(
              builder: (context, appState, _) => Authentication(
                email: appState.email,
                loginState: appState.loginState,
                startLoginFlow: appState.startLoginFlow,
                verifyEmail: appState.verifyEmail,
                signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
                cancelRegistration: appState.cancelRegistration,
                registerAccount: appState.registerAccountGeneral,
                signOut: appState.signOut,
                googleSignIn: () =>
                    ApplicationState.signInWithGoogle(context: context),
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
