import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/data/repositories/customer_repository.dart';
import 'package:royal_tint/domain/models/user/customer_model.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/customer_header.dart';
import 'package:royal_tint/data/repositories/branch_repository.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';

class CustomerFeedbackScreen extends StatefulWidget {
  const CustomerFeedbackScreen({super.key});

  @override
  State<CustomerFeedbackScreen> createState() => _CustomerFeedbackScreenState();
}

class _CustomerFeedbackScreenState extends State<CustomerFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _carPlateController = TextEditingController();
  final _customerRepo = CustomerRepository();
  final _branchRepo = BranchRepository();

  bool _isSubmitting = false;
  bool _branchesLoaded = false;
  String _selectedBranch = 'HQ'; // Default branch for feedback
  String _selectedCategory = 'Services';
  CustomerModel? _customer;

  late Future<CustomerModel> _customerFuture;
  late Future<List<Map<String, dynamic>>> _branchesFuture;

  static const _bg = Colors.white;
  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _customerFuture = _customerRepo.getCurrentCustomer();
    _branchesFuture = _branchRepo.getAllBranches();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _carPlateController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_customer == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final feedbackData = {
        'customerID': _customer!.uid,
        'customerName': _customer!.name,
        'customerEmail': _customer!.email,
        'customerPhone': _customer!.phone,
        'category': _selectedCategory,
        'carPlate': _carPlateController.text.trim().isEmpty ? null : _carPlateController.text.trim(),
        'comment': _commentController.text.trim(),
        'branchID': _selectedBranch,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('feedback').add(feedbackData);

      if (!mounted) return;
      _commentController.clear();
      _carPlateController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your feedback has been submitted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: FutureBuilder<CustomerModel>(
        future: _customerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _gold));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          _customer = snapshot.data;
          if (_customer != null && _customer!.preferredBranch.isNotEmpty && !_branchesLoaded) {
            _selectedBranch = _customer!.preferredBranch;
          }

          return Column(
            children: [
              const CustomerHeader(title: 'Feedback'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Share Your Experience',
                          style: TextStyle(
                            color: _surface,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We value your feedback. Let us know how we did and how we can improve our services for you.',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        // Customer Name Info (Read-Only Card)
                        _buildReadOnlyField(
                          label: 'CUSTOMER NAME',
                          value: _customer!.name,
                          icon: BootstrapIcons.person_fill,
                        ),
                        const SizedBox(height: 16),

                        // Customer Email Info (Read-Only Card)
                        _buildReadOnlyField(
                          label: 'CUSTOMER EMAIL',
                          value: _customer!.email,
                          icon: BootstrapIcons.envelope_fill,
                        ),
                        const SizedBox(height: 16),
                        
                        // Customer Phone Info (Read-Only Card)
                        _buildReadOnlyField(
                          label: 'PHONE NUMBER',
                          value: _customer!.phone,
                          icon: BootstrapIcons.telephone_fill,
                        ),
                        const SizedBox(height: 16),
                        
                        // Car Plate (Optional Text Field)
                        const Text(
                          'CAR PLATE (OPTIONAL)',
                          style: TextStyle(
                            color: _surface,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _carPlateController,
                          style: const TextStyle(color: _gold, fontSize: 14),
                          cursorColor: _gold,
                          decoration: InputDecoration(
                            hintText: 'E.g., ABC 1234',
                            hintStyle: TextStyle(color: _gold.withOpacity(0.5), fontSize: 13),
                            filled: true,
                            fillColor: _surface,
                            prefixIcon: const Icon(BootstrapIcons.car_front_fill, color: _gold, size: 16),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _gold, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _gold, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _gold, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        MenuDropdown<String>(
                          label: 'CATEGORY',
                          labelColor: _surface,
                          icon: BootstrapIcons.tags_fill,
                          hint: 'Select Category',
                          value: _selectedCategory,
                          items: const [
                            MenuItem(value: 'Services', label: 'SERVICES'),
                            MenuItem(value: 'Product Quality', label: 'PRODUCT QUALITY'),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _branchesFuture,
                          builder: (context, branchSnap) {
                            final branches = branchSnap.data ?? [];
                            if (branches.isNotEmpty && !_branchesLoaded) {
                              _branchesLoaded = true;
                              final ids = branches.map((b) => b['branchID'] as String).toList();
                              if (!ids.contains(_selectedBranch)) {
                                _selectedBranch = ids.first;
                              }
                            }
                            final selectedVal = _selectedBranch.isEmpty
                                ? (branches.isNotEmpty ? branches.first['branchID'] as String : 'HQ')
                                : _selectedBranch;

                            final branchItems = branches.isNotEmpty
                                ? branches.map((b) => MenuItem(
                                      value: b['branchID'] as String,
                                      label: (b['branchName'] as String).toUpperCase(),
                                    )).toList()
                                : const [MenuItem(value: 'HQ', label: 'HQ')];

                            return MenuDropdown<String>(
                              label: 'SELECT BRANCH',
                              labelColor: _surface,
                              icon: BootstrapIcons.shop,
                              hint: 'Select Branch',
                              value: selectedVal,
                              items: branchItems,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedBranch = val);
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Comment / Feedback Text Area
                        const Text(
                          'YOUR FEEDBACK',
                          style: TextStyle(
                            color: _surface,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _commentController,
                          maxLines: 6,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(color: _gold, fontSize: 14),
                          cursorColor: _gold,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your feedback comments.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Describe your experience with our services, staff, or facilities...',
                            hintStyle: TextStyle(color: _gold.withOpacity(0.5), fontSize: 13),
                            filled: true,
                            fillColor: _surface,
                            contentPadding: const EdgeInsets.all(18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _gold, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _gold, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _gold, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitFeedback,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _surface,
                              foregroundColor: _gold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: _gold, width: 2),
                              ),
                              elevation: 4,
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(color: _gold)
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(BootstrapIcons.send),
                                      SizedBox(width: 10),
                                      Text(
                                        'SUBMIT FEEDBACK',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _surface,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: _gold, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: _gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
