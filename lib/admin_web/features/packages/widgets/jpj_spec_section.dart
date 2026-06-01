import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class JpjSpecSection extends StatelessWidget {
  final bool isEditing;
  final TextEditingController frontWindscreenCtrl;
  final TextEditingController frontSideCtrl;
  final TextEditingController rearSideCtrl;
  final TextEditingController rearWindscreenCtrl;
  final TextEditingController jpjTitleCtrl;
  final TextEditingController jpjDescCtrl;

  const JpjSpecSection({
    super.key,
    required this.isEditing,
    required this.frontWindscreenCtrl,
    required this.frontSideCtrl,
    required this.rearSideCtrl,
    required this.rearWindscreenCtrl,
    required this.jpjTitleCtrl,
    required this.jpjDescCtrl,
  });

  Widget _buildSpecRow(String part, TextEditingController controller, bool isStrict) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                part,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                isStrict ? 'Minimum VLT allowed' : 'No minimum limit',
                style: TextStyle(color: isStrict ? const Color(0xFFFFD700) : Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16), 
        Container(
          width: 100, 
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEditing ? const Color(0xFFFFD700) : Colors.transparent, 
              width: 1,
            ),
          ),
          child: isEditing
              ? TextFormField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  cursorColor: const Color(0xFFFFD700), 
                  style: const TextStyle(
                    color: Color(0xFFFFD700), 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  ),
                  decoration: const InputDecoration(
                    isDense: true, 
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : Text(
                  controller.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD700), 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(BootstrapIcons.car_front_fill, color: Colors.black),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isEditing
                    ? TextFormField(
                        controller: jpjTitleCtrl,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: 'JPJ Section Title',
                          labelStyle: TextStyle(color: Color(0xFFFFD700)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                        ),
                      )
                    : Text(
                        jpjTitleCtrl.text.isEmpty ? 'JPJ Specifications' : jpjTitleCtrl.text,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          isEditing
              ? TextFormField(
                  controller: jpjDescCtrl,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'JPJ Section Description',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                )
              : Text(
                  jpjDescCtrl.text.isEmpty
                      ? 'Malaysia Road Transport Department (JPJ) regulations for Visible Light Transmission (VLT). Ensuring compliance helps avoid fines.'
                      : jpjDescCtrl.text,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
          const SizedBox(height: 24),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/JPJ Regulations.jpg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSpecRow('Front Windscreen', frontWindscreenCtrl, true),
          const Divider(color: Colors.white24, height: 32),
          _buildSpecRow('Front Side Windows', frontSideCtrl, true),
          const Divider(color: Colors.white24, height: 32),
          _buildSpecRow('Rear Side Windows', rearSideCtrl, false),
          const Divider(color: Colors.white24, height: 32),
          _buildSpecRow('Rear Windscreen', rearWindscreenCtrl, false),
        ],
      ),
    );
  }
}
