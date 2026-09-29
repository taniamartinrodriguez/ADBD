# Práctica 1. Conceptos fundamentales de PostgreSQL

**Asignatura:** Administración y diseño de bases de datos
**Grado:** Ingeniería Informática - Universidad de La Laguna

---

## 1. Creación de la base de datos

**a. Crear una base de datos llamada `biblioteca`.**

```sql
CREATE DATABASE biblioteca;
```
*Salida esperada:*
```text
CREATE DATABASE
```
*(A partir de aquí, nos conectamos a la base de datos creada usando `\c biblioteca` en psql).*

---

## 2. Creación de usuarios

**a. Crear dos usuarios: `admin_biblio` y `usuario_biblio`.**
```sql
CREATE USER admin_biblio WITH SUPERUSER PASSWORD 'admin123';
CREATE USER usuario_biblio WITH PASSWORD 'user123';
```

**b. Crear un rol llamado `lectores` con permisos de consulta.**
```sql
CREATE ROLE lectores;
GRANT CONNECT ON DATABASE biblioteca TO lectores;
GRANT USAGE ON SCHEMA public TO lectores;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO lectores;
```

**c. Asignar el usuario `usuario_biblio` a este rol.**
```sql
GRANT lectores TO usuario_biblio;
```

**d. Consultar las tablas del sistema para listar todos los usuarios creados.**
```sql
SELECT rolname, rolsuper, rolinherit, rolcreaterole, rolcreatedb, rolcanlogin 
FROM pg_roles 
WHERE rolname IN ('admin_biblio', 'usuario_biblio', 'lectores');
```
*Salida esperada:*
```text
    rolname     | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin 
----------------+----------+------------+---------------+-------------+-------------
 admin_biblio   | t        | t          | t             | t           | t
 lectores       | f        | t          | f             | f           | f
 usuario_biblio | f        | t          | f             | f           | t
```

**e. Cambiar la contraseña del usuario `usuario_biblio`.**
```sql
ALTER USER usuario_biblio WITH PASSWORD 'nueva_pass_456';
```

**f. Configurar permisos para que no pueda eliminar registros.**
*(Al asignarle únicamente el rol `lectores` que solo tiene `SELECT`, este usuario ya no puede hacer `DELETE`. Sin embargo, para ser explícitos y asegurar la restricción):*
```sql
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM usuario_biblio;
REVOKE DELETE ON ALL TABLES IN SCHEMA public FROM lectores;
```

---

## 3. Creación de tablas

**a y b. Crear tablas con sus claves primarias y foráneas.**

```sql
CREATE TABLE autores (
    id_autor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nacionalidad VARCHAR(50)
);

CREATE TABLE libros (
    id_libro SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    año_publicacion INT,
    id_autor INT REFERENCES autores(id_autor) ON DELETE CASCADE
);

CREATE TABLE prestamos (
    id_prestamo SERIAL PRIMARY KEY,
    id_libro INT REFERENCES libros(id_libro) ON DELETE CASCADE,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion DATE,
    usuario_prestatario VARCHAR(100) NOT NULL
);
```

---

## 4. Inserción de datos

**a. Insertar al menos 5 autores, 8 libros y 5 préstamos.**

```sql
INSERT INTO autores (nombre, nacionalidad) VALUES
('Gabriel García Márquez', 'Colombiana'),
('J.K. Rowling', 'Británica'),
('Isaac Asimov', 'Ruso-Estadounidense'),
('Isabel Allende', 'Chilena'),
('J.R.R. Tolkien', 'Británica');

INSERT INTO libros (titulo, año_publicacion, id_autor) VALUES
('Cien años de soledad', 1967, 1),
('El coronel no tiene quien le escriba', 1961, 1),
('Harry Potter y la piedra filosofal', 1997, 2),
('Fundación', 1951, 3),
('Yo, Robot', 1950, 3),
('La casa de los espíritus', 1982, 4),
('El señor de los anillos', 1954, 5),
('El hobbit', 1937, 5);

INSERT INTO prestamos (id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario) VALUES
(1, '2026-09-01', '2026-09-15', 'Ana Garcia'),
(3, '2026-09-10', NULL, 'Luis Perez'),
(4, '2026-09-12', '2026-09-20', 'Maria Lopez'),
(7, '2026-09-25', NULL, 'Carlos Diaz'),
(1, '2026-09-26', NULL, 'Ana Garcia');
```

---

## 5. Consultas básicas

**a. Listar todos los libros con su autor correspondiente.**
```sql
SELECT l.titulo, a.nombre AS autor 
FROM libros l 
JOIN autores a ON l.id_autor = a.id_autor;
```

**b. Mostrar los préstamos que aún no tienen fecha de devolución.**
```sql
SELECT * FROM prestamos WHERE fecha_devolucion IS NULL;
```
*Salida esperada:*
```text
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario 
-------------+----------+----------------+------------------+---------------------
           2 |        3 | 2026-09-10     |                  | Luis Perez
           4 |        7 | 2026-09-25     |                  | Carlos Diaz
           5 |        1 | 2026-09-26     |                  | Ana Garcia
```

**c. Obtener los autores que tienen más de un libro registrado.**
```sql
SELECT a.nombre, COUNT(l.id_libro) as numero_libros
FROM autores a
JOIN libros l ON a.id_autor = l.id_autor
GROUP BY a.id_autor
HAVING COUNT(l.id_libro) > 1;
```

---

## 6. Consultas con agregación

**a. Calcular el número total de préstamos realizados.**
```sql
SELECT COUNT(*) AS total_prestamos FROM prestamos;
```

**b. Obtener el número de libros prestados por cada usuario.**
```sql
SELECT usuario_prestatario, COUNT(*) AS libros_prestados
FROM prestamos
GROUP BY usuario_prestatario;
```
*Salida esperada:*
```text
 usuario_prestatario | libros_prestados 
---------------------+------------------
 Ana Garcia          |                2
 Carlos Diaz         |                1
 Maria Lopez         |                1
 Luis Perez          |                1
```

---

## 7. Modificación de datos

**a. Actualizar la fecha de devolución de un préstamo pendiente.**
```sql
UPDATE prestamos 
SET fecha_devolucion = CURRENT_DATE 
WHERE id_prestamo = 2 AND fecha_devolucion IS NULL;
```

**b. Eliminar un libro y comprobar el efecto en la tabla de préstamos.**
```sql
DELETE FROM libros WHERE id_libro = 1;
SELECT * FROM prestamos;
```
*Justificación:* Al eliminar el libro con `id_libro = 1` ('Cien años de soledad'), los préstamos asociados (id_prestamo 1 y 5) se eliminarán automáticamente. Esto ocurre gracias a la restricción `ON DELETE CASCADE` definida al crear la clave foránea en la tabla de préstamos, que mantiene la integridad referencial borrando los registros dependientes.

---

## 8. Creación de vistas

**a. Crear la vista `vista_libros_prestados`.**
```sql
CREATE VIEW vista_libros_prestados AS
SELECT l.titulo, a.nombre AS autor, p.usuario_prestatario AS prestatario
FROM prestamos p
JOIN libros l ON p.id_libro = l.id_libro
JOIN autores a ON l.id_autor = a.id_autor;
```

**b. Conceder permisos de consulta sobre esta vista únicamente a `usuario_biblio`.**
```sql
REVOKE ALL ON vista_libros_prestados FROM PUBLIC;
GRANT SELECT ON vista_libros_prestados TO usuario_biblio;
```

---

## 9. Funciones y consultas avanzadas

**a. Función para devolver los libros de un autor.**
```sql
CREATE OR REPLACE FUNCTION libros_por_autor(nombre_autor VARCHAR)
RETURNS TABLE (titulo_libro VARCHAR, anio INT) AS $$
BEGIN
    RETURN QUERY 
    SELECT l.titulo::VARCHAR, l.año_publicacion
    FROM libros l
    JOIN autores a ON l.id_autor = a.id_autor
    WHERE a.nombre = nombre_autor;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso:
SELECT * FROM libros_por_autor('Isaac Asimov');
```

**b. Consulta de los tres libros más prestados.**
```sql
SELECT l.titulo, COUNT(p.id_prestamo) AS veces_prestado
FROM libros l
JOIN prestamos p ON l.id_libro = p.id_libro
GROUP BY l.id_libro
ORDER BY veces_prestado DESC
LIMIT 3;
```

---

## 10. Exportación e importación de datos

*(Los siguientes comandos están diseñados para ser ejecutados en la consola `psql` usando el metacomando `\copy` que interactúa con el sistema de archivos local).*

**a. Exportar el contenido de la tabla libros a un archivo CSV.**
```sql
\copy libros TO 'libros_exportados.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```

**b. Importar datos adicionales de autores desde un archivo CSV externo.**
*(Asumiendo que existe un archivo llamado `nuevos_autores.csv` con dos columnas: nombre y nacionalidad).*
```sql
\copy autores (nombre, nacionalidad) FROM 'nuevos_autores.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');
```
