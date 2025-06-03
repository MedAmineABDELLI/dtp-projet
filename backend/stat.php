<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Configuration de la base de données
$host = 'localhost';
$dbname = 'employee_management'; // Remplacez par le nom de votre base
$username = 'root';   // Remplacez par votre nom d'utilisateur
$password = '';  // Remplacez par votre mot de passe

try {
    // Connexion à la base de données
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Récupération de tous les employés
    $query = "SELECT * FROM employees ORDER BY name";
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $employees = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Initialisation des variables de statistiques
    $totalEmployees = count($employees);
    $eligibleEmployees = 0;
    $promotedEmployees = 0;
    $positionStats = [];
    $degreeStats = [];
    $ageGroupStats = [];
    $seniorityStats = [];
    $topPerformers = [];
    $promotionsByPosition = [];

    $totalAge = 0;
    $totalSeniority = 0;
    $totalPoints = 0;

    // Traitement de chaque employé
    foreach ($employees as $employee) {
        // Calcul de l'âge
        $birthDate = new DateTime($employee['birth_date']);
        $today = new DateTime();
        $age = $today->diff($birthDate)->y;
        $totalAge += $age;

        // Calcul de l'ancienneté totale (en années)
        $firstAppointmentDate = new DateTime($employee['first_appointment_date']);
        $seniorityYears = $today->diff($firstAppointmentDate)->y;
        $totalSeniority += $seniorityYears;

        // Calcul de l'ancienneté dans le poste actuel (en mois)
        $currentAppointmentDate = new DateTime($employee['current_appointment_date']);
        $currentPositionMonths = $today->diff($currentAppointmentDate)->days / 30;

        // Calcul du total des points
        $employeePoints = $employee['position_seniority_points'] + 
                         $employee['director_points'] + 
                         $employee['training_points'];
        $totalPoints += $employeePoints;

        // Vérification de l'éligibilité (2 ans minimum dans le poste actuel)
        $isEligible = $currentPositionMonths >= 24;
        if ($isEligible) {
            $eligibleEmployees++;
        }

        // Simulation de promotion (top 60% des éligibles par points)
        $employee['total_points'] = $employeePoints;
        $employee['age'] = $age;
        $employee['seniority_years'] = $seniorityYears;
        $employee['eligible'] = $isEligible;

        // Statistiques par poste
        $position = $employee['position'];
        if (!isset($positionStats[$position])) {
            $positionStats[$position] = [
                'total' => 0,
                'eligible' => 0,
                'promoted' => 0
            ];
        }
        $positionStats[$position]['total']++;
        if ($isEligible) {
            $positionStats[$position]['eligible']++;
        }

        // Statistiques par degré
        $degree = $employee['degree'];
        if (!isset($degreeStats[$degree])) {
            $degreeStats[$degree] = [
                'total' => 0,
                'eligible' => 0,
                'promoted' => 0
            ];
        }
        $degreeStats[$degree]['total']++;
        if ($isEligible) {
            $degreeStats[$degree]['eligible']++;
        }

        // Groupes d'âge
        $ageGroup = '';
        if ($age < 30) $ageGroup = '20-29';
        elseif ($age < 40) $ageGroup = '30-39';
        elseif ($age < 50) $ageGroup = '40-49';
        elseif ($age < 60) $ageGroup = '50-59';
        else $ageGroup = '60+';

        if (!isset($ageGroupStats[$ageGroup])) {
            $ageGroupStats[$ageGroup] = 0;
        }
        $ageGroupStats[$ageGroup]++;

        // Groupes d'ancienneté
        $seniorityGroup = '';
        if ($seniorityYears < 5) $seniorityGroup = '0-4';
        elseif ($seniorityYears < 10) $seniorityGroup = '5-9';
        elseif ($seniorityYears < 15) $seniorityGroup = '10-14';
        elseif ($seniorityYears < 20) $seniorityGroup = '15-19';
        else $seniorityGroup = '20+';

        if (!isset($seniorityStats[$seniorityGroup])) {
            $seniorityStats[$seniorityGroup] = 0;
        }
        $seniorityStats[$seniorityGroup]++;
    }

    // Tri des employés éligibles par points pour déterminer les promotions
    $eligibleEmployeesList = array_filter($employees, function($emp) {
        $currentAppointmentDate = new DateTime($emp['current_appointment_date']);
        $today = new DateTime();
        $currentPositionMonths = $today->diff($currentAppointmentDate)->days / 30;
        return $currentPositionMonths >= 24;
    });

    // Calcul du total des points pour chaque employé éligible
    foreach ($eligibleEmployeesList as &$emp) {
        $emp['total_points'] = $emp['position_seniority_points'] + 
                              $emp['director_points'] + 
                              $emp['training_points'];
    }

    // Tri par points décroissants
    usort($eligibleEmployeesList, function($a, $b) {
        return $b['total_points'] <=> $a['total_points'];
    });

    // Détermination des promotions (60% des éligibles)
    $promotionCount = (int)($eligibleEmployees * 0.6);
    $promotedEmployees = $promotionCount;

    // Top 10 performers
    $topPerformers = array_slice($eligibleEmployeesList, 0, 10);

    // Mise à jour des statistiques de promotion par poste et degré
    for ($i = 0; $i < $promotionCount && $i < count($eligibleEmployeesList); $i++) {
        $emp = $eligibleEmployeesList[$i];
        $positionStats[$emp['position']]['promoted']++;
        $degreeStats[$emp['degree']]['promoted']++;
    }

    // Calcul des taux de promotion par poste
    foreach ($positionStats as $position => $stats) {
        $rate = $stats['total'] > 0 ? ($stats['promoted'] / $stats['total']) * 100 : 0;
        $promotionsByPosition[$position] = [
            'rate' => $rate,
            'promoted' => $stats['promoted'],
            'total' => $stats['total']
        ];
    }

    // Calculs des moyennes
    $averageAge = $totalEmployees > 0 ? $totalAge / $totalEmployees : 0;
    $averageSeniority = $totalEmployees > 0 ? $totalSeniority / $totalEmployees : 0;
    $averagePoints = $totalEmployees > 0 ? $totalPoints / $totalEmployees : 0;
    $eligibilityRate = $totalEmployees > 0 ? ($eligibleEmployees / $totalEmployees) * 100 : 0;
    $promotionRate = $totalEmployees > 0 ? ($promotedEmployees / $totalEmployees) * 100 : 0;

    // Préparation de la réponse
    $response = [
        'success' => true,
        'data' => [
            'totalEmployees' => $totalEmployees,
            'eligibleEmployees' => $eligibleEmployees,
            'promotedEmployees' => $promotedEmployees,
            'promotionRate' => round($promotionRate, 2),
            'positionStats' => $positionStats,
            'degreeStats' => $degreeStats,
            'ageGroupStats' => $ageGroupStats,
            'seniorityStats' => $seniorityStats,
            'detailedAnalysis' => [
                'averageAge' => round($averageAge, 1),
                'averageSeniority' => round($averageSeniority, 1),
                'averagePoints' => round($averagePoints, 2),
                'eligibilityRate' => round($eligibilityRate, 2),
                'topPerformers' => array_map(function($emp) {
                    return [
                        'name' => $emp['name'],
                        'position' => $emp['position'],
                        'degree' => $emp['degree'],
                        'positionSeniorityPoints' => $emp['position_seniority_points'],
                        'directorPoints' => $emp['director_points'],
                        'trainingPoints' => $emp['training_points']
                    ];
                }, $topPerformers),
                'promotionsByPosition' => $promotionsByPosition
            ]
        ]
    ];

    echo json_encode($response, JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de base de données: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>