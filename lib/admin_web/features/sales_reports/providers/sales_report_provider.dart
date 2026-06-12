import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/domain/models/tint_package_model.dart';
import 'package:royal_tint/data/services/package_service.dart';

class SalesReportProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<AppointmentModel> _allAppointments = [];
  List<TintPackageModel> _allPackages = [];
  bool _isLoading = false;
  String? _error;

  String _dateFilter = 'all';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String _selectedBrandFilter = 'All';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get dateFilter => _dateFilter;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  String get selectedBrandFilter => _selectedBrandFilter;

  // Change date filter
  void setDateFilter(String filter, {DateTime? startDate, DateTime? endDate}) {
    _dateFilter = filter;
    _customStartDate = startDate;
    _customEndDate = endDate;
    notifyListeners();
  }

  // Change brand filter
  void setBrandFilter(String brand) {
    _selectedBrandFilter = brand;
    notifyListeners();
  }

  String get dynamicPeriodLabel {
    final now = DateTime.now();
    if (_dateFilter == 'all') return 'All Time';
    if (_dateFilter == 'today') {
      return 'Today: ${DateFormat('dd/MM/yyyy').format(now)}';
    } else if (_dateFilter == 'this_week') {
      final startWeek = now.subtract(const Duration(days: 7));
      return 'This Week: ${DateFormat('dd/MM').format(startWeek)} - ${DateFormat('dd/MM/yyyy').format(now)}';
    } else if (_dateFilter == 'this_month') {
      return 'This Month: ${DateFormat('MMM yyyy').format(now)}';
    } else if (_dateFilter == 'select_month' && _customStartDate != null) {
      return DateFormat('MMM yyyy').format(_customStartDate!);
    } else if (_dateFilter == 'month_range' && _customStartDate != null && _customEndDate != null) {
      return '${DateFormat('MMM yyyy').format(_customStartDate!)} - ${DateFormat('MMM yyyy').format(_customEndDate!)}';
    } else if (_dateFilter == 'select_date' && _customStartDate != null) {
      return DateFormat('dd/MM/yyyy').format(_customStartDate!);
    } else if (_dateFilter == 'date_range' && _customStartDate != null && _customEndDate != null) {
      return '${DateFormat('dd/MM/yy').format(_customStartDate!)} - ${DateFormat('dd/MM/yy').format(_customEndDate!)}';
    }
    return '';
  }

  Future<void> loadSales(String branchID) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pkgService = PackageService();
      _allPackages = await pkgService.getAllPackages();

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
      final now = DateTime.now();

      if (_dateFilter == 'all') return true;
      if (_dateFilter == 'today') {
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } else if (_dateFilter == 'this_week') {
        return date.isAfter(now.subtract(const Duration(days: 7)));
      } else if (_dateFilter == 'this_month') {
        return date.year == now.year && date.month == now.month;
      } else if (_dateFilter == 'select_month' && _customStartDate != null) {
        return date.year == _customStartDate!.year && date.month == _customStartDate!.month;
      } else if (_dateFilter == 'month_range' && _customStartDate != null && _customEndDate != null) {
        final start = DateTime(_customStartDate!.year, _customStartDate!.month, 1);
        final end = DateTime(_customEndDate!.year, _customEndDate!.month + 1, 0, 23, 59, 59);
        return date.isAfter(start) && date.isBefore(end);
      } else if (_dateFilter == 'select_date' && _customStartDate != null) {
        return date.year == _customStartDate!.year && date.month == _customStartDate!.month && date.day == _customStartDate!.day;
      } else if (_dateFilter == 'date_range' && _customStartDate != null && _customEndDate != null) {
        final start = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
        final end = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day, 23, 59, 59);
        return date.isAfter(start) && date.isBefore(end);
      }
      return true;
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
    for (var pkg in _allPackages) {
      map[pkg.packageName] = 0.0;
    }
    for (var app in filteredSales) {
      map[app.packageName] = (map[app.packageName] ?? 0) + app.totalPrice;
    }
    var entries = map.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(entries);
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
    
    if (_dateFilter == 'today' || _dateFilter == 'select_date') {
      for (int i = 9; i <= 18; i++) {
        map['$i:00'] = 0;
      }
      for (var app in filteredSales) {
        final h = app.appointmentDateTime.hour;
        if (h >= 9 && h <= 18) {
          map['$h:00'] = (map['$h:00'] ?? 0) + app.totalPrice;
        }
      }
    } else if (_dateFilter == 'this_week') {
      final now = DateTime.now();
      // Use the last 7 days ending today, to perfectly match filteredSales logic
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final label = DateFormat('E dd/MM').format(day);
        map[label] = 0;
      }
      for (var app in filteredSales) {
        final label = DateFormat('E dd/MM').format(app.appointmentDateTime);
        if (map.containsKey(label)) {
          map[label] = (map[label] ?? 0) + app.totalPrice;
        }
      }
    } else if (_dateFilter == 'this_month' || _dateFilter == 'select_month') {
      final targetDate = _dateFilter == 'this_month' ? DateTime.now() : (_customStartDate ?? DateTime.now());
      final daysInMonth = DateUtils.getDaysInMonth(targetDate.year, targetDate.month);
      for (int i = 1; i <= daysInMonth; i++) {
        map['$i'] = 0;
      }
      for (var app in filteredSales) {
        final d = app.appointmentDateTime.day;
        map['$d'] = (map['$d'] ?? 0) + app.totalPrice;
      }
    } else if (_dateFilter == 'month_range') {
      if (_customStartDate != null && _customEndDate != null) {
        DateTime current = DateTime(_customStartDate!.year, _customStartDate!.month, 1);
        final end = DateTime(_customEndDate!.year, _customEndDate!.month, 1);
        while (!current.isAfter(end)) {
          final label = DateFormat('MMM yy').format(current);
          map[label] = 0;
          current = DateTime(current.year, current.month + 1, 1);
        }
        for (var app in filteredSales) {
          final label = DateFormat('MMM yy').format(app.appointmentDateTime);
          if (map.containsKey(label)) {
            map[label] = (map[label] ?? 0) + app.totalPrice;
          }
        }
      }
    } else if (_dateFilter == 'date_range') {
      if (_customStartDate != null && _customEndDate != null) {
        DateTime current = DateTime(_customStartDate!.year, _customStartDate!.month, _customStartDate!.day);
        final end = DateTime(_customEndDate!.year, _customEndDate!.month, _customEndDate!.day);
        while (!current.isAfter(end)) {
          final label = DateFormat('dd/MM').format(current);
          map[label] = 0;
          current = current.add(const Duration(days: 1));
        }
        for (var app in filteredSales) {
          final label = DateFormat('dd/MM').format(app.appointmentDateTime);
          if (map.containsKey(label)) {
            map[label] = (map[label] ?? 0) + app.totalPrice;
          }
        }
      }
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (var m in months) {
        map[m] = 0;
      }
      for (var app in filteredSales) {
        final mStr = months[app.appointmentDateTime.month - 1];
        map[mStr] = (map[mStr] ?? 0) + app.totalPrice;
      }
    }
    
    return map.entries.toList();
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
