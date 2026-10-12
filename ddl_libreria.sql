DROP DATABASE IF EXISTS libreria_sofia;
CREATE DATABASE libreria_sofia;

USE libreria_sofia;

CREATE TABLE editoriales (
    id_editorial INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(100) NOT NULL,
    CONSTRAINT pk_editoriales PRIMARY KEY (id_editorial),
    CONSTRAINT uq_editoriales_nombre UNIQUE (nombre)
);

CREATE TABLE categorias (
    id_categoria INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre       VARCHAR(60) NOT NULL,
    CONSTRAINT pk_categorias PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categorias_nombre UNIQUE (nombre)
);

CREATE TABLE autores (
    id_autor         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre           VARCHAR(120) NOT NULL,
    fecha_nacimiento DATE         NOT NULL,
    nacionalidad     VARCHAR(60)  NOT NULL,
    CONSTRAINT pk_autores PRIMARY KEY (id_autor),
    -- Evita registrar dos veces al mismo autor
    CONSTRAINT uq_autores_nombre_fecha UNIQUE (nombre, fecha_nacimiento)
);

CREATE TABLE libros (
    id_libro          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    isbn              CHAR(13)      NOT NULL,
    titulo            VARCHAR(200)  NOT NULL,
    id_editorial      INT UNSIGNED  NOT NULL,
    id_categoria      INT UNSIGNED  NOT NULL,
    fecha_publicacion DATE          NOT NULL,
    precio            DECIMAL(10,2) NOT NULL,
    stock             INT UNSIGNED  NOT NULL DEFAULT 0,
    CONSTRAINT pk_libros PRIMARY KEY (id_libro),
    CONSTRAINT uq_libros_isbn UNIQUE (isbn),
    CONSTRAINT ck_libros_precio CHECK (precio > 0),
    CONSTRAINT fk_libros_editorial FOREIGN KEY (id_editorial)
        REFERENCES editoriales (id_editorial)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_libros_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    -- Índice para la búsqueda por título (requisito de búsqueda)
    INDEX idx_libros_titulo (titulo)
);

CREATE TABLE libro_autor (
    id_libro INT UNSIGNED NOT NULL,
    id_autor INT UNSIGNED NOT NULL,
    -- La llave compuesta evita duplicar la pareja libro-autor
    CONSTRAINT pk_libro_autor PRIMARY KEY (id_libro, id_autor),
    CONSTRAINT fk_la_libro FOREIGN KEY (id_libro)
        REFERENCES libros (id_libro)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_la_autor FOREIGN KEY (id_autor)
        REFERENCES autores (id_autor)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    -- Índice inverso: buscar libros a partir de un autor
    INDEX idx_la_autor (id_autor)
);

CREATE TABLE clientes (
    id_cliente INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nombre     VARCHAR(120) NOT NULL,
    email      VARCHAR(120) NOT NULL,
    telefono   VARCHAR(20)  NULL,
    direccion  VARCHAR(255) NOT NULL,
    CONSTRAINT pk_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_email UNIQUE (email)
);

CREATE TABLE pedidos (
    id_pedido    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_cliente   INT UNSIGNED NOT NULL,
    fecha_pedido DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado       ENUM('pendiente','procesado','completado')
                              NOT NULL DEFAULT 'pendiente',
    CONSTRAINT pk_pedidos PRIMARY KEY (id_pedido),
    CONSTRAINT fk_pedidos_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_pedidos_cliente_fecha (id_cliente, fecha_pedido)
);

CREATE TABLE detalle_pedido (
    id_pedido       INT UNSIGNED  NOT NULL,
    id_libro        INT UNSIGNED  NOT NULL,
    cantidad        INT UNSIGNED  NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,   -- precio al momento de la compra
    CONSTRAINT pk_detalle_pedido PRIMARY KEY (id_pedido, id_libro),
    CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detalle_precio   CHECK (precio_unitario > 0),
    CONSTRAINT fk_dp_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedidos (id_pedido)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dp_libro FOREIGN KEY (id_libro)
        REFERENCES libros (id_libro)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_dp_libro (id_libro)
);

CREATE TABLE transacciones (
    id_transaccion    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    id_pedido         INT UNSIGNED  NOT NULL,
    metodo_pago       ENUM('tarjeta_credito','paypal','transferencia','efectivo')
                                    NOT NULL,
    monto_total       DECIMAL(10,2) NOT NULL,
    fecha_transaccion DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_transacciones PRIMARY KEY (id_transaccion),
    -- UNIQUE en id_pedido => relación 1:1 (un pedido, una transacción)
    CONSTRAINT uq_transacciones_pedido UNIQUE (id_pedido),
    CONSTRAINT ck_transacciones_monto CHECK (monto_total > 0),
    CONSTRAINT fk_trans_pedido FOREIGN KEY (id_pedido)
        REFERENCES pedidos (id_pedido)
        ON UPDATE CASCADE ON DELETE RESTRICT
);
