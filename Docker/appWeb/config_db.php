<?php
// Configuration de la connexion à la base de données PostgreSQL pour Docker

$host = 'postgres'; // Nom du service Docker
$dbname = 'jeux_video_db';
$username = 'postgres';
$password = 'password123'; // Correspond à POSTGRES_PASSWORD dans docker-compose.yml

// Attendre que PostgreSQL soit prêt (max 30 secondes)
$max_attempts = 15;
$attempt = 0;
$connected = false;

while ($attempt < $max_attempts && !$connected) {
    try {
        $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        $connected = true;
    } catch(PDOException $e) {
        $attempt++;
        if ($attempt >= $max_attempts) {
            die("Erreur de connexion à la base de données : " . $e->getMessage());
        }
        sleep(2); // Attendre 2 secondes avant de réessayer
    }
}
?>