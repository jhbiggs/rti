
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
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
    ga.File fileToUpload = ga.File();
    var file = await FilePicker.platform.pickFiles();
    fileToUpload.parents = ["appDataFolder"];
    fileToUpload.name = path.basename(file?.paths.first ?? "nothing");
    // print(response);
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
      }
    });
  }

  Future<void> _downloadGoogleDriveFile(String fName, String gdID) async {

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
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: Text('${i + 1}'),
            ),
            Expanded(
              child: Text(list.files![i].name ?? "nothing2"),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: TextButton(
                child: const Text(
                  'Download',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
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
                ? TextButton(
                    child: const Text('Upload File to Google Drive'),
                    onPressed: _uploadFileToGoogleDrive,
                  )
                : Container()),
            (signedIn
                ? TextButton(
                    child: const Text('List Google Drive Files'),
                    onPressed: _listGoogleDriveFiles,
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
                ? TextButton(
                    child: const Text('Google Logout'),
                    onPressed: () {},
                  )
                : TextButton(
                    child: const Text('Google Login'),
                    onPressed: () {
                      ApplicationState.signInWithGoogle(context: context);
                    },
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
