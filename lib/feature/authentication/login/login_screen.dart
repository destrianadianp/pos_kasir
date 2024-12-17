import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos_kasir/app/bloc/authentication_bloc.dart';
import 'package:pos_kasir/app/bloc/authentication_event.dart';
import 'package:pos_kasir/app/bloc/authentication_state.dart';
import 'package:pos_kasir/feature/kelola_produk/kelola_produk_screen.dart';
import 'package:pos_kasir/feature/ui/color.dart';
import 'package:pos_kasir/feature/ui/dimension.dart';
import 'package:pos_kasir/feature/ui/shared_view/custom_text_form_field.dart';

import '../../ui/shared_view/custom_button.dart';
import '../../ui/typography.dart';
import '../register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _isSeen = ValueNotifier(false);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondaryColor,
        automaticallyImplyLeading: false
      ),
      backgroundColor: secondaryColor,
      body: SafeArea(
          child: Form(
              child: SingleChildScrollView(
        padding: EdgeInsets.all(screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Sign in to your account",
              style: mSemiBold,
            ),
            SizedBox(
              height: spacing4,
            ),
            Image.asset('assets/images/img_kasir.png'),
            CustomTextFormField(
              backgroundColor: secondaryColor,
              placeholder: 'Masukan Email',
              controller: _emailController,
              validator: (e) {
                if (e.isEmpty) {
                  return "Email tidak boleh kosong";
                }
                return null;
              },
            ),
            SizedBox(height: spacing1,),
                ValueListenableBuilder(
                  valueListenable: _isSeen, 
                  builder: (context, value, child){
                    return CustomTextFormField(
                      backgroundColor: secondaryColor,
                      maxLines: 1,
                      obsecureText: !value,
                      placeholder: 'Masukan Password',
                      controller: _passwordController,
                      validator: (e) {
                        if (e.length<8) {
                          return "Kata sandi minimal terdiri dari 8 karakter";
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        onPressed: (){
                          _isSeen.value = !_isSeen.value;
                      }, 
                      icon: SvgPicture.asset(value ? 'assets/images/ic_eye_slash.svg': 'assets/images/ic_eye_closed.svg',color: iconNeutralPrimary,), 
                      ),
                    );
                  }
                ),
                SizedBox(height: spacing5,),


                BlocConsumer<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state){
                    return CustomButton(
                  child: Text("Login", style: mBold.copyWith(color: secondaryColor),),
                  onPressed: (){
                    BlocProvider.of<AuthenticationBloc>(context).add(
                      LoginUser(
                        email: _emailController.text.trim(), 
                        password: _passwordController.text.trim()));
                  }
                );
                  },
                  listener: (context, state){
                    if (state is AuthenticationSuccessState) {
                      Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (context)=>KelolaProdukPage()), 
                      (route)=>false);
                    }
                    else if(state is AuthenticationFailureState){
                      showDialog(
                        context: context, 
                        builder: (context){
                          return AlertDialog(
                            content: Text("Login failed. Please try again")
                          );
                        });
                    }
                  }),
                

                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterScreen()));
                    },
                    child: Text(
                      "Sign Up",
                      style: smMedium.copyWith(color: primaryColor),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ))),
    );
  }
}
