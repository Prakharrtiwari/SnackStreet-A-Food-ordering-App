import 'package:flutter/material.dart';

class OrderSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,  // White background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Big green check mark icon
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 150.0,  // Size of the check icon
            ),
            SizedBox(height: 20),  // Space between the icon and text
            Text(
              'Order Placed Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,  // Text color
              ),
            ),
            SizedBox(height: 10),  // Space between text and button
            ElevatedButton(
              onPressed: () {
                // Optional: Navigate to another screen or perform an action
                Navigator.pop(context);  // Go back to the previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:  Colors.green,  // Button color
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text(
                'Go to Home',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
