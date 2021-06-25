import 'package:flutter/material.dart';
import 'package:mlkit/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text('Inicia con Google'),
          onPressed: () async {
            authProvider.googleSignIn();
          } ,
        ),
      )
    );
  }
}