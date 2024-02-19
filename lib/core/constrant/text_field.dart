import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';

class TextFieldSection extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final controller;

  const TextFieldSection({
    Key? key,
    required this.label,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.mainColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Container(
          height: 35.0,
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              controller: controller,
              cursorHeight: 25,
              keyboardType: TextInputType.text,
              obscureText: obscureText,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                ),
                icon: icon,
                suffixIcon: suffixIcon,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 9.0, horizontal: 1.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
