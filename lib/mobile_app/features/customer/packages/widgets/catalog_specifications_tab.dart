import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:royal_tint/admin_web/features/packages/models/vlt_example.dart';

class CatalogSpecificationsTab extends StatelessWidget {
  const CatalogSpecificationsTab({super.key});

  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('cms').doc('film_specifications').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _gold));
        }

        Map<String, dynamic> data = {};
        if (snapshot.hasData && snapshot.data!.exists) {
          data = snapshot.data!.data() as Map<String, dynamic>;
        }

        final headerTitle = data['headerTitle'] ?? 'Film Specifications & Guide';
        final headerSubtitle = data['headerSubtitle'] ?? 'Compare different tint films and visually review their darkness levels.';

        final film1Title = data['film1Title'] ?? 'Silver Series';
        final film1Desc = data['film1Desc'] ?? 'USA Technology (Dyed Nano). Engineered for standard heat rejection and sleek aesthetics.';
        final film1Specs = data['film1Specs'] ?? '65% IRR • 99% UVR';

        final film2Title = data['film2Title'] ?? 'Gold Series';
        final film2Desc = data['film2Desc'] ?? 'USA Technology (Dyed Carbon Nano). Designed for superior solar protection and lifetime color stability.';
        final film2Specs = data['film2Specs'] ?? '80% IRR • 99% UVR';

        final film3Title = data['film3Title'] ?? 'Platinum Series';
        final film3Desc = data['film3Desc'] ?? 'USA Technology (Nano Ceramic). Ultimate heat deflector utilizing advanced multi-layer ceramic technology.';
        final film3Specs = data['film3Specs'] ?? '99% IRR • 99.9% UVR';

        final svSpectrum = _generateSpectrum(data, 'Silver Series', 'SV', 'USA Technology (Dyed Nano)', '65%');
        final glSpectrum = _generateSpectrum(data, 'Gold Series', 'GL', 'USA Technology (Dyed Carbon Nano)', '80%');
        final ptnSpectrum = _generateSpectrum(data, 'Platinum Series', 'PTN', 'USA Technology (Nano Ceramic)', '99%');

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

              _buildFilmSeriesSection(
                context,
                icon: BootstrapIcons.star,
                title: film1Title,
                description: film1Desc,
                specsHighlight: film1Specs,
                examples: svSpectrum,
              ),
              _buildFilmSeriesSection(
                context,
                icon: BootstrapIcons.stars,
                title: film2Title,
                description: film2Desc,
                specsHighlight: film2Specs,
                examples: glSpectrum,
              ),
              _buildFilmSeriesSection(
                context,
                icon: BootstrapIcons.gem,
                title: film3Title,
                description: film3Desc,
                specsHighlight: film3Specs,
                examples: ptnSpectrum,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  List<VltExample> _generateSpectrum(Map<String, dynamic> cmsData, String seriesName, String seriesCode, String technology, String irr) {
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
      defaults = [
        VltExample(vlt: '70%', opacity: 0.15, seriesName: seriesName, seriesCode: '${seriesCode}70', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN70.jpg'),
        VltExample(vlt: '50%', opacity: 0.35, seriesName: seriesName, seriesCode: '${seriesCode}50', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN50.jpg'),
        VltExample(vlt: '35%', opacity: 0.55, seriesName: seriesName, seriesCode: '${seriesCode}35', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN35.jpg'),
        VltExample(vlt: '20%', opacity: 0.70, seriesName: seriesName, seriesCode: '${seriesCode}20', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN20.jpg'),
        VltExample(vlt: '05%', opacity: 0.90, seriesName: seriesName, seriesCode: '${seriesCode}05', technology: technology, uvr: '99%', irr: irr, features: [], imagePath: '$basePath/PTN05.jpg'),
      ];
    }
    
    return defaults.map((defaultEx) {
      final key = 'spec_${defaultEx.seriesCode}';
      if (cmsData.containsKey(key)) {
        final custom = cmsData[key];
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
    }).toList();
  }

  Widget _buildFilmSeriesSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String specsHighlight,
    required List<VltExample> examples,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
              Icon(icon, color: _gold, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _gold),
            ),
            child: Text(
              specsHighlight,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _gold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Darkness Spectrum',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 10),
          _buildDarknessSpectrumRow(context, examples),
        ],
      ),
    );
  }

  Widget _buildDarknessSpectrumRow(BuildContext context, List<VltExample> examples) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: examples.map((ex) {
        return Expanded(
          child: GestureDetector(
            onTap: () => _showDarknessDetailDialog(context, ex),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _gold, width: 1),
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: ex.opacity),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildSpectrumImage(ex.imagePath),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ex.vlt,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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

  Widget _buildSpectrumImage(String path) {
    if (path.startsWith('data:image')) {
      final base64Str = path.split(',').last;
      return Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
    } else if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const SizedBox.shrink(),
      );
    } else {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }
  }

  void _showDarknessDetailDialog(BuildContext context, VltExample ex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _gold, width: 2),
          ),
          title: Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _gold, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ex.seriesName} - ${ex.seriesCode}',
                  style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  ex.technology,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _buildSpectrumImage(ex.imagePath),
                        ),
                        Positioned.fill(
                          child: Container(color: Colors.black.withValues(alpha: 0.5)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatBubble('VLT', ex.vlt),
                              _buildStatBubble('UVR', ex.uvr),
                              _buildStatBubble('IRR', ex.irr),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (ex.features.isNotEmpty) ...[
                    const Text('Features', style: TextStyle(color: _gold, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ex.features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(f, style: const TextStyle(color: Colors.white, fontSize: 13))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatBubble(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}
