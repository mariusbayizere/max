import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '873569769522-kt3nug9tc19s2venbme3q32qrut88f5q.apps.googleusercontent.com', // Add your Google client ID here
  );

  // Email and Password Sign Up
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Sign-up error: $e');
      return null;
    }
  }

  // Email and Password Sign In
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Sign-in error: $e');
      return null;
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }

  // Facebook Sign In
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        return null;
      }

      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Facebook sign-in error: $e');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign-out error: $e');
    }
  }
}

















// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     clientId:
//         '873569769522-kt3nug9tc19s2venbme3q32qrut88f5q.apps.googleusercontent.com', // Add your Google client ID here
//   );

//   // Email and Password Sign Up
//   Future<User?> signUpWithEmail(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);
//       return userCredential.user;
//     } catch (e) {
//       print('Sign-up error: $e');
//       return null;
//     }
//   }

//   // Email and Password Sign In
//   Future<User?> signInWithEmail(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       return userCredential.user;
//     } catch (e) {
//       print('Sign-in error: $e');
//       return null;
//     }
//   }

//   // Google Sign In
//   Future<User?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         // The user canceled the sign-in
//         return null;
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       UserCredential userCredential =
//           await _auth.signInWithCredential(credential);
//       return userCredential.user;
//     } catch (e) {
//       print('Google sign-in error: $e');
//       return null;
//     }
//   }

//   // Facebook Sign In
//   Future<User?> signInWithFacebook() async {
//     try {
//       final LoginResult result = await FacebookAuth.instance.login();
//       if (result.status != LoginStatus.success) {
//         return null;
//       }

//       final OAuthCredential credential =
//           FacebookAuthProvider.credential(result.accessToken!.token);
//       UserCredential userCredential =
//           await _auth.signInWithCredential(credential);
//       return userCredential.user;
//     } catch (e) {
//       print('Facebook sign-in error: $e');
//       return null;
//     }
//   }

//   // Sign Out
//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//     } catch (e) {
//       print('Sign-out error: $e');
//     }
//   }
// }













// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Email and Password Sign Up
//   Future<User?> signUpWithEmail(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//       return userCredential.user;
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }

//   // Email and Password Sign In
//   Future<User?> signInWithEmail(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
//       return userCredential.user;
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }

//   // Google Sign In
//   Future<User?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) {
//         return null;
//       }
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       UserCredential userCredential = await _auth.signInWithCredential(credential);
//       return userCredential.user;
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }

//   // Facebook Sign In
//   Future<User?> signInWithFacebook() async {
//     try {
//       final LoginResult result = await FacebookAuth.instance.login();
//       if (result.status != LoginStatus.success) {
//         return null;
//       }
//       final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
//       UserCredential userCredential = await _auth.signInWithCredential(credential);
//       return userCredential.user;
//     } catch (e) {
//       print(e);
//       return null;
//     }
//   }

//   // Sign Out
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
// }
