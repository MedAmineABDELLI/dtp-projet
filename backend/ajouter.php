<?php
// add_employee.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Configuration de la base de données
class DatabaseConfig {
    private $host = 'localhost';
    private $db_name = 'employee_management';
    private $username = 'root';
    private $password = '';
    private $conn;

    public function getConnection() {
        $this->conn = null;
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name,
                $this->username,
                $this->password,
                array(PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8")
            );
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch(PDOException $e) {
            echo json_encode(array(
                'success' => false,
                'message' => 'Erreur de connexion: ' . $e->getMessage()
            ));
            exit();
        }
        return $this->conn;
    }
}

// Classe Employee pour la gestion des employés
class Employee {
    private $conn;
    private $table_name = "employees";

    // Propriétés de l'employé
    public $id;
    public $name;
    public $birth_date;
    public $first_appointment_date;
    public $current_appointment_date;
    public $position;
    public $degree;
    public $position_seniority_points;
    public $director_points;
    public $training_points;

    public function __construct($db) {
        $this->conn = $db;
    }

    // Méthode pour ajouter un employé
    public function addEmployee() {
        try {
            // Vérifier si l'ID existe déjà
            if ($this->employeeExists()) {
                return array(
                    'success' => false,
                    'message' => 'Un employé avec cet ID existe déjà'
                );
            }

            // Valider les données
            $validation = $this->validateData();
            if (!$validation['valid']) {
                return array(
                    'success' => false,
                    'message' => $validation['message']
                );
            }

            // Requête d'insertion
            $query = "INSERT INTO " . $this->table_name . " 
                     (id, name, birth_date, first_appointment_date, 
                      current_appointment_date, position, degree, 
                      position_seniority_points, director_points, training_points) 
                     VALUES 
                     (:id, :name, :birth_date, :first_appointment_date, 
                      :current_appointment_date, :position, :degree, 
                      :position_seniority_points, :director_points, :training_points)";

            $stmt = $this->conn->prepare($query);

            // Nettoyer et lier les valeurs
            $this->id = htmlspecialchars(strip_tags($this->id));
            $this->name = htmlspecialchars(strip_tags($this->name));
            $this->position = htmlspecialchars(strip_tags($this->position));

            $stmt->bindParam(":id", $this->id);
            $stmt->bindParam(":name", $this->name);
            $stmt->bindParam(":birth_date", $this->birth_date);
            $stmt->bindParam(":first_appointment_date", $this->first_appointment_date);
            $stmt->bindParam(":current_appointment_date", $this->current_appointment_date);
            $stmt->bindParam(":position", $this->position);
            $stmt->bindParam(":degree", $this->degree);
            $stmt->bindParam(":position_seniority_points", $this->position_seniority_points);
            $stmt->bindParam(":director_points", $this->director_points);
            $stmt->bindParam(":training_points", $this->training_points);

            if ($stmt->execute()) {
                return array(
                    'success' => true,
                    'message' => 'Employé ajouté avec succès',
                    'employee_id' => $this->id
                );
            } else {
                return array(
                    'success' => false,
                    'message' => 'Erreur lors de l\'ajout de l\'employé'
                );
            }

        } catch(PDOException $e) {
            return array(
                'success' => false,
                'message' => 'Erreur de base de données: ' . $e->getMessage()
            );
        }
    }

    // Vérifier si l'employé existe déjà
    private function employeeExists() {
        $query = "SELECT id FROM " . $this->table_name . " WHERE id = :id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $this->id);
        $stmt->execute();
        
        return $stmt->rowCount() > 0;
    }

    // Valider les données d'entrée
    private function validateData() {
        // Vérifier les champs obligatoires
        if (empty($this->id) || empty($this->name)) {
            return array('valid' => false, 'message' => 'ID et nom sont obligatoires');
        }

        // Valider le degré
        if ($this->degree < 1 || $this->degree > 12) {
            return array('valid' => false, 'message' => 'Le degré doit être entre 1 et 12');
        }

        // Valider les dates
        if (!$this->isValidDate($this->birth_date) || 
            !$this->isValidDate($this->first_appointment_date) || 
            !$this->isValidDate($this->current_appointment_date)) {
            return array('valid' => false, 'message' => 'Format de date invalide');
        }

        // Valider les points (doivent être numériques)
        if (!is_numeric($this->position_seniority_points) || 
            !is_numeric($this->director_points) || 
            !is_numeric($this->training_points)) {
            return array('valid' => false, 'message' => 'Les points doivent être numériques');
        }

        return array('valid' => true, 'message' => 'Données valides');
    }

    // Valider le format de date
    private function isValidDate($date) {
        $d = DateTime::createFromFormat('Y-m-d', $date);
        return $d && $d->format('Y-m-d') === $date;
    }
}

// Traitement de la requête POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Obtenir les données JSON
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    if ($data === null) {
        echo json_encode(array(
            'success' => false,
            'message' => 'Données JSON invalides'
        ));
        exit();
    }

    // Connexion à la base de données
    $database = new DatabaseConfig();
    $db = $database->getConnection();

    // Créer un objet Employee
    $employee = new Employee($db);

    // Assigner les valeurs
    $employee->id = $data['id'] ?? '';
    $employee->name = $data['name'] ?? '';
    $employee->birth_date = $data['birth_date'] ?? '';
    $employee->first_appointment_date = $data['first_appointment_date'] ?? '';
    $employee->current_appointment_date = $data['current_appointment_date'] ?? '';
    $employee->position = $data['position'] ?? '';
    $employee->degree = intval($data['degree'] ?? 1);
    $employee->position_seniority_points = floatval($data['position_seniority_points'] ?? 0.0);
    $employee->director_points = floatval($data['director_points'] ?? 0.0);
    $employee->training_points = floatval($data['training_points'] ?? 0.0);

    // Ajouter l'employé
    $result = $employee->addEmployee();
    echo json_encode($result);

} else {
    echo json_encode(array(
        'success' => false,
        'message' => 'Méthode non autorisée. Utilisez POST.'
    ));
}
?>