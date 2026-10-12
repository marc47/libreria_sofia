-- =====================================================================
-- Librería "El mundo de Sofía"  |  02 - DML (Data Manipulation Language)
-- Ejecutar DESPUÉS de 01_ddl_libreria.sql
-- =====================================================================

USE libreria_sofia;

-- ---------- Editoriales ----------
INSERT INTO editoriales (id_editorial, nombre) VALUES
(1, 'Penguin Random House'),
(2, 'Alfaguara'),
(3, 'Anagrama'),
(4, 'Prentice Hall');

-- ---------- Categorías ----------
INSERT INTO categorias (id_categoria, nombre) VALUES
(1, 'Novela'),
(2, 'Realismo mágico'),
(3, 'Programación'),
(4, 'Sátira');

-- ---------- Autores ----------
INSERT INTO autores (id_autor, nombre, fecha_nacimiento, nacionalidad) VALUES
(1, 'Gabriel García Márquez',  '1927-03-06', 'Colombiana'),
(2, 'Isabel Allende',          '1942-08-02', 'Chilena'),
(3, 'Julio Cortázar',          '1914-08-26', 'Argentina'),
(4, 'Mario Vargas Llosa',      '1936-03-28', 'Peruana'),
(5, 'Robert C. Martin',        '1952-12-05', 'Estadounidense'),
(6, 'Jorge Luis Borges',       '1899-08-24', 'Argentina'),
(7, 'Adolfo Bioy Casares',     '1914-09-15', 'Argentina');

-- ---------- Libros (el stock inicial se descuenta luego con los pedidos) ----------
INSERT INTO libros (id_libro, isbn, titulo, id_editorial, id_categoria, fecha_publicacion, precio, stock) VALUES
(1, '9780307474728', 'Cien años de soledad',            2, 2, '1967-06-05', 18.50, 25),
(2, '9780553383805', 'La casa de los espíritus',        1, 2, '1982-01-01', 16.90, 30),
(3, '9788437604572', 'Rayuela',                         2, 1, '1963-06-28', 17.25, 20),
(4, '9788420471839', 'La ciudad y los perros',          2, 1, '1963-10-01', 15.00, 18),
(5, '9780132350884', 'Clean Code',                      4, 3, '2008-08-01', 42.00, 12),
(6, '9789871234567', 'Crónicas de Bustos Domecq',       3, 4, '1967-01-01', 14.00, 10),
(7, '9780307389732', 'El amor en los tiempos del cólera', 2, 1, '1985-09-05', 17.00, 22);

-- ---------- Relación libros - autores (N:M) ----------
-- 'Crónicas de Bustos Domecq' tiene dos autores
INSERT INTO libro_autor (id_libro, id_autor) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(6, 7),
(7, 1);

-- ---------- Clientes ----------
INSERT INTO clientes (id_cliente, nombre, email, telefono, direccion) VALUES
(1, 'Ana Morales',   'ana.morales@correo.com',   '5551-1001', 'Zona 10, Ciudad de Guatemala'),
(2, 'Luis Pérez',    'luis.perez@correo.com',    '5551-1002', 'Zona 1, Ciudad de Guatemala'),
(3, 'Carla Méndez',  'carla.mendez@correo.com',  '5551-1003', 'Mixco, Guatemala'),
(4, 'Diego Ramírez', 'diego.ramirez@correo.com', NULL,        'Antigua Guatemala');

-- ---------- Pedidos ----------
INSERT INTO pedidos (id_pedido, id_cliente, fecha_pedido, estado) VALUES
(1, 1, '2026-09-20 10:15:00', 'completado'),
(2, 2, '2026-09-28 16:40:00', 'procesado'),
(3, 1, '2026-10-05 09:05:00', 'pendiente'),
(4, 3, '2026-10-08 18:20:00', 'completado');

-- ---------- Detalle de pedidos ----------
-- El trigger trg_detalle_pedido_bi descuenta el stock automáticamente.
INSERT INTO detalle_pedido (id_pedido, id_libro, cantidad, precio_unitario) VALUES
(1, 1, 2, 18.50),
(1, 5, 1, 42.00),
(2, 2, 1, 16.90),
(2, 3, 1, 17.25),
(3, 4, 3, 15.00),
(4, 7, 2, 17.00),
(4, 1, 1, 18.50);

-- ---------- Transacciones ----------
-- El monto total se calcula a partir del detalle de cada pedido.
INSERT INTO transacciones (id_pedido, metodo_pago, monto_total, fecha_transaccion)
SELECT p.id_pedido,
       'tarjeta_credito',
       SUM(d.cantidad * d.precio_unitario),
       p.fecha_pedido
FROM pedidos p
JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
WHERE p.id_pedido = 1
GROUP BY p.id_pedido, p.fecha_pedido;

INSERT INTO transacciones (id_pedido, metodo_pago, monto_total, fecha_transaccion)
SELECT p.id_pedido,
       'paypal',
       SUM(d.cantidad * d.precio_unitario),
       p.fecha_pedido
FROM pedidos p
JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
WHERE p.id_pedido = 2
GROUP BY p.id_pedido, p.fecha_pedido;

INSERT INTO transacciones (id_pedido, metodo_pago, monto_total, fecha_transaccion)
SELECT p.id_pedido,
       'transferencia',
       SUM(d.cantidad * d.precio_unitario),
       p.fecha_pedido
FROM pedidos p
JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
WHERE p.id_pedido = 3
GROUP BY p.id_pedido, p.fecha_pedido;

INSERT INTO transacciones (id_pedido, metodo_pago, monto_total, fecha_transaccion)
SELECT p.id_pedido,
       'tarjeta_credito',
       SUM(d.cantidad * d.precio_unitario),
       p.fecha_pedido
FROM pedidos p
JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
WHERE p.id_pedido = 4
GROUP BY p.id_pedido, p.fecha_pedido;

-- ---------- Ejemplos de UPDATE y DELETE ----------
-- Actualizar el estado de un pedido
UPDATE pedidos SET estado = 'procesado' WHERE id_pedido = 3;

-- Reabastecer el stock de un libro
UPDATE libros SET stock = stock + 10 WHERE id_libro = 6;

-- Actualizar el teléfono de un cliente
UPDATE clientes SET telefono = '5551-1004' WHERE id_cliente = 4;
