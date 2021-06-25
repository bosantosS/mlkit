//Authentication
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mlkit/models/user_model.dart' as Us;

enum AuthStatus {
  Uninitialized, //No se sabe el estado pero existe
  Authenticated, //Autenticado
  Authenticating, //Autenticando
  Unauthenticated //No autenticado
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  GoogleSignInAccount _googleUser;

  Us.User _user = new Us.User();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  AuthStatus _status = AuthStatus.Uninitialized;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // https://stackoverflow.com/questions/45353730/firebase-login-with-flutter-using-onauthstatechanged
  AuthProvider.instance() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.Unauthenticated;
    } else {
      DocumentSnapshot userSnapshot =
          await _db.collection('users').doc(firebaseUser.uid).get();
      
      _user.setFromFireStore(userSnapshot);
      _status = AuthStatus.Authenticated;
    }

    notifyListeners();
  }

  Future<dynamic> googleSignIn() async {
    _status = AuthStatus.Authenticating;
    notifyListeners();

    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      this._googleUser = googleUser;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential authResult = await _auth.signInWithCredential(credential);
      User user = authResult.user;
      await updateUserData(user);
    } catch (error) {
      print('ERROR> $error');
      _status = AuthStatus.Uninitialized;
      notifyListeners();
      return null;
    }
  }

  Future<DocumentSnapshot> updateUserData(User user) async {
    DocumentReference userRef = _db.collection('users').doc(user.uid);

    userRef.set(
      {
        'uid': user.uid,
        'email': user.email,
        'lastSign': DateTime.now(),
        'photoURL': user.photoURL,
        'displayName': user.displayName,
      },
    );

    DocumentSnapshot userData = await userRef.get();
    return userData;
  }

  void signOut() {
    _auth.signOut();
    _status = AuthStatus.Unauthenticated;
    notifyListeners();
  }

  AuthStatus get status => _status;
  Us.User get user => _user;
  GoogleSignInAccount get googleUser => _googleUser;
}
