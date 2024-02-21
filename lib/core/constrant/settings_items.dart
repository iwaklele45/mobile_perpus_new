import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_perpus/core/constrant/colors.dart';

class ItemSetting extends StatelessWidget {
  final Widget icon;
  final function;
  final label;
  const ItemSetting({
    super.key,
    required this.function,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppColors.twoWhiteColor,
                  ),
                  child: icon),
              const SizedBox(
                width: 20,
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.arrow_forward_ios_sharp,
            size: 15,
          )
        ],
      ),
    );
  }
}
