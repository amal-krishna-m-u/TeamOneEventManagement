import 'package:flutter/material.dart';

class ManageEmp extends StatefulWidget {
  const ManageEmp({Key? key}) : super(key: key);

  @override
  State<ManageEmp> createState() => _ManageEmpState();
}

class _ManageEmpState extends State<ManageEmp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Employees',
        ),
      ),
      body: Center(
        child: Text(
          'Hello World!\nWelcome to the Manage Employees page.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
