import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogBasicInfoTab extends StatelessWidget {
  const CatalogBasicInfoTab({super.key});

  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('cms').doc('tinted_basic_info').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _gold));
        }

        Map<String, dynamic> data = {};
        if (snapshot.hasData && snapshot.data!.exists) {
          data = snapshot.data!.data() as Map<String, dynamic>;
        }

        final headerTitle = data['headerTitle'] ?? 'Tinted Basic Information';
        final headerSubtitle = data['headerSubtitle'] ?? 'Learn the basics of window tinting and stay compliant with Malaysia JPJ regulations.';

        final heatTitle = data['heatTitle'] ?? 'Infrared Rejection (IRR)';
        final heatDesc = data['heatDesc'] ?? 'Infrared radiation is the main source of heat from the sun. High IRR ratings mean the film blocks more infrared rays, keeping your cabin substantially cooler and reducing the need for heavy air conditioning.';
        final uvTitle = data['uvTitle'] ?? 'Ultra-Violet Rejection (UVR)';
        final uvDesc = data['uvDesc'] ?? 'Harmful UV rays cause skin damage and accelerate vehicle interior fading or cracking. Standard professional films offer 99% UVR protection, shielding both passengers and upholstery from dangerous sun exposure.';
        final vltTitle = data['vltTitle'] ?? 'Visible Light Transmission (VLT)';
        final vltDesc = data['vltDesc'] ?? 'VLT represents the percentage of visible light that passes through your vehicle\'s windows. A lower VLT percentage means a darker tint (e.g., 30% VLT is darker than 70% VLT).';

        final jpjTitle = data['jpjTitle'] ?? 'JPJ Specifications';
        final jpjDesc = data['jpjDesc'] ?? 'Malaysia Road Transport Department (JPJ) regulations for Visible Light Transmission (VLT). Ensuring compliance helps avoid fines.';

        final frontWindscreenVLT = data['frontWindscreenVLT'] ?? '70%';
        final frontSideVLT = data['frontSideVLT'] ?? '50%';
        final rearSideVLT = data['rearSideVLT'] ?? 'No Limit';
        final rearWindscreenVLT = data['rearWindscreenVLT'] ?? 'No Limit';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerTitle,
                style: const TextStyle(
                  color: _surface,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                headerSubtitle,
                style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              
              // Sequence: Heat Rejection (sun_fill), UV protection (shield_shaded), Privacy & Security (eye_slash_fill)
              _buildInfoCard(
                title: heatTitle,
                icon: BootstrapIcons.sun_fill,
                description: heatDesc,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: uvTitle,
                icon: BootstrapIcons.shield_shaded,
                description: uvDesc,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: vltTitle,
                icon: BootstrapIcons.eye_slash_fill,
                description: vltDesc,
              ),
              const SizedBox(height: 24),

              // JPJ specifications with black background and dynamic edit
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _gold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(BootstrapIcons.car_front_fill, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            jpjTitle,
                            style: const TextStyle(
                              color: _gold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      jpjDesc,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/JPJ Regulations.jpg',
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildJpjRow('Front Windscreen', frontWindscreenVLT, isStrict: true, isDarkBackground: true),
                    const Divider(color: Colors.white24, height: 20),
                    _buildJpjRow('Front Side Windows', frontSideVLT, isStrict: true, isDarkBackground: true),
                    const Divider(color: Colors.white24, height: 20),
                    _buildJpjRow('Rear Side Windows', rearSideVLT, isStrict: false, isDarkBackground: true),
                    const Divider(color: Colors.white24, height: 20),
                    _buildJpjRow('Rear Windscreen', rearWindscreenVLT, isStrict: false, isDarkBackground: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJpjRow(String part, String value, {required bool isStrict, bool isDarkBackground = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              part,
              style: TextStyle(color: isDarkBackground ? Colors.white : _surface, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              isStrict ? 'Minimum VLT allowed' : 'No minimum limit',
              style: TextStyle(
                color: isStrict ? _gold : (isDarkBackground ? Colors.white38 : Colors.grey[600]), 
                fontSize: 11, 
                fontWeight: isStrict ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkBackground ? _gold.withValues(alpha: 0.1) : _surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _gold, width: 1.5),
          ),
          child: Text(
            value,
            style: const TextStyle(color: _gold, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _gold, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
