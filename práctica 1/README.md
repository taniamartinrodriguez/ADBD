# Práctica 1. Conceptos fundamentales de PostgreSQL
---

# 1. Creación de la base de datos
## 1.1. Creación de `biblioteca`

Se crea una base de datos llamada `biblioteca`, tal y como solicita el enunciado.

### Comando
```sql
CREATE DATABASE biblioteca;
```

### Salida obtenida
```text
CREATE DATABASE
```

Para comprobar que la base de datos existe se utiliza:
```sql
\l
```

Entre las bases de datos mostradas aparece:
```text
biblioteca
```

Para conectarse a ella:
```sql
\c biblioteca
```

### Salida
```text
You are now connected to database "biblioteca" as user "postgres".
```

---

# 2. Creación de usuarios y roles
La práctica solicita dos usuarios y un rol:
- `admin_biblio`: usuario con permisos de administración sobre la base de datos.
- `usuario_biblio`: usuario destinado a la lectura.
- `lectores`: rol con permisos únicamente de consulta.

## 2.1. Creación de `admin_biblio`
Se crea el usuario con capacidad de iniciar sesión:
```sql
CREATE ROLE admin_biblio WITH LOGIN PASSWORD 'adminpass';
```

### Salida
```text
CREATE ROLE
```

Se le conceden todos los privilegios disponibles sobre la base de datos:
```sql
GRANT ALL PRIVILEGES ON DATABASE biblioteca TO admin_biblio;
```

### Salida
```text
GRANT
```

---

## 2.2. Creación de `usuario_biblio`
Se crea el usuario que posteriormente tendrá únicamente permisos de lectura:
```sql
CREATE ROLE usuario_biblio WITH LOGIN PASSWORD 'usuariopass';
```

### Salida
```text
CREATE ROLE
```

Se permite que pueda conectarse a la base de datos:
```sql
GRANT CONNECT ON DATABASE biblioteca TO usuario_biblio;
```

### Salida
```text
GRANT
```

---

## 2.3. Creación del rol `lectores`
Se crea un rol sin posibilidad de iniciar sesión directamente:
```sql
CREATE ROLE lectores NOLOGIN;
```

### Salida
```text
CREATE ROLE
```

El rol se utilizará para centralizar los permisos de lectura.

---

## 2.4. Asignación de `usuario_biblio` al rol `lectores`
Se asigna el usuario al rol:
```sql
GRANT lectores TO usuario_biblio;
```

### Salida
```text
GRANT ROLE
```

De esta forma, `usuario_biblio` heredará los permisos concedidos al rol `lectores`.

---

## 2.5. Consulta de los usuarios mediante `pg_roles`
PostgreSQL almacena la información de sus roles en la vista de sistema `pg_roles`.
Se utiliza:
```sql
SELECT rolname, rolsuper, rolcreaterole, rolcreatedb, rolcanlogin
FROM pg_roles
WHERE rolname IN ('admin_biblio', 'usuario_biblio', 'lectores')
ORDER BY rolname;
```

### Salida esperada
```text
    rolname     | rolsuper | rolcreaterole | rolcreatedb | rolcanlogin
----------------+----------+---------------+-------------+-------------
 admin_biblio   | f        | f             | f           | t
 lectores       | f        | f             | f           | f
 usuario_biblio | f        | f             | f           | t
```

---

## 2.6. Cambio de contraseña
Se cambia la contraseña de `usuario_biblio`:
```sql
ALTER ROLE usuario_biblio WITH PASSWORD '12345';
```

### Salida
```text
ALTER ROLE
```

---

## 2.7. Configuración de permisos de lectura
Se eliminan los privilegios generales del esquema `public` para evitar que otros usuarios reciban permisos automáticamente:
```sql
REVOKE ALL ON SCHEMA public FROM PUBLIC;
```

### Salida
```text
REVOKE
```

También se eliminan los privilegios generales sobre la base de datos:
```sql
REVOKE ALL ON DATABASE biblioteca FROM PUBLIC;
```

### Salida
```text
REVOKE
```

Una vez creadas las tablas, se concederá al rol `lectores` únicamente el permiso `SELECT`.
De esta forma, `usuario_biblio`, al pertenecer a `lectores`, podrá consultar los datos pero no insertar, modificar ni eliminar registros.

# 2.8. Comprobación de que `usuario_biblio` no puede eliminar datos
Una vez creadas las tablas se conceden permisos de consulta sobre todas ellas:

```sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO lectores;
```

### Salida

```text
GRANT
```

`usuario_biblio` pertenece al rol `lectores`:

```sql
GRANT lectores TO usuario_biblio;
```

El rol `lectores` únicamente tiene permisos `SELECT`.
Por tanto, no se concede ningún permiso `DELETE`, `INSERT` ni `UPDATE`.
Se puede consultar la pertenencia al rol mediante:

```sql
SELECT r.rolname AS usuario, m.rolname AS rol
FROM pg_auth_members am
JOIN pg_roles r ON r.oid = am.member
JOIN pg_roles m ON m.oid = am.roleid
WHERE r.rolname = 'usuario_biblio';
```

### Resultado esperado
```text
     usuario     |    rol
-----------------+----------
 usuario_biblio  | lectores
```

---

# 3. Creación de tablas
La práctica solicita tres tablas:
- `autores`
- `libros`
- `prestamos`

También se deben establecer las claves primarias y las claves foráneas correspondientes.

## 3.1. Tabla `autores`
La tabla contiene:
- `id_autor`: identificador del autor.
- `nombre`: nombre del autor.
- `nacionalidad`: nacionalidad del autor.

### Comando
```sql
CREATE TABLE autores (
    id_autor SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    nacionalidad TEXT
);
```

### Salida
```text
CREATE TABLE
```

Para comprobar su estructura:
```sql
\d autores
```

### Resultado esperado
```text
                             Table "public.autores"
    Column    |  Type   | Collation | Nullable |                Default
--------------+---------+-----------+----------+----------------------------------------
 id_autor     | integer |           | not null | nextval('autores_id_autor_seq'::regclass)
 nombre       | text    |           | not null |
 nacionalidad | text    |           |          |
Indexes:
    "autores_pkey" PRIMARY KEY, btree (id_autor)
```

---

## 3.2. Tabla `libros`
La tabla contiene:
- `id_libro`: identificador del libro.
- `titulo`: título.
- `año_publicacion`: año de publicación.
- `id_autor`: autor correspondiente.

El campo `id_autor` será una clave foránea que referencia a `autores`.
```sql
CREATE TABLE libros(
    id_libro SERIAL PRIMARY KEY, 
    titulo TEXT NOT NULL, 
    año_publicacion INT, 
    id_autor INT,
    CONSTRAINT fk_autor FOREIGN KEY (id_autor) REFERENCES autores(id_autor) ON DELETE CASCADE
);
```

### Salida
```text
CREATE TABLE
```

---

## 3.3. Tabla `prestamos`
La tabla contiene:
- `id_prestamo`: identificador del préstamo.
- `id_libro`: libro prestado.
- `fecha_prestamo`: fecha en la que se realiza el préstamo.
- `fecha_devolucion`: fecha de devolución. Puede quedar vacía mientras el libro esté prestado.
- `usuario_prestatario`: usuario que realiza el préstamo.

```sql
CREATE TABLE prestamos(
    id_prestamo SERIAL PRIMARY KEY, 
    id_libro INT, 
    fecha_prestamo DATE, 
    fecha_devolucion DATE, 
    usuario_prestatario TEXT,
    CONSTRAINT fk_libro FOREIGN KEY (id_libro) REFERENCES libros(id_libro) ON DELETE CASCADE
);
```

### Salida
```text
CREATE TABLE
```

Se utiliza `ON DELETE CASCADE` porque posteriormente la práctica solicita eliminar un libro y comprobar qué ocurre con sus préstamos.
Con esta opción, cuando se elimine un libro, los préstamos asociados a dicho libro también se eliminarán automáticamente.

---

## 3.4. Comprobación de las tablas
Se utiliza:
```sql
\dt
```

### Resultado esperado
```text
         List of relations
 Schema |   Name    | Type  |  Owner
--------+-----------+-------+----------
 public | autores   | table | postgres
 public | libros    | table | postgres
 public | prestamos | table | postgres
```

---

# 4. Inserción de datos
La práctica solicita como mínimo:
- 5 autores.
- 8 libros.
- 5 préstamos.

## 4.1. Insertar autores
```sql
INSERT INTO autores (nombre, nacionalidad) VALUES
('Gabriel García Márquez', 'Colombiana'),
('J. K. Rowling', 'Británica'),
('George Orwell', 'Británica'),
('Miguel de Cervantes', 'Española'),
('Jane Austen', 'Británica');
```

### Salida
```text
INSERT 0 5
```

---

## 4.2. Insertar libros
```sql
INSERT INTO libros (titulo, año_publicacion, id_autor) VALUES
('Cien años de soledad', 1967, 1),
('El amor en los tiempos del cólera', 1985, 1),
('Harry Potter y la piedra filosofal', 1997, 2),
('1984', 1949, 3),
('Rebelión en la granja', 1945, 3),
('Don Quijote de la Mancha', 1605, 4),
('Orgullo y prejuicio', 1813, 5),
('Emma', 1815, 5);
```

### Salida
```text
INSERT 0 8
```

Comprobación:
```sql
SELECT *
FROM libros
ORDER BY id_libro;
```

---

## 4.3. Insertar préstamos
Se insertan cinco préstamos de ejemplo. Algunos tienen fecha de devolución y otros todavía están pendientes.
```sql
INSERT INTO prestamos (id_libro, fecha_prestamo, fecha_devolucion, usuario_prestatario) VALUES
(1, '2026-09-01', '2026-09-10', 'ana'),
(2, '2026-09-03', NULL, 'carlos'),
(3, '2026-09-05', '2026-09-15', 'lucia'),
(4, '2026-09-07', NULL, 'ana'),
(1, '2026-09-10', NULL, 'pedro');
```

### Salida
```text
INSERT 0 5
```

Comprobación:
```sql
SELECT *
FROM prestamos
ORDER BY id_prestamo;
```

---

# 5. Consultas básicas
## 5.1. Listar todos los libros con su autor
Se utiliza una unión entre `libros` y `autores`:
```sql
SELECT l.id_libro, l.titulo, l.año_publicacion, a.nombre AS autor
FROM libros l
JOIN autores a ON l.id_autor = a.id_autor
ORDER BY l.id_libro;
```

### Resultado esperado
```text
 id_libro |               titulo                | año_publicacion |          autor
----------+-------------------------------------+-----------------+------------------------
 1        | Cien años de soledad                | 1967            | Gabriel García Márquez
 2        | El amor en los tiempos del cólera   | 1985            | Gabriel García Márquez
 3        | Harry Potter y la piedra filosofal  | 1997            | J. K. Rowling
 4        | 1984                                | 1949            | George Orwell
 5        | Rebelión en la granja               | 1945            | George Orwell
 6        | Don Quijote de la Mancha            | 1605            | Miguel de Cervantes
 7        | Orgullo y prejuicio                 | 1813            | Jane Austen
 8        | Emma                                | 1815            | Jane Austen
```

---

## 5.2. Mostrar préstamos pendientes de devolución
Los préstamos pendientes son aquellos cuya `fecha_devolucion` es `NULL`.
```sql
SELECT id_prestamo, id_libro, fecha_prestamo, usuario_prestatario
FROM prestamos
WHERE fecha_devolucion IS NULL;
```

### Resultado esperado
```text
 id_prestamo | id_libro | fecha_prestamo | usuario_prestatario
-------------+----------+----------------+---------------------
 2           | 2        | 2026-09-03     | carlos
 4           | 4        | 2026-09-07     | ana
 5           | 1        | 2026-09-10     | pedro
```

---

## 5.3. Obtener autores con más de un libro
Se agrupan los libros por autor y se utiliza `HAVING` para quedarse con aquellos autores que tienen más de un libro.
```sql
SELECT a.id_autor, a.nombre, COUNT(l.id_libro) AS numero_libros
FROM autores a
JOIN libros l ON a.id_autor = l.id_autor
GROUP BY a.id_autor, a.nombre
HAVING COUNT(l.id_libro) > 1
ORDER BY numero_libros DESC;
```

### Resultado esperado
```text
 id_autor |         nombre          | numero_libros
----------+-------------------------+---------------
 1        | Gabriel García Márquez  | 2
 3        | George Orwell           | 2
 5        | Jane Austen             | 2
```

---

# 6. Consultas con agregación
## 6.1. Número total de préstamos
Se utiliza `COUNT`:
```sql
SELECT COUNT(*) AS total_prestamos
FROM prestamos;
```

### Resultado esperado
```text
 total_prestamos
-----------------
 5
```

---

## 6.2. Número de libros prestados por cada usuario
Se agrupan los préstamos mediante `usuario_prestatario`:
```sql
SELECT usuario_prestatario, COUNT(*) AS numero_prestamos
FROM prestamos
GROUP BY usuario_prestatario
ORDER BY numero_prestamos DESC;
```

### Resultado esperado
```text
 usuario_prestatario | numero_prestamos
---------------------+-----------------
 ana                 | 2
 carlos              | 1
 lucia               | 1
 pedro               | 1
```

---

# 7. Modificación de datos
## 7.1. Actualizar la fecha de devolución de un préstamo
Se actualiza el préstamo número 2, que inicialmente estaba pendiente:

```sql
UPDATE prestamos
SET fecha_devolucion = '2026-09-20'
WHERE id_prestamo = 2;
```

### Salida
```text
UPDATE 1
```

Se comprueba:
```sql
SELECT *
FROM prestamos
WHERE id_prestamo = 2;
```

La columna `fecha_devolucion` ahora contiene:
```text
2026-09-20
```

---

## 7.2. Eliminar un libro y comprobar `ON DELETE CASCADE`
Antes de eliminar un libro se comprueba si tiene préstamos:
```sql
SELECT *
FROM prestamos
WHERE id_libro = 1;
```

El libro número 1 tiene préstamos asociados.
Se elimina el libro:
```sql
DELETE FROM libros
WHERE id_libro = 1;
```

### Salida
```text
DELETE 1
```

Como la clave foránea de `prestamos.id_libro` se definió con:
```sql
ON DELETE CASCADE
```

los préstamos asociados al libro también se eliminan automáticamente.
Se comprueba:

```sql
SELECT *
FROM prestamos
WHERE id_libro = 1;
```

### Resultado
```text
 id_prestamo | id_libro | fecha_prestamo | fecha_devolucion | usuario_prestatario
-------------+----------+----------------+------------------+---------------------
(0 rows)
```

Por tanto, se comprueba que `ON DELETE CASCADE` elimina automáticamente los préstamos relacionados con el libro eliminado.

---

# 8. Creación de vistas

La práctica solicita una vista denominada `vista_libros_prestados` que muestre:
- título del libro;
- autor;
- nombre del prestatario.

## 8.1. Crear la vista
```sql
CREATE VIEW vista_libros_prestados AS
SELECT l.titulo, a.nombre AS autor, p.usuario_prestatario AS prestatario
FROM prestamos p
JOIN libros l ON p.id_libro = l.id_libro
JOIN autores a ON l.id_autor = a.id_autor;
```

### Salida
```text
CREATE VIEW
```

---

## 8.2. Consultar la vista
```sql
SELECT *
FROM vista_libros_prestados;
```

La vista devuelve información combinada de las tres tablas.

---

## 8.3. Conceder permisos sobre la vist
Se concede permiso de consulta a `usuario_biblio`:

```sql
GRANT SELECT ON vista_libros_prestados TO usuario_biblio;
```

### Salida
```text
GRANT
```

De esta forma, `usuario_biblio` puede consultar la información de la vista sin necesidad de disponer de permisos de modificación.

---

# 9. Funciones y consultas avanzadas
## 9.1. Función para buscar los libros de un autor
La práctica solicita una función que reciba el nombre de un autor y devuelva todos sus libros.
Se crea mediante `CREATE FUNCTION`:

```sql
CREATE OR REPLACE FUNCTION libros_de_autor(nombre_autor TEXT)
RETURNS TABLE (titulo TEXT, año_publicacion INTEGER)
LANGUAGE SQL AS $$
    SELECT l.titulo, l.año_publicacion
    FROM libros l
    JOIN autores a ON l.id_autor = a.id_autor
    WHERE a.nombre = nombre_autor
    ORDER BY l.titulo;
$$;
```

### Salida
```text
CREATE FUNCTION
```

Para utilizar la función:

```sql
SELECT *
FROM libros_de_autor('George Orwell');
```

### Resultado esperado
```text
        titulo         | año_publicacion
-----------------------+-----------------
 1984                  | 1949
 Rebelión en la granja | 1945
```

También se puede utilizar otro autor:
```sql
SELECT *
FROM libros_de_autor('Jane Austen');
```

---

## 9.2. Tres libros más prestados
Se cuentan los préstamos de cada libro y se ordenan de mayor a menor.

```sql
SELECT l.id_libro, l.titulo, COUNT(p.id_prestamo) AS numero_prestamos
FROM libros l
LEFT JOIN prestamos p ON l.id_libro = p.id_libro
GROUP BY l.id_libro, l.titulo
ORDER BY numero_prestamos DESC
LIMIT 3;
```

### Explicación
- `LEFT JOIN` permite incluir libros que no tengan préstamos.
- `COUNT` cuenta el número de préstamos.
- `GROUP BY` agrupa los préstamos por libro.
- `ORDER BY ... DESC` coloca primero los libros con más préstamos.
- `LIMIT 3` limita el resultado a tres libros.

---

# 10. Exportación e importación de datos
## 10.1. Exportar `libros` a CSV
Desde `psql` se utiliza el comando `\copy`.

```sql
\copy libros TO '/tmp/libros.csv' WITH (FORMAT CSV, HEADER);
```

### Salida esperada
```text
COPY 7
```

El número dependerá de los libros que existan en ese momento, ya que en el apartado 7 se elimina un libro.
El archivo `libros.csv` contendrá las columnas:

```text
id_libro,titulo,año_publicacion,id_autor
```

---

## 10.2. Crear un CSV de autores
Para realizar la importación se puede crear un archivo denominado `autores_nuevos.csv` con contenido similar a:

```csv
nombre,nacionalidad
Stephen King,Estadounidense
Agatha Christie,Británica
```

Es importante que el archivo tenga el mismo orden de columnas que se utilizará en la importación.

---

## 10.3. Importar autores desde CSV
Primero se puede utilizar una tabla temporal para evitar problemas con el campo `id_autor`, que es generado automáticamente.

```sql
CREATE TEMP TABLE autores_importacion (nombre TEXT,nacionalidad TEXT);
```

Después se importa el archivo:
```sql
\copy autores_importacion(nombre, nacionalidad) FROM 'autores_nuevos.csv' WITH (FORMAT CSV, HEADER);
```

### Salida esperada

```text
COPY 2
```

Finalmente se incorporan los autores a la tabla principal:

```sql
INSERT INTO autores (nombre, nacionalidad)
SELECT nombre, nacionalidad
FROM autores_importacion;
```

### Salida

```text
INSERT 0 2
```

Se puede comprobar:

```sql
SELECT *
FROM autores
ORDER BY id_autor;
```

---
