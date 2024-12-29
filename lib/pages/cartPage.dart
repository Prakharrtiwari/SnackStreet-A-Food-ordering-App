import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:streetorder/pages/ordersuccsesspage.dart'; // Import Razorpay package

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late CollectionReference cartRef;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    cartRef = FirebaseFirestore.instance.collection('cart');
    _razorpay = Razorpay();

    // Register Razorpay event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_CANCELED, _handlePaymentCanceled);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear(); // Clear Razorpay instance when not needed
  }

  // Handle Razorpay payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Success: ${response.paymentId}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful! Payment ID: ${response.paymentId}")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OrderSuccessPage()),
    );
  }

  // Handle Razorpay payment error
  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  // // Handle Razorpay payment cancellation
  // void _handlePaymentCanceled(PaymentCancellationResponse response) {
  //   print("Payment Canceled: ${response.reason}");
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Payment Canceled: ${response.reason}")),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          "Your Cart",
          style: GoogleFonts.fredoka(
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No data found."));
          }

          Map<String, dynamic> cart = (snapshot.data!.data() as Map<String, dynamic>)['cart'] ?? {};

          if (cart.isEmpty) {
            return Center(child: Text("No items in cart."));
          }

          List<Widget> cartItems = [];
          double itemTotalAmount = 0;
          const double deliveryFee = 45.0;
          const double serviceTaxRate = 0.18;

          // Iterate through cart to calculate item total and prepare widgets
          cart.forEach((itemId, itemData) {
            final name = itemData['name'] ?? "Unknown";
            final priceString = itemData['price'] ?? "0";
            final quantity = itemData['quantity'] ?? 1;
            final imagePath = itemData['imagePath'] ?? "";

            // Extract numeric value from price
            final numericPrice = double.tryParse(RegExp(r'\d+').stringMatch(priceString) ?? "0") ?? 0;

            // Calculate total for this item
            final itemTotal = numericPrice * quantity;
            itemTotalAmount += itemTotal;

            // Add item widget
            cartItems.add(
              CartItemCard(
                title: name,
                price: "₹${numericPrice.toStringAsFixed(0)}",
                imagePath: imagePath,
                quantity: quantity,
                onRemove: () async {
                  await removeFromCart(itemId);
                },
                onIncrement: () async {
                  await updateCartItemQuantity(itemId, quantity + 1);
                },
                onDecrement: () async {
                  if (quantity > 1) {
                    await updateCartItemQuantity(itemId, quantity - 1);
                  }
                },
              ),
            );
          });

          // Calculate delivery fee and service tax
          final double serviceTax = itemTotalAmount * serviceTaxRate;
          final double totalAmount = itemTotalAmount + deliveryFee + serviceTax;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: cartItems,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Breakdown of charges
                    Text(
                      "Item Total: ₹${itemTotalAmount.toStringAsFixed(0)}",
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                    Text(
                      "Delivery Fee: ₹${deliveryFee.toStringAsFixed(0)}",
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                    Text(
                      "Service Tax (18%): ₹${serviceTax.toStringAsFixed(0)}",
                      style: GoogleFonts.fredoka(fontWeight: FontWeight.w400, fontSize: 16),
                    ),
                    Divider(thickness: 1, color: Colors.grey),
                    Text(
                      "Total Amount: ₹${totalAmount.toStringAsFixed(0)}",
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Initiate Razorpay payment
                        _proceedToPayment(totalAmount);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade800,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text(
                        "Proceed to Checkout",
                        style: GoogleFonts.fredoka(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Function to initiate the Razorpay payment
  void _proceedToPayment(double totalAmount) {
    var options = {
      'key': 'rzp_test_112oO1M4gQEiRp', // Replace with your Razorpay key
      'amount': (totalAmount * 100).toInt(), // Convert to paise
      'name': 'Your Store Name',
      'description': 'Order Payment',
      'prefill': {
        'contact': '1234567890',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['paytm']
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay payment: $e");
    }
  }
}

Future<void> updateCartItemQuantity(String itemId, int newQuantity) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Fetch the current cart data
      DocumentSnapshot userSnapshot = await userRef.get();
      Map<String, dynamic> cart = (userSnapshot.data() as Map<String, dynamic>)['cart'] ?? {};

      // Update the item quantity in the cart
      if (cart.containsKey(itemId)) {
        cart[itemId]['quantity'] = newQuantity;
      }

      // Update the cart field in the user's document
      await userRef.update({'cart': cart});
    }
  } catch (error) {
    print('Error updating cart item quantity: $error');
  }
}

Future<void> removeFromCart(String itemId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Fetch the current cart data
      DocumentSnapshot userSnapshot = await userRef.get();
      Map<String, dynamic> cart = (userSnapshot.data() as Map<String, dynamic>)['cart'] ?? {};

      // Remove the item from the cart
      cart.remove(itemId);

      // Update the cart field in the user's document
      await userRef.update({'cart': cart});
    }
  } catch (error) {
    print('Error removing item from cart: $error');
  }
}

class CartItemCard extends StatelessWidget {
  final String title;
  final String price;
  final String imagePath;
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  CartItemCard({
    required this.title,
    required this.price,
    required this.imagePath,
    required this.quantity,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              offset: Offset(10, 10),
              blurRadius: 20,
              spreadRadius: 20,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.fredoka(fontWeight: FontWeight.w500, fontSize: 16)),
                    SizedBox(height: 8),
                    Text(price, style: GoogleFonts.fredoka(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: onDecrement,
                          icon: Icon(Icons.remove_circle, color: Colors.black),
                        ),
                        Text(quantity.toString(), style: GoogleFonts.fredoka(fontWeight: FontWeight.w500, fontSize: 16)),
                        IconButton(
                          onPressed: onIncrement,
                          icon: Icon(Icons.add_circle, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
