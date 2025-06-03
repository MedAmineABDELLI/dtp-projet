class Employee {
  final String id;
  final String name;
  final DateTime birthDate;
  final DateTime firstAppointmentDate;
  final DateTime currentAppointmentDate;
  final String position;
  final int degree;
  final double positionSeniorityPoints;
  final double directorPoints;
  final double trainingPoints;

  Employee({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.firstAppointmentDate,
    required this.currentAppointmentDate,
    required this.position,
    required this.degree,
    required this.positionSeniorityPoints,
    required this.directorPoints,
    required this.trainingPoints,
  });

  // Constructor pour créer un Employee à partir de JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      birthDate: DateTime.parse(json['birthDate']),
      firstAppointmentDate: DateTime.parse(json['firstAppointmentDate']),
      currentAppointmentDate: DateTime.parse(json['currentAppointmentDate']),
      position: json['position'] ?? '',
      degree: json['degree'] ?? 0,
      positionSeniorityPoints: (json['positionSeniorityPoints'] ?? 0.0).toDouble(),
      directorPoints: (json['directorPoints'] ?? 0.0).toDouble(),
      trainingPoints: (json['trainingPoints'] ?? 0.0).toDouble(),
    );
  }

  // Méthode pour convertir Employee en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'firstAppointmentDate': firstAppointmentDate.toIso8601String(),
      'currentAppointmentDate': currentAppointmentDate.toIso8601String(),
      'position': position,
      'degree': degree,
      'positionSeniorityPoints': positionSeniorityPoints,
      'directorPoints': directorPoints,
      'trainingPoints': trainingPoints,
    };
  }

  // Calcul du total des points
  double calculateTotalPoints() {
    return positionSeniorityPoints + directorPoints + trainingPoints;
  }

  // Calcul de l'ancienneté en mois depuis la première nomination
  int calculateSeniorityInMonths() {
    final now = DateTime.now();
    final difference = now.difference(firstAppointmentDate);
    return (difference.inDays / 30).round();
  }

  // Calcul de l'ancienneté dans le poste actuel en mois
  int calculateCurrentPositionSeniorityInMonths() {
    final now = DateTime.now();
    final difference = now.difference(currentAppointmentDate);
    return (difference.inDays / 30).round();
  }

  // Vérifier si l'employé est éligible pour une promotion
  bool isEligibleForPromotion() {
    // Conditions d'éligibilité (vous pouvez ajuster selon vos règles)
    final seniorityInMonths = calculateCurrentPositionSeniorityInMonths();
    final minimumSeniorityRequired = 24; // 2 ans minimum dans le poste
    
    return seniorityInMonths >= minimumSeniorityRequired;
  }

  // Calcul de l'âge actuel
  int calculateAge() {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() {
    return 'Employee{id: $id, name: $name, position: $position, degree: $degree, totalPoints: ${calculateTotalPoints()}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}