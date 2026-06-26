class Appointment {
  final int id;
  final int weekNumber;
  final String title;
  final String description;
  final String appointmentType;

  Appointment({
    required this.id,
    required this.weekNumber,
    required this.title,
    required this.description,
    required this.appointmentType,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      weekNumber: json['week_number'],
      title: json['title'],
      description: json['description'] ?? '',
      appointmentType: json['appointment_type'] ?? '',
    );
  }
}