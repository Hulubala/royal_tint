import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/data/services/package_service.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';
import 'package:royal_tint/admin_web/features/packages/dialogs/package_management_dialogs.dart';

class EditPackageScreen extends StatefulWidget {
  const EditPackageScreen({super.key});

  @override
  State<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends State<EditPackageScreen> {
  final PackageService _packageService = PackageService();
  List<TintPackageModel> _filteredPackages = [];
  bool _isLoading = true;

  bool isEditingHeader = false;
  final _headerTitle = TextEditingController(text: 'Package Management');
  final _headerSubtitle = TextEditingController(text: 'Manage your window tint packages, options, and pricing.');

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  @override
  void dispose() {
    _headerTitle.dispose();
    _headerSubtitle.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    setState(() => _isLoading = true);
    try {
      final packages = await _packageService.getAllPackages();
      // Load header info
      final doc = await FirebaseFirestore.instance.collection('cms').doc('package_management').get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data['headerTitle'] != null) _headerTitle.text = data['headerTitle'];
        if (data['headerSubtitle'] != null) _headerSubtitle.text = data['headerSubtitle'];
      }
      setState(() {
        _filteredPackages = packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load packages: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showPackageDetails(TintPackageModel package) {
    showDialog(
      context: context,
      builder: (context) => ViewPackageDialog(package: package),
    );
  }

  void _addPackage() async {
    final result = await showDialog<TintPackageModel>(
      context: context,
      builder: (context) => const PackageEditDialog(),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      await _packageService.addPackage(result);
      _loadPackages();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Package added successfully')));
    }
  }

  void _editPackage(TintPackageModel package) async {
    final result = await showDialog<TintPackageModel>(
      context: context,
      builder: (context) => PackageEditDialog(package: package),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      await _packageService.updatePackage(result);
      _loadPackages();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Package updated successfully')));
    }
  }

  void _deletePackage(TintPackageModel package) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Are you sure you want to delete ${package.packageName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _packageService.deletePackage(package.packageID);
      _loadPackages();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Package deleted successfully')));
    }
  }

  Future<void> _toggleEditingHeader() async {
    if (isEditingHeader) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('cms').doc('package_management').set({
          'headerTitle': _headerTitle.text,
          'headerSubtitle': _headerSubtitle.text,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Header Saved successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving header: $e'), backgroundColor: Colors.red),
          );
        }
      }
      setState(() => _isLoading = false);
    }
    setState(() {
      isEditingHeader = !isEditingHeader;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 750;
              final headerContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(BootstrapIcons.box_seam, color: Color(0xFFFFD700), size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: isEditingHeader
                            ? TextFormField(
                                controller: _headerTitle,
                                decoration: const InputDecoration(
                                  labelText: 'Header Title',
                                  labelStyle: TextStyle(color: Color(0xFFFFD700)),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                                ),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFD700),
                                ),
                              )
                            : Text(
                                _headerTitle.text.isEmpty ? 'Package Management' : _headerTitle.text,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: isEditingHeader
                        ? TextFormField(
                            controller: _headerSubtitle,
                            decoration: const InputDecoration(
                              labelText: 'Header Subtitle',
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          )
                        : Text(
                            _headerSubtitle.text.isEmpty ? 'Manage your window tint packages, options, and pricing.' : _headerSubtitle.text,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                  ),
                ],
              );

              final actionButtons = Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: _toggleEditingHeader,
                    icon: Icon(isEditingHeader ? Icons.save : Icons.edit, size: 18),
                    label: Text(isEditingHeader ? 'Save Header' : 'Edit Header'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isEditingHeader ? const Color(0xFFFFD700) : Colors.transparent,
                      foregroundColor: isEditingHeader ? Colors.black : const Color(0xFFFFD700),
                      side: const BorderSide(color: Color(0xFFFFD700)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addPackage,
                    icon: const Icon(BootstrapIcons.plus, size: 18),
                    label: const Text(
                      'ADD NEW PACKAGE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                ),
                child: isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerContent,
                          const SizedBox(height: 24),
                          actionButtons,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: headerContent,
                          ),
                          const SizedBox(width: 24),
                          actionButtons,
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Table Section
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    border: Border(bottom: BorderSide(color: Color(0xFFFFD700), width: 2)),
                  ),
                  child: const Text(
                    'All Tinting Packages',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),

                // Table Body
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                        ),
                      )
                    : _filteredPackages.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No packages found',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    headingRowColor: WidgetStateProperty.all(Colors.black),
                                    dataRowMaxHeight: 70,
                                    dataRowMinHeight: 60,
                                    columns: const [
                                      DataColumn(label: Text('Package', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))),
                                      DataColumn(label: Text('VLT', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))),
                                      DataColumn(label: Text('UVR', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))),
                                      DataColumn(label: Text('IRR', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))),
                                      DataColumn(label: Text('Sedan Price', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))),
                                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700)))),
                                    ],
                                    rows: _filteredPackages.map((pkg) => _buildDataRow(pkg)).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatVlt(List<String> options) {
    if (options.isEmpty) return 'N/A';
    // Extract only percentages to ignore extra words like "VLT" in the data
    final filtered = options
        .map((e) => e.replaceAll(RegExp(r'[^0-9]'), ''))
        .where((e) => e.isNotEmpty)
        .toList();
        
    if (filtered.isEmpty) return 'N/A';
    if (filtered.length == 1) return filtered.first;
    return '${filtered.first}-${filtered.last}';
  }

  DataRow _buildDataRow(TintPackageModel pkg) {
    // Determine formats for UVR and IRR (just percentages)
    final uvrFormat = pkg.uvRejection.isEmpty ? 'N/A' : pkg.uvRejection.replaceAll(RegExp(r'[^0-9%-]'), '');
    final irrFormat = pkg.heatRejection.isEmpty ? 'N/A' : pkg.heatRejection.replaceAll(RegExp(r'[^0-9%-]'), '');
    
    return DataRow(
      cells: [
        DataCell(Text(pkg.packageName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white))),
        DataCell(Text(_formatVlt(pkg.darknessOptions), style: const TextStyle(color: Colors.white70))),
        DataCell(Text(uvrFormat, style: const TextStyle(color: Colors.white70))),
        DataCell(Text(irrFormat, style: const TextStyle(color: Colors.white70))),
        DataCell(Text('RM ${pkg.getPriceForVehicle('sedan').toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(BootstrapIcons.eye, color: Color(0xFFFFD700), size: 20),
                tooltip: 'View Details',
                onPressed: () => _showPackageDetails(pkg),
              ),
              IconButton(
                icon: const Icon(BootstrapIcons.pencil_square, color: Colors.blueAccent, size: 20),
                tooltip: 'Edit Package',
                onPressed: () => _editPackage(pkg),
              ),
              IconButton(
                icon: const Icon(BootstrapIcons.trash, color: Colors.redAccent, size: 20),
                tooltip: 'Delete Package',
                onPressed: () => _deletePackage(pkg),
              ),
            ],
          ),
        ),
      ],
    );
  }
}