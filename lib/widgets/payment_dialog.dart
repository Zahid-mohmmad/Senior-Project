import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentDialog extends StatefulWidget {
  final String fareAmount;

  PaymentDialog({Key? key, required this.fareAmount}) : super(key: key);

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 21,
            ),
            Text(
              "Pay Amount",
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 30),
            ),
            const Divider(
              height: 1.5,
              color: Colors.white,
              thickness: 1.0,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              "${widget.fareAmount} BHD",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "This is fare amount ${widget.fareAmount} BHD to be charged from the student",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(color: Colors.amber),
              ),
            ),
            const SizedBox(
              height: 31,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, "Paid"); // Close the container
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Pay Cash"),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context, 'Paid');
                final url =
                    'benefitpay://'; // Replace with the actual URL scheme for Benefit Pay
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('BenefitPay not installed'),
                        content: const Text(
                          'Please install BenefitPay to proceed.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Use BenefitPay colors here
              ),
              child: const Text(
                'BenefitPay',
                style: TextStyle(color: Colors.white), // BenefitPay text color
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                // Add your logic for Pay with Card
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Pay with Card"),
            ),
            const SizedBox(
              height: 41,
            )
          ],
        ),
      ),
    );
  }
}
