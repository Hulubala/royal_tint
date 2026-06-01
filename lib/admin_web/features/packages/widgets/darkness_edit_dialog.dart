import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/vlt_example.dart';

class DarknessEditDialog extends StatefulWidget {
  final VltExample example;
  final bool isEditing;
  final Function(VltExample) onSave;

  const DarknessEditDialog({super.key, required this.example, required this.isEditing, required this.onSave});

  @override
  State<DarknessEditDialog> createState() => _DarknessEditDialogState();
}

class _DarknessEditDialogState extends State<DarknessEditDialog> {
  late TextEditingController vltCtrl;
  late TextEditingController uvrCtrl;
  late TextEditingController irrCtrl;
  late TextEditingController techCtrl;
  late TextEditingController featuresCtrl;
  late TextEditingController seriesNameCtrl;
  late TextEditingController seriesCodeCtrl;
  Uint8List? _newImageBytes;
  String? _newImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    vltCtrl = TextEditingController(text: widget.example.vlt.replaceAll(RegExp(r'[^0-9]'), ''));
    uvrCtrl = TextEditingController(text: widget.example.uvr.replaceAll(RegExp(r'[^0-9]'), ''));
    irrCtrl = TextEditingController(text: widget.example.irr.replaceAll(RegExp(r'[^0-9]'), ''));
    techCtrl = TextEditingController(text: widget.example.technology);
    featuresCtrl = TextEditingController(text: widget.example.features.join('\n'));
    seriesNameCtrl = TextEditingController(text: widget.example.seriesName);
    seriesCodeCtrl = TextEditingController(text: widget.example.seriesCode);
    _newImageUrl = widget.example.imagePath;
  }

  @override
  void dispose() {
    vltCtrl.dispose(); uvrCtrl.dispose(); irrCtrl.dispose();
    techCtrl.dispose(); featuresCtrl.dispose();
    seriesNameCtrl.dispose(); seriesCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _newImageBytes = bytes;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isUploading = true);
    String finalImageUrl = _newImageUrl ?? '';
    
    if (_newImageBytes != null) {
      try {
        final base64String = base64Encode(_newImageBytes!);
        finalImageUrl = 'data:image/jpeg;base64,$base64String';
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image processing failed: $e')));
        setState(() => _isUploading = false);
        return;
      }
    }

    final updated = VltExample(
      vlt: '${vltCtrl.text}%',
      opacity: widget.example.opacity,
      seriesName: seriesNameCtrl.text,
      seriesCode: seriesCodeCtrl.text,
      technology: techCtrl.text,
      uvr: '${uvrCtrl.text}%',
      irr: '${irrCtrl.text}%',
      features: featuresCtrl.text.split('\n').where((s) => s.trim().isNotEmpty).toList(),
      imagePath: finalImageUrl,
    );
    
    widget.onSave(updated);
    setState(() => _isUploading = false);
    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildBgImage() {
    if (_newImageBytes != null) {
      return Image.memory(_newImageBytes!, fit: BoxFit.cover);
    } else if (_newImageUrl != null && _newImageUrl!.startsWith('data:image')) {
      final base64Str = _newImageUrl!.split(',').last;
      return Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
    } else if (_newImageUrl != null && _newImageUrl!.startsWith('http')) {
      return CachedNetworkImage(imageUrl: _newImageUrl!, fit: BoxFit.cover, errorWidget: (c,u,e) => const SizedBox.shrink());
    } else if (_newImageUrl != null) {
      return Image.asset(_newImageUrl!, fit: BoxFit.cover, errorBuilder: (c,e,s) => const SizedBox.shrink());
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatBubble(String label, TextEditingController ctrl) {
    return Column(
      children: [
        widget.isEditing
          ? SizedBox(
              width: 90,
              child: TextFormField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true, 
                  suffixText: '%', 
                  suffixStyle: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700)))
                ),
              ),
            )
          : Text('${ctrl.text}%', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFFFD700), width: 2),
      ),
      title: Container(
        padding: const EdgeInsets.only(bottom: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.isEditing
              ? Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: seriesNameCtrl,
                        style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 24),
                        decoration: const InputDecoration(isDense: true, hintText: 'Series Name', enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700)))),
                      ),
                    ),
                    const Text(' - ', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 24)),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: seriesCodeCtrl,
                        style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 24),
                        decoration: const InputDecoration(isDense: true, hintText: 'Code', enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700)))),
                      ),
                    ),
                  ],
                )
              : Text(
                  '${seriesNameCtrl.text} - ${seriesCodeCtrl.text}',
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 24),
                ),
            const SizedBox(height: 4),
            widget.isEditing
              ? TextFormField(
                  controller: techCtrl,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.normal),
                  decoration: const InputDecoration(isDense: true, hintText: 'Technology Description', enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54))),
                )
              : Text(
                  techCtrl.text,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.normal),
                ),
          ],
        ),
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Button (Editing Mode)
              if (widget.isEditing) ...[
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Upload New Sample Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Highlight important stats
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black26, // Fallback color
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: _buildBgImage(),
                    ),
                    // Semi-transparent overlay to ensure text readability
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.5)),
                    ),
                    // The actual stats
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatBubble('VLT', vltCtrl),
                          _buildStatBubble('UVR', uvrCtrl),
                          _buildStatBubble('IRR', irrCtrl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Features', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              widget.isEditing
                ? TextFormField(
                    controller: featuresCtrl,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Enter features (one per line)',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                  )
                : Column(
                    children: widget.example.features.map((f) => _buildBulletPoint(f)).toList(),
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        if (widget.isEditing)
          _isUploading
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2)),
              )
            : ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Save Details'),
              ),
      ],
    );
  }
}
