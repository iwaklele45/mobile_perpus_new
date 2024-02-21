import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/assets/assets.gen.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';
import 'package:mobile_perpus/core/constrant/text_field.dart';
import 'package:mobile_perpus/pages/loginPage/verifycation_email.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailControler = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final textFieldFocusNode = FocusNode();
  final otpMail = EmailOTP();
  bool _isLoading = false;
  bool _obscureText = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _emailControler.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _obscureText = true;
  }

  void _toogleShowPassword() {
    setState(() {
      if (textFieldFocusNode.hasPrimaryFocus) return;
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  void _toogleShowConfirmPassword() {
    setState(() {
      if (textFieldFocusNode.hasPrimaryFocus) return;
      textFieldFocusNode.canRequestFocus = false;
    });
  }

  Future registerUser(
    String fullName,
    String address,
    int phone,
    String uidUser,
  ) async {
    await FirebaseFirestore.instance.collection('users').add({
      'alamat': fullName,
      'denda': address,
      'email': _emailControler.text,
      'levelUser': uidUser,
      'levelUser': 'Peminjam',
      'namaLengkap': '',
      'username': '',
      'statusEmail': false,
    });
  }

  Future signUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_fullNameController.text.isEmpty ||
          _addressController.text.isEmpty ||
          _emailControler.text.isEmpty ||
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kolom harus di isi semua!')));
      } else {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailControler.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'alamat': _addressController.text,
          'denda': 0,
          'email': _emailControler.text,
          'levelUser': 'Pelanggan',
          'namaLengkap': _fullNameController.text,
          'username': _usernameController.text,
          'statusEmail': false,
        });
        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email verifikasi sudah dikirim!')));
        Future.delayed(const Duration(seconds: 10), () {
          _fullNameController.clear();
          _addressController.clear();
          _emailControler.clear();
          _passwordController.clear();
          _usernameController.clear();
        });
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error sending OTP email. Please try again.'),
          ));
          return;
        }

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => VerifyPage(
                  email: _emailControler.text,
                  myAuth: otpMail,
                )));
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.message) {
        case 'The email address is already in use by another account.':
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Email tersebut sudah terpakai oleh user lain!')));
          _emailControler.clear();
          break;
        case 'The email address is badly formatted.':
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Format email salah!')));
          _emailControler.clear();
          break;
        default:
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message.toString())));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                'Register Account',
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
                'Hello, please complete the data below to register a new account',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const SizedBox(
                height: 40,
              ),
              TextFieldSection(
                controller: _usernameController,
                label: 'Username',
                TextInputType: TextInputType.text,
                icon: Assets.icons.icRoundAlternateEmail.svg(height: 22),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldSection(
                controller: _fullNameController,
                label: 'Full Name',
                TextInputType: TextInputType.text,
                icon: Assets.icons.icRoundAlternateEmail.svg(height: 22),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldSection(
                controller: _emailControler,
                label: 'Email',
                TextInputType: TextInputType.emailAddress,
                icon: Assets.icons.icRoundAlternateEmail1.svg(height: 22),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldSection(
                controller: _addressController,
                label: 'Address',
                TextInputType: TextInputType.text,
                icon: Assets.icons.icRoundAlternateEmail2.svg(height: 22),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFieldSection(
                controller: _passwordController,
                label: 'Password',
                TextInputType: TextInputType.visiblePassword,
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
              SizedBox(
                height: screenHeight - 670,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: double.infinity,
                height: 50.0,
                child: MaterialButton(
                  onPressed: _isLoading ? null : signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          strokeAlign: -4,
                          color: Colors.white,
                        )
                      : Text(
                          'Register',
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
                    'Or you have an account?',
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
                      Navigator.pop(context);
                      _obscureText = true;
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
