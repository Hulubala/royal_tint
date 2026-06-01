import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/core/constants/tint_constants.dart';

import 'package:royal_tint/data/repositories/customer_repository.dart';
import 'package:royal_tint/data/repositories/vehicle_repository.dart';
import 'package:royal_tint/data/services/appointment_service.dart';
import 'package:royal_tint/data/services/package_service.dart';
import 'package:royal_tint/data/services/notification_service.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/domain/models/user/customer_model.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerBookingProvider extends ChangeNotifier {
  final CustomerRepository _customerRepo = CustomerRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();
  final PackageService _packageService = PackageService();
  final AppointmentService _appointmentService = AppointmentService();

  bool isLoading = false;
  int currentStep = 0;
  
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final TextEditingController plateController = TextEditingController();

  CustomerModel? currentCustomer;

  // Step 1: Vehicle
  List<VehicleBrand> brands = [];
  VehicleBrand? selectedBrand;
  VehicleModel? selectedVehicleModel;
  String detectedCarType = '';
  int estimatedMinutes = 0;

  // Step 2: Package
  List<TintPackageModel> packages = [];
  TintPackageModel? selectedPackage;
  Map<String, String> tintSelections = {
    TintSections.frontWindScreen: '',
    TintSections.frontSideWindows: '',
    TintSections.rearPassenger: '',
    TintSections.rearWindscreen: '',
  };
  double calculatedPrice = 0.0;

  // Step 3: Schedule
  String selectedBranch = 'melaka';
  DateTime? selectedDate;
  String? selectedTimeSlot;
  List<String> availableTimeSlots = [];
  bool isLoadingSlots = false;
  List<AppointmentModel> bookedAppointments = [];

  AppointmentModel? editAppointment;

  @override
  void dispose() {
    plateController.dispose();
    super.dispose();
  }

  void setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  void setStep(int step) {
    currentStep = step;
    notifyListeners();
  }

  Future<void> loadInitialData(AppointmentModel? editApt) async {
    editAppointment = editApt;
    setLoading(true);
    try {
      currentCustomer = await _customerRepo.getCurrentCustomer();
      packages = await _packageService.getAllPackages();
      brands = await _vehicleRepo.getBrands();
      
      if (editAppointment != null) {
        await _prefillEditData();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> _prefillEditData() async {
    final apt = editAppointment!;
    plateController.text = apt.vehiclePlate;
    detectedCarType = apt.vehicleType;
    selectedBranch = apt.branchID;

    try {
      selectedBrand = brands.firstWhere((b) => b.name == apt.vehicleBrand);
      if (selectedBrand != null) {
        final models = await _vehicleRepo.getModelsByBrandKey(selectedBrand!.brandKey);
        selectedVehicleModel = models.firstWhere((m) => m.name == apt.vehicleModel);
      }
    } catch (_) {}

    try {
      selectedPackage = packages.firstWhere((p) => p.packageID == apt.packageID);
      tintSelections = apt.tintSelections;
      updatePrice();
    } catch (_) {}

    try {
      selectedDate = DateFormat('yyyy-MM-dd').parse(apt.appointmentDate);
      selectedTimeSlot = apt.appointmentTime;
      generateTimeSlots();
    } catch (_) {}
  }

  Stream<List<VehicleModel>> watchModelsByBrandKey(String brandKey) {
    return _vehicleRepo.watchModelsByBrandKey(brandKey);
  }

  void selectBrand(VehicleBrand brand) {
    selectedBrand = brand;
    selectedVehicleModel = null;
    detectedCarType = '';
    calculatedPrice = 0.0;
    notifyListeners();
  }

  void selectModel(VehicleModel model) {
    selectedVehicleModel = model;
    detectedCarType = model.type ?? '';
    updatePrice();
  }

  void selectPackage(TintPackageModel pkg) {
    selectedPackage = pkg;
    tintSelections = defaultTintSelectionsForPackage(pkg.packageName);
    updatePrice();
  }

  void updateTintSelection(String sectionKey, String value) {
    tintSelections[sectionKey] = value;
    notifyListeners();
  }

  void updatePrice() {
    if (detectedCarType.isNotEmpty) {
      if (packages.isNotEmpty) {
        final duration = packages.first.getDurationForVehicle(detectedCarType);
        if (duration > 0) estimatedMinutes = duration;
      }
      
      if (selectedPackage != null) {
        calculatedPrice = selectedPackage!.getPriceForVehicle(detectedCarType);
      }
    }
    notifyListeners();
  }

  void generateTimeSlots() {
    availableTimeSlots.clear();
    for (int h = 9; h < 18; h++) {
      availableTimeSlots.add('${h.toString().padLeft(2, '0')}:00');
      availableTimeSlots.add('${h.toString().padLeft(2, '0')}:30');
    }
    notifyListeners();
  }

  Future<void> fetchBusySlots() async {
    if (selectedDate == null) return;
    isLoadingSlots = true;
    notifyListeners();
    
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final allAppointments = await _appointmentService.getAppointmentsByDate(
        branchID: selectedBranch,
        date: dateStr,
      );
      
      if (editAppointment != null) {
        bookedAppointments = allAppointments.where((apt) => apt.appointmentID != editAppointment!.appointmentID).toList();
      } else {
        bookedAppointments = allAppointments;
      }
    } catch (_) {
      bookedAppointments = [];
    }
    isLoadingSlots = false;
    notifyListeners();
  }

  bool isSlotBusy(String time) {
    if (selectedDate == null) return false;
    
    // Check if time is in the past
    final now = DateTime.now();
    if (selectedDate!.year == now.year && selectedDate!.month == now.month && selectedDate!.day == now.day) {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (slotTime.isBefore(now.add(const Duration(hours: 1)))) {
        return true; // Consider past as busy
      }
    }

    // Check appointment service
    try {
      final duration = estimatedMinutes > 0 ? estimatedMinutes : 90;
      return !_appointmentService.canAcceptAppointment(bookedAppointments, time, duration);
    } catch (_) {
      return false;
    }
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    selectedTimeSlot = null;
    generateTimeSlots();
    fetchBusySlots();
  }

  void selectTimeSlot(String time) {
    selectedTimeSlot = time;
    notifyListeners();
  }

  void selectBranch(String branch) {
    selectedBranch = branch;
    notifyListeners();
  }

  bool isTintSelectionValid() {
    for (final key in tintSelections.keys) {
      if (tintSelections[key] == null || tintSelections[key]!.isEmpty) return false;
    }
    return true;
  }

  bool validateStep(int step) {
    if (step == 0) {
      return formKey1.currentState!.validate() && selectedBrand != null && selectedVehicleModel != null;
    } else if (step == 1) {
      return selectedPackage != null && isTintSelectionValid();
    } else if (step == 2) {
      return selectedDate != null && selectedTimeSlot != null;
    }
    return true;
  }

  Future<bool> submitBooking() async {
    if (currentCustomer == null || selectedBrand == null || selectedVehicleModel == null || selectedPackage == null || selectedDate == null || selectedTimeSlot == null) {
      return false;
    }

    setLoading(true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final isWalkIn = dateStr == todayStr;
      
      String? finalAppointmentID;

      // Helper function to handle identical appointment creation logic
      Future<String?> createNewAppointment() async {
        return await _appointmentService.createAppointment(
          customerName: currentCustomer!.name,
          customerPhone: currentCustomer!.phone,
          branchID: selectedBranch,
          vehicleBrand: selectedBrand!.name,
          vehicleModel: selectedVehicleModel!.name,
          vehicleType: detectedCarType,
          vehiclePlate: plateController.text.trim(),
          packageID: selectedPackage!.packageID,
          packageName: selectedPackage!.packageName,
          warranty: selectedPackage!.warranty,
          tintSelections: tintSelections,
          appointmentDate: dateStr,
          appointmentTime: selectedTimeSlot!,
          appointmentType: isWalkIn ? 'walk-in' : 'scheduled',
          totalPrice: calculatedPrice,
          estimatedDuration: estimatedMinutes,
        );
      }

      if (editAppointment != null) {
        final apt = editAppointment!;
        final aptId = apt.appointmentID;
        
        if (selectedBranch != apt.branchID) {
          // Cancel old appointment due to branch swap
          await _appointmentService.updateAppointmentStatus(
            appointmentID: aptId,
            newStatus: 'cancelled',
            isBranchSwap: true,
          );
          await NotificationService().notifyManagersAppointmentCancelled(
            branchID: apt.branchID,
            customerName: apt.customerName,
            appointmentDate: apt.appointmentDate,
            appointmentTime: apt.appointmentTime,
            appointmentID: aptId,
          );

          finalAppointmentID = await createNewAppointment();
        } else {
          // Update existing appointment in the same branch
          await _appointmentService.updateAppointment(
            appointmentID: aptId,
            customerName: currentCustomer!.name,
            customerPhone: currentCustomer!.phone,
            vehiclePlate: plateController.text.trim(),
            appointmentDate: dateStr,
            appointmentTime: selectedTimeSlot!,
            packageID: selectedPackage!.packageID,
            packageName: selectedPackage!.packageName,
            tintSelections: tintSelections,
          );
          
          await _appointmentService.updateAppointmentStatus(
            appointmentID: aptId,
            newStatus: 'pending',
          );
          finalAppointmentID = aptId;
        }
      } else {
        finalAppointmentID = await createNewAppointment();
      }

      if (finalAppointmentID != null) {
        await FirebaseFirestore.instance.collection('appointments').doc(finalAppointmentID).update({
          'customerID': currentCustomer!.uid,
        });

        await NotificationService().notifyManagersNewAppointment(
          branchID: selectedBranch,
          customerName: currentCustomer!.name,
          appointmentDate: dateStr,
          appointmentTime: selectedTimeSlot!,
          appointmentID: finalAppointmentID,
        );
      }

      resetForm();
      return true;
    } catch (e) {
      debugPrint('Booking failed: $e');
      if (e.toString().contains('TIME_SLOT_FULL')) {
        throw 'This time slot is fully booked. Please select another time.';
      }
      throw 'Failed to create booking.';
    } finally {
      setLoading(false);
    }
  }

  void resetForm() {
    currentStep = 0;
    selectedBrand = null;
    selectedVehicleModel = null;
    plateController.clear();
    selectedPackage = null;
    selectedDate = null;
    selectedTimeSlot = null;
    notifyListeners();
  }
}
