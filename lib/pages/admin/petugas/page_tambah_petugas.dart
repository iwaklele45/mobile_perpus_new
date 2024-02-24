import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/assets/assets.gen.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';
import 'package:mobile_perpus/core/constrant/text_field.dart';

class PageTambahPetugas extends StatefulWidget {
  const PageTambahPetugas({super.key});

  @override
  State<PageTambahPetugas> createState() => _PageTambahPetugasState();
}

class _PageTambahPetugasState extends State<PageTambahPetugas> {
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
          'levelUser': 'Petugas',
          'namaLengkap': _fullNameController.text,
          'username': _usernameController.text,
          'statusEmail': true,
        });
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Success to add staf!')));
        Navigator.pop(context);

        Future.delayed(const Duration(seconds: 10), () {
          _fullNameController.clear();
          _addressController.clear();
          _emailControler.clear();
          _passwordController.clear();
          _usernameController.clear();
        });
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
        appBar: AppBar(
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.twoWhiteColor,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.mainColor,
                  ),
                ),
              ),
            ),
            title: Text(
              'Tambah Petugas',
              style: GoogleFonts.inter(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            )),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  TextFieldSection(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Assets.icons.icRoundAlternateEmail.svg(height: 22),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFieldSection(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Assets.icons.icRoundAlternateEmail.svg(height: 22),
                  ),
                  const SizedBox(
                    height: 15,
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
                    controller: _addressController,
                    label: 'Address',
                    icon: Assets.icons.icRoundAlternateEmail2.svg(height: 22),
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
                  SizedBox(
                    height: screenHeight - 570,
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
                              'Add',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.whiteColor,
                              ),
                            ),
                    ),
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
