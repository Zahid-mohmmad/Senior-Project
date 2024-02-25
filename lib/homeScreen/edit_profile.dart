import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final DatabaseReference _driversRef =
      FirebaseDatabase.instance.ref().child('drivers');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _carColorController = TextEditingController();
  TextEditingController _carModelController = TextEditingController();
  TextEditingController _carNumberController = TextEditingController();
  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  late String _carColor;
  late String _carModel;
  late String _carNumber;

  @override
  void initState() {
    super.initState();
    // _fetchDriverData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: _carColorController,
                decoration: InputDecoration(labelText: 'Car Color'),
              ),
              TextField(
                controller: _carModelController,
                decoration: InputDecoration(labelText: 'Car Model'),
              ),
              TextField(
                controller: _carNumberController,
                decoration: InputDecoration(labelText: 'Car Number'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showChangePasswordDialog();
                },
                child: Text('Change Password'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _updateProfileField('name', _nameController.text);
                },
                child: Text('Update Name'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _updateProfileField('phone', _phoneController.text);
                },
                child: Text('Update Phone'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _updateProfileField('carColor', _carColorController.text);
                },
                child: Text('Update Car Color'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _updateProfileField('carModel', _carModelController.text);
                },
                child: Text('Update Car Model'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _updateProfileField('carNumber', _carNumberController.text);
                },
                child: Text('Update Car Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfileField(String field, String value) async {
    try {
      // Update the corresponding field under 'car_details'
      await _driversRef.child('car_details').child(field).set(value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$field updated successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update $field. Please try again later.'),
        ),
      );
    }
  }

  Future<void> _showChangePasswordDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _oldPasswordController,
                decoration: InputDecoration(labelText: 'Old Password'),
                obscureText: true,
              ),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _changePassword();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(_newPasswordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found. Please login again.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password. Please try again later.'),
        ),
      );
    }
  }
}
