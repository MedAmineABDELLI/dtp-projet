<?php
// Headers CORS - doivent être en premier
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Gérer les requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Log pour debug
error_log("Request received: " . $_SERVER['REQUEST_METHOD'] . " " . $_SERVER['REQUEST_URI']);

// Configuration de la base de données
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "employee_management";

// Test de connexion à la base de données
try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    error_log("Database connection successful");
} catch(PDOException $e) {
    error_log("Database connection failed: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur de connexion à la base de données',
        'debug' => $e->getMessage()
    ]);
    exit();
}

// Vérifier la méthode de requête
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'error' => 'Méthode non autorisée'
    ]);
    exit();
}

// Récupérer le paramètre de recherche
$searchQuery = isset($_GET['query']) ? trim($_GET['query']) : '';
error_log("Search query: " . $searchQuery);

if (empty($searchQuery)) {
    echo json_encode([
        'success' => true,
        'employees' => [],
        'count' => 0
    ]);
    exit();
}

try {
    // Préparer la requête SQL pour rechercher par nom ou ID
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
                training_points
            FROM employees 
            WHERE name LIKE :query OR id LIKE :query
            ORDER BY name ASC
            LIMIT 50";
    
    $stmt = $pdo->prepare($sql);
    $searchParam = "%$searchQuery%";
    $stmt->bindParam(':query', $searchParam, PDO::PARAM_STR);
    $stmt->execute();
    
    $employees = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $employees[] = [
            'id' => $row['id'],
            'name' => $row['name'],
            'birthDate' => $row['birth_date'],
            'firstAppointmentDate' => $row['first_appointment_date'],
            'currentAppointmentDate' => $row['current_appointment_date'],
            'position' => $row['position'],
            'degree' => (int)$row['degree'],
            'positionSeniorityPoints' => (float)$row['position_seniority_points'],
            'directorPoints' => (float)$row['director_points'],
            'trainingPoints' => (float)$row['training_points']
        ];
    }
    
    error_log("Found " . count($employees) . " employees");
    
    echo json_encode([
        'success' => true,
        'employees' => $employees,
        'count' => count($employees)
    ]);
    
} catch(PDOException $e) {
    error_log("Search error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Erreur lors de la recherche',
        'debug' => $e->getMessage()
    ]);
}
?>