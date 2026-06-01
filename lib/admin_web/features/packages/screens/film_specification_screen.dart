import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vlt_example.dart';
import '../widgets/darkness_edit_dialog.dart';
import '../widgets/film_series_section.dart';

class FilmSpecificationScreen extends StatefulWidget {
  const FilmSpecificationScreen({super.key});

  @override
  State<FilmSpecificationScreen> createState() => _FilmSpecificationScreenState();
}

class _FilmSpecificationScreenState extends State<FilmSpecificationScreen> {
  bool isEditing = false;
  bool _isLoading = true;
  Map<String, dynamic> _cmsData = {};

  // Controllers
  final _headerTitle = TextEditingController(text: 'Film Specifications & Guide');
  final _headerSubtitle = TextEditingController(text: 'Compare different tint films and visually review their darkness levels.');
  final _film1Title = TextEditingController();
  final _film1Desc = TextEditingController();
  final _film1Specs = TextEditingController();

  final _film2Title = TextEditingController();
  final _film2Desc = TextEditingController();
  final _film2Specs = TextEditingController();

  final _film3Title = TextEditingController();
  final _film3Desc = TextEditingController();
  final _film3Specs = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('cms').doc('film_specifications').get();
      if (doc.exists) {
        final data = doc.data()!;
        _cmsData = data;
        if (data['headerTitle'] != null) _headerTitle.text = data['headerTitle'];
        if (data['headerSubtitle'] != null) _headerSubtitle.text = data['headerSubtitle'];
        if (data['film1Title'] != null) _film1Title.text = data['film1Title'];
        if (data['film1Desc'] != null) _film1Desc.text = data['film1Desc'];
        if (data['film1Specs'] != null) _film1Specs.text = data['film1Specs'];
        if (data['film2Title'] != null) _film2Title.text = data['film2Title'];
        if (data['film2Desc'] != null) _film2Desc.text = data['film2Desc'];
        if (data['film2Specs'] != null) _film2Specs.text = data['film2Specs'];
        if (data['film3Title'] != null) _film3Title.text = data['film3Title'];
        if (data['film3Desc'] != null) _film3Desc.text = data['film3Desc'];
        if (data['film3Specs'] != null) _film3Specs.text = data['film3Specs'];
      }
    } catch (e) {
      print('Error loading film specs: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleEditing() async {
    if (isEditing) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('cms').doc('film_specifications').set({
          'headerTitle': _headerTitle.text,
          'headerSubtitle': _headerSubtitle.text,
          'film1Title': _film1Title.text,
          'film1Desc': _film1Desc.text,
          'film1Specs': _film1Specs.text,
          'film2Title': _film2Title.text,
          'film2Desc': _film2Desc.text,
          'film2Specs': _film2Specs.text,
          'film3Title': _film3Title.text,
          'film3Desc': _film3Desc.text,
          'film3Specs': _film3Specs.text,
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
  void dispose() {
    _headerTitle.dispose();
    _headerSubtitle.dispose();
    _film1Title.dispose(); _film1Desc.dispose(); _film1Specs.dispose();
    _film2Title.dispose(); _film2Desc.dispose(); _film2Specs.dispose();
    _film3Title.dispose(); _film3Desc.dispose(); _film3Specs.dispose();
    super.dispose();
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
                // Top Header Section
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
                  child: Row(
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
                                _headerTitle.text.isEmpty ? 'Film Specifications & Guide' : _headerTitle.text,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _headerSubtitle.text.isEmpty ? 'Compare different tint films and visually review their darkness levels.' : _headerSubtitle.text,
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
                ),
                const SizedBox(height: 32),
                
                // Responsive Content
                LayoutBuilder(
                  builder: (context, constraints) {
                    final svSpectrum = _generateSpectrum('Silver Series', 'SV', 'USA Technology (Dyed Nano)', '65%');
                    final glSpectrum = _generateSpectrum('Gold Series', 'GL', 'USA Technology (Dyed Carbon Nano)', '80%');
                    final ptnSpectrum = _generateSpectrum('Platinum Series', 'PTN', 'USA Technology (Nano Ceramic)', '99%');

                    if (constraints.maxWidth > 1100) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: FilmSeriesSection(icon: BootstrapIcons.star, titleCtrl: _film1Title, descCtrl: _film1Desc, specsCtrl: _film1Specs, examples: svSpectrum, isEditing: isEditing, onShowDialog: _showDarknessDialog)),
                          const SizedBox(width: 24),
                          Expanded(child: FilmSeriesSection(icon: BootstrapIcons.stars, titleCtrl: _film2Title, descCtrl: _film2Desc, specsCtrl: _film2Specs, examples: glSpectrum, isEditing: isEditing, onShowDialog: _showDarknessDialog)),
                          const SizedBox(width: 24),
                          Expanded(child: FilmSeriesSection(icon: BootstrapIcons.gem, titleCtrl: _film3Title, descCtrl: _film3Desc, specsCtrl: _film3Specs, examples: ptnSpectrum, isEditing: isEditing, onShowDialog: _showDarknessDialog)),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilmSeriesSection(icon: BootstrapIcons.star, titleCtrl: _film1Title, descCtrl: _film1Desc, specsCtrl: _film1Specs, examples: svSpectrum, isEditing: isEditing, onShowDialog: _showDarknessDialog),
                          const SizedBox(height: 24),
                          FilmSeriesSection(icon: BootstrapIcons.stars, titleCtrl: _film2Title, descCtrl: _film2Desc, specsCtrl: _film2Specs, examples: glSpectrum, isEditing: isEditing, onShowDialog: _showDarknessDialog),
                          const SizedBox(height: 24),
                          FilmSeriesSection(icon: BootstrapIcons.gem, titleCtrl: _film3Title, descCtrl: _film3Desc, specsCtrl: _film3Specs, examples: ptnSpectrum, isEditing: isEditing, onShowDialog: _showDarknessDialog),
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

  // Override default values if custom CMS data exists for this specific film variant
  VltExample _overrideWithCms(VltExample defaultEx) {
    final key = 'spec_${defaultEx.seriesCode}';
    if (_cmsData.containsKey(key)) {
      final custom = _cmsData[key];
      return VltExample(
        vlt: custom['vlt'] ?? defaultEx.vlt,
        opacity: defaultEx.opacity,
        seriesName: defaultEx.seriesName,
        seriesCode: defaultEx.seriesCode,
        technology: custom['technology'] ?? defaultEx.technology,
        uvr: custom['uvr'] ?? defaultEx.uvr,
        irr: custom['irr'] ?? defaultEx.irr,
        features: custom['features'] != null ? List<String>.from(custom['features']) : defaultEx.features,
        imagePath: custom['imagePath'] ?? defaultEx.imagePath,
      );
    }
    return defaultEx;
  }

  List<VltExample> _generateSpectrum(String seriesName, String seriesCode, String technology, String irr) {
    String folderName = seriesName.toLowerCase().replaceAll(' ', '_');
    String basePath = 'assets/images/film/$folderName';
    
    List<VltExample> defaults;
    if (seriesCode == 'SV') {
      defaults = [
        VltExample(vlt: '50%', opacity: 0.35, seriesName: seriesName, seriesCode: '${seriesCode}50', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/SV50.jpg'),
        VltExample(vlt: '35%', opacity: 0.55, seriesName: seriesName, seriesCode: '${seriesCode}35', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/SV35.jpg'),
        VltExample(vlt: '20%', opacity: 0.70, seriesName: seriesName, seriesCode: '${seriesCode}20', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/SV20.jpg'),
        VltExample(vlt: '05%', opacity: 0.90, seriesName: seriesName, seriesCode: '${seriesCode}05', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/SV05.jpg'),
      ];
    } else if (seriesCode == 'GL') {
      defaults = [
        VltExample(vlt: '70%', opacity: 0.15, seriesName: seriesName, seriesCode: '${seriesCode}70', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/GL70.jpg'),
        VltExample(vlt: '50%', opacity: 0.35, seriesName: seriesName, seriesCode: '${seriesCode}50', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/GL50.jpg'),
        VltExample(vlt: '30%', opacity: 0.50, seriesName: seriesName, seriesCode: '${seriesCode}30', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/GL30.jpg'),
        VltExample(vlt: '20%', opacity: 0.70, seriesName: seriesName, seriesCode: '${seriesCode}20', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/GL20.jpg'),
        VltExample(vlt: '05%', opacity: 0.90, seriesName: seriesName, seriesCode: '${seriesCode}05', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/GL05.jpg'),
      ];
    } else {
      // PTN
      defaults = [
        VltExample(vlt: '70%', opacity: 0.15, seriesName: seriesName, seriesCode: '${seriesCode}70', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN70.jpg'),
        VltExample(vlt: '50%', opacity: 0.35, seriesName: seriesName, seriesCode: '${seriesCode}50', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN50.jpg'),
        VltExample(vlt: '35%', opacity: 0.55, seriesName: seriesName, seriesCode: '${seriesCode}35', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN35.jpg'),
        VltExample(vlt: '20%', opacity: 0.70, seriesName: seriesName, seriesCode: '${seriesCode}20', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN20.jpg'),
        VltExample(vlt: '05%', opacity: 0.90, seriesName: seriesName, seriesCode: '${seriesCode}05', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN05.jpg'),
      ];
    }
    
    return defaults.map((e) => _overrideWithCms(e)).toList();
  }

  void _showDarknessDialog(VltExample example) {
    showDialog(
      context: context,
      builder: (context) {
        return DarknessEditDialog(
          example: example,
          isEditing: isEditing,
          onSave: (updatedExample) async {
            final key = 'spec_${updatedExample.seriesCode}';
            final dataToSave = {
              'vlt': updatedExample.vlt,
              'technology': updatedExample.technology,
              'uvr': updatedExample.uvr,
              'irr': updatedExample.irr,
              'features': updatedExample.features,
              'imagePath': updatedExample.imagePath,
            };
            
            try {
              await FirebaseFirestore.instance.collection('cms').doc('film_specifications').set({
                key: dataToSave,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
              
              if (mounted) {
                setState(() {
                  _cmsData[key] = dataToSave;
                });
                ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Details saved successfully!')));
              }
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red));
            }
          }
        );
      },
    );
  }
}