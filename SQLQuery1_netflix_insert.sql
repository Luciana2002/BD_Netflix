USE netflix

-- Insertar cada dato de la tabla netflix_titles dentro de las tablas definidas -- 

---------------------
-- Tabla Tipo_show --
---------------------

INSERT INTO tipo_show (descripcion)
SELECT DISTINCT type
FROM netflix_titles

select * from tipo_show

------------------
-- Tabla Rating --
------------------

INSERT INTO rating (descripcion)
SELECT DISTINCT rating
FROM netflix_titles
WHERE rating IS NOT NULL

select * from rating

----------------
-- Tabla Pais --
----------------

INSERT INTO pais (descripcion)
SELECT DISTINCT TRIM(value) AS descripcion
FROM netflix_titles
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL AND TRIM(value) <> ''
ORDER BY descripcion ASC

select * from pais

---------------------
-- Tabla Categoría --
---------------------

INSERT INTO categoria (descripcion)
SELECT DISTINCT TRIM(value) AS descripcion
FROM netflix_titles
CROSS APPLY STRING_SPLIT(listed_in, ',')
WHERE listed_in IS NOT NULL
ORDER BY descripcion ASC

select * from categoria

-----------------
-- Tabla Actor --
-----------------

INSERT INTO actor (nombre_apellido)
SELECT DISTINCT TRIM(value) AS nombre_apellido
FROM netflix_titles
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE cast IS NOT NULL
ORDER BY nombre_apellido ASC

select * from actor

--------------------
-- Tabla Director --
--------------------

INSERT INTO director (nombre_apellido)
SELECT DISTINCT TRIM(value) AS nombre_apellido
FROM netflix_titles
CROSS APPLY STRING_SPLIT(director, ',')
WHERE director IS NOT NULL
ORDER BY nombre_apellido ASC

select * from director

----------------
-- Tabla Show --
----------------

INSERT INTO Show (id_show, titulo, fecha_salida, duracion, año_lanzamiento, descripcion, id_tipo, id_rating)
SELECT show_id, 
	   title, 
       date_added, 
       duration, 
       release_year, 
       description,
       (SELECT id_tipo FROM tipo_show WHERE descripcion = netflix_titles.type),
       (SELECT id_rating FROM rating WHERE descripcion = netflix_titles.rating)
FROM netflix_titles;

select * from Show

------------------------------------------------------------
---------------- INSERTS Tablas intermedias ----------------
------------------------------------------------------------

-------------------------
-- Tabla Show_director --
-------------------------

INSERT INTO show_director (id_director, id_show)
SELECT DISTINCT
	d.id_director, 
	n.show_id
FROM netflix_titles n
CROSS APPLY STRING_SPLIT(n.director, ',') AS s
JOIN director d ON TRIM(s.value) = d.nombre_apellido

select * from show_director

---------------------
-- Tabla Show_pais --
---------------------

INSERT INTO show_pais (id_pais, id_show)
SELECT DISTINCT
	p.id_pais, 
	n.show_id
FROM netflix_titles n
CROSS APPLY STRING_SPLIT(n.country, ',') AS s
JOIN pais p ON TRIM(s.value) = p.descripcion

select * from show_pais

--------------------------
-- Tabla Show_categoria --
--------------------------

INSERT INTO show_categoria (id_categoria, id_show)
SELECT DISTINCT
	c.id_categoria, 
	n.show_id
FROM netflix_titles n
CROSS APPLY STRING_SPLIT(n.listed_in, ',') AS s
JOIN categoria c ON TRIM(s.value) = c.descripcion

select * from show_categoria

------------------
-- Tabla Elenco --
------------------

INSERT INTO elenco (id_actor, id_show)
SELECT DISTINCT
	a.id_actor, 
	n.show_id
FROM netflix_titles n
CROSS APPLY STRING_SPLIT(n.cast, ',') AS s
JOIN actor a ON TRIM(s.value) = a.nombre_apellido

select * from elenco

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