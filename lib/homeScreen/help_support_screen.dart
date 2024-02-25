import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help and Support'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          FAQItem(
            question: 'How do I create an account?',
            answer:
                'To create an account, navigate to the signup page and provide the required information. Follow the on-screen instructions to complete the signup process.',
          ),
          FAQItem(
            question: 'I forgot my password. What should I do?',
            answer:
                'If you forgot your password, click on the "Forgot Password" link on the login page. Follow the instructions to reset your password.',
          ),
          SizedBox(height: 24),
          Text(
            'Contact Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Email: Uober@gmail.com'),
            onTap: () {
              // Implement email functionality here
            },
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone:+973-17762121'),
            onTap: () {
              // Implement phone functionality here
            },
          ),
          SizedBox(height: 24),
          Text(
            'Troubleshooting Guides',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text('How to troubleshoot app startup issues'),
            onTap: () {
              // Implement guide functionality here
            },
          ),
          ListTile(
            title: Text('Resolving connection problems'),
            onTap: () {
              // Implement guide functionality here
            },
          ),
        ],
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  @override
  _FAQItemState createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            widget.question,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
        ),
        if (isExpanded)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(widget.answer),
          ),
        Divider(),
      ],
    );
  }
}
