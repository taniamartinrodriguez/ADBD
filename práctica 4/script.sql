-- Creación de la base de datos
CREATE DATABASE viveros;
-- Si quiere ejecutar a la primera, ejecutar el script en la terminal y descomentar la siguiente línea:
-- \c viveros;

----------------------------------------------------
-- 1. CREACIÓN DE TABLAS Y RESTRICCIONES
----------------------------------------------------

CREATE TABLE vivero (
 id_vivero SERIAL PRIMARY KEY,
 latitud NUMERIC(9,6) NOT NULL CHECK (latitud BETWEEN -90 AND 90),
 longitud NUMERIC(9,6) NOT NULL CHECK (longitud BETWEEN -180 AND 180)
);
CREATE TABLE zona (
 id_vivero INTEGER NOT NULL,
 nombre_zona VARCHAR(80) NOT NULL,
 latitud NUMERIC(9,6) NOT NULL CHECK (latitud BETWEEN -90 AND 90),
 longitud NUMERIC(9,6) NOT NULL CHECK (longitud BETWEEN -180 AND 180),
 PRIMARY KEY (id_vivero,nombre_zona),
 FOREIGN KEY (id_vivero) REFERENCES vivero(id_vivero) ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE producto (
 id_producto SERIAL PRIMARY KEY,
 nombre VARCHAR(120) NOT NULL
);
CREATE TABLE empleado (
 id_empleado SERIAL PRIMARY KEY,
 nombre VARCHAR(80) NOT NULL,
 apellido VARCHAR(120) NOT NULL,
 dni VARCHAR(12) NOT NULL UNIQUE
);
CREATE TABLE cliente (
 id_cliente SERIAL PRIMARY KEY,
 nombre VARCHAR(120) NOT NULL,
 correo VARCHAR(254) NOT NULL UNIQUE
);
-- IS_A: el subtipo reutiliza la clave del supertipo
CREATE TABLE cliente_plus (
 id_cliente INTEGER PRIMARY KEY,
 fecha_ingreso DATE NOT NULL,
 FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Atributo multivaluado Bonificaciones -> tabla separada.
-- Sin mes asociado en el ER: cada fila es una bonificación individual.
CREATE TABLE bonificacion (
 id_bonificacion SERIAL PRIMARY KEY,
 id_cliente INTEGER NOT NULL,
 bonificacion NUMERIC(10,2) NOT NULL CHECK (bonificacion >= 0),
 FOREIGN KEY (id_cliente) REFERENCES cliente_plus(id_cliente) ON UPDATE CASCADE ON DELETE CASCADE
);
-- Relación N:M STOCK_ASIGNADO con atributo cantidad_disponible
CREATE TABLE stock_asignado (
 id_vivero INTEGER NOT NULL,
 nombre_zona VARCHAR(80) NOT NULL,
 id_producto INTEGER NOT NULL,
 cantidad_disponible INTEGER NOT NULL DEFAULT 0 CHECK (cantidad_disponible >= 0),
 PRIMARY KEY (id_vivero,nombre_zona,id_producto),
 FOREIGN KEY (id_vivero,nombre_zona) REFERENCES zona(id_vivero,nombre_zona) ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON UPDATE CASCADE ON DELETE RESTRICT
);
-- TRABAJA_EN es BINARIA en el ER definitivo; Tarea y Puesto son atributos de la relación.
CREATE TABLE trabaja_en (
 id_empleado INTEGER NOT NULL,
 id_vivero INTEGER NOT NULL,
 nombre_zona VARCHAR(80) NOT NULL,
 fecha_ini DATE NOT NULL,
 fecha_fin DATE,
 tarea VARCHAR(120) NOT NULL,
 puesto VARCHAR(120) NOT NULL,
 PRIMARY KEY (id_empleado,id_vivero,nombre_zona,fecha_ini),
 CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_ini),
 FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado) ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (id_vivero,nombre_zona) REFERENCES zona(id_vivero,nombre_zona) ON UPDATE CASCADE ON DELETE RESTRICT
);
-- REALIZA vincula Cliente general (no únicamente Plus) con Pedido.
CREATE TABLE pedido (
 id_pedido SERIAL PRIMARY KEY,
 fecha DATE NOT NULL,
 id_cliente INTEGER NOT NULL,
 id_empleado INTEGER NOT NULL,
 FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT,
 FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado) ON UPDATE CASCADE ON DELETE RESTRICT
);
-- CONTIENE N:M con atributo Cantidad
CREATE TABLE contiene (
 id_pedido INTEGER NOT NULL,
 id_producto INTEGER NOT NULL,
 cantidad INTEGER NOT NULL CHECK (cantidad > 0),
 PRIMARY KEY (id_pedido,id_producto),
 FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (id_producto) REFERENCES producto(id_producto) ON UPDATE CASCADE ON DELETE RESTRICT
);

----------------------------------------------------
-- 2. INSERCIÓN DE DATOS (Mínimo 5 por tabla)
----------------------------------------------------

INSERT INTO vivero(id_vivero,latitud,longitud) VALUES
 (1,28.468240,-16.254620),(2,28.123550,-16.562110),(3,28.104800,-15.413900),
 (4,28.291560,-16.629130),(5,28.410310,-16.548750),(6,28.033160,-16.580120);

INSERT INTO zona(id_vivero,nombre_zona,latitud,longitud) VALUES
 (1,'Exterior',28.468000,-16.254500),(1,'Almacen',28.468100,-16.254700),
 (2,'Exterior',28.123600,-16.562200),(2,'Invernadero',28.123700,-16.562000),
 (3,'Exterior',28.104900,-15.414000),(3,'Almacen',28.104700,-15.413800),
 (4,'Decoracion',28.291400,-16.629000),(4,'Exterior',28.291600,-16.629200),
 (5,'Invernadero',28.410400,-16.548800),(6,'Exterior',28.033200,-16.580200);

INSERT INTO producto(id_producto,nombre) VALUES
 (1,'Rosal'),(2,'Cactus'),(3,'Tierra vegetal'),(4,'Maceta ceramica'),(5,'Abono organico'),(6,'Lavanda');

INSERT INTO empleado(id_empleado,nombre,apellido,dni) VALUES
 (1,'Ana','Perez','11111111A'),(2,'Luis','Martin','22222222B'),
 (3,'Eva','Diaz','33333333C'),(4,'Pablo','Suarez','44444444D'),
 (5,'Sara','Lopez','55555555E'),(6,'Mario','Torres','66666666F');

INSERT INTO cliente(id_cliente,nombre,correo) VALUES
 (1,'Marta Ruiz','marta@example.com'),(2,'Carlos Gil','carlos@example.com'),
 (3,'Paula Leon','paula@example.com'),(4,'Andres Vega','andres@example.com'),
 (5,'Lucia Melo','lucia@example.com'),(6,'Nerea Perez','nerea@example.com'),
 (7,'Jorge Diaz','jorge@example.com'),(8,'Elena Cruz','elena@example.com');

INSERT INTO cliente_plus(id_cliente,fecha_ingreso) VALUES
 (1,'2025-01-10'),(2,'2025-02-15'),(3,'2025-03-01'),
 (4,'2025-05-20'),(5,'2025-06-01');

INSERT INTO bonificacion(id_bonificacion,id_cliente,bonificacion) VALUES
 (1,1,5.00),(2,1,8.00),(3,2,4.50),(4,3,6.00),(5,4,7.50),(6,5,3.00);

INSERT INTO stock_asignado(id_vivero,nombre_zona,id_producto,cantidad_disponible) VALUES
 (1,'Exterior',1,40),(1,'Exterior',6,20),(1,'Almacen',3,70),
 (2,'Exterior',2,25),(2,'Invernadero',1,18),(3,'Almacen',4,35),
 (4,'Decoracion',4,12),(5,'Invernadero',6,60),(6,'Exterior',5,0);

INSERT INTO trabaja_en(id_empleado,id_vivero,nombre_zona,fecha_ini,fecha_fin,tarea,puesto) VALUES
 (1,1,'Exterior','2025-01-01','2025-08-31','Riego','Operaria'),
 (1,2,'Invernadero','2025-09-01',NULL,'Supervision','Encargada'),
 (2,1,'Almacen','2025-04-01',NULL,'Inventario','Almacenero'),
 (3,3,'Exterior','2025-02-10',NULL,'Atencion al publico','Vendedora'),
 (4,4,'Decoracion','2025-03-01',NULL,'Reposicion','Dependiente'),
 (5,5,'Invernadero','2025-04-15',NULL,'Cultivo','Tecnica'),
 (6,6,'Exterior','2025-06-01','2025-12-31','Poda','Jardinero'),
 (6,1,'Exterior','2026-01-01',NULL,'Mantenimiento','Jardinero');

INSERT INTO pedido(id_pedido,fecha,id_cliente,id_empleado) VALUES
 (1,'2026-01-15',1,1),(2,'2026-01-20',1,2),(3,'2026-02-10',2,3),
 (4,'2026-02-11',3,4),(5,'2026-03-05',4,5),(6,'2026-03-10',5,6),
 (7,'2026-04-01',6,1),(8,'2026-04-08',7,2),(9,'2026-04-09',8,3);

INSERT INTO contiene(id_pedido,id_producto,cantidad) VALUES
 (1,1,2),(1,3,1),(2,4,3),(3,2,2),(4,5,1),
 (5,6,5),(6,1,1),(7,4,2),(8,5,3),(9,3,1);

-- Atributos derivados del ER, NO almacenados:
-- Volumen_compras_mensual: dado que el ER no tiene precios, se interpreta como
-- unidades de producto compradas al mes (no como euros) desde la afiliación.
CREATE VIEW volumen_compras_mensual AS
 SELECT cp.id_cliente, EXTRACT(YEAR FROM p.fecha) AS anio,
        EXTRACT(MONTH FROM p.fecha) AS mes,
        SUM(c.cantidad) AS volumen_compras_mensual
 FROM cliente_plus cp
 JOIN pedido p ON p.id_cliente=cp.id_cliente AND p.fecha >= cp.fecha_ingreso
 JOIN contiene c ON c.id_pedido=p.id_pedido
 GROUP BY cp.id_cliente,EXTRACT(YEAR FROM p.fecha),EXTRACT(MONTH FROM p.fecha);

-- Productividad por zona: el enunciado no da fórmula; mostramos un indicador
-- derivable (número de asignaciones registradas), NO productividad económica.
CREATE VIEW productividad_zona AS
 SELECT z.id_vivero,z.nombre_zona,COUNT(t.id_empleado) AS numero_asignaciones
 FROM zona z LEFT JOIN trabaja_en t ON (z.id_vivero=t.id_vivero AND z.nombre_zona=t.nombre_zona)
 GROUP BY z.id_vivero,z.nombre_zona;

----------------------------------------------------
-- 3. EJEMPLOS DE OPERACIONES DELETE REPRESENTATIVAS
----------------------------------------------------

-- Ejemplo A: Borrar un vivero.
-- Al tener ON DELETE CASCADE, también se borrarán sus
-- zonas y los registros de stock asociados.
DELETE FROM vivero WHERE id_vivero = 5;


-- Ejemplo B: Borrar un producto.
-- Como tiene ON DELETE RESTRICT, no se puede borrar
-- si aparece en stock_asignado o contiene.
-- Primero eliminamos sus registros relacionados.
DELETE FROM stock_asignado WHERE id_producto = 5;
DELETE FROM contiene WHERE id_producto = 5;
DELETE FROM producto WHERE id_producto = 5;


-- Ejemplo C: Borrar un cliente Plus.
-- Al tener ON DELETE CASCADE, también se eliminarán
-- sus bonificaciones, pero el cliente general se conserva.
DELETE FROM cliente_plus WHERE id_cliente = 5;


-- Ejemplo D: Borrar un registro del historial de trabajo.
-- Se elimina una asignación concreta de un empleado.
DELETE FROM trabaja_en
WHERE id_empleado = 1
AND id_vivero = 1
AND nombre_zona = 'Exterior'
AND fecha_ini = '2025-01-01';


-- Ejemplo E: Borrar un empleado.
-- Primero se eliminan sus pedidos, ya que tienen
-- ON DELETE RESTRICT respecto al empleado.
-- Sus registros de trabaja_en se borrarán por CASCADE.
DELETE FROM pedido WHERE id_empleado = 3;
DELETE FROM empleado WHERE id_empleado = 3;
