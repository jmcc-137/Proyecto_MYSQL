# **Documento Técnico del Proyecto de Base de Datos: Plataforma de Comercialización Digital Multinivel**

## **1. Descripción General del Proyecto**

El presente documento tiene como objetivo describir el diseño e implementación de un sistema de gestión de bases de datos relacional, desarrollado en MySQL, que respalda la operación de una plataforma digital destinada a la comercialización de productos y servicios ofrecidos por empresas registradas. Esta solución se fundamenta en un modelo entidad-relación previamente estructurado, que contempla la gestión integral de clientes, empresas, productos, evaluaciones, membresías, beneficios y ubicaciones geográficas, todo ello con un enfoque escalable y modular.

## **2. Justificación Técnica**

La creciente demanda de plataformas B2C y B2B con soporte para personalización, evaluación de calidad, segmentación de usuarios y fidelización mediante beneficios, exige la implementación de soluciones robustas basadas en esquemas normalizados y eficientes. El modelo propuesto responde a dicha necesidad mediante un diseño altamente relacional, cumpliendo con las buenas prácticas en modelado de datos, seguridad, integridad referencial y expansión futura.

## **3. Objetivo del Sistema de Base de Datos**

Desarrollar e implementar una base de datos normalizada en MySQL que permita gestionar eficientemente los datos relacionados con:

- Clientes y empresas
- Catálogo de productos y servicios
- Georreferenciación de usuarios
- Preferencias y favoritos
- Evaluación de productos mediante encuestas
- Planes de membresía y beneficios asociados
- Métricas de calidad y segmentación por audiencia

## **4. Modelo de Datos y Estructura Relacional**

### 4.1 Estructura Geográfica

El sistema implementa una jerarquía de localización geográfica compuesta por:

- `countries` (países)
- `stateregions` (departamentos o estados)
- `citiesormunicipalities` (ciudades o municipios)

Esta estructura permite realizar segmentaciones geográficas precisas tanto para clientes como empresas, lo cual facilita análisis de mercado y distribución logística.

### 4.2 Gestión de Entidades Principales

- **Empresas (`companies`)**: Se almacenan con información clave como ciudad, tipo, categoría y audiencia objetivo. Pueden estar vinculadas a múltiples productos y recibir evaluaciones.
- **Clientes (`customers`)**: Registran información personal, ubicación y perfil de audiencia, además de su historial de calificaciones y favoritos.

### 4.3 Catálogo de Productos

- **Productos (`products`)**: Incluyen atributos como descripción, precio, categoría e imagen.
- **Relación Empresa-Producto (`companyproducts`)**: Permite que múltiples empresas ofrezcan el mismo producto con precios diferenciados y unidades de medida específicas.

### 4.4 Evaluaciones y Métricas

- **Encuestas (`polls`)**: Formato configurable para evaluar empresas o productos.
- **Valoraciones (`rates`)**: Registro de puntuaciones dadas por clientes a productos de empresas específicas.
- **Calidad de productos (`quality_products`)**: Métricas avanzadas para análisis de satisfacción, asociadas a encuestas y usuarios.

### 4.5 Personalización del Usuario

- **Favoritos (`favorites` y `details_favorites`)**: Permite a los clientes gestionar listas de productos de interés.
- **Audiencias (`audiences`)**: Segmenta a los usuarios por perfil demográfico o preferencial.

### 4.6 Programa de Membresías y Beneficios

- **Membresías (`memberships`)**: Tipologías de planes comerciales ofrecidos a los clientes.
- **Periodos de membresía (`membershipperiods`)**: Definen vigencia y costo de cada plan.
- **Beneficios (`benefits`)**: Accesos o privilegios otorgados por membresía.
- **Relación audiencia-beneficio (`audiencebenefits`)** y membresía-beneficio (`membershipbenefits`) permiten una gestión granular del acceso a ventajas según el perfil del usuario o plan adquirido.

## **5. Normalización y Control de Integridad**

El diseño de la base de datos se encuentra normalizado hasta la Tercera Forma Normal (3FN), lo cual garantiza:

- Eliminación de redundancias
- Integridad semántica de los datos
- Eficiencia en las operaciones de actualización y consulta

Además, todas las relaciones cuentan con restricciones de clave foránea (`FOREIGN KEY`) para asegurar la integridad referencial entre tablas, apoyándose en el motor de almacenamiento **InnoDB** de MySQL.

## **6. Consideraciones Técnicas de Implementación**

- **SGBD**: MySQL 8.x
- **Motor de almacenamiento**: InnoDB
- **Interfaz de administración recomendada**: MySQL Workbench o DBeaver
- **Lenguaje de consultas**: SQL estándar con extensiones propias de MySQL (índices, restricciones, vistas materializadas si se requieren en etapas futuras)

## **7. Escalabilidad y Seguridad**

El modelo permite escalar horizontalmente mediante la adición de nuevas categorías, productos, empresas, zonas geográficas y planes de membresía. La seguridad se garantiza mediante una arquitectura orientada a roles (por implementar en la capa de aplicación) y validaciones a nivel de esquema, tales como claves únicas, restricciones de nulidad y control de longitud de campos.

## **8. Conclusión**

La solución propuesta responde a los requerimientos funcionales y no funcionales de una plataforma de comercialización moderna. El modelo relacional garantiza consistencia, rendimiento y extensibilidad, permitiendo el desarrollo de aplicaciones web o móviles que consuman esta base de datos mediante APIs, análisis de datos o dashboards administrativos. Este sistema sienta las bases para una arquitectura de información sólida, adaptable y preparada para evolucionar hacia entornos distribuidos o microservicios.

# Der Propuesto

https://i.ibb.co/JwMnYkcr/DERPlat-Products.png

![](https://i.ibb.co/JwMnYkcr/DERPlat-Products.png)

# Historias de Usuario


# 🔹 **1. Consultas SQL Especializadas**

## 1. Como analista, quiero listar todos los productos con su empresa asociada y el precio más bajo por ciudad.

### RESPUSTA
```sql
SELECT ci.name AS ciudad, p.name AS producto, co.name AS empresa, MIN(cp.price) AS precio_mas_bajo
FROM citiesormunicipalities AS ci
JOIN companies AS co ON ci.code = co.city_id
JOIN companyproducts AS cp ON co.id = cp.company_id
JOIN products AS p ON cp.product_id = p.id
GROUP  BY ci.name, p.name, co.name 
ORDER BY   ci.name, precio_mas_bajo;
```
## 2. Como administrador, deseo obtener el top 5 de clientes que más productos han calificado en los últimos 6 meses.

### RESPUESTA
```sql
SELECT c.id AS cliente_id,c.name AS nombre_cliente,COUNT(DISTINCT qp.product_id) AS cantidad_productos_calificados,ROUND(AVG(qp.rating), 2) AS promedio
FROM customers AS c
JOIN quality_products AS qp ON c.id = qp.customer_id
WHERE qp.daterating >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
GROUP BY c.id, c.name 
ORDER BY cantidad_productos_calificados DESC, promedio DESC LIMIT 5;

```
## 3. Como gerente de ventas, quiero ver la distribución de productos por categoría y unidad de medida.

### RESPUESTA
 ```sql
 SELECT p.category_id, cp.unimeasure_id, COUNT(*) AS total_productos
 FROM products AS p
 JOIN categori
 JOIN companyproducts AS cp ON p.id = cp.product_id
 GROUP BY p.category_id, cp.unimeasure_id; 
 ```
## 4. Como cliente, quiero saber qué productos tienen calificaciones superiores al promedio general.

### RESPUESTA
```sql
SELECT 
    p.name AS producto,
    ROUND(AVG(q.rating), 2) AS calificacion_promedio,
    (SELECT ROUND(AVG(rating), 2) FROM quality_products) AS promedio_general,
    COUNT(*) AS total_calificaciones
FROM 
    products p 
JOIN 
    quality_products AS q ON p.id = q.product_id
GROUP BY 
    p.id, p.name
HAVING 
    AVG(q.rating) > (SELECT AVG(rating) FROM quality_products)
ORDER BY 
    calificacion_promedio DESC;
```
## 5. Como auditor, quiero conocer todas las empresas que no han recibido ninguna calificación.
### REPUESTA
```sql
SELECT c.id AS compania_id, c.name AS NOMBRE
FROM companies AS c
LEFT JOIN rates AS r ON c.id = r.company_id
LEFT JOIN quality_products AS qp ON c.id = qp.company_id
WHERE r.company_id IS NULL OR qp.company_id IS NULL;

```

## 6. Como operador, deseo obtener los productos que han sido añadidos como favoritos por más de 10 clientes distintos.

### RESPUESTA
```sql
SELECT p.id AS producto_id, p.name AS nombre, COUNT(DISTINCT f.customer_id) AS total_clientes
FROM products AS p
JOIN details_favorites AS df ON p.id = df.product_id
JOIN favorites AS f ON df.favorite_id = f.id
GROUP BY p.id, p.name
HAVING COUNT(DISTINCT f.customer_id) > 10;
```
## 7. Como gerente regional, quiero obtener todas las empresas activas por ciudad y categoría.

### RESPUESTA

```sql
SELECT c.city_id,c.category_id,COUNT(DISTINCT c.id) AS empresas_activas
FROM companies AS c
JOIN companyproducts cp ON c.id = cp.company_id
GROUP BY c.city_id, c.category_id;
```
## 8. Como especialista en marketing, deseo obtener los 10 productos más calificados en cada ciudad.

### RESPUESTA
```sql
SELECT ci.name AS ciuadad,
p.name AS producto,
COUNT(qp.rating) AS total_calificaciones,
ROUND(AVG(qp.rating), 2) AS promedio_calificacion
FROM citiesormunicipalities AS ci
JOIN companies AS co ON ci.code = co.city_id
JOIN quality_products qp ON co.id = qp.company_id
JOIN products AS p ON qp.product_id = p.id
GROUP BY ci.name, p.name
ORDER BY ci.name, total_calificaciones DESC LIMIT 10;
```

## 9. Como técnico, quiero identificar productos sin unidad de medida asignada.

### RESPUESTA
```sql
SELECT p.id AS producto_id, p.name AS nombre_producto
FROM products AS p
LEFT JOIN companyproducts AS cp ON p.id = cp.product_id
WHERE cp.unimeasure_id IS NULL
ORDER BY p.name;
```
## 10. Como gestor de beneficios, deseo ver los planes de membresía sin beneficios registrados.

### RESPUESTA
```sql
SELECT m.id AS membresia_id, m.name AS nombre_membresia,m.description AS descripcion
FROM memberships AS m
LEFT JOIN membershipbenefits AS mb ON m.id = mb.membership_id
WHERE mb.membership_id IS NULL
ORDER BY m.name;
```
## 11. Como supervisor, quiero obtener los productos de una categoría específica con su promedio de calificación.

### RESPUESTA
```sql
SELECT p.id AS producto_id, p.name AS nombre, AVG(qp.rating) AS promedio
FROM products AS p
JOIN quality_products AS qp ON p.id = qp.product_id
WHERE p.category_id = 1
GROUP BY p.id, p.name;

```
## 12. Como asesor, deseo obtener los clientes que han comprado productos de más de una empresa.
### RESPUESTA
```sql
SELECT qp.customer_id, cu.name AS nombre_cliente, COUNT(DISTINCT qp.company_id) AS total_empresas
FROM quality_products AS qp
JOIN customers AS cu ON qp.customer_id = cu.id
GROUP BY qp.customer_id, cu.name
HAVING COUNT(DISTINCT qp.company_id) > 1;
```
## 13. Como director, quiero identificar las ciudades con más clientes activos.

### REPUESTA
```sql
SELECT c.name AS ciudad, COUNT(DISTINCT cu.id) AS total_clientes,s.name AS region,
co.name AS pais
FROM citiesormunicipalities AS c 
JOIN customers AS cu ON c.code = cu.city_id
JOIN stateorregions AS s ON c.statereg_id = s.code
JOIN countries AS co ON s.country_id = co.isocode
GROUP BY c.name, s.name, co.name
HAVING COUNT(DISTINCT cu.id) > 0
ORDER BY  total_clientes DESC;
```
## 14. Como analista de calidad, deseo obtener el ranking de productos por empresa basado en la media de `quality_products`.

### RESPUESTA
```sql
SELECT co.name AS empresa,p.name AS producto,ROUND(AVG(qp.rating), 2) AS promedio_calificacion,COUNT(qp.rating) AS total_calificaciones,DENSE_RANK() OVER(PARTITION BY co.name ORDER BY AVG(qp.rating) DESC) AS ranking_calidad
FROM companies co
JOIN quality_products qp ON co.id = qp.company_id
JOIN products p ON qp.product_id = p.id
GROUP BY co.name, p.name
HAVING COUNT(qp.rating) >= 3 
ORDER BY co.name,promedio_calificacion DESC;

```
## 15. Como administrador, quiero listar empresas que ofrecen más de cinco productos distintos.

### REPUESTA
```sql
SELECT c.id AS empresa_id, c.name AS empresa, COUNT(DISTINCT cp.product_id) AS total_productos
FROM companies AS c
JOIN companyproducts AS cp ON c.id = cp.company_id
GROUP BY c.id,c.name
HAVING COUNT(DISTINCT cp.product_id) > 5;
```
## 16. Como cliente, deseo visualizar los productos favoritos que aún no han sido calificados.

### RESPUESTA

```sql
SELECT p.id AS producto_id,p.name AS producto_nombre,
f.customer_id
FROM favorites AS f
JOIN details_favorites AS df ON f.id = df.favorite_id
JOIN products AS p ON df.product_id = p.id
LEFT JOIN quality_products AS qp ON p.id = qp.product_id AND f.customer_id = qp.customer_id
WHERE qp.product_id IS NULL;
```
## 17. Como desarrollador, deseo consultar los beneficios asignados a cada audiencia junto con su descripción.

### RESPUESTA
```sql
SELECT 
    a.id AS audiencia_id,
    a.description AS audiencia,
    b.id AS beneficio_id,
    b.description AS beneficio,
    b.detail AS detalle
FROM audiencebenefits ab
JOIN audiences a ON ab.audience_id = a.id
JOIN benefits b ON ab.benefit_id = b.id
ORDER BY a.id, b.id;
```
## 18. Como operador logístico, quiero saber en qué ciudades hay empresas sin productos asociados.

### RESPUESTA

```sql
SELECT 
    cm.code AS ciudad_id,
    cm.name AS ciudad_nombre,
    COUNT(c.id) AS empresas_sin_productos
FROM companies c
JOIN citiesormunicipalities cm ON c.city_id = cm.code
LEFT JOIN companyproducts cp ON c.id = cp.company_id
WHERE cp.product_id IS NULL
GROUP BY cm.code, cm.name;
```
## 19. Como técnico, deseo obtener todas las empresas con productos duplicados por nombre.

### RESPUESTA
```sql
SELECT 
    c.id AS empresa_id,
    c.name AS empresa_nombre,
    p.name AS nombre_producto,
    COUNT(*) AS veces_repetido
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
JOIN products p ON cp.product_id = p.id
GROUP BY c.id, p.name
HAVING COUNT(*) > 1
ORDER BY c.id, veces_repetido DESC;
```
## 20. Como analista, quiero una vista resumen de clientes, productos favoritos y promedio de calificación recibido.


### RESPUESTAS

```sql
SELECT 
    c.id AS cliente_id,
    c.name AS nombre_cliente,
    c.email AS email_cliente,
    COUNT(DISTINCT f.id) AS total_favoritos,
    COUNT(DISTINCT qp.product_id) AS productos_calificados,
    ROUND(AVG(qp.rating), 2) AS promedio_calificaciones,
    GROUP_CONCAT(DISTINCT p.name SEPARATOR ' | ') AS productos_favoritos
FROM 
    customers c
LEFT JOIN 
    favorites f ON c.id = f.customer_id
LEFT JOIN 
    details_favorites df ON f.id = df.favorite_id
LEFT JOIN 
    products p ON df.product_id = p.id
LEFT JOIN 
    quality_products qp ON c.id = qp.customer_id
GROUP BY 
    c.id, c.name, c.email
ORDER BY 
    total_favoritos DESC, promedio_calificaciones DESC;

```
------

## 🔹 **2. Subconsultas**

# 1. Como gerente, quiero ver los productos cuyo precio esté por encima del promedio de su categoría.
 ## RESPUESTA

 ```sql
  SELECT p.id, p.name, p.price, p.category_id
  FROM products AS p 
  WHERE p.price >(
    SELECT AVG(p2.price)
    FROM products AS p2
    WHERE p2.category_id = p.category_id
    );
 ```
# 2. Como administrador, deseo listar las empresas que tienen más productos que la media de empresas.

## RESPUESTA
```sql
SELECT c.id, c.name,COUNT(cp.product_id) AS total_productos
FROM companies AS c
JOIN companyproducts AS cp ON c.id = cp.company_id
GROUP BY c.id, c.name
HAVING COUNT(cp.product_id) > (
    SELECT AVG(productos_por_empresa)
    FROM (
        SELECT COUNT(cp2.product_id) AS productos_por_empresa
        FROM companyproducts AS cp2
        GROUP BY cp2.company_id) AS sub
);
```
# 3. Como cliente, quiero ver mis productos favoritos que han sido calificados por otros clientes.
### RESPUESTA

``` sql
SELECT  c.name AS cliente,
p.name AS producto_favorito,
(
    SELECT ROUND(AVG(qp.rating),2)
    FROM quality_products AS qp
    WHERE qp.product_id = p.id AND qp.customer_id != c.id
) AS calificacion_de_otros_clientes
FROM customers AS c
JOIN favorites AS f ON c.id = f.customer_id
JOIN details_favorites AS df ON f.id = df.favorite_id
JOIN products AS p ON df.product_id = p.id
WHERE EXISTS (
    SELECT 1 FROM quality_products AS qp
    WHERE qp.product_id = p.id AND qp.customer_id != c.id
)
ORDER BY c.name, calificacion_de_otros_clientes DESC;
```
# 4. Como supervisor, deseo obtener los productos con el mayor número de veces añadidos como favoritos.

## RESPUESTA
```sql
SELECT p.name AS producto,COUNT(DISTINCT df.favorite_id) AS añadidos_favoritos,(SELECT COUNT(DISTINCT id) FROM customers) AS total_clientes
FROM products AS p
JOIN details_favorites AS df ON p.id = df.product_id
GROUP BY p.id, p.name
ORDER BY añadidos_favoritos DESC LIMIT 10;

```
# 5. Como técnico, quiero listar los clientes cuyo correo no aparece en la tabla `rates` ni en `quality_products`.

### RESPUESTA

```sql
SELECT c.id, c.name, c.email
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 FROM rates r 
    JOIN customers c2 ON r.customer_id = c2.id 
    WHERE c2.email = c.email
)
AND NOT EXISTS (
    SELECT 1 FROM quality_products qp
    JOIN customers c3 ON qp.customer_id = c3.id
    WHERE c3.email = c.email
)
ORDER BY c.name;
```
# 6. Como gestor de calidad, quiero obtener los productos con una calificación inferior al mínimo de su categoría.
## REPUESTA
```sql
SELECT qp.product_id, p.name, qp.rating, p.category_id
FROM quality_products AS qp
JOIN products AS p ON qp.product_id = p.id
WHERE qp.rating = (
    SELECT MIN(qp2.rating)
    FROM quality_products AS qp2
    JOIN products AS p2 ON qp2.product_id = p2.id
    WHERE p2.category_id = p.category_id
);
```
# 7. Como desarrollador, deseo listar las ciudades que no tienen clientes registrados.
### RESPUESTA
``` sql
SELECT c.code, c.name
FROM citiesormunicipalities c
WHERE NOT EXISTS (
    SELECT 1
    FROM customers cu
    WHERE cu.city_id = c.code
);
```

# 8. Como administrador, quiero ver los productos que no han sido evaluados en ninguna encuesta.
## RESPUESTA
```sql
SELECT p.id, p.name, p.category_id
FROM products p
WHERE p.id NOT IN (
    SELECT DISTINCT product_id FROM quality_products
)
AND p.id NOT IN (
    SELECT DISTINCT cp.product_id 
    FROM companyproducts cp
    JOIN rates r ON cp.company_id = r.company_id
)
ORDER BY p.name;
```

# 9. Como auditor, quiero listar los beneficios que no están asignados a ninguna audiencia.

## REPUESTA
```sql
SELECT b.id, b.description
FROM benefits b
WHERE NOT EXISTS (
    SELECT 1
    FROM audiencebenefits ab
    WHERE ab.benefit_id = b.id
);
```
# 10. Como cliente, deseo obtener mis productos favoritos que no están disponibles actualmente en ninguna empresa.
## RESPUESTA

```sql

SELECT p.id, p.name, p.detail
FROM products p
JOIN details_favorites df ON p.id = df.product_id
JOIN favorites f ON df.favorite_id = f.id
WHERE f.customer_id = @cliente_id
  AND p.id NOT IN (
    SELECT DISTINCT product_id 
    FROM companyproducts
    WHERE product_id IS NOT NULL
)
ORDER BY p.name;
```
# 11. Como director, deseo consultar los productos vendidos en empresas cuya ciudad tenga menos de tres empresas registradas.
## RESPUESTA
```sql
SELECT 
    p.id AS producto_id,
    p.name AS producto,
    c.name AS ciudad,
    COUNT(DISTINCT co.id) AS empresas_en_ciudad
FROM 
    products p
JOIN 
    companyproducts cp ON p.id = cp.product_id
JOIN 
    companies co ON cp.company_id = co.id
JOIN 
    citiesormunicipalities c ON co.city_id = c.code
GROUP BY 
    p.id, p.name, c.name
HAVING 
    COUNT(DISTINCT co.id) < 3
ORDER BY 
    c.name, p.name;
```

# 12. Como analista, quiero ver los productos con calidad superior al promedio de todos los productos.
## RESPUESTA
```sql
SELECT 
    p.id AS producto_id,
    p.name AS producto,
    ROUND(AVG(qp.rating), 2) AS calificacion_promedio,
    (SELECT ROUND(AVG(rating), 2) FROM quality_products) AS promedio_general
FROM 
    products p
JOIN 
    quality_products qp ON p.id = qp.product_id
GROUP BY 
    p.id, p.name
HAVING 
    AVG(qp.rating) > (SELECT AVG(rating) FROM quality_products)
ORDER BY 
    calificacion_promedio DESC;
```
# 13. Como gestor, quiero ver empresas que sólo venden productos de una única categoría.
## RESPUESTA
```sql
SELECT 
    co.id AS empresa_id,
    co.name AS empresa,
    COUNT(DISTINCT p.category_id) AS categorias_distintas,
    MAX(c.description) AS categoria_unica
FROM 
    companies co
JOIN 
    companyproducts cp ON co.id = cp.company_id
JOIN 
    products p ON cp.product_id = p.id
JOIN 
    categories c ON p.category_id = c.id
GROUP BY 
    co.id, co.name
HAVING 
    COUNT(DISTINCT p.category_id) = 1
ORDER BY 
    co.name;
```
# 14. Como gerente comercial, quiero consultar los productos con el mayor precio entre todas las empresas.
## RESPUESTA
```sql
SELECT 
    p.id AS producto_id,
    p.name AS producto,
    MAX(cp.price) AS precio_maximo,
    GROUP_CONCAT(DISTINCT co.name SEPARATOR ' | ') AS empresas_con_precio_maximo
FROM 
    products p
JOIN 
    companyproducts cp ON p.id = cp.product_id
JOIN 
    companies co ON cp.company_id = co.id
WHERE 
    cp.price = (SELECT MAX(price) FROM companyproducts WHERE product_id = p.id)
GROUP BY 
    p.id, p.name
ORDER BY 
    precio_maximo DESC;
```
# 15. Como cliente, quiero saber si algún producto de mis favoritos ha sido calificado por otro cliente con más de 4 estrellas.
## RESPUESTA
```sql
SELECT DISTINCT
    c.name AS cliente,
    p.name AS producto_favorito,
    (SELECT COUNT(*) 
     FROM quality_products qp 
     WHERE qp.product_id = p.id 
     AND qp.rating > 4 
     AND qp.customer_id != c.id) AS calificaciones_altas
FROM 
    customers c
JOIN 
    favorites f ON c.id = f.customer_id
JOIN 
    details_favorites df ON f.id = df.favorite_id
JOIN 
    products p ON df.product_id = p.id
WHERE 
    EXISTS (SELECT 1 FROM quality_products qp 
            WHERE qp.product_id = p.id 
            AND qp.rating > 4 
            AND qp.customer_id != c.id)
ORDER BY 
    c.name, calificaciones_altas DESC;
```
# 16. Como operador, quiero saber qué productos no tienen imagen asignada pero sí han sido calificados.
## RESPUESTA
```sql
SELECT 
    p.id AS producto_id,
    p.name AS producto,
    COUNT(qp.rating) AS total_calificaciones,
    ROUND(AVG(qp.rating), 2) AS promedio_calificacion
FROM 
    products p
JOIN 
    quality_products qp ON p.id = qp.product_id
WHERE 
    p.image IS NULL OR p.image = ''
GROUP BY 
    p.id, p.name
HAVING 
    COUNT(qp.rating) > 0
ORDER BY 
    total_calificaciones DESC;
```
# 17. Como auditor, quiero ver los planes de membresía sin periodo vigente.
## RESPUESTA
```sql
SELECT 
    m.id AS membresia_id,
    m.name AS membresia,
    m.description AS descripcion
FROM 
    memberships m
LEFT JOIN 
    membershipperiods mp ON m.id = mp.membership_id
WHERE 
    mp.membership_id IS NULL
ORDER BY 
    m.name;
```
# 18. Como especialista, quiero identificar los beneficios compartidos por más de una audiencia.
## RESPUESTA
```sql
SELECT 
    b.id AS beneficio_id,
    b.description AS beneficio,
    COUNT(DISTINCT ab.audience_id) AS audiencias_asignadas,
    GROUP_CONCAT(DISTINCT a.description SEPARATOR ' | ') AS audiencias
FROM 
    benefits b
JOIN 
    audiencebenefits ab ON b.id = ab.benefit_id
JOIN 
    audiences a ON ab.audience_id = a.id
GROUP BY 
    b.id, b.description
HAVING 
    COUNT(DISTINCT ab.audience_id) > 1
ORDER BY 
    audiencias_asignadas DESC;
```
# 19. Como técnico, quiero encontrar empresas cuyos productos no tengan unidad de medida definida.
## RESPUESTA
```sql
SELECT 
    co.id AS empresa_id,
    co.name AS empresa,
    COUNT(DISTINCT cp.product_id) AS productos_sin_unidad
FROM 
    companies co
JOIN 
    companyproducts cp ON co.id = cp.company_id
WHERE 
    cp.unimeasure_id IS NULL
GROUP BY 
    co.id, co.name
HAVING 
    COUNT(DISTINCT cp.product_id) > 0
ORDER BY 
    productos_sin_unidad DESC;
```
# 20. Como gestor de campañas, deseo obtener los clientes con membresía activa y sin productos favoritos.
## RESPUESTA
```sql
SELECT 
    c.id AS cliente_id,
    c.name AS cliente,
    c.email,
    m.name AS membresia_activa
FROM 
    customers c
JOIN 
    memberships m ON c.audience_id = m.id  -- Asumiendo que audience_id relaciona con membresía
LEFT JOIN 
    favorites f ON c.id = f.customer_id
WHERE 
    f.id IS NULL
ORDER BY 
    c.name;
```

------

## 🔹 **3. Funciones Agregadas**

1. ### **1. Obtener el promedio de calificación por producto**

   > *"Como analista, quiero obtener el promedio de calificación por producto."*

   🔍 **Explicación para dummies:**
    La persona encargada de revisar el rendimiento quiere saber **qué tan bien calificado está cada producto**. Con `AVG(rating)` agrupado por `product_id`, puede verlo de forma resumida.

   ------
### RESPUESTA
```sql
SELECT product_id, AVG(rating) as promedio_calificacion
FROM quality_products
GROUP BY product_id;
```

   ### **2. Contar cuántos productos ha calificado cada cliente**

   > *"Como gerente, desea contar cuántos productos ha calificado cada cliente."*

   🔍 **Explicación:**
    Aquí se quiere saber **quiénes están activos opinando**. Se usa `COUNT(*)` sobre `rates`, agrupando por `customer_id`.

   ------
### RESPUESTA
```sql
SELECT customer_id, COUNT(DISTINCT product_id) as productos_calificados
FROM quality_products
GROUP BY customer_id;
```
   ### **3. Sumar el total de beneficios asignados por audiencia**

   > *"Como auditor, quiere sumar el total de beneficios asignados por audiencia."*

   🔍 **Explicación:**
    El auditor busca **cuántos beneficios tiene cada tipo de usuario**. Con `COUNT(*)` agrupado por `audience_id` en `audiencebenefits`, lo obtiene.

   ------
### RESPUESTA
```sql
SELECT audience_id, COUNT(*) as total_beneficios
FROM audiencebenefits
GROUP BY audience_id;
```
   ### **4. Calcular la media de productos por empresa**

   > *"Como administrador, desea conocer la media de productos por empresa."*

   🔍 **Explicación:**
    El administrador quiere saber si **las empresas están ofreciendo pocos o muchos productos**. Cuenta los productos por empresa y saca el promedio con `AVG(cantidad)`.

   ------
### RESPUESTA
```sql
SELECT AVG(conteo) as media_productos
FROM (
  SELECT company_id, COUNT(*) as conteo
  FROM companyproducts
  GROUP BY company_id
) as subquery;
```
   ### **5. Contar el total de empresas por ciudad**

   > *"Como supervisor, quiere ver el total de empresas por ciudad."*

   🔍 **Explicación:**
    La idea es ver **en qué ciudades hay más movimiento empresarial**. Se usa `COUNT(*)` en `companies`, agrupando por `city_id`.

   ------
### RESPUESTA
```sql
SELECT city_id, COUNT(*) as total_empresas
FROM companies
GROUP BY city_id;
```
   ### **6. Calcular el promedio de precios por unidad de medida**

   > *"Como técnico, desea obtener el promedio de precios de productos por unidad de medida."*

   🔍 **Explicación:**
    Se necesita saber si **los precios son coherentes según el tipo de medida**. Con `AVG(price)` agrupado por `unit_id`, se compara cuánto cuesta el litro, kilo, unidad, etc.

   ------
### RESPUESTA
```sql
SELECT unimeasure_id, AVG(price) as precio_promedio
FROM companyproducts
GROUP BY unimeasure_id;
```
   ### **7. Contar cuántos clientes hay por ciudad**

   > *"Como gerente, quiere ver el número de clientes registrados por cada ciudad."*

   🔍 **Explicación:**
    Con `COUNT(*)` agrupado por `city_id` en la tabla `customers`, se obtiene **la cantidad de clientes que hay en cada zona**.

   ------
### RESPUESTA
```sql
SELECT city_id, COUNT(*) as total_clientes
FROM customers
GROUP BY city_id;
```
   ### **8. Calcular planes de membresía por periodo**

   > *"Como operador, desea contar cuántos planes de membresía existen por periodo."*

   🔍 **Explicación:**
    Sirve para ver **qué tantos planes están vigentes cada mes o trimestre**. Se agrupa por periodo (`start_date`, `end_date`) y se cuenta cuántos registros hay.

   ------
### RESPUESTA
```sql
SELECT period_id, COUNT(*) as total_planes
FROM membershipperiods
GROUP BY period_id;
```
   ### **9. Ver el promedio de calificaciones dadas por un cliente a sus favoritos**

   > *"Como cliente, quiere ver el promedio de calificaciones que ha otorgado a sus productos favoritos."*

   🔍 **Explicación:**
    El cliente quiere saber **cómo ha calificado lo que más le gusta**. Se hace un `JOIN` entre favoritos y calificaciones, y se saca `AVG(rating)`.

   ------
### RESPUESTA
```sql
SELECT f.customer_id, AVG(qp.rating) as promedio_favoritos
FROM favorites f
JOIN details_favorites df ON f.id = df.favorite_id
JOIN quality_products qp ON df.product_id = qp.product_id AND f.customer_id = qp.customer_id
GROUP BY f.customer_id;
```
   ### **10. Consultar la fecha más reciente en que se calificó un producto**

   > *"Como auditor, desea obtener la fecha más reciente en la que se calificó un producto."*

   🔍 **Explicación:**
    Busca el `MAX(created_at)` agrupado por producto. Así sabe **cuál fue la última vez que se evaluó cada uno**.

   ------
### RESPUESTA
```sql
SELECT product_id, MAX(daterating) as ultima_calificacion
FROM quality_products
GROUP BY product_id;
```
   ### **11. Obtener la desviación estándar de precios por categoría**

   > *"Como desarrollador, quiere conocer la variación de precios por categoría de producto."*

   🔍 **Explicación:**
    Usando `STDDEV(price)` en `companyproducts` agrupado por `category_id`, se puede ver **si hay mucha diferencia de precios dentro de una categoría**.

   ------
### RESPUESTA
```sql
SELECT p.category_id, STDDEV(cp.price) as desviacion_precios
FROM companyproducts cp
JOIN products p ON cp.product_id = p.id
GROUP BY p.category_id;
```
   ### **12. Contar cuántas veces un producto fue favorito**

   > *"Como técnico, desea contar cuántas veces un producto fue marcado como favorito."*

   🔍 **Explicación:**
    Con `COUNT(*)` en `details_favorites`, agrupado por `product_id`, se obtiene **cuáles productos son los más populares entre los clientes**.

   ------
### RESPUESTA
```sql
SELECT product_id, COUNT(*) as veces_favorito
FROM details_favorites
GROUP BY product_id;
```
   ### **13. Calcular el porcentaje de productos evaluados**

   > *"Como director, quiere saber qué porcentaje de productos han sido calificados al menos una vez."*

   🔍 **Explicación:**
    Cuenta cuántos productos hay en total y cuántos han sido evaluados (`rates`). Luego calcula `(evaluados / total) * 100`.

   ------
### RESPUESTA
```sql
SELECT 
  (COUNT(DISTINCT qp.product_id) * 100.0 / COUNT(DISTINCT p.id)) as porcentaje_evaluados
FROM products p
LEFT JOIN quality_products qp ON p.id = qp.product_id;
```
   ### **14. Ver el promedio de rating por encuesta**

   > *"Como analista, desea conocer el promedio de rating por encuesta."*

   🔍 **Explicación:**
    Agrupa por `poll_id` en `rates`, y calcula el `AVG(rating)` para ver **cómo se comportó cada encuesta**.

   ------
### RESPUESTA
```sql
SELECT poll_id, AVG(rating) as promedio_rating
FROM quality_products
GROUP BY poll_id;
```
   ### **15. Calcular el promedio y total de beneficios por plan**

   > *"Como gestor, quiere obtener el promedio y el total de beneficios asignados a cada plan de membresía."*

   🔍 **Explicación:**
    Agrupa por `membership_id` en `membershipbenefits`, y usa `COUNT(*)` y `AVG(beneficio)` si aplica (si hay ponderación).

   ------
### RESPUESTA
```sql
SELECT 
  membership_id, 
  COUNT(*) as total_beneficios,
  AVG(benefit_id) as promedio_beneficios
FROM membershipbenefits
GROUP BY membership_id;
```
   ### **16. Obtener media y varianza de precios por empresa**

   > *"Como gerente, desea obtener la media y la varianza del precio de productos por empresa."*

   🔍 **Explicación:**
    Se agrupa por `company_id` y se usa `AVG(price)` y `VARIANCE(price)` para saber **qué tan consistentes son los precios por empresa**.

   ------
### RESPUESTA
```sql
SELECT 
  company_id,
  AVG(price) as precio_medio,
  VARIANCE(price) as varianza_precios
FROM companyproducts
GROUP BY company_id;
```
   ### **17. Ver total de productos disponibles en la ciudad del cliente**

   > *"Como cliente, quiere ver cuántos productos están disponibles en su ciudad."*

   🔍 **Explicación:**
    Hace un `JOIN` entre `companies`, `companyproducts` y `citiesormunicipalities`, filtrando por la ciudad del cliente. Luego se cuenta.

   ------
### RESPUESTA
```sql
SELECT 
  c.city_id,
  COUNT(DISTINCT cp.product_id) as productos_disponibles
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
GROUP BY c.city_id;
```
   ### **18. Contar productos únicos por tipo de empresa**

   > *"Como administrador, desea contar los productos únicos por tipo de empresa."*

   🔍 **Explicación:**
    Agrupa por `company_type_id` y cuenta cuántos productos diferentes tiene cada tipo de empresa.

   ------
### RESPUESTA
```sql
SELECT 
  c.type_id,
  COUNT(DISTINCT cp.product_id) as productos_unicos
FROM companies c
JOIN companyproducts cp ON c.id = cp.company_id
GROUP BY c.type_id;
```
   ### **19. Ver total de clientes sin correo electrónico registrado**

   > *"Como operador, quiere saber cuántos clientes no han registrado su correo."*

   🔍 **Explicación:**
    Filtra `customers WHERE email IS NULL` y hace un `COUNT(*)`. Esto ayuda a mejorar la base de datos para campañas.
### RESPUESTA
```sql
SELECT COUNT(*) as clientes_sin_email
FROM customers
WHERE email IS NULL OR email = '';
```
   ------

   ### **20. Empresa con más productos calificados**

   > *"Como especialista, desea obtener la empresa con el mayor número de productos calificados."*

   🔍 **Explicación:**
    Hace un `JOIN` entre `companies`, `companyproducts`, y `rates`, agrupa por empresa y usa `COUNT(DISTINCT product_id)`, ordenando en orden descendente y tomando solo el primero.

------
### RESPUESTA
```sql
SELECT 
  c.id,
  c.name,
  COUNT(DISTINCT qp.product_id) as productos_calificados
FROM companies c
JOIN quality_products qp ON c.id = qp.company_id
GROUP BY c.id, c.name
ORDER BY productos_calificados DESC
LIMIT 1;
```
## 🔹 **4. Procedimientos Almacenados**

1. ### **1. Registrar una nueva calificación y actualizar el promedio**

   > *"Como desarrollador, quiero un procedimiento que registre una calificación y actualice el promedio del producto."*

   🧠 **Explicación:**
    Este procedimiento recibe `product_id`, `customer_id` y `rating`, inserta la nueva fila en `rates`, y recalcula automáticamente el promedio en la tabla `products` (campo `average_rating`).
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_registrar_calificacion(
    IN p_product_id INT,
    IN p_customer_id INT,
    IN p_rating DECIMAL(3,1)
)
BEGIN
    DECLARE avg_rating DECIMAL(3,1);
    
    -- Insertar nueva calificación
    INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
    VALUES (p_product_id, p_customer_id, 1, NULL, NOW(), p_rating);
    
    SELECT AVG(rating) INTO avg_rating
    FROM quality_products
    WHERE product_id = p_product_id;
    
    UPDATE products
    SET average_rating = avg_rating
    WHERE id = p_product_id;
END //
DELIMITER ;


CALL sp_registrar_calificacion(5, 10, 4.5);
```
   ------

   ### **2. Insertar empresa y asociar productos por defecto**

   > *"Como administrador, deseo un procedimiento para insertar una empresa y asociar productos por defecto."*

   🧠 **Explicación:**
    Este procedimiento inserta una empresa en `companies`, y luego vincula automáticamente productos predeterminados en `companyproducts`.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_insertar_empresa_con_productos(
    IN p_id VARCHAR(20),
    IN p_type_id INT,
    IN p_name VARCHAR(80),
    IN p_category_id INT,
    IN p_city_id VARCHAR(6),
    IN p_audience_id INT,
    IN p_cellphone VARCHAR(15),
    IN p_email VARCHAR(80))
BEGIN

    INSERT INTO companies (id, type_id, name, category_id, city_id, audience_id, cellphone, email)
    VALUES (p_id, p_type_id, p_name, p_category_id, p_city_id, p_audience_id, p_cellphone, p_email);
    
   
    INSERT INTO companyproducts (company_id, product_id, price, unimeasure_id)
    VALUES 
        (p_id, 1, 100.00, 1),
        (p_id, 2, 150.00, 1),
        (p_id, 3, 200.00, 2),
        (p_id, 4, 75.00, 3),
        (p_id, 5, 120.00, 1);
END //
DELIMITER ;

CALL sp_insertar_empresa_con_productos(
    'COMP021', 
    4, 
    'Nueva Empresa SA', 
    3, 
    'BOG001', 
    6, 
    '6012345678', 
    'contacto@nuevaempresa.com'
);
```
   ------

   ### **3. Añadir producto favorito validando duplicados**

   > *"Como cliente, quiero un procedimiento que añada un producto favorito y verifique duplicados."*

   🧠 **Explicación:**
    Verifica si el producto ya está en favoritos (`details_favorites`). Si no lo está, lo inserta. Evita duplicaciones silenciosamente.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_agregar_favorito(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_company_id VARCHAR(20))
BEGIN
    DECLARE v_favorite_id INT;
    DECLARE v_exists INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_exists
    FROM favorites f
    JOIN details_favorites df ON f.id = df.favorite_id
    WHERE f.customer_id = p_customer_id
    AND df.product_id = p_product_id;
    
    IF v_exists = 0 THEN
        SELECT id INTO v_favorite_id FROM favorites 
        WHERE customer_id = p_customer_id AND company_id = p_company_id;
        
        IF v_favorite_id IS NULL THEN
            INSERT INTO favorites (customer_id, company_id)
            VALUES (p_customer_id, p_company_id);
            SET v_favorite_id = LAST_INSERT_ID();
        END IF;
    
        INSERT INTO details_favorites (favorite_id, product_id)
        VALUES (v_favorite_id, p_product_id);
    END IF;
END //
DELIMITER ;

CALL sp_agregar_favorito(8, 12, 'COMP005');
```
   ------

   ### **4. Generar resumen mensual de calificaciones por empresa**

   > *"Como gestor, deseo un procedimiento que genere un resumen mensual de calificaciones por empresa."*

   🧠 **Explicación:**
    Hace una consulta agregada con `AVG(rating)` por empresa, y guarda los resultados en una tabla de resumen tipo `resumen_calificaciones`.
### REPUESTA
```sql
DELIMITER //
CREATE PROCEDURE sp_generar_resumen_calificaciones(IN p_mes INT, IN p_anio INT)
BEGIN
    DELETE FROM resumen_calificaciones 
    WHERE mes = p_mes AND anio = p_anio;
    
    INSERT INTO resumen_calificaciones (empresa_id, mes, anio, promedio_calificacion, total_calificaciones)
    SELECT 
        qp.company_id,
        p_mes,
        p_anio,
        AVG(qp.rating) AS promedio,
        COUNT(*) AS total
    FROM quality_products qp
    WHERE MONTH(qp.daterating) = p_mes 
    AND YEAR(qp.daterating) = p_anio
    GROUP BY qp.company_id;
END //
DELIMITER ;

CALL sp_generar_resumen_calificaciones(6, 2023);
```
   ------

   ### **5. Calcular beneficios activos por membresía**

   > *"Como supervisor, quiero un procedimiento que calcule beneficios activos por membresía."*

   🧠 **Explicación:**
    Consulta `membershipbenefits` junto con `membershipperiods`, y devuelve una lista de beneficios vigentes según la fecha actual.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_beneficios_activos_membresia(IN p_membership_id INT)
BEGIN
    SELECT b.id, b.description, b.detail
    FROM membershipbenefits mb
    JOIN benefits b ON mb.benefit_id = b.id
    JOIN membershipperiods mp ON mb.membership_id = mp.membership_id AND mb.period_id = mp.period_id
    WHERE mb.membership_id = p_membership_id
    AND mp.start_date <= CURDATE()
    AND mp.end_date >= CURDATE();
END //
DELIMITER ;


CALL sp_beneficios_activos_membresia(3);
```
   ------

   ### **6. Eliminar productos huérfanos**

   > *"Como técnico, deseo un procedimiento que elimine productos sin calificación ni empresa asociada."*

   🧠 **Explicación:**
    Elimina productos de la tabla `products` que no tienen relación ni en `rates` ni en `companyproducts`.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_eliminar_productos_huérfanos()
BEGIN
    DELETE FROM products
    WHERE id NOT IN (SELECT product_id FROM companyproducts)
    AND id NOT IN (SELECT product_id FROM quality_products);
END //
DELIMITER ;

CALL sp_eliminar_productos_huérfanos();
```
   ------

   ### **7. Actualizar precios de productos por categoría**

   > *"Como operador, quiero un procedimiento que actualice precios de productos por categoría."*

   🧠 **Explicación:**
    Recibe un `categoria_id` y un `factor` (por ejemplo 1.05), y multiplica todos los precios por ese factor en la tabla `companyproducts`.
### REPUESTA
```sql
DELIMITER //
CREATE PROCEDURE sp_actualizar_precios_categoria(
    IN p_category_id INT,
    IN p_factor DECIMAL(10,2))
BEGIN
    UPDATE companyproducts cp
    JOIN products p ON cp.product_id = p.id
    SET cp.price = cp.price * p_factor
    WHERE p.category_id = p_category_id;
END //
DELIMITER ;

CALL sp_actualizar_precios_categoria(3, 1.1);
```
   ------

   ### **8. Validar inconsistencia entre `rates` y `quality_products`**

   > *"Como auditor, deseo un procedimiento que liste inconsistencias entre `rates` y `quality_products`."*

   🧠 **Explicación:**
    Busca calificaciones (`rates`) que no tengan entrada correspondiente en `quality_products`. Inserta el error en una tabla `errores_log`.
### REPUESTA
```sql
DELIMITER //
CREATE PROCEDURE sp_validar_inconsistencias_ratings()
BEGIN
    INSERT INTO errores_log (tipo_error, descripcion, fecha)
    SELECT 
        'INCONSISTENCIA_RATINGS',
        CONCAT('Rating sin entrada en quality_products: ', r.id),
        NOW()
    FROM rates r
    LEFT JOIN quality_products qp ON r.customer_id = qp.customer_id AND r.company_id = qp.company_id
    WHERE qp.id IS NULL;
END //
DELIMITER ;

CALL sp_validar_inconsistencias_ratings();
```
   ------

   ### **9. Asignar beneficios a nuevas audiencias**

   > *"Como desarrollador, quiero un procedimiento que asigne beneficios a nuevas audiencias."*

   🧠 **Explicación:**
    Recibe un `benefit_id` y `audience_id`, verifica si ya existe el registro, y si no, lo inserta en `audiencebenefits`.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_asignar_beneficio_audiencia(
    IN p_benefit_id INT,
    IN p_audience_id INT)
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_exists
    FROM audiencebenefits
    WHERE benefit_id = p_benefit_id AND audience_id = p_audience_id;
    
    IF v_exists = 0 THEN
        INSERT INTO audiencebenefits (audience_id, benefit_id)
        VALUES (p_audience_id, p_benefit_id);
    END IF;
END //
DELIMITER ;

CALL sp_asignar_beneficio_audiencia(5, 2);
```
   ------

   ### **10. Activar planes de membresía vencidos con pago confirmado**

   > *"Como administrador, deseo un procedimiento que active planes de membresía vencidos si el pago fue confirmado."*

   🧠 **Explicación:**
    Actualiza el campo `status` a `'ACTIVA'` en `membershipperiods` donde la fecha haya vencido pero el campo `pago_confirmado` sea `TRUE`.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_activar_planes_vencidos()
BEGIN
    UPDATE membershipperiods
    SET status = 'ACTIVA'
    WHERE end_date < CURDATE()
    AND pago_confirmado = TRUE
    AND status = 'INACTIVA';
END //
DELIMITER ;


CALL sp_activar_planes_vencidos();
```
   ------

   ### **11. Listar productos favoritos del cliente con su calificación**

   > *"Como cliente, deseo un procedimiento que me devuelva todos mis productos favoritos con su promedio de rating."*

   🧠 **Explicación:**
    Consulta todos los productos favoritos del cliente y muestra el promedio de calificación de cada uno, uniendo `favorites`, `rates` y `products`.
### REPUESTA
```sql
DELIMITER //
CREATE PROCEDURE sp_favoritos_con_calificacion(IN p_customer_id INT)
BEGIN
    SELECT 
        p.id AS product_id,
        p.name AS product_name,
        AVG(qp.rating) AS average_rating
    FROM favorites f
    JOIN details_favorites df ON f.id = df.favorite_id
    JOIN products p ON df.product_id = p.id
    LEFT JOIN quality_products qp ON p.id = qp.product_id AND f.customer_id = qp.customer_id
    WHERE f.customer_id = p_customer_id
    GROUP BY p.id, p.name;
END //
DELIMITER ;

CALL sp_favoritos_con_calificacion(15);
```
   ------

   ### **12. Registrar encuesta y sus preguntas asociadas**

   > *"Como gestor, quiero un procedimiento que registre una encuesta y sus preguntas asociadas."*

   🧠 **Explicación:**
    Inserta la encuesta principal en `polls` y luego cada una de sus preguntas en otra tabla relacionada como `poll_questions`.
### REPUESTA
```sql
DELIMITER //
CREATE PROCEDURE sp_registrar_encuesta_con_preguntas(
    IN p_name VARCHAR(80),
    IN p_description TEXT,
    IN p_categorypoll_id INT,
    IN p_preguntas TEXT) -- JSON array con preguntas
BEGIN
    DECLARE v_poll_id INT;
    
    INSERT INTO polls (name, description, isactive, categorypoll_id)
    VALUES (p_name, p_description, TRUE, p_categorypoll_id);
    
    SET v_poll_id = LAST_INSERT_ID();

    SET @preguntas = p_preguntas;
    SET @i = 0;
    WHILE @i < JSON_LENGTH(@preguntas) DO
        INSERT INTO poll_questions (poll_id, question_text, question_order)
        VALUES (v_poll_id, JSON_UNQUOTE(JSON_EXTRACT(@preguntas, CONCAT('$[', @i, ']'))), @i+1);
        SET @i = @i + 1;
    END WHILE;
END //
DELIMITER ;

CALL sp_registrar_encuesta_con_preguntas(
    'Satisfacción General', 
    'Encuesta sobre satisfacción con nuestros productos', 
    1,
    '["¿Cómo calificaría nuestro producto?", "¿Recomendaría nuestro servicio?"]'
);
```
   ------

   ### **13. Eliminar favoritos antiguos sin calificaciones**

   > *"Como técnico, deseo un procedimiento que borre favoritos antiguos no calificados en más de un año."*

   🧠 **Explicación:**
    Filtra productos favoritos que no tienen calificaciones recientes y fueron añadidos hace más de 12 meses, y los elimina de `details_favorites`.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_limpiar_favoritos_antiguos()
BEGIN
    DELETE df FROM details_favorites df
    JOIN favorites f ON df.favorite_id = f.id
    LEFT JOIN quality_products qp ON df.product_id = qp.product_id AND f.customer_id = qp.customer_id
    WHERE qp.id IS NULL
    AND f.created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
END //
DELIMITER ;

CALL sp_limpiar_favoritos_antiguos();
```
   ------

   ### **14. Asociar beneficios automáticamente por audiencia**

   > *"Como operador, quiero un procedimiento que asocie automáticamente beneficios por audiencia."*

   🧠 **Explicación:**
    Inserta en `audiencebenefits` todos los beneficios que apliquen según una lógica predeterminada (por ejemplo, por tipo de usuario).
### REPUESTA
```sql
DELIMITER //
CREATE PROCEDURE sp_asociar_beneficios_automaticos()
BEGIN
    INSERT INTO audiencebenefits (audience_id, benefit_id)
    SELECT a.id, b.id
    FROM audiences a
    CROSS JOIN benefits b
    WHERE b.is_basic = TRUE
    AND NOT EXISTS (
        SELECT 1 FROM audiencebenefits ab 
        WHERE ab.audience_id = a.id AND ab.benefit_id = b.id
    );
END //
DELIMITER ;

CALL sp_asociar_beneficios_automaticos();
```
   ------

   ### **15. Historial de cambios de precio**

   > *"Como administrador, deseo un procedimiento para generar un historial de cambios de precio."*

   🧠 **Explicación:**
    Cada vez que se cambia un precio, el procedimiento compara el anterior con el nuevo y guarda un registro en una tabla `historial_precios`.
### REPUESTA
```sql
DELIMITER //
CREATE PROCEDURE sp_registrar_cambio_precio(
    IN p_company_id VARCHAR(20),
    IN p_product_id INT,
    IN p_nuevo_precio DECIMAL(10,2))
BEGIN
    DECLARE v_viejo_precio DECIMAL(10,2);
    
    SELECT price INTO v_viejo_precio
    FROM companyproducts
    WHERE company_id = p_company_id AND product_id = p_product_id;
    
    INSERT INTO historial_precios (
        company_id, 
        product_id, 
        precio_anterior, 
        precio_nuevo, 
        fecha_cambio
    ) VALUES (
        p_company_id,
        p_product_id,
        v_viejo_precio,
        p_nuevo_precio,
        NOW()
    );

    UPDATE companyproducts
    SET price = p_nuevo_precio
    WHERE company_id = p_company_id AND product_id = p_product_id;
END //
DELIMITER ;

CALL sp_registrar_cambio_precio('COMP010', 7, 85.99);
```
   ------

   ### **16. Registrar encuesta activa automáticamente**

   > *"Como desarrollador, quiero un procedimiento que registre automáticamente una nueva encuesta activa."*

   🧠 **Explicación:**
    Inserta una encuesta en `polls` con el campo `status = 'activa'` y una fecha de inicio en `NOW()`.
### REPUESTA
```sql
DELIMITER //
CREATE PROCEDURE sp_registrar_encuesta_activa(
    IN p_name VARCHAR(80),
    IN p_description TEXT,
    IN p_categorypoll_id INT)
BEGIN
    UPDATE polls
    SET isactive = FALSE
    WHERE categorypoll_id = p_categorypoll_id;

    INSERT INTO polls (name, description, isactive, categorypoll_id, start_date)
    VALUES (p_name, p_description, TRUE, p_categorypoll_id, NOW());
END //
DELIMITER ;


CALL sp_registrar_encuesta_activa(
    'Nueva Encuesta de Calidad',
    'Encuesta sobre calidad de productos 2023',
    2
);
```
   ------

   ### **17. Actualizar unidad de medida de productos sin afectar ventas**

   > *"Como técnico, deseo un procedimiento que actualice la unidad de medida de productos sin afectar si hay ventas."*

   🧠 **Explicación:**
    Verifica si el producto no ha sido vendido, y si es así, permite actualizar su `unit_id`.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_actualizar_unidad_medida(
    IN p_company_id VARCHAR(20),
    IN p_product_id INT,
    IN p_new_unit_id INT)
BEGIN
    DECLARE v_has_sales INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_has_sales
    FROM sales
    WHERE company_id = p_company_id AND product_id = p_product_id;
    
    IF v_has_sales = 0 THEN
        UPDATE companyproducts
        SET unimeasure_id = p_new_unit_id
        WHERE company_id = p_company_id AND product_id = p_product_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede cambiar la unidad de medida: el producto tiene ventas registradas';
    END IF;
END //
DELIMITER ;


CALL sp_actualizar_unidad_medida('COMP003', 5, 3);
```
   ------

   ### **18. Recalcular promedios de calidad semanalmente**

   > *"Como supervisor, quiero un procedimiento que recalcule todos los promedios de calidad cada semana."*

   🧠 **Explicación:**
    Hace un `AVG(rating)` agrupado por producto y lo actualiza en `products`.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_recalcular_promedios_calidad()
BEGIN
    UPDATE products p
    JOIN (
        SELECT product_id, AVG(rating) AS avg_rating
        FROM quality_products
        GROUP BY product_id
    ) qp ON p.id = qp.product_id
    SET p.average_rating = qp.avg_rating;
END //
DELIMITER ;

CALL sp_recalcular_promedios_calidad();
```
   ------

   ### **19. Validar claves foráneas entre calificaciones y encuestas**

   > *"Como auditor, deseo un procedimiento que valide claves foráneas cruzadas entre calificaciones y encuestas."*

   🧠 **Explicación:**
    Busca registros en `rates` con `poll_id` que no existen en `polls`, y los reporta.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_validar_claves_foraneas_ratings()
BEGIN
    INSERT INTO errores_log (tipo_error, descripcion, fecha)
    SELECT 
        'CLAVE_FORANEA_INVALIDA',
        CONCAT('Poll ID ', r.poll_id, ' no existe en tabla polls para rating ', r.id),
        NOW()
    FROM rates r
    LEFT JOIN polls p ON r.poll_id = p.id
    WHERE p.id IS NULL;
END //
DELIMITER ;


CALL sp_validar_claves_foraneas_ratings();
```
   ------

   ### **20. Generar el top 10 de productos más calificados por ciudad**

   > *"Como gerente, quiero un procedimiento que genere el top 10 de productos más calificados por ciudad."*

   🧠 **Explicación:**
    Agrupa las calificaciones por ciudad (a través de la empresa que lo vende) y selecciona los 10 productos con más evaluaciones.
### REPUESTA
```sql

DELIMITER //
CREATE PROCEDURE sp_top10_productos_por_ciudad()
BEGIN
    SELECT 
        c.city_id,
        ci.name AS city_name,
        p.id AS product_id,
        p.name AS product_name,
        COUNT(qp.id) AS total_ratings
    FROM quality_products qp
    JOIN products p ON qp.product_id = p.id
    JOIN companies c ON qp.company_id = c.id
    JOIN citiesormunicipalities ci ON c.city_id = ci.code
    GROUP BY c.city_id, ci.name, p.id, p.name
    ORDER BY c.city_id, total_ratings DESC
    LIMIT 10;
END //
DELIMITER ;


CALL sp_top10_productos_por_ciudad();
```
------

## 🔹 **5. Triggers**

1. ### 🔎 **1. Actualizar la fecha de modificación de un producto**?

   > "Como desarrollador, deseo un trigger que actualice la fecha de modificación cuando se actualice un producto."

   🧠 **Explicación:**
    Cada vez que se actualiza un producto, queremos que el campo `updated_at` se actualice automáticamente con la fecha actual (`NOW()`), sin tener que hacerlo manualmente desde la app.

   🔁 Se usa un `BEFORE UPDATE`.
### REPUESTA
```sql

DELIMITER //
CREATE TRIGGER tr_producto_actualizado
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END //
DELIMITER ;
```
   ------

   ### 🔎 **2. Registrar log cuando un cliente califica un producto**?

   > "Como administrador, quiero un trigger que registre en log cuando un cliente califica un producto."

   🧠 **Explicación:**
    Cuando alguien inserta una fila en `rates`, el trigger crea automáticamente un registro en `log_acciones` con la información del cliente y producto calificado.

   🔁 Se usa un `AFTER INSERT` sobre `rates`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_log_calificacion
AFTER INSERT ON rates
FOR EACH ROW
BEGIN
    INSERT INTO log_acciones (accion, tabla_afectada, id_registro, descripcion, fecha)
    VALUES (
        'CALIFICACION_INSERTADA',
        'rates',
        NEW.id,
        CONCAT('Cliente ', NEW.customer_id, ' calificó con ', NEW.rating),
        NOW()
    );
END //
DELIMITER ;
```
   ### 🔎 **3. Impedir insertar productos sin unidad de medida**

   > "Como técnico, deseo un trigger que impida insertar productos sin unidad de medida."

   🧠 **Explicación:**
    Antes de guardar un nuevo producto, el trigger revisa si `unit_id` es `NULL`. Si lo es, lanza un error con `SIGNAL`.

   🔁 Se usa un `BEFORE INSERT`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_validar_unidad_medida
BEFORE INSERT ON companyproducts
FOR EACH ROW
BEGIN
    IF NEW.unimeasure_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede insertar producto sin unidad de medida';
    END IF;
END //
DELIMITER ;

```
   ### 🔎 **4. Validar calificaciones no mayores a 5**

   > "Como auditor, quiero un trigger que verifique que las calificaciones no superen el valor máximo permitido."

   🧠 **Explicación:**
    Si alguien intenta insertar una calificación de 6 o más, se bloquea automáticamente. Esto evita errores o trampa.

   🔁 Se usa un `BEFORE INSERT`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_validar_calificacion_maxima
BEFORE INSERT ON rates
FOR EACH ROW
BEGIN
    IF NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La calificación no puede ser mayor a 5';
    END IF;
END //
DELIMITER ;
```
   ### 🔎 **5. Actualizar estado de membresía cuando vence**?

   > "Como supervisor, deseo un trigger que actualice automáticamente el estado de membresía al vencer el periodo."

   🧠 **Explicación:**
    Cuando se actualiza un periodo de membresía (`membershipperiods`), si `end_date` ya pasó, se puede cambiar el campo `status` a 'INACTIVA'.

   🔁 `AFTER UPDATE` o `BEFORE UPDATE` dependiendo de la lógica.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_actualizar_membresia_vencida
BEFORE UPDATE ON membershipperiods
FOR EACH ROW
BEGIN
    IF NEW.end_date < CURDATE() THEN
        SET NEW.status = 'INACTIVA';
    END IF;
END //
DELIMITER ;
```
   ### 🔎 **6. Evitar duplicados de productos por empresa**

   > "Como operador, quiero un trigger que evite duplicar productos por nombre dentro de una misma empresa."

   🧠 **Explicación:**
    Antes de insertar un nuevo producto en `companyproducts`, el trigger puede consultar si ya existe uno con el mismo `product_id` y `company_id`.

   🔁 `BEFORE INSERT`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_evitar_duplicados_productos
BEFORE INSERT ON companyproducts
FOR EACH ROW
BEGIN
    DECLARE producto_existente INT;
    
    SELECT COUNT(*) INTO producto_existente
    FROM companyproducts
    WHERE company_id = NEW.company_id AND product_id = NEW.product_id;
    
    IF producto_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este producto ya existe para la empresa especificada';
    END IF;
END //
DELIMITER ;
```
   ### 🔎 **7. Enviar notificación al añadir un favorito**

   > "Como cliente, deseo un trigger que envíe notificación cuando añado un producto como favorito."

   🧠 **Explicación:**
    Después de un `INSERT` en `details_favorites`, el trigger agrega un mensaje a una tabla `notificaciones`.

   🔁 `AFTER INSERT`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_notificar_favorito
AFTER INSERT ON details_favorites
FOR EACH ROW
BEGIN
    INSERT INTO notificaciones (usuario_id, mensaje, tipo, fecha)
    SELECT 
        f.customer_id,
        CONCAT('Has añadido el producto ', p.name, ' a tus favoritos'),
        'FAVORITO',
        NOW()
    FROM favorites f
    JOIN products p ON NEW.product_id = p.id
    WHERE f.id = NEW.favorite_id;
END //
DELIMITER ;
```
   ### 🔎 **8. Insertar fila en `quality_products` tras calificación**

   > "Como técnico, quiero un trigger que inserte una fila en `quality_products` cuando se registra una calificación."

   🧠 **Explicación:**
    Al insertar una nueva calificación en `rates`, se crea automáticamente un registro en `quality_products` para mantener métricas de calidad.

   🔁 `AFTER INSERT`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_sincronizar_calificaciones
AFTER INSERT ON rates
FOR EACH ROW
BEGIN
    INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
    SELECT 
        cp.product_id,
        NEW.customer_id,
        NEW.poll_id,
        NEW.company_id,
        NEW.daterating,
        NEW.rating
    FROM companyproducts cp
    WHERE cp.company_id = NEW.company_id;
END //
DELIMITER ;
```
   ### 🔎 **9. Eliminar favoritos si se elimina el producto**

   > "Como desarrollador, deseo un trigger que elimine los favoritos si se elimina el producto."

   🧠 **Explicación:**
    Cuando se borra un producto, el trigger elimina las filas en `details_favorites` donde estaba ese producto.

   🔁 `AFTER DELETE` en `products`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_eliminar_favoritos_producto
AFTER DELETE ON products
FOR EACH ROW
BEGIN
    DELETE FROM details_favorites
    WHERE product_id = OLD.id;
END //
DELIMITER ;
```
   ### 🔎 **10. Bloquear modificación de audiencias activas**

   > "Como administrador, quiero un trigger que bloquee la modificación de audiencias activas."

   🧠 **Explicación:**
    Si un usuario intenta modificar una audiencia que está en uso, el trigger lanza un error con `SIGNAL`.

   🔁 `BEFORE UPDATE`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_bloquear_audiencias_activas
BEFORE UPDATE ON audiences
FOR EACH ROW
BEGIN
    DECLARE audiencia_en_uso INT;
    
    SELECT COUNT(*) INTO audiencia_en_uso
    FROM customers
    WHERE audience_id = OLD.id
    LIMIT 1;
    
    IF audiencia_en_uso > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede modificar una audiencia en uso';
    END IF;
END //
DELIMITER ;
```
   ### 🔎 **11. Recalcular promedio de calidad del producto tras nueva evaluación**

   > "Como gestor, deseo un trigger que actualice el promedio de calidad del producto tras una nueva evaluación."

   🧠 **Explicación:**
    Después de insertar en `rates`, el trigger actualiza el campo `average_rating` del producto usando `AVG()`.

   🔁 `AFTER INSERT`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_actualizar_promedio_calidad
AFTER INSERT ON quality_products
FOR EACH ROW
BEGIN
    DECLARE avg_rating DECIMAL(3,1);
    
    SELECT AVG(rating) INTO avg_rating
    FROM quality_products
    WHERE product_id = NEW.product_id;
    
    UPDATE products
    SET average_rating = avg_rating
    WHERE id = NEW.product_id;
END //
DELIMITER ;

```
   ### 🔎 **12. Registrar asignación de nuevo beneficio**

   > "Como auditor, quiero un trigger que registre cada vez que se asigna un nuevo beneficio."

   🧠 **Explicación:**
    Cuando se hace `INSERT` en `membershipbenefits` o `audiencebenefits`, se agrega un log en `bitacora`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_log_asignacion_beneficio
AFTER INSERT ON membershipbenefits
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (accion, descripcion, usuario, fecha)
    VALUES (
        'ASIGNACION_BENEFICIO',
        CONCAT('Se asignó el beneficio ', NEW.benefit_id, ' al plan ', NEW.membership_id),
        CURRENT_USER(),
        NOW()
    );
END //
DELIMITER ;

```
   ### 🔎 **13. Impedir doble calificación por parte del cliente**

   > "Como cliente, deseo un trigger que me impida calificar el mismo producto dos veces seguidas."

   🧠 **Explicación:**
    Antes de insertar en `rates`, el trigger verifica si ya existe una calificación de ese `customer_id` y `product_id`.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_evitar_doble_calificacion
BEFORE INSERT ON rates
FOR EACH ROW
BEGIN
    DECLARE calificacion_existente INT;
    
    SELECT COUNT(*) INTO calificacion_existente
    FROM rates
    WHERE customer_id = NEW.customer_id
    AND company_id = NEW.company_id
    AND poll_id = NEW.poll_id;
    
    IF calificacion_existente > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No puedes calificar el mismo producto/empresa más de una vez';
    END IF;
END //
DELIMITER ;
```
   ### 🔎 **14. Validar correos duplicados en clientes**
 
   > "Como técnico, quiero un trigger que valide que el email del cliente no se repita."

   🧠 **Explicación:**
    Verifica, antes del `INSERT`, si el correo ya existe en la tabla `customers`. Si sí, lanza un error.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_validar_email_unico
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
    DECLARE email_existente INT;
    
    IF NEW.email IS NOT NULL THEN
        SELECT COUNT(*) INTO email_existente
        FROM customers
        WHERE email = NEW.email;
        
        IF email_existente > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El correo electrónico ya está registrado';
        END IF;
    END IF;
END //
DELIMITER ;
```
   ### 🔎 **15. Eliminar detalles de favoritos huérfanos**

   > "Como operador, deseo un trigger que elimine registros huérfanos de `details_favorites`."

   🧠 **Explicación:**
    Si se elimina un registro de `favorites`, se borran automáticamente sus detalles asociados.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_eliminar_detalles_favoritos
AFTER DELETE ON favorites
FOR EACH ROW
BEGIN
    DELETE FROM details_favorites
    WHERE favorite_id = OLD.id;
END //
DELIMITER ;
```
   ### 🔎 **16. Actualizar campo `updated_at` en `companies`**

   > "Como administrador, quiero un trigger que actualice el campo `updated_at` en `companies`."

   🧠 **Explicación:**
    Como en productos, actualiza automáticamente la fecha de última modificación cada vez que se cambia algún dato.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_empresa_actualizada
BEFORE UPDATE ON companies
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END //
DELIMITER ;
```
   ### 🔎 **17. Impedir borrar ciudad si hay empresas activas**

   > "Como desarrollador, deseo un trigger que impida borrar una ciudad si hay empresas activas en ella."

   🧠 **Explicación:**
    Antes de hacer `DELETE` en `citiesormunicipalities`, el trigger revisa si hay empresas registradas en esa ciudad.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_proteger_ciudad_con_empresas
BEFORE DELETE ON citiesormunicipalities
FOR EACH ROW
BEGIN
    DECLARE empresas_activas INT;
    
    SELECT COUNT(*) INTO empresas_activas
    FROM companies
    WHERE city_id = OLD.code;
    
    IF empresas_activas > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar una ciudad con empresas registradas';
    END IF;
END //
DELIMITER ;
```
   ### 🔎 **18. Registrar cambios de estado en encuestas**

   > "Como auditor, quiero un trigger que registre cambios de estado de encuestas."

   🧠 **Explicación:**
    Cada vez que se actualiza el campo `status` en `polls`, el trigger guarda la fecha, nuevo estado y usuario en un log.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_log_cambio_estado_encuesta
AFTER UPDATE ON polls
FOR EACH ROW
BEGIN
    IF NEW.isactive <> OLD.isactive THEN
        INSERT INTO log_encuestas (poll_id, estado_anterior, estado_nuevo, fecha_cambio, usuario)
        VALUES (
            NEW.id,
            OLD.isactive,
            NEW.isactive,
            NOW(),
            CURRENT_USER()
        );
    END IF;
END //
DELIMITER ;
```
   ### 🔎 **19. Sincronizar `rates` y `quality_products`**

   > "Como supervisor, deseo un trigger que sincronice `rates` con `quality_products` al calificar."

   🧠 **Explicación:**
    Inserta o actualiza la calidad del producto en `quality_products` cada vez que se inserta una nueva calificación.

   ------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_sincronizar_quality_products
AFTER INSERT ON rates
FOR EACH ROW
BEGIN
    -- Verificar si ya existe una entrada para este producto y cliente
    IF NOT EXISTS (
        SELECT 1 FROM quality_products 
        WHERE product_id IN (
            SELECT product_id FROM companyproducts 
            WHERE company_id = NEW.company_id
        )
        AND customer_id = NEW.customer_id
    ) THEN
        -- Insertar nueva entrada en quality_products
        INSERT INTO quality_products (product_id, customer_id, poll_id, company_id, daterating, rating)
        SELECT 
            cp.product_id,
            NEW.customer_id,
            NEW.poll_id,
            NEW.company_id,
            NEW.daterating,
            NEW.rating
        FROM companyproducts cp
        WHERE cp.company_id = NEW.company_id;
    END IF;
END //
DELIMITER ;
```
   ### 🔎 **20. Eliminar productos sin relación a empresas**

   > "Como operador, quiero un trigger que elimine automáticamente productos sin relación a empresas."

   🧠 **Explicación:**
    Después de borrar la última relación entre un producto y una empresa (`companyproducts`), el trigger puede eliminar ese producto.

------
### REPUESTA
```sql
DELIMITER //
CREATE TRIGGER tr_eliminar_productos_huérfanos
AFTER DELETE ON companyproducts
FOR EACH ROW
BEGIN
    DECLARE relaciones_restantes INT;
    
    SELECT COUNT(*) INTO relaciones_restantes
    FROM companyproducts
    WHERE product_id = OLD.product_id;
    
    IF relaciones_restantes = 0 THEN
        DELETE FROM products
        WHERE id = OLD.product_id;
    END IF;
END //
DELIMITER ;
```
## 🔹 **6. Events (Eventos Programados..Usar procedimientos o funciones para cada evento)**

1. ## 🔹 **1. Borrar productos sin actividad cada 6 meses**

   > **Historia:** Como administrador, quiero un evento que borre productos sin actividad cada 6 meses.

   🧠 **Explicación:**
    Algunos productos pueden haber sido creados pero nunca calificados, marcados como favoritos ni asociados a una empresa. Este evento eliminaría esos productos cada 6 meses.

   🛠️ **Se usaría un `DELETE`** sobre `products` donde no existan registros en `rates`, `favorites` ni `companyproducts`.

   📅 **Frecuencia del evento:** `EVERY 6 MONTH`

   ------

   ## 🔹 **2. Recalcular el promedio de calificaciones semanalmente**

   > **Historia:** Como supervisor, deseo un evento semanal que recalcula el promedio de calificaciones.

   🧠 **Explicación:**
    Se puede tener una tabla `product_metrics` que almacena promedios pre-calculados para rapidez. El evento actualizaría esa tabla con nuevos promedios.

   🛠️ **Usa `UPDATE` con `AVG(rating)` agrupado por producto.**

   📅 Frecuencia: `EVERY 1 WEEK`

   ------

   ## 🔹 **3. Actualizar precios según inflación mensual**

   > **Historia:** Como operador, quiero un evento mensual que actualice los precios de productos por inflación.

   🧠 **Explicación:**
    Aplicar un porcentaje de aumento (por ejemplo, 3%) a los precios de todos los productos.

   🛠️ `UPDATE companyproducts SET price = price * 1.03;`

   📅 Frecuencia: `EVERY 1 MONTH`

   ------

   ## 🔹 **4. Crear backups lógicos diariamente**

   > **Historia:** Como auditor, deseo un evento que genere un backup lógico cada medianoche.

   🧠 **Explicación:**
    Este evento no ejecuta comandos del sistema, pero puede volcar datos clave a una tabla temporal o de respaldo (`products_backup`, `rates_backup`, etc.).

   📅 `EVERY 1 DAY STARTS '00:00:00'`

   ------

   ## 🔹 **5. Notificar sobre productos favoritos sin calificar**

   > **Historia:** Como cliente, quiero un evento que me recuerde los productos que tengo en favoritos y no he calificado.

   🧠 **Explicación:**
    Genera una lista (`user_reminders`) de `product_id` donde el cliente tiene el producto en favoritos pero no hay `rate`.

   🛠️ Requiere `INSERT INTO recordatorios` usando un `LEFT JOIN` y `WHERE rate IS NULL`.

   ------

   ## 🔹 **6. Revisar inconsistencias entre empresa y productos**

   > **Historia:** Como técnico, deseo un evento que revise inconsistencias entre empresas y productos cada domingo.

   🧠 **Explicación:**
    Detecta productos sin empresa, o empresas sin productos, y los registra en una tabla de anomalías.

   🛠️ Puede usar `NOT EXISTS` y `JOIN` para llenar una tabla `errores_log`.

   📅 `EVERY 1 WEEK ON SUNDAY`

   ------

   ## 🔹 **7. Archivar membresías vencidas diariamente**

   > **Historia:** Como administrador, quiero un evento que archive membresías vencidas.

   🧠 **Explicación:**
    Cambia el estado de la membresía cuando su `end_date` ya pasó.

   🛠️ `UPDATE membershipperiods SET status = 'INACTIVA' WHERE end_date < CURDATE();`

   ------

   ## 🔹 **8. Notificar beneficios nuevos a usuarios semanalmente**

   > **Historia:** Como supervisor, deseo un evento que notifique por correo sobre beneficios nuevos.

   🧠 **Explicación:**
    Detecta registros nuevos en la tabla `benefits` desde la última semana y los inserta en `notificaciones`.

   🛠️ `INSERT INTO notificaciones SELECT ... WHERE created_at >= NOW() - INTERVAL 7 DAY`

   ------

   ## 🔹 **9. Calcular cantidad de favoritos por cliente mensualmente**

   > **Historia:** Como operador, quiero un evento que calcule el total de favoritos por cliente y lo guarde.

   🧠 **Explicación:**
    Cuenta los productos favoritos por cliente y guarda el resultado en una tabla de resumen mensual (`favoritos_resumen`).

   🛠️ `INSERT INTO favoritos_resumen SELECT customer_id, COUNT(*) ... GROUP BY customer_id`

   ------

   ## 🔹 **10. Validar claves foráneas semanalmente**

   > **Historia:** Como auditor, deseo un evento que valide claves foráneas semanalmente y reporte errores.

   🧠 **Explicación:**
    Comprueba que cada `product_id`, `customer_id`, etc., tengan correspondencia en sus tablas. Si no, se registra en una tabla `inconsistencias_fk`.

   ------

   ## 🔹 **11. Eliminar calificaciones inválidas antiguas**

   > **Historia:** Como técnico, quiero un evento que elimine calificaciones con errores antiguos.

   🧠 **Explicación:**
    Borra `rates` donde el valor de `rating` es NULL o <0 y que hayan sido creadas hace más de 3 meses.

   🛠️ `DELETE FROM rates WHERE rating IS NULL AND created_at < NOW() - INTERVAL 3 MONTH`

   ------

   ## 🔹 **12. Cambiar estado de encuestas inactivas automáticamente**

   > **Historia:** Como desarrollador, deseo un evento que actualice encuestas que no se han usado en mucho tiempo.

   🧠 **Explicación:**
    Cambia el campo `status = 'inactiva'` si una encuesta no tiene nuevas respuestas en más de 6 meses.

   ------

   ## 🔹 **13. Registrar auditorías de forma periódica**

   > **Historia:** Como administrador, quiero un evento que inserte datos de auditoría periódicamente.

   🧠 **Explicación:**
    Cada día, se puede registrar el conteo de productos, usuarios, etc. en una tabla tipo `auditorias_diarias`.

   ------

   ## 🔹 **14. Notificar métricas de calidad a empresas**

   > **Historia:** Como gestor, deseo un evento que notifique a las empresas sus métricas de calidad cada lunes.

   🧠 **Explicación:**
    Genera una tabla o archivo con `AVG(rating)` por producto y empresa y se registra en `notificaciones_empresa`.

   ------

   ## 🔹 **15. Recordar renovación de membresías**

   > **Historia:** Como cliente, quiero un evento que me recuerde renovar la membresía próxima a vencer.

   🧠 **Explicación:**
    Busca `membershipperiods` donde `end_date` esté entre hoy y 7 días adelante, e inserta recordatorios.

   ------

   ## 🔹 **16. Reordenar estadísticas generales cada semana**

   > **Historia:** Como operador, deseo un evento que reordene estadísticas generales.

   🧠 **Explicación:**
    Calcula y actualiza métricas como total de productos activos, clientes registrados, etc., en una tabla `estadisticas`.

   ------

   ## 🔹 **17. Crear resúmenes temporales de uso por categoría**

   > **Historia:** Como técnico, quiero un evento que cree resúmenes temporales por categoría.

   🧠 **Explicación:**
    Cuenta cuántos productos se han calificado en cada categoría y guarda los resultados para dashboards.

   ------

   ## 🔹 **18. Actualizar beneficios caducados**

   > **Historia:** Como gerente, deseo un evento que desactive beneficios que ya expiraron.

   🧠 **Explicación:**
    Revisa si un beneficio tiene una fecha de expiración (campo `expires_at`) y lo marca como inactivo.

   ------

   ## 🔹 **19. Alertar productos sin evaluación anual**

   > **Historia:** Como auditor, quiero un evento que genere alertas sobre productos sin evaluación anual.

   🧠 **Explicación:**
    Busca productos sin `rate` en los últimos 365 días y genera alertas o registros en `alertas_productos`.

   ------

   ## 🔹 **20. Actualizar precios con índice externo**

   > **Historia:** Como administrador, deseo un evento que actualice precios según un índice referenciado.

   🧠 **Explicación:**
    Se podría tener una tabla `inflacion_indice` y aplicar ese valor multiplicador a los precios de productos activos.

   

## 🔹 **7. Historias de Usuario con JOINs**

1. ## 🔹 **1. Ver productos con la empresa que los vende**

   > **Historia:** Como analista, quiero consultar todas las empresas junto con los productos que ofrecen, mostrando el nombre del producto y el precio.

   🧠 **Explicación para dummies:**
    Imagina que tienes dos tablas: una con empresas (`companies`) y otra con productos (`products`). Hay una tabla intermedia llamada `companyproducts` que dice qué empresa vende qué producto y a qué precio.
    Con un `JOIN`, unes estas tablas para ver “Empresa A vende Producto X a $10”.

   🔍 Se usa un `INNER JOIN`.

   ------

   ## 🔹 **2. Mostrar productos favoritos con su empresa y categoría**

   > **Historia:** Como cliente, deseo ver mis productos favoritos junto con la categoría y el nombre de la empresa que los ofrece.

   🧠 **Explicación:**
    Tú como cliente guardaste algunos productos en favoritos. Quieres ver no solo el nombre, sino también quién lo vende y a qué categoría pertenece.

   🔍 Aquí se usan varios `JOIN` para traer todo en una sola consulta bonita y completa.

   ------

   ## 🔹 **3. Ver empresas aunque no tengan productos**

   > **Historia:** Como supervisor, quiero ver todas las empresas aunque no tengan productos asociados.

   🧠 **Explicación:**
    No todas las empresas suben productos de inmediato. Queremos verlas igualmente.
    Un `LEFT JOIN` te permite mostrar la empresa, aunque no tenga productos en la otra tabla.

   🔍 Se une `companies LEFT JOIN`.

   ------

   ## 🔹 **4. Ver productos que fueron calificados (o no)**

   > **Historia:** Como técnico, deseo obtener todas las calificaciones de productos incluyendo aquellos productos que aún no han sido calificados.

   🧠 **Explicación:**
    Queremos ver todos los productos. Si hay calificación, que la muestre; si no, que aparezca como NULL.
    Esto se hace con un `RIGHT JOIN` desde `rates` hacia `products`.

   🔍 Así sabrás qué productos no tienen aún calificaciones.

   ------

   ## 🔹 **5. Ver productos con promedio de calificación y empresa**

   > **Historia:** Como gestor, quiero ver productos con su promedio de calificación y nombre de la empresa.

   🧠 **Explicación:**
    El producto vive en la tabla `products`, el precio y empresa están en `companyproducts`, y las calificaciones en `rates`.
    Un `JOIN` permite unir todo y usar `AVG(rates.valor)` para calcular el promedio.

   🔍 Combinas `products JOIN companyproducts JOIN companies JOIN rates`.

   ------

   ## 🔹 **6. Ver clientes y sus calificaciones (si las tienen)**

   > **Historia:** Como operador, deseo obtener todos los clientes y sus calificaciones si existen.

   🧠 **Explicación:**
    A algunos clientes no les gusta calificar, pero igual deben aparecer.
    Se hace un `LEFT JOIN` desde `customers` hacia `rates`.

   🔍 Devuelve calificaciones o `NULL` si el cliente nunca calificó.

   ------

   ## 🔹 **7. Ver favoritos con la última calificación del cliente**

   > **Historia:** Como cliente, quiero consultar todos mis favoritos junto con la última calificación que he dado.

   🧠 **Explicación:**
    Esto requiere unir tus productos favoritos (`favorites` + `details_favorites`) con las calificaciones (`rates`), filtradas por la fecha más reciente.

   🔍 Requiere `JOIN` y subconsulta con `MAX(created_at)` o `ORDER BY` + `LIMIT 1`.

   ------

   ## 🔹 **8. Ver beneficios incluidos en cada plan de membresía**

   > **Historia:** Como administrador, quiero unir `membershipbenefits`, `benefits` y `memberships`.

   🧠 **Explicación:**
    Tienes planes (`memberships`), beneficios (`benefits`) y una tabla que los relaciona (`membershipbenefits`).
    Un `JOIN` muestra qué beneficios tiene cada plan.

   ------

   ## 🔹 **9. Ver clientes con membresía activa y sus beneficios**

   > **Historia:** Como gerente, deseo ver todos los clientes con membresía activa y sus beneficios actuales.

   🧠 **Explicación:** La intención es **mostrar una lista de clientes** que:

   1. Tienen **una membresía activa** (vigente hoy).
   2. Y a esa membresía le corresponden **uno o más beneficios**.

   🔍 Mucho `JOIN`, pero muestra todo lo que un cliente recibe por su membresía.

   ------

   ## 🔹 **10. Ver ciudades con cantidad de empresas**

   > **Historia:** Como operador, quiero obtener todas las ciudades junto con la cantidad de empresas registradas.

   🧠 **Explicación:**
    Unes `citiesormunicipalities` con `companies` y cuentas cuántas empresas hay por ciudad (`COUNT(*) GROUP BY ciudad`).

   ------

   ## 🔹 **11. Ver encuestas con calificaciones**

   > **Historia:** Como analista, deseo unir `polls` y `rates`.

   🧠 **Explicación:**
    Cada encuesta (`polls`) puede estar relacionada con una calificación (`rates`).
    El `JOIN` permite ver qué encuesta usó el cliente para calificar.

   ------

   ## 🔹 **12. Ver productos evaluados con datos del cliente**

   > **Historia:** Como técnico, quiero consultar todos los productos evaluados con su fecha y cliente.

   🧠 **Explicación:**
    Unes `rates`, `products` y `customers` para saber qué cliente evaluó qué producto y cuándo.

   ------

   ## 🔹 **13. Ver productos con audiencia de la empresa**

   > **Historia:** Como supervisor, deseo obtener todos los productos con la audiencia objetivo de la empresa.

   🧠 **Explicación:**
    Unes `products`, `companyproducts`, `companies` y `audiences` para saber si ese producto está dirigido a niños, adultos, etc.

   ------

   ## 🔹 **14. Ver clientes con sus productos favoritos**

   > **Historia:** Como auditor, quiero unir `customers` y `favorites`.

   🧠 **Explicación:**
    Para ver qué productos ha marcado como favorito cada cliente.
    Unes `customers` → `favorites` → `details_favorites` → `products`.

   ------

   ## 🔹 **15. Ver planes, periodos, precios y beneficios**

   > **Historia:** Como gestor, deseo obtener la relación de planes de membresía, periodos, precios y beneficios.

   🧠 **Explicación:**
    Unes `memberships`, `membershipperiods`, `membershipbenefits`, y `benefits`.

   🔍 Sirve para hacer un catálogo completo de lo que incluye cada plan.

   ------

   ## 🔹 **16. Ver combinaciones empresa-producto-cliente calificados**

   > **Historia:** Como desarrollador, quiero consultar todas las combinaciones empresa-producto-cliente que hayan sido calificadas.

   🧠 **Explicación:**
    Une `rates` con `products`, `companyproducts`, `companies`, y `customers`.

   🔍 Así sabes: quién calificó, qué producto, de qué empresa.

   ------

   ## 🔹 **17. Comparar favoritos con productos calificados**

   > **Historia:** Como cliente, quiero ver productos que he calificado y también tengo en favoritos.

   🧠 **Explicación:**
    Une `details_favorites` y `rates` por `product_id`, filtrando por tu `customer_id`.

   ------

   ## 🔹 **18. Ver productos ordenados por categoría**

   > **Historia:** Como operador, quiero unir `categories` y `products`.

   🧠 **Explicación:**
    Cada producto tiene una categoría.
    El `JOIN` permite ver el nombre de la categoría junto al nombre del producto.

   ------

   ## 🔹 **19. Ver beneficios por audiencia, incluso vacíos**

   > **Historia:** Como especialista, quiero listar beneficios por audiencia, incluso si no tienen asignados.

   🧠 **Explicación:**
    Un `LEFT JOIN` desde `audiences` hacia `audiencebenefits` y luego `benefits`.

   🔍 Audiencias sin beneficios mostrarán `NULL`.

   ------

   ## 🔹 **20. Ver datos cruzados entre calificaciones, encuestas, productos y clientes**

   > **Historia:** Como auditor, deseo una consulta que relacione `rates`, `polls`, `products` y `customers`.

   🧠 **Explicación:**
    Es una auditoría cruzada. Se une todo lo relacionado con una calificación:

   - ¿Quién calificó? (`customers`)
   - ¿Qué calificó? (`products`)
   - ¿En qué encuesta? (`polls`)
   - ¿Qué valor dio? (`rates`)

## 🔹 **8. Historias de Usuario con Funciones Definidas por el Usuario (UDF)**

1. Como analista, quiero una función que calcule el **promedio ponderado de calidad** de un producto basado en sus calificaciones y fecha de evaluación.

   > **Explicación:** Se desea una función `calcular_promedio_ponderado(product_id)` que combine el valor de `rate` y la antigüedad de cada calificación para dar más peso a calificaciones recientes.

2. Como auditor, deseo una función que determine si un producto ha sido **calificado recientemente** (últimos 30 días).

   > **Explicación:** Se busca una función booleana `es_calificacion_reciente(fecha)` que devuelva `TRUE` si la calificación se hizo en los últimos 30 días.

3. Como desarrollador, quiero una función que reciba un `product_id` y devuelva el **nombre completo de la empresa** que lo vende.

   > **Explicación:** La función `obtener_empresa_producto(product_id)` haría un `JOIN` entre `companyproducts` y `companies` y devolvería el nombre de la empresa.

4. Como operador, deseo una función que, dado un `customer_id`, me indique si el cliente tiene una **membresía activa**.

   > **Explicación:** `tiene_membresia_activa(customer_id)` consultaría la tabla `membershipperiods` para ese cliente y verificaría si la fecha actual está dentro del rango.

5. Como administrador, quiero una función que valide si una ciudad tiene **más de X empresas registradas**, recibiendo la ciudad y el número como 

   parámetros.

   > **Explicación:** `ciudad_supera_empresas(city_id, limite)` devolvería `TRUE` si el conteo de empresas en esa ciudad excede `limite`.

6. Como gerente, deseo una función que, dado un `rate_id`, me devuelva una **descripción textual de la calificación** (por ejemplo, “Muy bueno”, “Regular”).

   > **Explicación:** `descripcion_calificacion(valor)` devolvería “Excelente” si `valor = 5`, “Bueno” si `valor = 4`, etc.

7. Como técnico, quiero una función que devuelva el **estado de un producto** en función de su evaluación (ej. “Aceptable”, “Crítico”).

   > **Explicación:** `estado_producto(product_id)` clasificaría un producto como “Crítico”, “Aceptable” o “Óptimo” según su promedio de calificaciones.

8. Como cliente, deseo una función que indique si un producto está **entre mis favoritos**, recibiendo el `product_id` y mi `customer_id`.

   > **Explicación:** `es_favorito(customer_id, product_id)` devolvería `TRUE` si hay un registro en `details_favorites`.

9. Como gestor de beneficios, quiero una función que determine si un beneficio está **asignado a una audiencia específica**, retornando verdadero o falso.

   > **Explicación:** `beneficio_asignado_audiencia(benefit_id, audience_id)` buscaría en `audiencebenefits` y retornaría `TRUE` si hay coincidencia.

10. Como auditor, deseo una función que reciba una fecha y determine si se encuentra dentro de un **rango de membresía activa**.

    > **Explicación:** `fecha_en_membresia(fecha, customer_id)` compararía `fecha` con los rangos de `membershipperiods` activos del cliente.

11. Como desarrollador, quiero una función que calcule el **porcentaje de calificaciones positivas** de un producto respecto al total.

    > **Explicación:** `porcentaje_positivas(product_id)` devolvería la relación entre calificaciones mayores o iguales a 4 y el total de calificaciones.

12. Como supervisor, deseo una función que calcule la **edad de una calificación**, en días, desde la fecha actual.

    > Un **supervisor** quiere saber cuántos **días han pasado** desde que se registró una calificación de un producto. Este cálculo debe hacerse dinámicamente comparando la **fecha actual del sistema (`CURRENT_DATE`)** con la **fecha en que se hizo la calificación** (que suponemos está almacenada en un campo como `created_at` o `rate_date` en la tabla `rates`).

13. Como operador, quiero una función que, dado un `company_id`, devuelva la **cantidad de productos únicos** asociados a esa empresa.

    > **Explicación:** `productos_por_empresa(company_id)` haría un `COUNT(DISTINCT product_id)` en `companyproducts`.

14. Como gerente, deseo una función que retorne el **nivel de actividad** de un cliente (frecuente, esporádico, inactivo), según su número de calificaciones.

15. Como administrador, quiero una función que calcule el **precio promedio ponderado** de un producto, tomando en cuenta su uso en favoritos.

16. Como técnico, deseo una función que me indique si un `benefit_id` está asignado a más de una audiencia o membresía (valor booleano).

17. Como cliente, quiero una función que, dada mi ciudad, retorne un **índice de variedad** basado en número de empresas y productos.

18. Como gestor de calidad, deseo una función que evalúe si un producto debe ser **desactivado** por tener baja calificación histórica.

## 19. Como desarrollador, quiero una función que calcule el **índice de popularidad** de un producto (combinando favoritos y ratings).

## 20. Como auditor, deseo una función que genere un código único basado en el nombre del producto y su fecha de creación.


# Requerimientos de entrega

1. Instrucciones DDL con la creación de la estructura completa de la base de datos.
2. Instrucciones Insert para cada una de las tablas.
3. Documentos de codificacion geografica : https://drive.google.com/drive/folders/1zvAgacAzQUo2zyHho6C7eHhmQkc3SHmO?usp=sharing