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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthenticationBloc(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductCartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(),
        ),
      ],
      child: MaterialApp(
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/tambah-produk': (context) => const TambahProduk(),
          '/liat-produk': (context) => const KelolaProdukPage(),
        },
      ),
    );
  }
}
