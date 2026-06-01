import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';

class AppointmentProvider extends ChangeNotifier {
  // data
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<AppointmentModel>>? _subscription;

  // filters
  String _selectedType = 'all';     // all / walk-in / scheduled
  String _selectedStatus = 'all';   // all / pending / confirmed / completed / cancelled ...
  String _dateFilter = 'all';       // all / today / tomorrow / week / month / custom / range
  String _searchQuery = '';
  DateTime? _customDate;
  DateTime? _startDate;
  DateTime? _endDate;

  // getters
  List<AppointmentModel> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get selectedType => _selectedType;
  String get selectedStatus => _selectedStatus;
  String get dateFilter => _dateFilter;
  String get searchQuery => _searchQuery;
  DateTime? get customDate => _customDate;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // setters (state)
  void setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void setError(String? v) { _error = v; notifyListeners(); }
  void setAppointments(List<AppointmentModel> v) { _appointments = v; notifyListeners(); }

  void setSubscription(StreamSubscription<List<AppointmentModel>> sub) {
    _subscription?.cancel();
    _subscription = sub;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // setters (filters)
  void setSelectedType(String v) { _selectedType = v; notifyListeners(); }
  void setSelectedStatus(String v) { _selectedStatus = v; notifyListeners(); }
  void setDateFilter(String v) { _dateFilter = v; notifyListeners(); }
  void setSearchQuery(String v) { _searchQuery = v; notifyListeners(); }
  void setCustomDate(DateTime? v) { _customDate = v; notifyListeners(); }
  void setDateRange(DateTime? start, DateTime? end) { _startDate = start; _endDate = end; notifyListeners(); }

  void resetFilters() {
    _selectedType = 'all';
    _selectedStatus = 'all';
    _dateFilter = 'all';
    _searchQuery = '';
    _customDate = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<AppointmentModel> get filteredAppointments {
    final now = DateTime.now();

    return _appointments.where((apt) {
      // type
      if (_selectedType != 'all' && apt.appointmentType.toLowerCase() != _selectedType) {
        return false;
      }

      // status
      if (_selectedStatus != 'all' && apt.status.toLowerCase() != _selectedStatus) {
        return false;
      }

      // search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final qNumeric = _searchQuery.replaceAll(RegExp(r'[^0-9]'), '');
        
        bool matches = apt.customerName.toLowerCase().contains(q) ||
            apt.vehiclePlate.toLowerCase().contains(q) ||
            apt.vehicleModel.toLowerCase().contains(q);
            
        if (!matches && apt.customerPhone != null) {
          final phoneNumeric = apt.customerPhone!.replaceAll(RegExp(r'[^0-9]'), '');
          if (qNumeric.isNotEmpty && phoneNumeric.contains(qNumeric)) {
            matches = true;
          } else {
            matches = apt.customerPhone!.toLowerCase().contains(q);
          }
        }

        if (!matches) return false;
      }

      // date filter
      if (_dateFilter != 'all') {
        final aptDate = DateTime.parse(apt.appointmentDate);

        switch (_dateFilter) {
          case 'today':
            if (!_isSameDay(aptDate, now)) return false;
            break;
          case 'tomorrow':
            if (!_isSameDay(aptDate, now.add(const Duration(days: 1)))) return false;
            break;
          case 'week':
            if (aptDate.isBefore(now) || aptDate.isAfter(now.add(const Duration(days: 7)))) return false;
            break;
          case 'month':
            if (aptDate.month != now.month || aptDate.year != now.year) return false;
            break;
          case 'custom':
            if (_customDate != null && !_isSameDay(aptDate, _customDate!)) return false;
            break;
          case 'range':
            if (_startDate != null && _endDate != null) {
              if (aptDate.isBefore(_startDate!) || aptDate.isAfter(_endDate!)) return false;
            }
            break;
        }
      }

      return true;
    }).toList();
  }

  Map<String, int> get stats {
    int countWhere(String s) => _appointments.where((a) => a.status.toLowerCase() == s).length;

    return {
      'total': _appointments.length,
      'pending': countWhere('pending'),
      'confirmed': countWhere('confirmed'),
      'in-progress': countWhere('in-progress'),
      'completed': countWhere('completed'),
      'cancelled': countWhere('cancelled'),
    };
  }
}