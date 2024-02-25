import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ComplainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complain Screen'),
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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _complainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                // TODO: Add email validation logic if needed
                return null;
              },
            ),
            TextFormField(
              controller: _complainController,
              decoration: InputDecoration(labelText: 'Complaint'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your complaint';
                }
                return null;
              },
            ),
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
                    print('Message sent: ' + sendReport.toString());
                    // Show success message to the user
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Success'),
                        content: Text('Complaint submitted successfully.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    print('Error occurred while sending email: $e');
                    // Show error message to the user
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Error'),
                        content: Text(
                            'An error occurred while submitting the complaint.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
