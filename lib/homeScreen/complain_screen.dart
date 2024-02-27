import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uober/global/global_variable.dart';

class ComplainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Complain Screen')),
      ),
      body: Center(
        child: ComplaintForm(),
      ),
    );
  }
}

class ComplaintForm extends StatefulWidget {
  @override
  _ComplaintFormState createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _complainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = userName;
    _emailController.text = userEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _complainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // TODO: Add email validation logic if needed
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _complainController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Complaint',
                      prefixIcon: Icon(Icons.message),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your complaint';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        final String name = _nameController.text;
                        final String email = _emailController.text;
                        final String complain = _complainController.text;
                        final String complainText =
                            'Name: $name\nEmail: $email\nComplaint: $complain';

                        // Configure the SMTP server settings with the app password
                        final smtpServer = SmtpServer('smtp.gmail.com',
                            username: 'uoberservice@gmail.com',
                            password: 'qgng tdjn bdux vgrf',
                            port: 587);

                        // Create the email message
                        final message = Message()
                          ..from = Address(email, name)
                          ..recipients.add('uoberservice@gmail.com')
                          ..subject = 'New Complaint'
                          ..text = complainText;

                        try {
                          final sendReport = await send(message, smtpServer);

                          // Show success message to the user
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Success'),
                              content: const Text(
                                  'Complaint submitted successfully.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          // Show error message to the user
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'An error occurred while submitting the complaint.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      backgroundColor: Colors.amber,
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.poppins(
                          color: Colors.black), // Change text color to black
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
