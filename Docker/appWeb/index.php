<?php
// Inclusion de la configuration de la base de données
require_once 'config_db.php';

$message = '';
$messageType = '';
$editMode = false;
$editData = null;

// Affichage des messages de succès après redirection
if (isset($_GET['success'])) {
    switch ($_GET['success']) {
        case 'create':
            $message = "✓ Le jeu a été ajouté avec succès !";
            $messageType = 'success';
            break;
        case 'update':
            $message = "✓ Le jeu a été modifié avec succès !";
            $messageType = 'success';
            break;
        case 'delete':
            $message = "✓ Le jeu a été supprimé avec succès !";
            $messageType = 'success';
            break;
    }
}

// Traitement des actions CRUD
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        if (isset($_POST['action'])) {
            switch ($_POST['action']) {
                case 'create':
                    // CREATE - Ajout d'un nouveau jeu
                    $stmt = $pdo->prepare("
                        INSERT INTO jeux (titre, plateforme, genre, annee_sortie, note, description) 
                        VALUES (:titre, :plateforme, :genre, :annee_sortie, :note, :description)
                    ");
                    $stmt->execute([
                        ':titre' => $_POST['titre'],
                        ':plateforme' => $_POST['plateforme'],
                        ':genre' => $_POST['genre'],
                        ':annee_sortie' => $_POST['annee_sortie'] ?: null,
                        ':note' => $_POST['note'] ?: null,
                        ':description' => $_POST['description']
                    ]);
                    // Redirection après ajout
                    header('Location: index.php?success=create');
                    exit();
                    break;

                case 'update':
                    // UPDATE - Modification d'un jeu existant
                    $stmt = $pdo->prepare("
                        UPDATE jeux 
                        SET titre = :titre, 
                            plateforme = :plateforme, 
                            genre = :genre, 
                            annee_sortie = :annee_sortie, 
                            note = :note, 
                            description = :description 
                        WHERE id = :id
                    ");
                    $stmt->execute([
                        ':titre' => $_POST['titre'],
                        ':plateforme' => $_POST['plateforme'],
                        ':genre' => $_POST['genre'],
                        ':annee_sortie' => $_POST['annee_sortie'] ?: null,
                        ':note' => $_POST['note'] ?: null,
                        ':description' => $_POST['description'],
                        ':id' => $_POST['id']
                    ]);
                    // Redirection après modification
                    header('Location: index.php?success=update');
                    exit();
                    break;

                case 'delete':
                    // DELETE - Suppression d'un jeu
                    $stmt = $pdo->prepare("DELETE FROM jeux WHERE id = :id");
                    $stmt->execute([':id' => $_POST['id']]);
                    // Redirection après suppression
                    header('Location: index.php?success=delete');
                    exit();
                    break;
            }
        }
    } catch(PDOException $e) {
        $message = "✗ Erreur : " . $e->getMessage();
        $messageType = 'error';
    }
}

// Mode édition - READ d'un jeu spécifique
if (isset($_GET['edit'])) {
    $editMode = true;
    $stmt = $pdo->prepare("SELECT * FROM jeux WHERE id = :id");
    $stmt->execute([':id' => $_GET['edit']]);
    $editData = $stmt->fetch();
    
    if (!$editData) {
        $message = "✗ Jeu introuvable.";
        $messageType = 'error';
        $editMode = false;
    }
}

// READ - Récupération de tous les jeux
$stmt = $pdo->query("SELECT * FROM jeux ORDER BY date_ajout DESC");
$jeux = $stmt->fetchAll();

// Listes pour les selects
$plateformes = ['PC', 'PlayStation 5', 'PlayStation 4', 'Xbox Series X/S', 'Xbox One', 'Nintendo Switch', 'Mobile'];
$genres = ['Action', 'Aventure', 'RPG', 'FPS', 'Stratégie', 'Sport', 'Course', 'Puzzle', 'Simulation', 'Horreur'];
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestionnaire de Jeux Vidéo - CRUD</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>🎮 Gestionnaire de Jeux Vidéo</h1>
        
        <?php if ($message): ?>
            <div class="message <?php echo $messageType; ?>">
                <?php echo htmlspecialchars($message); ?>
            </div>
        <?php endif; ?>

        <!-- Formulaire d'ajout/modification -->
        <div class="form-section">
            <h2><?php echo $editMode ? '✏️ Modifier un jeu' : '➕ Ajouter un nouveau jeu'; ?></h2>
            <form method="POST" action="">
                <input type="hidden" name="action" value="<?php echo $editMode ? 'update' : 'create'; ?>">
                <?php if ($editMode): ?>
                    <input type="hidden" name="id" value="<?php echo $editData['id']; ?>">
                <?php endif; ?>

                <div class="form-group">
                    <label for="titre">Titre du jeu *</label>
                    <input 
                        type="text" 
                        id="titre" 
                        name="titre" 
                        required 
                        value="<?php echo $editMode ? htmlspecialchars($editData['titre']) : ''; ?>"
                    >
                </div>

                <div class="form-group">
                    <label for="plateforme">Plateforme *</label>
                    <select id="plateforme" name="plateforme" required>
                        <option value="">-- Sélectionner une plateforme --</option>
                        <?php foreach ($plateformes as $p): ?>
                            <option value="<?php echo $p; ?>" 
                                <?php echo ($editMode && $editData['plateforme'] == $p) ? 'selected' : ''; ?>>
                                <?php echo $p; ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label for="genre">Genre *</label>
                    <select id="genre" name="genre" required>
                        <option value="">-- Sélectionner un genre --</option>
                        <?php foreach ($genres as $g): ?>
                            <option value="<?php echo $g; ?>" 
                                <?php echo ($editMode && $editData['genre'] == $g) ? 'selected' : ''; ?>>
                                <?php echo $g; ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label for="annee_sortie">Année de sortie</label>
                    <input 
                        type="number" 
                        id="annee_sortie" 
                        name="annee_sortie" 
                        min="1980" 
                        max="2030"
                        value="<?php echo $editMode ? $editData['annee_sortie'] : ''; ?>"
                    >
                </div>

                <div class="form-group">
                    <label for="note">Note (0-10)</label>
                    <input 
                        type="number" 
                        id="note" 
                        name="note" 
                        step="0.1" 
                        min="0" 
                        max="10"
                        value="<?php echo $editMode ? $editData['note'] : ''; ?>"
                    >
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description"><?php echo $editMode ? htmlspecialchars($editData['description']) : ''; ?></textarea>
                </div>

                <div class="form-actions">
                    <button type="submit">
                        <?php echo $editMode ? '💾 Modifier' : '➕ Ajouter'; ?>
                    </button>
                    <?php if ($editMode): ?>
                        <a href="index.php">
                            <button type="button" class="btn-cancel">✖ Annuler</button>
                        </a>
                    <?php endif; ?>
                </div>
            </form>
        </div>

        <!-- Liste des jeux -->
        <h2>📚 Collection de jeux (<?php echo count($jeux); ?>)</h2>
        
        <?php if (count($jeux) > 0): ?>
            <table>
                <thead>
                    <tr>
                        <th>Titre</th>
                        <th>Plateforme</th>
                        <th>Genre</th>
                        <th>Année</th>
                        <th>Note</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($jeux as $jeu): ?>
                    <tr>
                        <td><strong><?php echo htmlspecialchars($jeu['titre']); ?></strong></td>
                        <td><?php echo htmlspecialchars($jeu['plateforme']); ?></td>
                        <td><?php echo htmlspecialchars($jeu['genre']); ?></td>
                        <td><?php echo $jeu['annee_sortie'] ?: '-'; ?></td>
                        <td><?php echo $jeu['note'] ? $jeu['note'] . '/10 ⭐' : '-'; ?></td>
                        <td>
                            <div class="actions">
                                <a href="?edit=<?php echo $jeu['id']; ?>">
                                    <button class="btn-edit">✏️ Modifier</button>
                                </a>
                                <form method="POST" style="display: inline;" 
                                      onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer le jeu \'<?php echo htmlspecialchars($jeu['titre']); ?>\' ?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<?php echo $jeu['id']; ?>">
                                    <button type="submit" class="btn-delete">🗑️ Supprimer</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php else: ?>
            <div class="empty-state">
                <p>🎮 Aucun jeu dans la collection.</p>
                <p>Ajoutez votre premier jeu avec le formulaire ci-dessus !</p>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>
