USE bibliotheque;

WITH emprunts_2025 AS (
    SELECT 
        e.abonne_id,
        e.ouvrage_id,
        YEAR(e.date_debut) AS annee,
        MONTH(e.date_debut) AS mois
    FROM emprunt e
    WHERE YEAR(e.date_debut) = 2025
),
stats_mensuelles AS (
    SELECT 
        annee,
        mois,
        COUNT(*) AS total_emprunts,
        COUNT(DISTINCT abonne_id) AS abonnes_actifs,
        ROUND(COUNT(*) / COUNT(DISTINCT abonne_id), 2) AS moyenne_par_abonne
    FROM emprunts_2025
    GROUP BY annee, mois
),
top_ouvrages AS (
    SELECT
        e.annee,
        e.mois,
        e.ouvrage_id,
        COUNT(*) AS nb_emprunts,
        ROW_NUMBER() OVER (
            PARTITION BY e.annee, e.mois
            ORDER BY COUNT(*) DESC
        ) AS rang
    FROM emprunts_2025 e
    GROUP BY e.annee, e.mois, e.ouvrage_id
),
top3_ouvrages AS (
    SELECT
        t.annee,
        t.mois,
        GROUP_CONCAT(o.titre ORDER BY t.nb_emprunts DESC SEPARATOR ', ') AS top3_titres
    FROM top_ouvrages t
    JOIN ouvrage o ON o.id = t.ouvrage_id
    WHERE t.rang <= 3
    GROUP BY t.annee, t.mois
),
pct_ouvrages AS (
    SELECT
        e.annee,
        e.mois,
        ROUND(COUNT(DISTINCT e.ouvrage_id) * 100 / (SELECT COUNT(*) FROM ouvrage), 2) AS pct_empruntes
    FROM emprunts_2025 e
    GROUP BY e.annee, e.mois
)
SELECT 
    s.annee,
    s.mois,
    COALESCE(s.total_emprunts, 0) AS total_emprunts,
    COALESCE(s.abonnes_actifs, 0) AS abonnes_actifs,
    COALESCE(s.moyenne_par_abonne, 0) AS moyenne_par_abonne,
    COALESCE(p.pct_empruntes, 0) AS pct_ouvrages_empruntes,
    COALESCE(t.top3_titres, '') AS top3_ouvrages
FROM stats_mensuelles s
LEFT JOIN pct_ouvrages p
    ON p.annee = s.annee AND p.mois = s.mois
LEFT JOIN top3_ouvrages t
    ON t.annee = s.annee AND t.mois = s.mois
ORDER BY s.annee, s.mois;
