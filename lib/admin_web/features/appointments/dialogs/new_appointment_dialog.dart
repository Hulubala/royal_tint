import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/core/widgets/custom_menu_dropdown.dart';
import 'package:royal_tint/data/repositories/vehicle_repository.dart';
import 'package:royal_tint/data/services/appointment_service.dart';
import 'package:royal_tint/data/services/package_service.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';
import 'package:royal_tint/admin_web/features/appointments/dialogs/thirty_minute_time_picker.dart';

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
                  const Spacer(),
                  IconButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFFFFD700))),
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
                                '0123456789',
                                [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                  LengthLimitingTextInputFormatter(11)
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
                            StreamBuilder<List<VehicleBrand>>(
                              stream: _vehicleRepo.watchBrands(),
                              builder: (context, snap) {
                                final brands = snap.data ?? [];

                                if (snap.hasError) {
                                  return Text('Brand load error: ${snap.error}', style: const TextStyle(color: Colors.red));
                                }

                                return _buildSmartDropdown(
                                  value: _selectedBrand?.brandKey,
                                  label: 'Vehicle Brand',
                                  icon: BootstrapIcons.car_front,
                                  hint: brands.isEmpty ? 'No brands found' : 'Select brand',
                                  items: brands
                                    .map((b) => DropdownMenuItem<String>(
                                        value: b.brandKey, child: Text(b.name),
                                      ))
                                    .toList(),
                                  onChanged: (brandKey) {
                                    if (brandKey == null) return;
                                    final brand = brands.firstWhere((b) => b.brandKey == brandKey);

                                    setState(() {
                                      _selectedBrand = brand;
                                      _selectedVehicleModel = null;

                                      _detectedCarType = '';
                                      _estimatedMinutes = 0;
                                      _calculatedPrice = 0.0;
                                    });
                                  },
                                  validator: (v) => v == null ? 'Select a brand' : null,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_selectedBrand == null)
                              _buildSmartDropdown(
                                value: null,
                                label: 'Vehicle Model',
                                icon: BootstrapIcons.car_front_fill,
                                hint: 'Select brand first',
                                items: const [],
                                onChanged: (_) {},
                                enabled: false,
                                validator: (v) => v == null ? 'Select a model' : null,
                              )
                            else
                              StreamBuilder<List<VehicleModel>>(
                                stream: _vehicleRepo.watchModelsByBrandKey(_selectedBrand!.brandKey),
                                builder: (context, snap) {
                                  if (snap.hasError) {
                                    return Text(
                                      'Model load error: ${snap.error}',
                                      style: const TextStyle(color: Colors.red),
                                    );
                                  }

                                final models = snap.data ?? [];
                                return _buildSmartDropdown(
                                  value: _selectedVehicleModel?.id,
                                  label: 'Vehicle Model',
                                  icon: BootstrapIcons.car_front_fill,
                                  hint: models.isEmpty ? 'No models found' : 'Select model',
                                  items: models
                                      .map((m) => DropdownMenuItem<String>(
                                            value: m.id,
                                            child: Text(m.name),
                                          ))
                                      .toList(),
                                  onChanged: (modelId) {
                                    if (modelId == null) return;
                                    final model = models.firstWhere((m) => m.id == modelId);

                                    setState(() {
                                      _selectedVehicleModel = model;
                                      _detectedCarType = model.type ?? 'Sedan';
                                      _estimatedMinutes = model.minutes ?? 90;

                                      _updatePrice(); // keep your package override logic
                                    });
                                  },
                                  enabled: models.isNotEmpty,
                                  validator: (v) => v == null ? 'Select a model' : null,
                                );
                              },
                            ),
                            if (_detectedCarType.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildDetectedInfo()
                            ],
                            if (_appointmentType == 'scheduled') ...[
                              const SizedBox(height: 16),
                              _buildDatePicker()
                            ],
                            const SizedBox(height: 16),
                            _buildTimePicker(),
                            const SizedBox(height: 16),
                            _buildPackageDropdown(),
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
    final isSelected = _appointmentType == value;
    return InkWell(
      onTap: () => setState(() => _appointmentType = value),
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      String hint,
      List<TextInputFormatter> formatters,
      String? Function(String?)? validator,
      {TextInputType? keyboardType,
      int maxLines = 1}) {
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
          enabled: !_isSaving,
          onChanged: (_) => setState(() {}),
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

  Widget _buildSmartDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    final menuItems = items.map((e) {
      final v = e.value;
      final child = e.child;

      String text = '';
      if (child is Text) {
        text = child.data ?? '';
      }
      text = text.isNotEmpty ? text : (v ?? '');

      return MenuItem<String>(
        value: v ?? '',
        label: text,
      );
    }).toList();

    return MenuDropdown<String>(
      label: label,
      icon: icon,
      hint: hint,
      value: value,
      enabled: enabled && !_isSaving,
      menuMaxHeight: 320,
      items: menuItems,
      onChanged: (v) => onChanged(v),
    );
  }

  Widget _buildPackageDropdown() {
    if (_packages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: const Row(
          children: [
            Icon(BootstrapIcons.exclamation_triangle, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No packages available. Please add packages first.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return MenuDropdown<String>(
      label: 'Service Package',
      icon: BootstrapIcons.box_seam,
      hint: 'Select package',
      value: _selectedPackage?.packageID,
      enabled: !_isSaving,
      menuMaxHeight: 320,
      items: _packages
          .map((p) => MenuItem<String>(value: p.packageID, label: p.packageName))
          .toList(),
      onChanged: (id) {
        if (id == null) return;
        final pkg = _packages.firstWhere((x) => x.packageID == id);
        _onPackageChanged(pkg);
      },
    );
  }

  Widget _buildDetectedInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CC)]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(BootstrapIcons.info_circle,
                  color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text('Auto-Detected',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildInfoChip(
                      'Type', _detectedCarType, BootstrapIcons.car_front_fill)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildInfoChip('Est. Time', '$_estimatedMinutes min',
                      BootstrapIcons.clock)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
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

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Appointment Date',
            style: TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSaving
              ? null
              : () async {
                  // ⭐ FIX: Store context before async gap
                  final pickerContext = context;

                  final DateTime? pickedDate = await showDatePicker(
                    context: pickerContext,
                    initialDate: _selectedDate ??
                        DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFFFFD700),
                            onPrimary: Colors.black,
                            surface: Color(0xFF1A1A1A),
                            onSurface: Color(0xFFFFD700),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null && mounted) {
                    setState(() {
                      _selectedDate = pickedDate;
                      // ⭐ ALSO RESET TIME when date changes
                      _selectedTime = null;
                    });
                  }
                },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.calendar3, color: Color(0xFFFFD700)),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!),
                  style: TextStyle(
                    color: _selectedDate == null
                        ? const Color(0xFFFFD700).withOpacity(0.4)
                        : const Color(0xFFFFD700),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Appointment Time',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            if (_estimatedMinutes > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700))),
                child: Text('Allow $_estimatedMinutes min',
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isSaving
              ? null
              : () async {
                  final now = TimeOfDay.now();
                  const openingTime = TimeOfDay(hour: 9, minute: 0);
                  const closingTime = TimeOfDay(hour: 19, minute: 0);

                  final todayStr =
                      DateFormat('yyyy-MM-dd').format(DateTime.now());
                  final selectedDateStr = _selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                      : todayStr;

                  final isToday = selectedDateStr == todayStr;

                  // Determine minimum time based on appointment type and date
                  TimeOfDay minTime;
                  if (_appointmentType == 'walk-in') {
                    minTime = now;
                  } else {
                    if (isToday) {
                      final nowMinutes = now.hour * 60 + now.minute;
                      final openingMinutes =
                          openingTime.hour * 60 + openingTime.minute;
                      minTime = nowMinutes > openingMinutes ? now : openingTime;
                    } else {
                      minTime = openingTime;
                    }
                  }

                  // ⭐ FIX: Properly await the dialog result
                  final TimeOfDay? selectedTime = await showDialog<TimeOfDay>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext dialogContext) =>
                        ThirtyMinuteTimePicker(
                      initialTime: _selectedTime ?? minTime,
                      minTime: minTime,
                      maxTime: closingTime,
                      isWalkIn: _appointmentType == 'walk-in',
                      appointmentDate: selectedDateStr,
                      branchID: widget.branchID,
                      estimatedDuration:
                          _estimatedMinutes > 0 ? _estimatedMinutes : 90,
                    ),
                  );

                  // ⭐ FIX: Check if time was selected
                  if (selectedTime != null) {
                    final selectionMinutes =
                        selectedTime.hour * 60 + selectedTime.minute;
                    final nowMinutes = now.hour * 60 + now.minute;
                    final closingMinutes =
                        closingTime.hour * 60 + closingTime.minute;

                    // Validate time selection
                    if (_appointmentType == 'walk-in' &&
                        isToday &&
                        selectionMinutes < nowMinutes) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Cannot select past time for walk-in.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    if (selectionMinutes >= closingMinutes) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Selected time is outside operating hours.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    // ⭐ FIX: Update state with selected time
                    setState(() {
                      _selectedTime = selectedTime;
                    });
                  }
                },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.clock, color: Color(0xFFFFD700)),
                const SizedBox(width: 12),
                Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : _formatTime(_selectedTime!),
                  style: TextStyle(
                    color: _selectedTime == null
                        ? const Color(0xFFFFD700).withOpacity(0.4)
                        : const Color(0xFFFFD700),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

    setState(() => _isSaving = true);

    try {
      final appointmentDate = _appointmentType == 'scheduled'
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      final hour = _selectedTime!.hour.toString().padLeft(2, '0');
      final minute = _selectedTime!.minute.toString().padLeft(2, '0');
      final appointmentTime = '$hour:$minute';

      // ⭐ The validation now happens INSIDE createAppointment with transaction
      await _appointmentService.createAppointment(
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        branchID: widget.branchID,
        vehicleBrand: _selectedBrand!.name,
        vehicleModel: _selectedVehicleModel!.name,
        vehicleType: _detectedCarType,
        vehiclePlate: _plateController.text.trim(),
        packageID: _selectedPackage!.packageID,
        packageName: _selectedPackage!.packageName,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        appointmentType: _appointmentType,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        totalPrice: _calculatedPrice,
        estimatedDuration: _estimatedMinutes,
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