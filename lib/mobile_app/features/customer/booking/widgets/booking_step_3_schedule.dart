import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:intl/intl.dart';
import 'package:royal_tint/core/constants/app_strings.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/providers/customer_booking_provider.dart';

class BookingStep3Schedule extends StatelessWidget {
  const BookingStep3Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerBookingProvider>();
    const gold = Color(0xFFFFD700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Branch', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildBranchOption(context, 'melaka', AppStrings.melakaBranch),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBranchOption(context, 'seremban2', AppStrings.seremban2Branch),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const Text('Appointment Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime initDate = provider.selectedDate ?? DateTime.now();
            if (initDate.weekday == DateTime.sunday) {
              initDate = initDate.add(const Duration(days: 1));
            }
            
            DateTime firstDate = DateTime.now();
            if (firstDate.weekday == DateTime.sunday) {
              firstDate = firstDate.add(const Duration(days: 1));
            }

            final date = await showDatePicker(
              context: context,
              initialDate: initDate,
              firstDate: firstDate,
              lastDate: DateTime.now().add(const Duration(days: 365)),
              selectableDayPredicate: (date) => date.weekday != DateTime.sunday,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: gold,
                      onPrimary: Colors.black,
                      surface: Colors.black,
                      onSurface: gold,
                    ),
                    dialogTheme: const DialogThemeData(backgroundColor: Colors.black),
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.black,
                      labelStyle: TextStyle(color: gold),
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: gold)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold, width: 2)),
                    ),
                    textTheme: const TextTheme(
                      titleMedium: TextStyle(color: gold),
                      bodyLarge: TextStyle(color: gold),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              provider.selectDate(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: gold, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.calendar3, color: gold, size: 18),
                const SizedBox(width: 12),
                Text(
                  provider.selectedDate != null ? DateFormat('EEEE, MMM dd, yyyy').format(provider.selectedDate!) : 'Select Date',
                  style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (provider.selectedDate != null) ...[
          const Text('Available Time Slots', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          const SizedBox(height: 12),
          
          if (provider.isLoadingSlots)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: gold),
            ))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: provider.availableTimeSlots.map((time) {
                final isBusy = provider.isSlotBusy(time);
                return _buildTimeSlot(context, time, isBusy);
              }).toList(),
            ),
        ],
      ],
    );
  }

  Widget _buildTimeSlot(BuildContext context, String time, bool isBusy) {
    final provider = context.watch<CustomerBookingProvider>();
    const gold = Color(0xFFFFD700);
    
    final isSelected = provider.selectedTimeSlot == time;
    
    return GestureDetector(
      onTap: isBusy ? null : () => provider.selectTimeSlot(time),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(
            color: isBusy ? Colors.grey.withValues(alpha: 0.3) : (isSelected ? gold : Colors.grey.withValues(alpha: 0.5)),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          isBusy ? 'Busy' : time,
          style: TextStyle(
            color: isBusy ? Colors.grey : (isSelected ? gold : Colors.black),
            fontWeight: FontWeight.bold,
            fontSize: isBusy ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBranchOption(BuildContext context, String branchId, String name) {
    final provider = context.watch<CustomerBookingProvider>();
    const gold = Color(0xFFFFD700);
    final isSelected = provider.selectedBranch == branchId;
    
    return GestureDetector(
      onTap: () => provider.selectBranch(branchId),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: isSelected ? gold : Colors.grey, width: isSelected ? 3 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(BootstrapIcons.shop, color: isSelected ? gold : Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              name.replaceAll('Royal Tint ', ''),
              style: TextStyle(
                color: isSelected ? gold : Colors.white,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
