
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Informar de cualquier cambio
class User with ChangeNotifier {
  
  String id;
  String displayName;
  String photoURL;
  String email;

  User({
    this.id,
    this.displayName,
    this.photoURL,
    this.email
  });

  // Constructor desde Firestore 
  factory User.fromFirestore(DocumentSnapshot userDoc){
    Map<String,dynamic> userData = userDoc.data();
    return new User(
      id: userDoc.reference.id,
      displayName: userData['displayName'],
      photoURL: userData['photoURL'],
      email: userData['email']
    );
  }

  // Update una instancia ya creada
  void setFromFireStore(DocumentSnapshot userDoc){
    Map<String,dynamic> userData = userDoc.data();
    this.id = userDoc.reference.id;
    this.displayName = userData['displayName'];
    this.photoURL = userData['photoURL'];
    this.email = userData['email'];
    notifyListeners();
  }
}