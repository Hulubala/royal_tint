import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:intl/intl.dart';

enum ReportPeriod { daily, monthly, yearly }

class SalesReportProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<AppointmentModel> _allAppointments = [];
  bool _isLoading = false;
  String? _error;

  ReportPeriod _selectedPeriod = ReportPeriod.monthly;
  DateTime _selectedDate = DateTime.now();
  String _selectedBrandFilter = 'All';

  bool get isLoading => _isLoading;
  String? get error => _error;
  ReportPeriod get selectedPeriod => _selectedPeriod;
  DateTime get selectedDate => _selectedDate;
  String get selectedBrandFilter => _selectedBrandFilter;

  // Change period
  void setPeriod(ReportPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  // Change brand filter
  void setBrandFilter(String brand) {
    _selectedBrandFilter = brand;
    notifyListeners();
  }

  // Change selected date (used for daily/monthly/yearly navigation)
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  void navigatePrevious() {
    if (_selectedPeriod == ReportPeriod.daily) {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    } else if (_selectedPeriod == ReportPeriod.monthly) {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    } else {
      _selectedDate = DateTime(_selectedDate.year - 1, 1, 1);
    }
    notifyListeners();
  }

  void navigateNext() {
    if (_selectedPeriod == ReportPeriod.daily) {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    } else if (_selectedPeriod == ReportPeriod.monthly) {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    } else {
      _selectedDate = DateTime(_selectedDate.year + 1, 1, 1);
    }
    notifyListeners();
  }

  String get periodLabel {
    if (_selectedPeriod == ReportPeriod.daily) {
      return DateFormat('dd MMM yyyy').format(_selectedDate);
    } else if (_selectedPeriod == ReportPeriod.monthly) {
      return DateFormat('MMMM yyyy').format(_selectedDate);
    } else {
      return DateFormat('yyyy').format(_selectedDate);
    }
  }

  Future<void> loadSales(String branchID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all completed appointments for the branch
      final snapshot = await _firestore
          .collection('appointments')
          .where('branchID', isEqualTo: branchID)
          .where('status', isEqualTo: 'completed')
          .get();

      _allAppointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AppointmentModel> get filteredSales {
    return _allAppointments.where((app) {
      final date = app.appointmentDateTime;
      if (_selectedPeriod == ReportPeriod.daily) {
        return date.year == _selectedDate.year &&
               date.month == _selectedDate.month &&
               date.day == _selectedDate.day;
      } else if (_selectedPeriod == ReportPeriod.monthly) {
        return date.year == _selectedDate.year &&
               date.month == _selectedDate.month;
      } else {
        return date.year == _selectedDate.year;
      }
    }).toList();
  }

  double get totalSales {
    return filteredSales.fold(0.0, (currentTotal, app) => currentTotal + app.totalPrice);
  }

  int get totalCompletedAppointments {
    return filteredSales.length;
  }

  // --- Data Breakdowns ---

  Map<String, double> get salesByPackage {
    final map = <String, double>{};
    for (var app in filteredSales) {
      map[app.packageName] = (map[app.packageName] ?? 0) + app.totalPrice;
    }
    return _sortMapDesc(map);
  }

  Map<String, int> get countByCarBrand {
    final map = <String, int>{};
    for (var app in filteredSales) {
      final brand = app.vehicleBrand.isEmpty ? 'Unknown' : app.vehicleBrand;
      map[brand] = (map[brand] ?? 0) + 1;
    }
    return _sortMapDescInt(map);
  }
  
  List<String> get availableBrands {
    final brands = <String>{};
    for (var app in filteredSales) {
      if (app.vehicleBrand.isNotEmpty) {
        brands.add(app.vehicleBrand);
      }
    }
    final sorted = brands.toList()..sort();
    sorted.insert(0, 'All');
    return sorted;
  }

  Map<String, int> get countByCarModel {
    final map = <String, int>{};
    for (var app in filteredSales) {
      if (_selectedBrandFilter != 'All') {
        if (app.vehicleBrand != _selectedBrandFilter) continue;
      }
      final model = app.vehicleModel.isEmpty ? 'Unknown' : app.vehicleModel;
      map[model] = (map[model] ?? 0) + 1;
    }
    return _sortMapDescInt(map);
  }

  // --- Chart Data ---
  
  // Returns List of MapEntry where key is label (e.g. "1", "2" for days, or "Jan" for months)
  // and value is the total sales for that period.
  List<MapEntry<String, double>> get chartData {
    final map = <String, double>{};
    
    if (_selectedPeriod == ReportPeriod.daily) {
      // Group by hour
      for (int i = 9; i <= 18; i++) {
        map['$i:00'] = 0;
      }
      for (var app in filteredSales) {
        final h = app.appointmentDateTime.hour;
        if (h >= 9 && h <= 18) {
          map['$h:00'] = (map['$h:00'] ?? 0) + app.totalPrice;
        }
      }
      return map.entries.toList();
    } 
    else if (_selectedPeriod == ReportPeriod.monthly) {
      // Group by day of month
      final daysInMonth = DateUtils.getDaysInMonth(_selectedDate.year, _selectedDate.month);
      for (int i = 1; i <= daysInMonth; i++) {
        map['$i'] = 0;
      }
      for (var app in filteredSales) {
        final d = app.appointmentDateTime.day;
        map['$d'] = (map['$d'] ?? 0) + app.totalPrice;
      }
      return map.entries.toList();
    } 
    else {
      // Group by month
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (var m in months) {
        map[m] = 0;
      }
      for (var app in filteredSales) {
        final mStr = months[app.appointmentDateTime.month - 1];
        map[mStr] = (map[mStr] ?? 0) + app.totalPrice;
      }
      return map.entries.toList();
    }
  }

  Map<String, double> _sortMapDesc(Map<String, double> map) {
    var entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  Map<String, int> _sortMapDescInt(Map<String, int> map) {
    var entries = map.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }
}
