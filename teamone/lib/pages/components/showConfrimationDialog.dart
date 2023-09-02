import 'package:flutter/material.dart';

Future<void> showConfirmationDialog(
    BuildContext context, // Pass the context
    String title,
    String message,
    Function() onConfirm,
) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
            return AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                    TextButton(
                        onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Cancel'),
                    ),
                    TextButton(
                        onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            onConfirm(); // Call the provided function
                        },
                        child: Text('Confirm'),
                    ),
                ],
            );
        },
    );
}
