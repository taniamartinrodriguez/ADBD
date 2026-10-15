# Práctica 4. Modelo relacional de Viveros

**Alumno/a:** Tania Martín Rodríguez  
**Asignatura:** Administración y Diseño de Bases de Datos  
**Curso:** 2026-2027

## Modelo entidad-relación

![Modelo entidad-relación de Viveros](modelo_er.png)

## Modelo relacional

![Modelo relacional de Viveros](modelo_relacional.png)

## Salida de un SELECT por cada tabla

### 1. Tabla Vivero (`vivero`)

**Comando:**

```sql
SELECT * FROM vivero;
```

**Resultado:**

```text
 id_vivero |  latitud  |  longitud
-----------+-----------+------------
         1 | 28.468240 | -16.254620
         2 | 28.123550 | -16.562110
         3 | 28.104800 | -15.413900
         4 | 28.291560 | -16.629130
         5 | 28.410310 | -16.548750
         6 | 28.033160 | -16.580120
(6 rows)
```

### 2. Tabla Zona (`zona`)

**Comando:**

```sql
SELECT * FROM zona;
```

**Resultado:**

```text
 id_vivero | nombre_zona |  latitud  |  longitud
-----------+-------------+-----------+------------
         1 | Exterior    | 28.468000 | -16.254500
         1 | Almacen     | 28.468100 | -16.254700
         2 | Exterior    | 28.123600 | -16.562200
         2 | Invernadero | 28.123700 | -16.562000
         3 | Exterior    | 28.104900 | -15.414000
         3 | Almacen     | 28.104700 | -15.413800
         4 | Decoracion  | 28.291400 | -16.629000
         4 | Exterior    | 28.291600 | -16.629200
         5 | Invernadero | 28.410400 | -16.548800
         6 | Exterior    | 28.033200 | -16.580200
(10 rows)
```

### 3. Tabla Producto (`producto`)

**Comando:**

```sql
SELECT * FROM producto;
```

**Resultado:**

```text
 id_producto |     nombre
-------------+-----------------
           1 | Rosal
           2 | Cactus
           3 | Tierra vegetal
           4 | Maceta ceramica
           5 | Abono organico
           6 | Lavanda
(6 rows)
```

### 4. Tabla Empleado (`empleado`)

**Comando:**

```sql
SELECT * FROM empleado;
```

**Resultado:**

```text
 id_empleado | nombre | apellido |    dni
-------------+--------+----------+-----------
           1 | Ana    | Perez    | 11111111A
           2 | Luis   | Martin   | 22222222B
           3 | Eva    | Diaz     | 33333333C
           4 | Pablo  | Suarez   | 44444444D
           5 | Sara   | Lopez    | 55555555E
           6 | Mario  | Torres   | 66666666F
(6 rows)
```

### 5. Tabla Cliente (`cliente`)

**Comando:**

```sql
SELECT * FROM cliente;
```

**Resultado:**

```text
 id_cliente |   nombre    |       correo
------------+-------------+--------------------
          1 | Marta Ruiz  | marta@example.com
          2 | Carlos Gil  | carlos@example.com
          3 | Paula Leon  | paula@example.com
          4 | Andres Vega | andres@example.com
          5 | Lucia Melo  | lucia@example.com
          6 | Nerea Perez | nerea@example.com
          7 | Jorge Diaz  | jorge@example.com
          8 | Elena Cruz  | elena@example.com
(8 rows)
```

### 6. Tabla Cliente Plus (`cliente_plus`)

**Comando:**

```sql
SELECT * FROM cliente_plus;
```

**Resultado:**

```text
 id_cliente | fecha_ingreso
------------+---------------
          1 | 2025-01-10
          2 | 2025-02-15
          3 | 2025-03-01
          4 | 2025-05-20
          5 | 2025-06-01
(5 rows)
```

### 7. Tabla Bonificación (`bonificacion`)

**Comando:**

```sql
SELECT * FROM bonificacion;
```

**Resultado:**

```text
 id_bonificacion | id_cliente | bonificacion
-----------------+------------+--------------
               1 |          1 |         5.00
               2 |          1 |         8.00
               3 |          2 |         4.50
               4 |          3 |         6.00
               5 |          4 |         7.50
               6 |          5 |         3.00
(6 rows)
```

### 8. Tabla Stock asignado (`stock_asignado`)

**Comando:**

```sql
SELECT * FROM stock_asignado;
```

**Resultado:**

```text
 id_vivero | nombre_zona | id_producto | cantidad_disponible
-----------+-------------+-------------+---------------------
         1 | Exterior    |           1 |                  40
         1 | Exterior    |           6 |                  20
         1 | Almacen     |           3 |                  70
         2 | Exterior    |           2 |                  25
         2 | Invernadero |           1 |                  18
         3 | Almacen     |           4 |                  35
         4 | Decoracion  |           4 |                  12
         5 | Invernadero |           6 |                  60
         6 | Exterior    |           5 |                   0
(9 rows)
```

### 9. Tabla Histórico de trabajo (`trabaja_en`)

**Comando:**

```sql
SELECT * FROM trabaja_en;
```

**Resultado:**

```text
 id_empleado | id_vivero | nombre_zona | fecha_ini  | fecha_fin  |        tarea        |   puesto
-------------+-----------+-------------+------------+------------+---------------------+-------------
           1 |         1 | Exterior    | 2025-01-01 | 2025-08-31 | Riego               | Operaria
           1 |         2 | Invernadero | 2025-09-01 |            | Supervision         | Encargada
           2 |         1 | Almacen     | 2025-04-01 |            | Inventario          | Almacenero
           3 |         3 | Exterior    | 2025-02-10 |            | Atencion al publico | Vendedora
           4 |         4 | Decoracion  | 2025-03-01 |            | Reposicion          | Dependiente
           5 |         5 | Invernadero | 2025-04-15 |            | Cultivo             | Tecnica
           6 |         6 | Exterior    | 2025-06-01 | 2025-12-31 | Poda                | Jardinero
           6 |         1 | Exterior    | 2026-01-01 |            | Mantenimiento       | Jardinero
(8 rows)
```

### 10. Tabla Pedido (`pedido`)

**Comando:**

```sql
SELECT * FROM pedido;
```

**Resultado:**

```text
 id_pedido |   fecha    | id_cliente | id_empleado
-----------+------------+------------+-------------
         1 | 2026-01-15 |          1 |           1
         2 | 2026-01-20 |          1 |           2
         3 | 2026-02-10 |          2 |           3
         4 | 2026-02-11 |          3 |           4
         5 | 2026-03-05 |          4 |           5
         6 | 2026-03-10 |          5 |           6
         7 | 2026-04-01 |          6 |           1
         8 | 2026-04-08 |          7 |           2
         9 | 2026-04-09 |          8 |           3
(9 rows)
```

### 11. Tabla Contiene (`contiene`)

**Comando:**

```sql
SELECT * FROM contiene;
```

**Resultado:**

```text
 id_pedido | id_producto | cantidad
-----------+-------------+----------
         1 |           1 |        2
         1 |           3 |        1
         2 |           4 |        3
         3 |           2 |        2
         4 |           5 |        1
         5 |           6 |        5
         6 |           1 |        1
         7 |           4 |        2
         8 |           5 |        3
         9 |           3 |        1
(10 rows)
```
