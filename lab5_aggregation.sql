USE bibliotheque;



SELECT COUNT(*) AS total_abonnes
FROM abonne;

SELECT AVG(nb) AS moyenne_emprunts
FROM (
  SELECT COUNT(*) AS nb
  FROM emprunt
  GROUP BY abonne_id
) AS sous;

SELECT AVG(prix_unitaire) AS prix_moyen
FROM ouvrage;


SELECT abonne_id, COUNT(*) AS nbre
FROM emprunt
GROUP BY abonne_id;

SELECT auteur_id, COUNT(*) AS total_ouvrages
FROM ouvrage
GROUP BY auteur_id;



SELECT abonne_id, COUNT(*) AS nbre
FROM emprunt
GROUP BY abonne_id
HAVING COUNT(*) >= 3;

SELECT auteur_id, COUNT(*) AS total_ouvrages
FROM ouvrage
GROUP BY auteur_id
HAVING COUNT(*) > 5;



SELECT a.nom, COUNT(e.id) AS emprunts
FROM abonne a
LEFT JOIN emprunt e ON e.abonne_id = a.id
GROUP BY a.id, a.nom;

SELECT au.nom, COUNT(e.id) AS total_emprunts
FROM auteur au
JOIN ouvrage o ON o.auteur_id = au.id
LEFT JOIN emprunt e ON e.ouvrage_id = o.id
GROUP BY au.id, au.nom;


SELECT 
  ROUND(
    COUNT(CASE WHEN e.id IS NOT NULL THEN 1 END) * 100
    / COUNT(DISTINCT o.id), 2
  ) AS pct_ouvrages_empruntes
FROM ouvrage o
LEFT JOIN emprunt e ON e.ouvrage_id = o.id;

SELECT a.nom, COUNT(*) AS nbre_emprunts
FROM abonne a
JOIN emprunt e ON e.abonne_id = a.id
GROUP BY a.id, a.nom
ORDER BY nbre_emprunts DESC
LIMIT 3;

WITH stats AS (
  SELECT o.auteur_id,
         COUNT(e.id) AS emprunts,
         COUNT(DISTINCT o.id) AS ouvrages
  FROM ouvrage o
  LEFT JOIN emprunt e ON e.ouvrage_id = o.id
  GROUP BY o.auteur_id
)
SELECT auteur_id,
       emprunts / ouvrages AS moyenne_emprunts
FROM stats
WHERE emprunts / ouvrages > 2;


CREATE INDEX idx_emprunt_abonne ON emprunt(abonne_id);

EXPLAIN
SELECT abonne_id, COUNT(*)
FROM emprunt
GROUP BY abonne_id;



SELECT DAYOFWEEK(date_debut) AS jour_semaine,
       COUNT(*) / COUNT(DISTINCT DATE(date_debut)) AS moyenne_emprunts
FROM emprunt
GROUP BY DAYOFWEEK(date_debut);

SELECT MONTH(date_debut) AS mois,
       COUNT(*) AS total_emprunts
FROM emprunt
WHERE YEAR(date_debut) = 2025
GROUP BY MONTH(date_debut)
ORDER BY mois;

SELECT COUNT(*) AS ouvrages_jamais_empruntes
FROM ouvrage o
LEFT JOIN emprunt e ON e.ouvrage_id = o.id
WHERE e.id IS NULL;

SELECT o.id, o.titre
FROM ouvrage o
LEFT JOIN emprunt e ON e.ouvrage_id = o.id
WHERE e.id IS NULL;
