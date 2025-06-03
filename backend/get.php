<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Configuration de la base de données
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "employee_management";

try {
    // Connexion à la base de données
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Requête pour récupérer tous les employés
    $sql = "SELECT 
                id,
                name,
                birth_date,
                first_appointment_date,
                current_appointment_date,
                position,
                degree,
                position_seniority_points,
                director_points,
                training_points,
                created_at,
                updated_at
            FROM employees 
            ORDER BY position, degree, name";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    
    $employees = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Formatage des données pour Flutter
    $formattedEmployees = [];
    
    foreach ($employees as $employee) {
        $formattedEmployees[] = [
            'id' => $employee['id'],
            'name' => $employee['name'],
            'birthDate' => $employee['birth_date'],
            'firstAppointmentDate' => $employee['first_appointment_date'],
            'currentAppointmentDate' => $employee['current_appointment_date'],
            'position' => $employee['position'],
            'degree' => (int)$employee['degree'],
            'positionSeniorityPoints' => (float)$employee['position_seniority_points'],
            'directorPoints' => (float)$employee['director_points'],
            'trainingPoints' => (float)$employee['training_points'],
            'createdAt' => $employee['created_at'],
            'updatedAt' => $employee['updated_at']
        ];
    }
    
    // Retourner la réponse JSON
    echo json_encode([
        'success' => true,
        'data' => $formattedEmployees,
        'count' => count($formattedEmployees)
    ]);
    
} catch(PDOException $e) {
    // Gestion des erreurs
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur de base de données: ' . $e->getMessage()
    ]);
} catch(Exception $e) {
    // Gestion des autres erreurs
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur serveur: ' . $e->getMessage()
    ]);
}
?>