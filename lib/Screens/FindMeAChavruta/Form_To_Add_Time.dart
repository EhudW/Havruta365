import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormAddTimeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => FormAddTimeScreenState();
}

class FormAddTimeScreenState extends State<FormAddTimeScreen> {
  String _startTime;
  String _endTime;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildName() {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("הוסיפו זמן")),
      body: Container(
        margin: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildName(),
              SizedBox(height: 100),
              ElevatedButton(
                onPressed: () {
                  null;
                },
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
