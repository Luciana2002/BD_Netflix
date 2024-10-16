USE netflix

-----------------------------------------------------------
---------------- Consultas de virificacion ---------------- 
-----------------------------------------------------------

-- 1) Cantidad de directores con mas de 10 películas o series dirigidas

SELECT d.nombre_apellido, COUNT(sd.id_show) AS 'Cantidad Películas o Series'
FROM show_director sd
INNER JOIN director d ON d.id_director = sd.id_director
GROUP BY d.nombre_apellido
HAVING COUNT(sd.id_show) > 10
ORDER BY COUNT(sd.id_show) DESC

-- Verificacion utilizando la tabla netflix_titles --
SELECT TRIM(d.value) AS director, COUNT(nt.title) AS total_titulos
FROM netflix_titles nt
CROSS APPLY STRING_SPLIT(nt.director, ',') AS d
WHERE nt.director IS NOT NULL   
GROUP BY TRIM(d.value)           
HAVING COUNT(nt.title) > 10 
ORDER BY total_titulos DESC       

-- 2) El actor con mayor participación en películas o series

SELECT TOP 1 a.nombre_apellido, COUNT(e.id_show) AS 'Cantidad Películas o Series'
FROM elenco e
INNER JOIN actor a ON a.id_actor = e.id_actor
GROUP BY a.nombre_apellido
HAVING COUNT(e.id_show) > 10
ORDER BY COUNT(e.id_show) DESC

-- Verificacion utilizando la tabla netflix_titles --
SELECT TOP 1 TRIM(a.value) AS actor, COUNT(nt.title) AS total_titulos
FROM netflix_titles nt
CROSS APPLY STRING_SPLIT(nt.cast, ',') AS a
WHERE nt.cast IS NOT NULL   
GROUP BY TRIM(a.value)           
HAVING COUNT(nt.title) > 10 
ORDER BY total_titulos DESC  

-- 3) Cantidad de series añadidas en los últimos cinco años

SELECT COUNT(*) AS 'Cantidad de Series en los últimos cinco años'
FROM Show 
WHERE año_lanzamiento >= YEAR(GETDATE()) - 5

-- Verificacion utilizando la tabla netflix_titles --
SELECT COUNT(*) AS cantidad_series_peliculas
FROM netflix_titles
WHERE  release_year >= YEAR(GETDATE()) - 5