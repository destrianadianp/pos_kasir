import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register a new user
  Future<UserModel?> signUpUser(
      String userName, String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'userName': userName,
          'email': email,
          'userId': firebaseUser.uid,
        });
        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email,
          userName: userName,
        );
      }
    } catch (e) {
      print('Error during sign up: $e');
    }
    return null;
  }

  /// Login a user
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final DocumentSnapshot doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          return UserModel(
            id: firebaseUser.uid,
            email: data['email'] ?? '',
            userName: data['userName'] ?? '',
          );
        }
      }
    } catch (e) {
      print('Error during login: $e');
    }
    return null;
  }

  /// Edit profile
  Future<bool> editProfile(String uid, String userName, String email) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'userName': userName,
        'email': email,
      });
      final User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null && firebaseUser.email != email) {
        await firebaseUser.updateEmail(email);
      }
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  /// Logout
  Future<void> signOutUser() async {
    await _firebaseAuth.signOut();
  }


  /// Tambahkan Produk
Future<void> addProduct(String userId, String name, double price, int quantity) async {
  try {
    final newProduct = {
      "userId": userId,
      "name": name,
      "price": price,
      "quantity": quantity,
      "createdAt": FieldValue.serverTimestamp(),
    };
    await _firestore.collection('products').add(newProduct);
  } catch (e) {
    print("Error adding product: $e");
  }
}

/// Ambil Produk Berdasarkan UID
Future<List<Map<String, dynamic>>> fetchUserProducts(String userId) async {
  try {
    final querySnapshot = await _firestore
        .collection('products')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print("Error fetching products: $e");
    return [];
  }
}

/// Tambahkan Transaksi
Future<void> addTransaction(String userId, List<Map<String, dynamic>> items, double total) async {
  try {
    final newTransaction = {
      "userId": userId,
      "items": items,
      "total": total,
      "transactionDate": FieldValue.serverTimestamp(),
    };
    await _firestore.collection('transaction').add(newTransaction);
  } catch (e) {
    print("Error adding transaction: $e");
  }
}

/// Ambil Transaksi Berdasarkan UID
Future<List<Map<String, dynamic>>> fetchUserTransactions(String userId) async {
  try {
    final querySnapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print("Error fetching transactions: $e");
    return [];
  }
}

}
