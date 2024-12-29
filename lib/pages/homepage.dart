import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streetorder/pages/cartPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(StreetFoodApp());
}

class StreetFoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/cart': (context) => CartPage(),  // Add the cart page route
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Icon(Icons.location_on, color: Colors.black),
        title: Text(
          "Crossing Republik , Noida",
          style: GoogleFonts.fredoka(color: Colors.black, fontSize: 19, fontWeight: FontWeight.w500),
        ),
        actions: [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 16),
          Stack(
            children: [
              Icon(Icons.notifications, color: Colors.black),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor: Colors.red,
                  child: Text(
                    '2',
                    style: GoogleFonts.fredoka(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Coffee machines are available for rent here.",
                            style: GoogleFonts.fredoka(fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Book Now",
                              style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Image.asset(
                      'assets/coffee_machine.png', // Add the correct asset path
                      width: 80,
                      height: 80,
                    )
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                "All Categories",
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 5,
                children: [
                  CategoryItem("Fuchka", "assets/fuchka.png"),
                  CategoryItem("Chaat", "assets/chaat.png"),
                  CategoryItem("Ghugni", "assets/ghugni.png"),
                  CategoryItem("Roll", "assets/roll.png"),
                  CategoryItem("Momo", "assets/momo.png"),
                  CategoryItem("Chaomin", "assets/chaomin.png"),
                  CategoryItem("Pasta", "assets/pasta.png"),
                  CategoryItem("Boiled egg", "assets/boiled_egg.png"),
                ],
              ),
              SizedBox(height: 24),
              Text(
                "Order your Food",
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              SizedBox(height: 16),
              FoodItem("Fuchka", "₹ 40/plate", "assets/fuchka.png"),
              FoodItem("Chaat", "₹ 60/plate", "assets/chaat.png"),
              FoodItem("Ghugni", "₹ 60/plate", "assets/ghugni.png"),
              FoodItem("Roll", "₹ 80/plate", "assets/roll.png"),
              FoodItem("Momo", "₹ 100/plate", "assets/momo.png"),
              FoodItem("Chaomin", "₹ 50/plate", "assets/chaomin.png"),
              FoodItem("Pasta", "₹ 140/plate", "assets/pasta.png"),
              FoodItem("Boiled Eggs", "₹ 40/plate", "assets/boiled_egg.png"),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          textTheme: GoogleFonts.fredokaTextTheme(),
        ),
        child: BottomNavigationBar(
          currentIndex: 0, // Update this dynamically if needed to reflect the current tab
          selectedItemColor: Colors.yellow.shade700,
          unselectedItemColor: Colors.black,
          onTap: (index) {
            switch (index) {
              case 0: // Home
                Navigator.pushNamed(context, '/home');
                break;
              case 1: // Order (Cart)
                Navigator.pushNamed(context, '/cart');
                break;
              // case 2: // Chat
              //   Navigator.pushNamed(context, '/chat');
              //   break;
              case 2: // Profile
                Navigator.pushNamed(context, '/profile'); // Navigate to ProfilePage
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: "Order",
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.chat),
            //   label: "Chat",
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        )

      ),
    );
  }
}




class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;

  CategoryItem(this.title, this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(height: 8),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
class FoodItem extends StatelessWidget {
  final String title;
  final String price;
  final String imagePath;

  FoodItem(this.title, this.price, this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage(imagePath),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: GoogleFonts.fredoka(fontWeight: FontWeight.w400, fontSize: 18),
                    softWrap: true,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  price,
                  style: GoogleFonts.fredoka(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

                // Fetch the current cart data
                DocumentSnapshot userSnapshot = await userRef.get();
                Map<String, dynamic> cart = (userSnapshot.data() as Map<String, dynamic>)['cart'] ?? {};

                // Check if the item already exists in the cart
                if (cart.containsKey(title)) {
                  // Item exists, increment the quantity
                  cart[title]['quantity'] = cart[title]['quantity'] + 1;
                } else {
                  // Item doesn't exist, add it to the cart
                  cart[title] = {
                    'name': title,
                    'price': price,
                    'imagePath': imagePath,
                    'quantity': 1,
                  };
                }

                // Update the cart field in the user's document
                await userRef.update({'cart': cart});

                // Show the SnackBar after adding the item to the cart
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "$title added to cart successfully!",
                      style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Add to Cart",
              style: GoogleFonts.fredoka(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  final String id;
  final String title;
  final String price;
  final String imagePath;
  final int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imagePath,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'imagePath': imagePath,
      'quantity': quantity,
    };
  }
}
