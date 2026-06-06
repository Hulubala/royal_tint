import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';
import 'package:royal_tint/data/repositories/vehicle_repository.dart';
import 'package:royal_tint/data/services/appointment_service.dart';
import 'package:royal_tint/data/services/package_service.dart';
import 'package:royal_tint/data/services/notification_service.dart';
import 'package:royal_tint/data/repositories/customer_repository.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_form_widgets.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/vehicle_selection_section.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/package_tint_selection_section.dart';
import 'package:royal_tint/admin_web/features/appointments/widgets/appointment_date_time_section.dart';

// NEW APPOINTMENT DIALOG
class NewAppointmentDialog extends StatefulWidget {
  final String branchID;
  final Future<void> Function()? onSaved;

  const NewAppointmentDialog({super.key, required this.branchID, this.onSaved});

  @override
  State<NewAppointmentDialog> createState() => _NewAppointmentDialogState();
}

class _NewAppointmentDialogState extends State<NewAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentService _appointmentService = AppointmentService();
  final PackageService _packageService = PackageService();

  String _appointmentType = 'scheduled';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _plateController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final VehicleRepository _vehicleRepo = VehicleRepository();

  VehicleBrand? _selectedBrand;      // contains brandKey + name
  VehicleModel? _selectedVehicleModel;

  String _detectedCarType = '';
  int _estimatedMinutes = 0;

  List<TintPackageModel> _packages = [];
  TintPackageModel? _selectedPackage;
  bool _isLoadingPackages = true;
  double _calculatedPrice = 0.0;

  Map<String, String> _tintSelections = {
    'frontWindScreen': '',
    'frontSideWindows': '',
    'rearPassenger': '',
    'rearWindscreen': '',
  };

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
    _loadPackages();
    _selectedDate =
        DateTime.now().add(const Duration(days: 1)); // Initialize to tomorrow
    _selectedTime = TimeOfDay.now();
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
        if (_packages.isNotEmpty) {
          _selectedPackage = _packages.first;
          _updatePrice();
          _tintSelections = defaultTintSelectionsForPackage(_selectedPackage!.packageName);
        }
      });
    } catch (e) {
      setState(() => _isLoadingPackages = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load packages: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _onPackageChanged(TintPackageModel? package) {
    if (package != null) {
      setState(() {
        _selectedPackage = package;
        _updatePrice();
        _tintSelections = defaultTintSelectionsForPackage(package.packageName);
      });
    }
  }

  void _updatePrice() {
    if (_selectedPackage != null && _detectedCarType.isNotEmpty) {
      setState(() {
        _calculatedPrice =
            _selectedPackage!.getPriceForVehicle(_detectedCarType);
        final packageDuration =
            _selectedPackage!.getDurationForVehicle(_detectedCarType);
        if (packageDuration > 0) {
          _estimatedMinutes = packageDuration;
        }
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black, Color(0xFF1A1A1A), Colors.black]),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13)),
                border: Border(
                    bottom: BorderSide(color: Color(0xFFFFD700), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(BootstrapIcons.plus_circle,
                      color: Color(0xFFFFD700), size: 24),
                  const SizedBox(width: 12),
                  const Text('CREATE NEW APPOINTMENT',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),
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
                            Row(
                              children: [
                                Expanded(
                                    child: _buildTypeOption(
                                        'scheduled',
                                        'Scheduled',
                                        BootstrapIcons.calendar_check)),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: _buildTypeOption(
                                        'walk-in',
                                        'Walk-In',
                                        BootstrapIcons.person_walking)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(
                                _nameController,
                                'Customer Name',
                                BootstrapIcons.person_fill,
                                'Ahmad Ibrahim',
                                [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r"[a-zA-Z\s]")),
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                (v) => v == null || v.isEmpty
                                    ? 'Required'
                                    : v.length < 2
                                        ? 'At least 2 characters'
                                        : null),
                            const SizedBox(height: 16),
                            _buildTextField(
                                _phoneController,
                                'Phone Number',
                                BootstrapIcons.telephone_fill,
                                '012-3456789',
                                [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9\-]')),
                                  LengthLimitingTextInputFormatter(13)
                                ],
                                (v) => v == null || v.isEmpty
                                    ? 'Required'
                                    : v.length < 10
                                        ? 'At least 10 digits'
                                        : !v.startsWith('01')
                                            ? 'Must start with 01'
                                            : null,
                                keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                            _buildTextField(
                                _plateController,
                                'Vehicle Plate',
                                BootstrapIcons.car_front_fill,
                                'ABC 1234',
                                [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Za-z0-9\s]')),
                                  LengthLimitingTextInputFormatter(10),
                                  TextInputFormatter.withFunction(
                                      (old, newValue) => TextEditingValue(
                                          text: newValue.text.toUpperCase(),
                                          selection: newValue.selection))
                                ],
                                (v) => v == null || v.isEmpty
                                    ? 'Required'
                                    : v.length < 4
                                        ? 'Invalid'
                                        : null),
                            const SizedBox(height: 16),
                            VehicleSelectionSection(
                              vehicleRepo: _vehicleRepo,
                              selectedBrand: _selectedBrand,
                              selectedVehicleModel: _selectedVehicleModel,
                              detectedCarType: _detectedCarType,
                              estimatedMinutes: _estimatedMinutes,
                              isSaving: _isSaving,
                              onBrandChanged: (brand) {
                                setState(() {
                                  _selectedBrand = brand;
                                  _selectedVehicleModel = null;
                                  _detectedCarType = '';
                                  _estimatedMinutes = 0;
                                  _calculatedPrice = 0.0;
                                });
                              },
                              onModelChanged: (model) {
                                setState(() {
                                  _selectedVehicleModel = model;
                                  _detectedCarType = model?.type ?? 'Sedan';
                                  _estimatedMinutes = model?.minutes ?? 90;
                                  _updatePrice();
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            AppointmentDateTimeSection(
                              isSaving: _isSaving,
                              appointmentType: _appointmentType,
                              selectedDate: _selectedDate,
                              selectedTime: _selectedTime,
                              estimatedMinutes: _estimatedMinutes,
                              branchID: widget.branchID,
                              onDateChanged: (date) {
                                setState(() {
                                  _selectedDate = date;
                                  _selectedTime = null;
                                });
                              },
                              onTimeChanged: (time) {
                                setState(() {
                                  _selectedTime = time;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
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
                            if (_calculatedPrice > 0) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFFFFF9E6),
                                    Color(0xFFFFF3CC)
                                  ]),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFFFD700), width: 2),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(BootstrapIcons.cash_stack,
                                            color: Color(0xFFFFD700), size: 20),
                                        SizedBox(width: 8),
                                        Text('Total Price',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                      ],
                                    ),
                                    Text(
                                        'RM ${_calculatedPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildTextField(
                                _notesController,
                                'Notes (Optional - Max 200 characters)',
                                BootstrapIcons.sticky,
                                'Add any special requests...',
                                [LengthLimitingTextInputFormatter(200)],
                                null,
                                keyboardType: TextInputType.multiline,
                                maxLines: 3),
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
                  TextButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveAppointment,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.black)))
                        : const Icon(BootstrapIcons.check_circle),
                    label:
                        Text(_isSaving ? 'Creating...' : 'Create Appointment'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String value, String label, IconData icon) {
    return AppointmentTypeOption(
      value: value,
      label: label,
      icon: icon,
      isSelected: _appointmentType == value,
      onTap: () => setState(() => _appointmentType = value),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      String hint,
      List<TextInputFormatter> formatters,
      String? Function(String?)? validator,
      {TextInputType? keyboardType,
      int maxLines = 1}) {
    return AppointmentTextField(
      controller,
      label,
      icon,
      hint,
      formatters,
      validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !_isSaving,
      onChanged: (_) => setState(() {}),
    );
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBrand == null || _selectedVehicleModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select vehicle brand and model'),
          backgroundColor: Colors.red));
      return;
    }

    if (_appointmentType == 'scheduled' && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a date'), backgroundColor: Colors.red));
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a time'), backgroundColor: Colors.red));
      return;
    }

    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a package'),
          backgroundColor: Colors.red));
      return;
    }

    if (!_isTintSelectionValid()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a darkness paper for all sections!'),
        backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final appointmentDate = _appointmentType == 'scheduled'
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      final hour = _selectedTime!.hour.toString().padLeft(2, '0');
      final minute = _selectedTime!.minute.toString().padLeft(2, '0');
      final appointmentTime = '$hour:$minute';

      final phone = _phoneController.text.trim();
      
      // Attempt to link to an existing customer account by phone number
      String? matchedCustomerID;
      try {
        final customerRepo = CustomerRepository();
        final matchedCustomer = await customerRepo.getCustomerByPhone(phone);
        if (matchedCustomer != null) {
          matchedCustomerID = matchedCustomer.uid;
          print('✅ [DEBUG] Successfully linked appointment to existing customer: ${matchedCustomer.name} ($matchedCustomerID)');
        } else {
          print('⚠️ [DEBUG] No matching customer profile found for phone: $phone');
        }
      } catch (e) {
        print('❌ [DEBUG] Error searching for customer by phone: $e');
      }

      // ⭐ The validation now happens INSIDE createAppointment with transaction
      final appointmentID = await _appointmentService.createAppointment(
        customerID: matchedCustomerID,
        customerName: _nameController.text.trim(),
        customerPhone: phone,
        branchID: widget.branchID,
        vehicleBrand: _selectedBrand!.name,
        vehicleModel: _selectedVehicleModel!.name,
        vehicleType: _detectedCarType,
        vehiclePlate: _plateController.text.trim(),
        packageID: _selectedPackage!.packageID,
        packageName: _selectedPackage!.packageName,
        warranty: _selectedPackage!.warranty,
        tintSelections: _tintSelections,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        appointmentType: _appointmentType,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        totalPrice: _calculatedPrice,
        estimatedDuration: _estimatedMinutes,
      );

      // Notify managers about this new appointment
      await NotificationService().notifyManagersNewAppointment(
        branchID: widget.branchID,
        customerName: _nameController.text.trim(),
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        appointmentID: appointmentID,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Appointment created successfully! Vehicle: ${_selectedBrand!.name} ${_selectedVehicleModel!.name}'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 3),
        ),
      );
      
      await widget.onSaved!();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        String errorMessage = 'Failed to create appointment';

        if (e.toString().contains('TIME_SLOT_FULL')) {
          errorMessage =
              '⚠️ This time slot is fully booked (max 2 cars). Please select another time.';
        } else {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}