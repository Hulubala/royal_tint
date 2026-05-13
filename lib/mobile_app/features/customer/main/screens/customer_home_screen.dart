import 'package:flutter/material.dart';
import 'package:royal_tint/data/repositories/customer_repository.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = CustomerRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Dashboard')),
      body: FutureBuilder(
        future: repo.getCurrentCustomer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final customer = snapshot.data!;
          return Center(
            child: Text(
              'Welcome ${customer.name}\nVehicles: ${customer.vehicles.length}',
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}