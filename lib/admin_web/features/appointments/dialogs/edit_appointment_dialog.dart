import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';
import 'package:royal_tint/data/services/appointment_service.dart';
import 'package:royal_tint/data/services/package_service.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/thirty_minute_time_picker.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/package_tint_selection_section.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_date_time_section.dart';

// EDIT APPOINTMENT DIALOG
class EditAppointmentDialog extends StatefulWidget {
  final AppointmentModel appointment;
  final String branchID;
  final Future<void> Function()? onSaved;

  const EditAppointmentDialog(
      {super.key, required this.appointment, required this.branchID, this.onSaved});

  @override
  State<EditAppointmentDialog> createState() => EditAppointmentDialogState();
}

class EditAppointmentDialogState extends State<EditAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentService _appointmentService = AppointmentService();
  final PackageService _packageService = PackageService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _plateController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedBrand;
  late String _selectedModel;
  late Map<String, String> _tintSelections;

  List<TintPackageModel> _packages = [];
  TintPackageModel? _selectedPackage;
  bool _isLoadingPackages = true;

  bool _isTintSelectionValid() {
    for (final key in _tintSelections.keys) {
      if (_tintSelections[key] == null || _tintSelections[key]!.isEmpty) {
        return false;
      }
    }
    return true;
  }

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.appointment.customerName);
    _phoneController =
        TextEditingController(text: widget.appointment.customerPhone ?? '');
    _plateController =
        TextEditingController(text: widget.appointment.vehiclePlate);
    _notesController =
        TextEditingController(text: widget.appointment.notes ?? '');

    _selectedDate = DateTime.parse(widget.appointment.appointmentDate);
    final timeParts = widget.appointment.appointmentTime.split(':');
    _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

    _selectedBrand = widget.appointment.vehicleBrand;
    _selectedModel = widget.appointment.vehicleModel;

    _loadPackages();

    _tintSelections = Map<String, String>.from(widget.appointment.tintSelections);
    _tintSelections.putIfAbsent('frontWindshield', () => '');
    _tintSelections.putIfAbsent('rearWindscreen', () => '');
    _tintSelections.putIfAbsent('frontSideWindows', () => '');
    _tintSelections.putIfAbsent('rearPassenger', () => '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await _packageService.getAllPackages();
      setState(() {
        _packages = packages;
        _isLoadingPackages = false;
        _selectedPackage = packages.firstWhere(
          (p) => p.packageName == widget.appointment.packageName,
          orElse: () => packages.first,
        );
      });
    } catch (e) {
      setState(() => _isLoadingPackages = false);
    }
  }

  void _onPackageChanged(TintPackageModel? package) {
    if (package != null) {
      setState(() {
        _selectedPackage = package;
        final opts = package.darknessOptions; 
        final def = opts.isNotEmpty ? opts.first : ''; 
        _tintSelections = {
          'frontWindshield': def,
          'rearWindscreen': def,
          'frontSideWindows': def,
          'rearPassenger': def,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 750),
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(colors: [Color(0xFF1A1A1A), Colors.black]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD700), width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13)),
                border: Border(
                    bottom: BorderSide(color: Color(0xFFFFD700), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(BootstrapIcons.pencil,
                      color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 12),
                  const Text('EDIT APPOINTMENT',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),

            // Content
            Flexible(
              child: _isLoadingPackages
                  ? const Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFFFD700))))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditField(
                              'CUSTOMER NAME',
                              _nameController,
                              BootstrapIcons.person_fill,
                              formatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[a-zA-Z\s]")),
                                LengthLimitingTextInputFormatter(50)
                              ],
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Required'
                                  : v.length < 2
                                      ? 'At least 2 characters'
                                      : null,
                            ),
                            const SizedBox(height: 16),

                            _buildEditField(
                              'PHONE NUMBER',
                              _phoneController,
                              BootstrapIcons.telephone_fill,
                              keyboardType: TextInputType.phone,
                              formatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                                LengthLimitingTextInputFormatter(11)
                              ],
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Required'
                                  : v.length < 10
                                      ? 'At least 10 digits'
                                      : !v.startsWith('01')
                                          ? 'Must start with 01'
                                          : null,
                            ),
                            const SizedBox(height: 16),

                            _buildEditField(
                              'CAR PLATE NUMBER',
                              _plateController,
                              BootstrapIcons.car_front_fill,
                              formatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9\s]')),
                                LengthLimitingTextInputFormatter(10),
                                TextInputFormatter.withFunction(
                                    (old, newValue) => TextEditingValue(
                                        text: newValue.text.toUpperCase(),
                                        selection: newValue.selection))
                              ],
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Required'
                                  : v.length < 4
                                      ? 'Invalid plate number'
                                      : null,
                            ),
                            const SizedBox(height: 16),

                            // Car Model (read-only)
                            _buildReadOnlyField(
                                'CAR MODEL',
                                '$_selectedBrand $_selectedModel',
                                BootstrapIcons.car_front_fill),
                            const SizedBox(height: 16),

                            // Date & Time Picker
                            AppointmentDateTimeSection(
                              isSaving: _isSaving,
                              appointmentType: 'scheduled', // edit is always scheduled
                              selectedDate: _selectedDate,
                              selectedTime: _selectedTime,
                              estimatedMinutes: widget.appointment.estimatedDuration > 0
                                  ? widget.appointment.estimatedDuration
                                  : 90,
                              branchID: widget.branchID,
                              onDateChanged: (date) {
                                setState(() {
                                  _selectedDate = date ?? _selectedDate;
                                });
                              },
                              onTimeChanged: (time) {
                                setState(() {
                                  _selectedTime = time ?? _selectedTime;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Branch (read-only)
                            _buildReadOnlyField(
                                'BRANCH',
                                widget.branchID == 'melaka'
                                    ? 'Melaka'
                                    : 'Seremban 2',
                                BootstrapIcons.geo_alt_fill),
                            const SizedBox(height: 16),

                            // Package & Tint Selection
                            PackageTintSelectionSection(
                              packages: _packages,
                              selectedPackage: _selectedPackage,
                              tintSelections: _tintSelections,
                              isSaving: _isSaving,
                              onPackageChanged: _onPackageChanged,
                              onTintSelectionChanged: (key, value) {
                                setState(() {
                                  _tintSelections[key] = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // Notes
                            _buildEditField(
                              'SPECIAL NOTES',
                              _notesController,
                              BootstrapIcons.sticky,
                              maxLines: 3,
                              formatters: [
                                LengthLimitingTextInputFormatter(200)
                              ],
                            ),

                            // ⭐ ADD CHARACTER COUNTER for Notes
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                    '${_notesController.text.length}/200',
                                    style: TextStyle(
                                        color:
                                            _notesController.text.length > 200
                                                ? Colors.red
                                                : const Color(0xFFFFD700)
                                                    .withOpacity(0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.black, Color(0xFF1A1A1A)]),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(13),
                    bottomRight: Radius.circular(13)),
                border:
                    Border(top: BorderSide(color: Color(0xFFFFD700), width: 2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CANCEL',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveChanges,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black)))
                        : const Icon(BootstrapIcons.download),
                    label: Text(_isSaving ? 'SAVING...' : 'SAVE CHANGES',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_isSaving,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: formatters,
          validator: validator,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Color(0xFFFFD700)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFFFD700), size: 20),
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
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.5), width: 2),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: const Color(0xFFFFD700).withOpacity(0.5), size: 20),
              const SizedBox(width: 12),
              Text(value,
                  style: TextStyle(
                      color: const Color(0xFFFFD700).withOpacity(0.7),
                      fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }



  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isTintSelectionValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a darkness level for all tint sections!'),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }

    setState(() => _isSaving = true);

    try {
      final hour = _selectedTime.hour.toString().padLeft(2, '0');
      final minute = _selectedTime.minute.toString().padLeft(2, '0');
      final appointmentTime = '$hour:$minute';
      final appointmentDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      await _appointmentService.updateAppointment(
        appointmentID: widget.appointment.appointmentID,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        vehiclePlate: _plateController.text.trim(),
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        packageID: _selectedPackage?.packageID ?? widget.appointment.packageID,
        packageName: _selectedPackage?.packageName ?? widget.appointment.packageName,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        tintSelections: _tintSelections,
      );

      if (!mounted) return;

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment updated successfully!'),
          backgroundColor: Color(0xFF4CAF50)),
      );

      await widget.onSaved?.call();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}