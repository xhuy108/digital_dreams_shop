import 'package:digital_dreams_shop/config/theme/colors.dart';
import 'package:digital_dreams_shop/config/theme/media_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class InformationItem extends StatelessWidget {
  const InformationItem({super.key, required this.content, required this.icon});

  final String icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: AppColor.background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD8D8D8).withOpacity(0.25),
            offset: const Offset(0, 1),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 13, right: 5),
        child: Row(
          children: [
            SizedBox(
              height: 40,
              width: 40,
              child: IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(icon),
                style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF4F4F4), elevation: 2),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColor.bodyText,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {},
              child: IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(MediaResource.next),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0), elevation: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
