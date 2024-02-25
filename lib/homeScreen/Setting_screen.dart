import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uober/authentication/login_screen.dart';

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Account Settings'),
            onTap: () => _navigateToAccountSettings(context),
          ),
          ListTile(
            title: Text('Privacy Policy'),
            onTap: () => _navigateToPrivacyPolicy(context),
          ),
          ListTile(
            title: Text('Change Password'),
            onTap: () => _showChangePasswordDialog(context),
          ),
          ListTile(
            title: Text('Delete Account'),
            onTap: () => _confirmDeleteAccount(context),
          ),
          ListTile(
            title: Text('Change Language'),
            onTap: _changeLanguage,
          ),
          ListTile(
            title: Text('Contact Support'),
            onTap: _contactSupport,
          ),
          ListTile(
            title: Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  void _navigateToAccountSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountSettingsPage()),
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String currentPassword = '';
        String newPassword = '';
        String retypeNewPassword = '';

        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Current Password'),
                onChanged: (value) {
                  currentPassword = value;
                },
                obscureText: true,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'New Password'),
                onChanged: (value) {
                  newPassword = value;
                },
                obscureText: true,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Retype New Password'),
                onChanged: (value) {
                  retypeNewPassword = value;
                },
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _changePassword(
                  context,
                  currentPassword,
                  newPassword,
                  retypeNewPassword,
                );
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void _changePassword(
    BuildContext context,
    String currentPassword,
    String newPassword,
    String retypeNewPassword,
  ) async {
    if (newPassword != retypeNewPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Mismatch'),
            content: Text('New password and retype new password do not match.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // Password change logic here...

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Changed'),
            content: Text('Your password has been successfully changed.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
              'An error occurred while changing the password. Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Delete Account'),
          content: Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteAccount(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) {
    try {
      // Account deletion logic here...

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Account Deleted'),
            content: Text('Your account has been successfully deleted.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
              'An error occurred while deleting the account. Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _changeLanguage() {
    // Language change logic here...
  }

  void _contactSupport() {
    // Contact support logic here...
  }

  void _logout() {
    // Logout logic here...
  }
}

class AccountSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: Center(
        child: Text('Account Settings Page'),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: Center(
        child: Text('Privacy Policy Page'),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SettingsPage(),
    );
  }
}

void main() {
  runApp(MyApp());
}
