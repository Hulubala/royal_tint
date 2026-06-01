import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/knowledge_section.dart';
import '../widgets/jpj_spec_section.dart';

class TintedBasicInfoScreen extends StatefulWidget {
  const TintedBasicInfoScreen({super.key});

  @override
  State<TintedBasicInfoScreen> createState() => _TintedBasicInfoScreenState();
}

class _TintedBasicInfoScreenState extends State<TintedBasicInfoScreen> {
  bool isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('cms').doc('tinted_basic_info').get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['headerTitle'] != null) _headerTitle.text = data['headerTitle'];
        if (data['headerSubtitle'] != null) _headerSubtitle.text = data['headerSubtitle'];
        if (data['heatTitle'] != null) _heatTitle.text = data['heatTitle'];
        if (data['heatDesc'] != null) _heatDesc.text = data['heatDesc'];
        if (data['uvTitle'] != null) _uvTitle.text = data['uvTitle'];
        if (data['uvDesc'] != null) _uvDesc.text = data['uvDesc'];
        if (data['vltTitle'] != null) _vltTitle.text = data['vltTitle'];
        if (data['vltDesc'] != null) _vltDesc.text = data['vltDesc'];
        if (data['frontWindscreenVLT'] != null) _frontWindscreenVLT.text = data['frontWindscreenVLT'];
        if (data['frontSideVLT'] != null) _frontSideVLT.text = data['frontSideVLT'];
        if (data['rearSideVLT'] != null) _rearSideVLT.text = data['rearSideVLT'];
        if (data['rearWindscreenVLT'] != null) _rearWindscreenVLT.text = data['rearWindscreenVLT'];
        if (data['jpjTitle'] != null) _jpjTitle.text = data['jpjTitle'];
        if (data['jpjDesc'] != null) _jpjDesc.text = data['jpjDesc'];
      }
    } catch (e) {
      print('Error loading cms data: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final _headerTitle = TextEditingController(text: 'Tinted Basic Information');
  final _headerSubtitle = TextEditingController(text: 'Learn the basics of window tinting and stay compliant with Malaysia JPJ regulations.');
  final _heatTitle = TextEditingController();
  final _heatDesc = TextEditingController();
  
  final _uvTitle = TextEditingController();
  final _uvDesc = TextEditingController();

  final _vltTitle = TextEditingController();
  final _vltDesc = TextEditingController();

  final _frontWindscreenVLT = TextEditingController();
  final _frontSideVLT = TextEditingController();
  final _rearSideVLT = TextEditingController();
  final _rearWindscreenVLT = TextEditingController();

  final _jpjTitle = TextEditingController(text: 'JPJ Specifications');
  final _jpjDesc = TextEditingController(text: 'Malaysia Road Transport Department (JPJ) regulations for Visible Light Transmission (VLT). Ensuring compliance helps avoid fines.');

  @override
  void dispose() {
    _headerTitle.dispose();
    _headerSubtitle.dispose();
    _heatTitle.dispose();
    _heatDesc.dispose();
    _uvTitle.dispose();
    _uvDesc.dispose();
    _vltTitle.dispose();
    _vltDesc.dispose();
    _frontWindscreenVLT.dispose();
    _frontSideVLT.dispose();
    _rearSideVLT.dispose();
    _rearWindscreenVLT.dispose();
    _jpjTitle.dispose();
    _jpjDesc.dispose();
    super.dispose();
  }

  Future<void> _toggleEditing() async {
    if (isEditing) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('cms').doc('tinted_basic_info').set({
          'headerTitle': _headerTitle.text,
          'headerSubtitle': _headerSubtitle.text,
          'heatTitle': _heatTitle.text,
          'heatDesc': _heatDesc.text,
          'uvTitle': _uvTitle.text,
          'uvDesc': _uvDesc.text,
          'vltTitle': _vltTitle.text,
          'vltDesc': _vltDesc.text,
          'frontWindscreenVLT': _frontWindscreenVLT.text,
          'frontSideVLT': _frontSideVLT.text,
          'rearSideVLT': _rearSideVLT.text,
          'rearWindscreenVLT': _rearWindscreenVLT.text,
          'jpjTitle': _jpjTitle.text,
          'jpjDesc': _jpjDesc.text,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Content Saved successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
          );
        }
      }
      setState(() => _isLoading = false);
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEditing) ...[
                              TextFormField(
                                controller: _headerTitle,
                                decoration: const InputDecoration(
                                  labelText: 'Header Title',
                                  labelStyle: TextStyle(color: Color(0xFFFFD700)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                                ),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _headerSubtitle,
                                decoration: const InputDecoration(
                                  labelText: 'Header Subtitle',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ] else ...[
                              Text(
                                _headerTitle.text.isEmpty ? 'Tinted Basic Information' : _headerTitle.text,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _headerSubtitle.text.isEmpty ? 'Learn the basics of window tinting and stay compliant with Malaysia JPJ regulations.' : _headerSubtitle.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _toggleEditing,
                        icon: Icon(isEditing ? Icons.save : Icons.edit, size: 18),
                        label: Text(isEditing ? 'Save Changes' : 'Edit Content'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEditing ? const Color(0xFFFFD700) : Colors.transparent,
                          foregroundColor: isEditing ? Colors.black : const Color(0xFFFFD700),
                          side: BorderSide(color: const Color(0xFFFFD700)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: KnowledgeSection(
                          isEditing: isEditing,
                          heatTitleCtrl: _heatTitle,
                          heatDescCtrl: _heatDesc,
                          uvTitleCtrl: _uvTitle,
                          uvDescCtrl: _uvDesc,
                          vltTitleCtrl: _vltTitle,
                          vltDescCtrl: _vltDesc,
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 4,
                        child: JpjSpecSection(
                          isEditing: isEditing,
                          frontWindscreenCtrl: _frontWindscreenVLT,
                          frontSideCtrl: _frontSideVLT,
                          rearSideCtrl: _rearSideVLT,
                          rearWindscreenCtrl: _rearWindscreenVLT,
                          jpjTitleCtrl: _jpjTitle,
                          jpjDescCtrl: _jpjDesc,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KnowledgeSection(
                        isEditing: isEditing,
                        heatTitleCtrl: _heatTitle,
                        heatDescCtrl: _heatDesc,
                        uvTitleCtrl: _uvTitle,
                        uvDescCtrl: _uvDesc,
                        vltTitleCtrl: _vltTitle,
                        vltDescCtrl: _vltDesc,
                      ),
                      const SizedBox(height: 32),
                      JpjSpecSection(
                        isEditing: isEditing,
                        frontWindscreenCtrl: _frontWindscreenVLT,
                        frontSideCtrl: _frontSideVLT,
                        rearSideCtrl: _rearSideVLT,
                        rearWindscreenCtrl: _rearWindscreenVLT,
                        jpjTitleCtrl: _jpjTitle,
                        jpjDescCtrl: _jpjDesc,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}