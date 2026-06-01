import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:royal_tint/domain/models/appointment_model.dart';
import 'package:royal_tint/mobile_app/features/customer/main/widgets/customer_header.dart';
import 'package:royal_tint/mobile_app/features/customer/main/screens/customer_main_screen.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/providers/customer_booking_provider.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/widgets/booking_step_1_vehicle.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/widgets/booking_step_2_package.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/widgets/booking_step_3_schedule.dart';
import 'package:royal_tint/mobile_app/features/customer/booking/widgets/booking_step_4_review.dart';

class CustomerBookingScreen extends StatelessWidget {
  final AppointmentModel? editAppointment;

  const CustomerBookingScreen({super.key, this.editAppointment});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerBookingProvider()..loadInitialData(editAppointment),
      child: _CustomerBookingView(editAppointment: editAppointment),
    );
  }
}

class _CustomerBookingView extends StatelessWidget {
  final AppointmentModel? editAppointment;

  const _CustomerBookingView({this.editAppointment});

  static const _bg = Colors.white;
  static const _surface = Colors.black;
  static const _gold = Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerBookingProvider>();

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          CustomerHeader(
            title: editAppointment == null ? 'Book Appointment' : 'Edit Appointment',
            onBack: editAppointment != null ? () => Navigator.pop(context) : null,
          ),
          Expanded(
            child: provider.isLoading && provider.currentCustomer == null
                ? const Center(child: CircularProgressIndicator(color: _gold))
                : Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.transparent,
                      colorScheme: const ColorScheme.dark(
                        primary: _gold,
                        onPrimary: Colors.black,
                      ),
                    ),
                    child: Stepper(
                      type: StepperType.vertical,
                      currentStep: provider.currentStep,
                      stepIconBuilder: (stepIndex, stepState) {
                        return Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: _gold, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              stepState == StepState.complete ? '✓' : '${stepIndex + 1}',
                              style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                      onStepContinue: () async {
                        if (provider.currentStep < 3) {
                          if (provider.validateStep(provider.currentStep)) {
                            provider.setStep(provider.currentStep + 1);
                          } else {
                            String msg = 'Please complete all details';
                            if (provider.currentStep == 0) msg = 'Please complete all vehicle details';
                            if (provider.currentStep == 1) msg = 'Please select a package and all tint darknesses';
                            if (provider.currentStep == 2) msg = 'Please select a date and time slot';
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
                          }
                        } else if (provider.currentStep == 3) {
                          try {
                            final success = await provider.submitBooking();
                            if (success && context.mounted) {
                              _showSuccessDialog(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                            }
                          }
                        }
                      },
                      onStepCancel: () {
                        if (provider.currentStep > 0) {
                          provider.setStep(provider.currentStep - 1);
                        }
                      },
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: provider.isLoading ? null : details.onStepContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _surface,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: provider.isLoading && provider.currentStep == 3
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: _gold, strokeWidth: 2))
                                      : Text(
                                          provider.currentStep == 3 ? 'CONFIRM BOOKING' : 'CONTINUE',
                                          style: const TextStyle(color: _gold, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                              if (provider.currentStep > 0) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: provider.isLoading ? null : details.onStepCancel,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: const BorderSide(color: _surface),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('BACK', style: TextStyle(color: _surface, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                      steps: [
                        Step(
                          title: const Text('Vehicle Details', style: TextStyle(fontWeight: FontWeight.bold)),
                          isActive: provider.currentStep >= 0,
                          state: provider.currentStep > 0 ? StepState.complete : StepState.indexed,
                          content: const BookingStep1Vehicle(),
                        ),
                        Step(
                          title: const Text('Package Selection', style: TextStyle(fontWeight: FontWeight.bold)),
                          isActive: provider.currentStep >= 1,
                          state: provider.currentStep > 1 ? StepState.complete : StepState.indexed,
                          content: const BookingStep2Package(),
                        ),
                        Step(
                          title: const Text('Date & Branch', style: TextStyle(fontWeight: FontWeight.bold)),
                          isActive: provider.currentStep >= 2,
                          state: provider.currentStep > 2 ? StepState.complete : StepState.indexed,
                          content: const BookingStep3Schedule(),
                        ),
                        Step(
                          title: const Text('Review & Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                          isActive: provider.currentStep >= 3,
                          content: const BookingStep4Review(),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: _gold, width: 2)),
        title: const Row(
          children: [
            Icon(BootstrapIcons.check_circle_fill, color: Colors.green),
            SizedBox(width: 10),
            Text('Booking Successful', style: TextStyle(color: _gold)),
          ],
        ),
        content: const Text(
          'Your appointment has been successfully requested. You will receive a notification once the manager confirms it.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                CustomerMainScreen.changeTab(context, 0);
              },
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
      ),
    );
  }
}
