import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class KnowledgeSection extends StatelessWidget {
  final bool isEditing;
  final TextEditingController heatTitleCtrl;
  final TextEditingController heatDescCtrl;
  final TextEditingController uvTitleCtrl;
  final TextEditingController uvDescCtrl;
  final TextEditingController vltTitleCtrl;
  final TextEditingController vltDescCtrl;

  const KnowledgeSection({
    super.key,
    required this.isEditing,
    required this.heatTitleCtrl,
    required this.heatDescCtrl,
    required this.uvTitleCtrl,
    required this.uvDescCtrl,
    required this.vltTitleCtrl,
    required this.vltDescCtrl,
  });

  Widget _buildEditableInfoItem({required IconData icon, required TextEditingController titleController, required TextEditingController descController}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isEditing
                  ? TextFormField(
                      controller: titleController,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                    )
                  : Text(
                      titleController.text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              const SizedBox(height: 4),
              isEditing
                  ? TextFormField(
                      controller: descController,
                      maxLines: null,
                      style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                      decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                    )
                  : Text(
                      descController.text,
                      style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                    ),
            ],
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
                child: const Icon(BootstrapIcons.info_circle_fill, color: Colors.black),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Why Tint Your Car?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEditableInfoItem(
            icon: BootstrapIcons.sun_fill,
            titleController: heatTitleCtrl,
            descController: heatDescCtrl,
          ),
          const SizedBox(height: 20),
          _buildEditableInfoItem(
            icon: BootstrapIcons.shield_shaded,
            titleController: uvTitleCtrl,
            descController: uvDescCtrl,
          ),
          const SizedBox(height: 20),
          _buildEditableInfoItem(
            icon: BootstrapIcons.eye_slash_fill,
            titleController: vltTitleCtrl,
            descController: vltDescCtrl,
          ),
        ],
      ),
    );
  }
}
