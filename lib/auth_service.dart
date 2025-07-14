import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı oluşturma
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Signup Error: $e');
      return null;
    }
  }

  // Giriş yapma
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('SignIn Error: $e');
      return null;
    }
  }

  // Çıkış yapma
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Şu anki kullanıcı
  User? get currentUser => _auth.currentUser;

  // Auth durumunu dinleme
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
