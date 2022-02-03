import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_chatapp/helper/sharedpref_helper.dart';
import 'package:my_chatapp/services/database.dart';
import 'package:my_chatapp/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User userDetail = result.user;

    if (result != null) {
      SharedPreferenceHelper().saveUserEmail(userDetail.email);
      SharedPreferenceHelper().saveUserId(userDetail.uid);
      SharedPreferenceHelper()
          .saveUserName(userDetail.email.replaceAll("@gmail.com", ""));
      SharedPreferenceHelper().saveDisplayName(userDetail.displayName);
      SharedPreferenceHelper().saveUserProfileUrl(userDetail.photoURL);

      Map<String, dynamic> userInfoMap = {
        "email": userDetail.email,
        "username": userDetail.email.replaceAll("@gmail.com", ""),
        "name": userDetail.displayName,
        "imgUrl": userDetail.photoURL
      };

      DatabaseMethods()
          .addUserInfoToDB(userDetail.uid, userInfoMap)
          .then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  Future signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    await auth.signOut();
  }
}
