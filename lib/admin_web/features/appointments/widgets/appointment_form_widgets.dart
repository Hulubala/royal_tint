import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppointmentTypeOption extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const AppointmentTypeOption({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFC700)])
              : null,
          color: isSelected ? null : Colors.black,
          border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFD700)
                  : const Color(0xFFFFD700).withOpacity(0.3),
              width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.black : const Color(0xFFFFD700),
                size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: isSelected ? Colors.black : const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class AppointmentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final List<TextInputFormatter> formatters;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const AppointmentTextField(
    this.controller,
    this.label,
    this.icon,
    this.hint,
    this.formatters,
    this.validator, {
    super.key,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          validator: validator,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: const Color(0xFFFFD700).withOpacity(0.4)),
            prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFFFD700), width: 2)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFFFD700), width: 2)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFFFC700), width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2)),
          ),
          style: const TextStyle(color: Color(0xFFFFD700)),
        ),
      ],
    );
  }
}

class AppointmentInfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const AppointmentInfoChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFD700))),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
          Text(value,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
