import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/assets/assets.gen.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';
import 'package:mobile_perpus/core/constrant/text_field.dart';
import 'package:mobile_perpus/main.dart';
import 'package:mobile_perpus/pages/loginPage/forgot_password.dart';
import 'package:mobile_perpus/pages/loginPage/register_page.dart';
import 'package:mobile_perpus/pages/loginPage/verifycation_email.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailControler = TextEditingController();
  final _passwordController = TextEditingController();
  final textFieldFocusNode = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  final otpMail = EmailOTP();
  bool _obscureText = false;

  @override
  void initState() {
    _obscureText = true;
    super.initState();
  }

  void _toogleObscured() {
    setState(() {
      _obscureText = !_obscureText;
      if (textFieldFocusNode.hasPrimaryFocus) return;
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  void _hiddenPassword() {
    setState(() {
      _obscureText = true;
    });
  }

  Future signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userEmail = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: _emailControler.text)
          .get();
      if (_emailControler.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kolom harus di isi semua!')),
        );
      } else {
        if (userEmail.docs.isNotEmpty) {
          final userData = userEmail.docs[0].data();
          final userStatus = userData['statusEmail'];
          if ('$userStatus' == 'true') {
            await _auth.signInWithEmailAndPassword(
              email: _emailControler.text,
              password: _passwordController.text,
            );

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
          } else {
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Failed'),
                  content: const Text('Email belum terverifikasi'),
                  actions: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Kembali'),
                        ),
                        TextButton(
                          onPressed: () async {
                            otpMail.setConfig(
                              appEmail: 'mobilePerpus123@gmail.com',
                              appName: 'Email OTP',
                              userEmail: _emailControler.text,
                              otpLength: 5,
                              otpType: OTPType.digitsOnly,
                            );
                            try {
                              await otpMail.sendOTP();
                            } catch (e) {
                              print('Error sending OTP email: $e');
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Error sending OTP email. Please try again.'),
                              ));
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Email verifikasi sudah dikirim!')));
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (context) => VerifyPage(
                                          email: _emailControler.text,
                                          myAuth: otpMail,
                                        )));
                          },
                          child: const Text('Verifikasi'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email tidak ditemukan')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email atau Password Salah!')),
      );
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailControler.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 120,
                ),
                Text(
                  'Login on your account',
                  style: GoogleFonts.inter(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Hello, please complete the data below to login on your account',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 60,
                ),
                TextFieldSection(
                  controller: _emailControler,
                  label: 'Email',
                  icon: Assets.icons.icRoundAlternateEmail1.svg(height: 22),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFieldSection(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Assets.icons.icRoundAlternateEmail3.svg(height: 22),
                  obscureText: _obscureText,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: _obscureText
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off_rounded),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _hiddenPassword();
                        _emailControler.clear();
                        _passwordController.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: screenHeight - 570),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  width: double.infinity,
                  height: 50.0,
                  child: MaterialButton(
                    onPressed: _isLoading ? null : signIn,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            strokeAlign: -4,
                            color: Colors.white,
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.whiteColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1,
                      width: 155,
                      color: Colors.black,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'OR',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 155,
                      color: Colors.black,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Or you haven’t an account?',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const RegisterPage()));
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _obscureText = true;
                          });
                        });
                      },
                      child: Text(
                        'Register',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
