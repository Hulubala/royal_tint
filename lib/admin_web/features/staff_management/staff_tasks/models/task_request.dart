class TaskRequest {
  final String staffId;
  final String staffName;
  final String appointmentId;
  final String appointmentTitle;
  final String carInfo;
  final String mirrorSection;

  TaskRequest({
    required this.staffId,
    required this.staffName,
    required this.appointmentId,
    required this.appointmentTitle,
    required this.carInfo,
    required this.mirrorSection,
  });
}