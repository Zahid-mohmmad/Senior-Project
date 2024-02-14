import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingDialog extends StatelessWidget {
  final String messageText;

  const LoadingDialog({
    Key? key,
    required this.messageText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.orange,
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.02), // Adjust the multiplier as needed
        width: screenWidth * 0.8, // Adjust the multiplier as needed
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02), // Adjust the multiplier as needed
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 5,
              ),
              SizedBox(
                width: screenWidth * 0.1, // Adjust the multiplier as needed
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Flexible(
                child: Text(
                  messageText,
                  style: GoogleFonts.openSans(
                    fontSize: screenWidth * 0.04, // Adjust the multiplier as needed
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
