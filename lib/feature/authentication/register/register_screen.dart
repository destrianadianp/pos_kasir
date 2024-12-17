import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pos_kasir/app/bloc/authentication_bloc.dart';
import 'package:pos_kasir/app/bloc/authentication_event.dart';
import 'package:pos_kasir/app/bloc/authentication_state.dart';
import 'package:pos_kasir/feature/authentication/login/login_screen.dart';

import '../../kelola_produk/kelola_produk_screen.dart';
import '../../ui/color.dart';
import '../../ui/dimension.dart';
import '../../ui/shared_view/custom_button.dart';
import '../../ui/shared_view/custom_text_form_field.dart';
import '../../ui/typography.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
   final _isSeen = ValueNotifier(false);
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose(){
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
          child: Form(
              child: SingleChildScrollView(
        padding: EdgeInsets.all(screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Create an account",
              style: mSemiBold,
            ),
            SizedBox(
              height: spacing4,
            ),
            Image.asset('assets/images/img_kasir.png'),
            CustomTextFormField(
              backgroundColor: secondaryColor,
              placeholder: 'Username',
              controller: _usernameController,
              validator: (e) {
                if (e.isEmpty) {
                  return "Username tidak boleh kosong";
                }
                return null;
              },
            ),
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

                //menghubungkan ke firebase
                BlocConsumer<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state){
                    return CustomButton(
                  child: Text("Sign Up",style: mBold.copyWith(color: secondaryColor)),
                  onPressed: (){
                    BlocProvider.of<AuthenticationBloc>(context).add(
                      SignUpUser(
                        userName: _usernameController.text.trim(), 
                        email: _emailController.text.trim(), 
                        password: _passwordController.text.trim()));
                  }
                );
                  }, 
                  
                  listener: (context,state){
                    if (state is AuthenticationSuccessState) {
                      Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (context)=>LoginScreen()), 
                        (route)=>false);
                    }
                    else if(state is AuthenticationFailureState){
                      showDialog(
                        context: context, 
                        builder: (context){
                          return AlertDialog(
                            content: Text("Error during Sign Up"),
                          );
                        });
                    }
                  }),
                

                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                    },
                    child: Text(
                      "Sign In",
                      style: smMedium.copyWith(color: primaryColor)
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
