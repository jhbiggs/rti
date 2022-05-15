/*
 * Created on Sat Mar 26 2022
 *
 * Copyright (c) 2022 Justin Biggs, Mindframe
 */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:com.mindframe.rti/Model/role.dart';
import 'package:com.mindframe.rti/Model/subject.dart';

import '../../widgets.dart';
import 'authentication_google.dart';

enum ApplicationLoginState {
  loggedOut,
  emailAddress,
  register,
  role,
  googleLogIn,
  password,
  loggedIn,
}

class Authentication extends StatelessWidget {
  const Authentication(
      {required this.loginState,
      required this.email,
      required this.startLoginFlow,
      required this.verifyEmail,
      required this.signInWithEmailAndPassword,
      required this.cancelRegistration,
      required this.registerAccount,
      required this.googleSignIn,
      required this.signOut,
      required this.context});

  final BuildContext context;
  final ApplicationLoginState loginState;
  final String? email;
  final void Function() startLoginFlow;
  final void Function(
    String email,
    void Function(Exception e) error,
  ) verifyEmail;
  final void Function(
      String email,
      String password,
      void Function(Exception e) error,
      BuildContext context) signInWithEmailAndPassword;
  final void Function() googleSignIn;
  final void Function() cancelRegistration;
  final void Function(
    String email,
    String displayName,
    Role role,
    Subject subject,
    String password,
    String schoolCode,
    void Function(Exception e) error,
  ) registerAccount;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    switch (loginState) {
      case ApplicationLoginState.loggedOut:
        return ListView(
          // padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
              child: StyledButton(
                onPressed: () {
                  startLoginFlow();
                },
                child: Text('Sign In/Sign Up',
                    style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GoogleSignInButton(googleSignIn: googleSignIn),
            )
          ],
        );

      case ApplicationLoginState.emailAddress:
        return EmailForm(
            callback: (email) => verifyEmail(
                email, (e) => _showErrorDialog(context, 'Invalid email', e)));
      case ApplicationLoginState.password:
        return PasswordForm(
            email: email!,
            login: (email, password, context) {
              signInWithEmailAndPassword(
                  email,
                  password,
                  (e) => _showErrorDialog(context, 'Failed to sign in', e),
                  context);
            },
            context: context);
      case ApplicationLoginState.register:
        return RegisterFormGeneral(
          email: email!,
          cancel: () {
            cancelRegistration();
          },
          registerAccount:
              (email, displayName, role, subject, password, schoolCode) {
            registerAccount(
                email,
                displayName,
                role,
                subject,
                password,
                schoolCode,
                (e) =>
                    _showErrorDialog(context, 'Failed to create account', e));
          },
        );
      case ApplicationLoginState.loggedIn:
        return Row(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StyledButton(
                onPressed: () {
                  signOut();
                },
                child: const Text('LOGOUT'),
              ),
            ),
            const Spacer(),
          ],
        );
      case ApplicationLoginState.googleLogIn:
        return GoogleSignInButton(googleSignIn: googleSignIn);
      default:
        return Row(
          children: const [
            Text("Internal error, this shouldn't happen..."),
          ],
        );
    }
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '$e',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            StyledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ],
        );
      },
    );
  }
}

class EmailForm extends StatefulWidget {
  const EmailForm({required this.callback});
  final void Function(String email) callback;
  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailFormState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const Padding(
          padding:  EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
          child:  Header('Sign in with email'),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 30),
                      child: StyledButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            widget.callback(_controller.text);
                          }
                        },
                        child: const Text('NEXT'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterFormGeneral extends StatefulWidget {
  const RegisterFormGeneral({
    required this.registerAccount,
    required this.cancel,
    required this.email,
  });
  final String email;
  final void Function(String email, String displayName, Role role,
      Subject subject, String password, String schoolCode) registerAccount;
  final void Function() cancel;
  @override
  _RegisterFormGeneralState createState() => _RegisterFormGeneralState();
}

class _RegisterFormGeneralState extends State<RegisterFormGeneral> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterFormState');
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _schoolCodeController = TextEditingController();

  Role _dropdownValueRole = Role.parent;
  Subject _dropDownValueSubject = Subject.art;
  var _isDropdownSubjectVisible = false;

  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const Header('Create account'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      hintText: 'First & last name',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter a name';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: DropdownButton<Role>(
                    value: _dropdownValueRole,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.grey),
                    underline: Container(
                      height: 2,
                      color: Colors.grey,
                    ),
                    onChanged: (Role? newValue) {
                      _dropdownValueRole = newValue!;
                      if (newValue == Role.teacher) {
                        _isDropdownSubjectVisible = true;
                      } else {
                        _isDropdownSubjectVisible = false;
                      }
                      setState(() {});
                    },
                    items: <Role>[
                      Role.administrator,
                      Role.parent,
                      Role.teacher,
                      Role.student
                    ].map<DropdownMenuItem<Role>>((Role value) {
                      return DropdownMenuItem<Role>(
                        value: value,
                        child: Text(value.name.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ),
                /* we don't want the Subject dropdown menu to be visible if the
                user is anything but a teacher, so add a boolean to show/hide
                the menu depending on the user's choice in the role dropdown
                above. */
                _isDropdownSubjectVisible
                    ? Padding(
                        key: GlobalKey(debugLabel: '_subjectDropdownChooser'),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: DropdownButton<Subject>(
                          hint: const Text(
                            "Subject",
                            style: TextStyle(inherit: true),
                          ),
                          value: _dropDownValueSubject,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.grey),
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (Subject? newValue) {
                            setState(() {
                              _dropDownValueSubject = newValue!;
                            });
                          },
                          items: Subject.values
                              .map<DropdownMenuItem<Subject>>((Subject value) {
                            return DropdownMenuItem<Subject>(
                              value: value,
                              child: Text(value.name),
                            );
                          }).toList(),
                        ),
                      )
                    : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _schoolCodeController,
                    decoration: const InputDecoration(
                      hintText: 'School Code for RTI',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter code';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter a password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.cancel,
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 16),
                      StyledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.registerAccount(
                                _emailController.text,
                                _displayNameController.text,
                                _dropdownValueRole,
                                _dropDownValueSubject,
                                _passwordController.text,
                                _schoolCodeController.text);
                          }
                        },
                        child: const Text('SAVE'),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordForm extends StatefulWidget {
  const PasswordForm(
      {required this.login, required this.email, required this.context});
  final String email;
  final void Function(String email, String password, BuildContext context)
      login;
  final BuildContext context;
  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_PasswordFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const Header('Sign in'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 16),
                      StyledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.login(
                              _emailController.text,
                              _passwordController.text,
                              context,
                            );
                          }
                        },
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor),
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key, required this.googleSignIn})
      : super(key: key);
  final void Function() googleSignIn;

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return _isSigningIn
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: StyledButton(
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });

                User? user = await AuthenticationGoogle.signInWithGoogle(
                    context: context);
                _isSigningIn = false;

                setState(() {
                  _isSigningIn = false;
                });

                if (user != null) {
                  widget.googleSignIn;
                }
              },
              child: Row(
                children: <Widget>[
                  const Spacer(),
                  const Image(
                    image: AssetImage("assets/google_logo.png"),
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
  }
}
