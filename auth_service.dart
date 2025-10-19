import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<AppUser> register(String name, String email, String pass) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
    final uid = cred.user!.uid;
    final user = AppUser(uid: uid, email: email, displayName: name, role: 'employee');
    await _db.collection('users').doc(uid).set(user.toMap());
    await saveFcmToken(uid);
    return user;
  }

  Future<AppUser> signIn(String email, String pass) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
    final uid = cred.user!.uid;
    final snap = await _db.collection('users').doc(uid).get();
    await saveFcmToken(uid);
    return AppUser.fromMap(uid, snap.data() ?? {'email': email, 'displayName': cred.user?.displayName ?? ''});
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> saveFcmToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _db.collection('users').doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
    }
  }
}
