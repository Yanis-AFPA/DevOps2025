-- Script d'initialisation de la base de données

-- Suppression de la table si elle existe déjà
DROP TABLE IF EXISTS jeux;

-- Création de la table jeux
CREATE TABLE jeux (
    id SERIAL PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    plateforme VARCHAR(100) NOT NULL,
    genre VARCHAR(100) NOT NULL,
    annee_sortie INTEGER CHECK (annee_sortie >= 1980 AND annee_sortie <= 2030),
    note DECIMAL(3,1) CHECK (note >= 0 AND note <= 10),
    description TEXT,
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion de quelques données de test
INSERT INTO jeux (titre, plateforme, genre, annee_sortie, note, description) VALUES
('The Legend of Zelda: Breath of the Wild', 'Nintendo Switch', 'Aventure', 2017, 9.5, 'Un jeu d''aventure en monde ouvert révolutionnaire.'),
('God of War', 'PlayStation 4', 'Action', 2018, 9.3, 'L''histoire épique de Kratos et son fils Atreus.'),
('Elden Ring', 'PC', 'RPG', 2022, 9.2, 'Un RPG d''action développé par FromSoftware.'),
('Red Dead Redemption 2', 'Xbox One', 'Action', 2018, 9.7, 'Une épopée western en monde ouvert.'),
('Hades', 'Nintendo Switch', 'Aventure', 2020, 9.1, 'Un roguelike d''action dans l''univers de la mythologie grecque.');
