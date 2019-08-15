import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAnonAuth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<FirebaseUser> signInAnon() async {
      FirebaseUser user = await firebaseAuth.signInAnonymously();
      return user;
  }

  Future<FirebaseUser> signInEmail(String email, String password) async {
      FirebaseUser user = await firebaseAuth.signInWithEmailAndPassword(email: email,password: password);
      return user;
  }

  Future<FirebaseUser> isLoggedIn() async {
      FirebaseUser user = await firebaseAuth.currentUser();
      return user;
  }

  FirebaseAuth getFirebaseAuth(){
    return firebaseAuth;
  }

  signOut(){
      return firebaseAuth.signOut();
  }
}
