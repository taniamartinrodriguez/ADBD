# Práctica 2: Modelo Entidad-Relación - Tajinaste S.A.


## Archivos incluidos en el repositorio
* `practica2_adbd.drawio`: Archivo fuente editable con el diagrama Entidad-Relación.
* `practica2_adbd.drawio.png`: Imagen exportada del modelo conceptual.

![Diagrama Entidad-Relación](practica2_adbd.drawio.png)

---

## 1. Descripción de las Entidades

* **Vivero (Entidad Fuerte):** Representa cada uno de los centros físicos que conforman la red de ventas de plantas, jardinería y decoración de la empresa.
* **Zona (Entidad Débil):** Representa las distintas áreas o divisiones operativas ubicadas dentro de un vivero específico (por ejemplo, almacén, zona exterior, invernadero). Es una entidad débil por identificación, ya que el nombre de una zona no es único por sí solo, sino que depende del vivero al que pertenece.
* **Producto (Entidad Fuerte):** Representa los artículos comercializados por Tajinaste S.A. (plantas, productos de jardinería y decoración) cuyo stock se desea controlar en las diferentes zonas.
* **Empleado (Entidad Fuerte):** Representa a los trabajadores de la empresa, los cuales son destinados a distintas zonas según la época del año y se encargan de gestionar los pedidos de los clientes fidelizados.
* **Cliente_Plus (Entidad Fuerte):** Representa a los clientes adheridos al programa de fidelización *Tajinaste Plus*, a quienes se les realiza un seguimiento de sus compras mensuales para asignarles bonificaciones y dirigir campañas comerciales.
* **Pedido (Entidad Fuerte):** Representa las órdenes de compra efectuadas por los clientes del programa *Tajinaste Plus* desde su ingreso en el mismo, las cuales son gestionadas por un único empleado responsable.

---

## 2. Dominio de los Atributos (Entidades y Relaciones)

### Atributos de Entidades

#### **Vivero**
* **`Id_Vivero`** *(Clave Primaria)*: Código alfanumérico único que identifica a cada vivero.
  * *Dominio:* Cadena de caracteres de longitud fija (ej. `VIV-001`, `VIV-002`).
* **`Georreferenciación`** *(Atributo Compuesto)*: Ubicación geográfica exacta del vivero. Se descompone en:
  * **`Latitud`**: Coordenada geográfica norte/sur en grados decimales. *Dominio:* Número real entre `-90.0` y `90.0` (ej. `28.487401`).
  * **`Longitud`**: Coordenada geográfica este/oeste en grados decimales. *Dominio:* Número real entre `-180.0` y `180.0` (ej. `-16.315906`).

#### **Zona**
* **`Nombre_Zona`** *(Clave Parcial / Discriminador)*: Nombre descriptivo del área dentro de un vivero.
* **`Georreferenciación`** *(Atributo Compuesto)*: Coordenadas específicas donde se sitúa la zona dentro del vivero. Se compone de:
  * **`Latitud`**.
  * **`Longitud`**.
* **`Productividad`** *(Atributo Derivado)*: Índice global de rendimiento de la zona a lo largo del tiempo, calculado a partir de la productividad obtenida por los empleados asignados a dicha zona.

#### **Producto**
* **`Id_Producto`** *(Clave Primaria)*: Identificador único de cada artículo del catálogo.

#### **Empleado**
* **`Id_Empleado`** *(Clave Primaria)*: Código interno o documento de identidad que identifica de manera única al trabajador.

#### **Cliente_Plus**
* **`Id_Cliente`** *(Clave Primaria)*: Identificador único del socio en el programa *Tajinaste Plus*.
* **`Volumen_compras_mensual`** *(Atributo Derivado)*: Suma del importe o cantidad de pedidos realizados por el cliente en el mes en curso.
* **`Bonificaciones`**: Beneficios o descuentos asignados al cliente en función de su volumen de compras mensual.
* **`Categoría`**: Nivel de fidelización o clasificación asociada dentro del catálogo/programa.

#### **Pedido**+
* **`Id_Pedido`** *(Clave Primaria)*: Código único de registro de cada compra realizada[cite: 3].

---

### Atributos de Relaciones

#### **Relación `STOCK_ASIGNADO`**
* **`Cantidad_disponible`**: Número de unidades físicas de un producto concreto disponibles en una zona determinada.

#### **Relación `TRABAJA_EN`**
* **`Tarea`**: Puesto o labor específica que desempeña el empleado durante su asignación a esa zona.
* **`Productividad`**: Evaluación del rendimiento del empleado en dicho puesto y zona durante el periodo asignado.
* **`Fechas`** *(Atributo Compuesto)*: Rango temporal en el que el empleado estuvo destinado en la zona, permitiendo conservar el seguimiento histórico. Se divide en:
  * **`Fecha_ini`**: Fecha de inicio del destino.
  * **`Fecha_fin`**: Fecha de finalización del destino.

---

## 3. Descripción de las Relaciones y Cardinalidades

* **`SE_DIVIDE_EN` (Vivero — Zona)**
  * **Descripción:** Relación jerárquica que vincula a cada vivero con las zonas que lo componen.
  * **Cardinalidad Global:** **1:N** (Uno a Muchos).
  * **Detalle de participación:** Un vivero se divide en un mínimo de 1 y un máximo de N zonas `(1,N)`. Cada zona pertenece única y exclusivamente a un vivero `(1,1)`.

* **`STOCK_ASIGNADO` (Zona — Producto)**
  * **Descripción:** Registra qué productos están ubicados en qué zonas de los viveros y en qué cantidad.
  * **Cardinalidad Global:** **N:M** (Muchos a Muchos).
  * **Detalle de participación:** En una zona pueden asignarse desde ningún producto hasta muchos productos distintos `(0,N)`. A su vez, un mismo producto puede no tener stock asignado temporalmente o estar repartido en múltiples zonas `(0,N)`.

* **`TRABAJA_EN` (Empleado — Zona)**
  * **Descripción:**Recoge el histórico de puestos y destinos de los empleados en las diferentes zonas de los viveros a lo largo de las distintas épocas del año.
  * **Cardinalidad Global:** **N:M** (Muchos a Muchos).
  * **Detalle de participación:** Un empleado pasa por una o varias zonas a lo largo de su historial laboral `(1,N)`, y en una zona pueden desempeñar tareas cero o muchos empleados a lo largo del tiempo `(0,N)`.

* **`REALIZA` (Cliente_Plus — Pedido)**
  * **Descripción:** Asocia a los clientes del programa de fidelización *Tajinaste Plus* con los pedidos que han efectuado desde su alta en el programa.
  * **Cardinalidad Global:** **1:N** (Uno a Muchos).
  * **Detalle de participación:** Un cliente *Tajinaste Plus* puede haber realizado cero o muchos pedidos `(0,N)`[cite: 3], mientras que cada pedido registrado corresponde a un único cliente `(1,1)`.

* **`GESTIONA` (Empleado — Pedido)**
  * **Descripción:** Permite controlar qué empleado es responsable de cada pedido de cara a medir su capacidad para lograr objetivos de venta.
  * **Cardinalidad Global:** **1:N** (Uno a Muchos).
  * **Detalle de participación:** Un empleado puede gestionar desde ninguno hasta múltiples pedidos `(0,N)`[cite: 3], pero cada pedido tiene única y exclusivamente un empleado responsable `(1,1)`.
