import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/vlt_example.dart';

class FilmSeriesSection extends StatelessWidget {
  final IconData icon;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController specsCtrl;
  final List<VltExample> examples;
  final bool isEditing;
  final Function(VltExample) onShowDialog;

  const FilmSeriesSection({
    super.key,
    required this.icon,
    required this.titleCtrl,
    required this.descCtrl,
    required this.specsCtrl,
    required this.examples,
    required this.isEditing,
    required this.onShowDialog,
  });

  Widget _buildDarknessSpectrum() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: examples.map((ex) {
        return Expanded(
          child: GestureDetector(
            onTap: () => onShowDialog(ex),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white, // White base so opacity shows clearly
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFFD700), width: 1),
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(ex.opacity),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ex.imagePath.startsWith('data:image')
                      ? Image.memory(
                          base64Decode(ex.imagePath.split(',').last),
                          fit: BoxFit.cover,
                        )
                      : ex.imagePath.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: ex.imagePath,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const SizedBox.shrink(),
                            )
                          : Image.asset(
                              ex.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54, // Ensure text is always readable over any image
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ex.vlt,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.black, Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFFD700), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: isEditing
                  ? TextFormField(
                      controller: titleCtrl,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: const InputDecoration(
                        isDense: true, 
                        border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                      ),
                    )
                  : Text(
                      titleCtrl.text,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isEditing
            ? TextFormField(
                controller: descCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                ),
              )
            : Text(
                descCtrl.text,
                style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
              ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFD700)),
            ),
            child: isEditing
              ? TextFormField(
                  controller: specsCtrl,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFFD700)),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                  textAlign: TextAlign.center,
                )
              : Text(
                  specsCtrl.text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFFD700)),
                  textAlign: TextAlign.center,
                ),
          ),
          const SizedBox(height: 24),
          const Text('Darkness Spectrum', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          const SizedBox(height: 12),
          _buildDarknessSpectrum(),
        ],
      ),
    );
  }
}
