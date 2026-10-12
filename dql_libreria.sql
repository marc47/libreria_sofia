-- SOLICITUDES A GESTIONAR

USE libreria_sofia;

-- STOCK
SELECT l.id_libro,
       l.titulo,
       GROUP_CONCAT(a.nombre ORDER BY a.nombre SEPARATOR ', ') AS autores,
       e.nombre AS editorial,
       c.nombre AS categoria,
       l.precio,
       l.stock
FROM libros l
JOIN editoriales e   ON e.id_editorial = l.id_editorial
JOIN categorias c    ON c.id_categoria = l.id_categoria
JOIN libro_autor la  ON la.id_libro    = l.id_libro
JOIN autores a       ON a.id_autor     = la.id_autor
GROUP BY l.id_libro, l.titulo, e.nombre, c.nombre, l.precio, l.stock
ORDER BY l.titulo;

-- LIBROS POR TITULO
SELECT id_libro, titulo, precio, stock
FROM libros
WHERE titulo LIKE '%soledad%';

-- LIBROS POR AUTOR
SELECT l.titulo, a.nombre AS autor
FROM libros l
JOIN libro_autor la ON la.id_libro = l.id_libro
JOIN autores a      ON a.id_autor  = la.id_autor
WHERE a.nombre LIKE '%García Márquez%';

-- POR CATEGORIA
SELECT l.titulo, l.precio
FROM libros l
JOIN categorias c ON c.id_categoria = l.id_categoria
WHERE c.nombre = 'Novela'
ORDER BY l.titulo;

-- PEDIDOS CON ESTADO
SELECT c.nombre AS cliente,
       p.id_pedido,
       p.fecha_pedido,
       p.estado
FROM clientes c
JOIN pedidos p ON p.id_cliente = c.id_cliente
ORDER BY c.nombre, p.fecha_pedido;

-- DETALLE DE PEDIDO
SELECT p.id_pedido,
       l.titulo,
       d.cantidad,
       d.precio_unitario,
       d.cantidad * d.precio_unitario AS subtotal
FROM pedidos p
JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
JOIN libros l         ON l.id_libro  = d.id_libro
WHERE p.id_pedido = 1;

-- TOTAL DE CADA PEDIDO
SELECT p.id_pedido,
       SUM(d.cantidad * d.precio_unitario) AS total_calculado,
       t.monto_total                       AS total_cobrado,
       t.metodo_pago
FROM pedidos p
JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
JOIN transacciones t  ON t.id_pedido = p.id_pedido
GROUP BY p.id_pedido, t.monto_total, t.metodo_pago;

-- LIBROS MAS VENDIDOS
SELECT l.titulo, SUM(d.cantidad) AS unidades_vendidas
FROM libros l
JOIN detalle_pedido d ON d.id_libro = l.id_libro
GROUP BY l.id_libro, l.titulo
ORDER BY unidades_vendidas DESC;

-- PEDIDOS PENDIENTES
SELECT p.id_pedido, c.nombre AS cliente, p.estado, p.fecha_pedido
FROM pedidos p
JOIN clientes c ON c.id_cliente = p.id_cliente
WHERE p.estado IN ('pendiente', 'procesado');

