<?php
// Headers CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Gérer les requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configuration de la base de données
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "employee_management";

try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur de connexion à la base de données'
    ]);
    exit();
}

// Vérifier la méthode de requête
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'error' => 'Méthode non autorisée'
    ]);
    exit();
}

// Récupérer les données JSON
$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Données JSON invalides'
    ]);
    exit();
}

// Valider les données requises
$requiredFields = ['id', 'name', 'birth_date', 'first_appointment_date', 'current_appointment_date', 'position', 'degree'];
foreach ($requiredFields as $field) {
    if (!isset($data[$field]) || empty($data[$field])) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => "Le champ '$field' est requis"
        ]);
        exit();
    }
}

try {
    // Vérifier si l'employé existe
    $checkSql = "SELECT id FROM employees WHERE id = :id";
    $checkStmt = $pdo->prepare($checkSql);
    $checkStmt->bindParam(':id', $data['id']);
    $checkStmt->execute();
    
    if ($checkStmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'error' => 'Employé non trouvé'
        ]);
        exit();
    }

    // Préparer la requête de mise à jour
    $sql = "UPDATE employees SET 
                name = :name,
                birth_date = :birth_date,
                first_appointment_date = :first_appointment_date,
                current_appointment_date = :current_appointment_date,
                position = :position,
                degree = :degree,
                position_seniority_points = :position_seniority_points,
                director_points = :director_points,
                training_points = :training_points,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = :id";
    
    $stmt = $pdo->prepare($sql);
    
    // Lier les paramètres
    $stmt->bindParam(':id', $data['id']);
    $stmt->bindParam(':name', $data['name']);
    $stmt->bindParam(':birth_date', $data['birth_date']);
    $stmt->bindParam(':first_appointment_date', $data['first_appointment_date']);
    $stmt->bindParam(':current_appointment_date', $data['current_appointment_date']);
    $stmt->bindParam(':position', $data['position']);
    $stmt->bindParam(':degree', $data['degree'], PDO::PARAM_INT);
    
    // Paramètres optionnels avec valeurs par défaut
    $positionSeniorityPoints = isset($data['position_seniority_points']) ? floatval($data['position_seniority_points']) : 0.0;
    $directorPoints = isset($data['director_points']) ? floatval($data['director_points']) : 0.0;
    $trainingPoints = isset($data['training_points']) ? floatval($data['training_points']) : 0.0;
    
    $stmt->bindParam(':position_seniority_points', $positionSeniorityPoints);
    $stmt->bindParam(':director_points', $directorPoints);
    $stmt->bindParam(':training_points', $trainingPoints);
    
    // Exécuter la requête
    $stmt->execute();
    
    if ($stmt->rowCount() > 0) {
        // Récupérer l'employé mis à jour
        $selectSql = "SELECT 
                        id,
                        name,
                        birth_date,
                        first_appointment_date,
                        current_appointment_date,
                        position,
                        degree,
                        position_seniority_points,
                        director_points,
                        training_points
                      FROM employees 
                      WHERE id = :id";
        
        $selectStmt = $pdo->prepare($selectSql);
        $selectStmt->bindParam(':id', $data['id']);
        $selectStmt->execute();
        
        $updatedEmployee = $selectStmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'message' => 'Employé mis à jour avec succès',
            'employee' => [
                'id' => $updatedEmployee['id'],
                'name' => $updatedEmployee['name'],
                'birthDate' => $updatedEmployee['birth_date'],
                'firstAppointmentDate' => $updatedEmployee['first_appointment_date'],
                'currentAppointmentDate' => $updatedEmployee['current_appointment_date'],
                'position' => $updatedEmployee['position'],
                'degree' => (int)$updatedEmployee['degree'],
                'positionSeniorityPoints' => (float)$updatedEmployee['position_seniority_points'],
                'directorPoints' => (float)$updatedEmployee['director_points'],
                'trainingPoints' => (float)$updatedEmployee['training_points']
            ]
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'error' => 'Aucune modification effectuée'
        ]);
    }
    
} catch(PDOException $e) {
    error_log("Update error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur lors de la mise à jour'
    ]);
}
?>