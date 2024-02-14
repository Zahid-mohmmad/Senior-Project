import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController? editingController;
  final IconData? iconData;
  final String? assetRef;
  final String? labelText;
  final bool? isObscure;

  const CustomTextFieldWidget(
      {super.key,
      this.editingController,
      this.iconData,
      this.assetRef,
      this.labelText,
      this.isObscure});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: editingController,
      decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: iconData != null
              ? Icon(
                  iconData,
                  color: Colors.black,
                )
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(assetRef.toString()),
                ),
          labelStyle: GoogleFonts.roboto(
            fontSize: 18,
            color: Colors.black,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.black))),
      obscureText: isObscure!,
    );
  }
}
