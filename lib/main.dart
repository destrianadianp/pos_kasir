import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_kasir/app/bloc/authentication_bloc.dart';
import 'package:pos_kasir/feature/authentication/login/login_screen.dart';
import 'package:pos_kasir/feature/kelola_produk/kelola_produk_screen.dart';
import 'package:pos_kasir/feature/tambah_produk/tambah_produk.dart';
import 'package:pos_kasir/firebase_options.dart';
import 'package:pos_kasir/provider/category_provider.dart';
import 'package:pos_kasir/provider/product_provider.dart';
import 'package:pos_kasir/provider/transaction_provider.dart';
import 'package:provider/provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (context)=>AuthenticationBloc()),
        ChangeNotifierProvider(create: (_)=>ProductCartProvider()),
        ChangeNotifierProvider(create: (_)=>CategoryProvider()),
        ChangeNotifierProvider(create: (_)=>TransactionProvider()),

      ],
      child: MaterialApp(
        home: LoginScreen(),
        routes: {
          '/tambah-produk' : (context)=>TambahProduk(),
          '/liat-produk':(context)=>KelolaProdukPage(),
        },
      ),
    );
  }
}
