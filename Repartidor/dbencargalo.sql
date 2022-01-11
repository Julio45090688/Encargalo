-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 25-11-2021 a las 19:58:28
-- Versión del servidor: 5.7.26
-- Versión de PHP: 7.2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `dbencargalo`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `AceptarRechazarPedidotendero`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AceptarRechazarPedidotendero` (IN `idpedido` INT, IN `estadopedido` INT)  BEGIN
    
    UPDATE  tblpedido set IdEstadoPedido=estadopedido
    
	where tblpedido.IdPedido=idpedido;
END$$

DROP PROCEDURE IF EXISTS `consultaIdtienda`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `consultaIdtienda` (IN `idusuario` VARCHAR(12))  BEGIN
SELECT IdTienda
FROM tbltienda 
INNER JOIN tblpersona ON tblpersona.Idpersona=tblusuario.Idpersona
WHERE tblusuario.IdUsuario=idusuario;
END$$

DROP PROCEDURE IF EXISTS `consultarUsuario`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `consultarUsuario` (IN `idusuario` VARCHAR(12))  BEGIN
	SELECT tblpersona.nombres, tblubicacion.descripcion 
	FROM tblusuario
	INNER JOIN tblpersona ON tblpersona.IdPersona = tblusuario.IdPersona
	INNER JOIN tblubicacion ON tblubicacion.IdPersona = tblpersona.IdPersona
	WHERE tblusuario.IdUsuario = idusuario;
END$$

DROP PROCEDURE IF EXISTS `consultaTendero`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `consultaTendero` (IN `idusuario` VARCHAR(12))  BEGIN
SELECT tblusuario.IdUsuario, tblpersona.nombres, tblpersona.apPaterno, tblpersona.apmaterno, tbltienda.nombre, tbltienda.IdTienda
FROM tblusuario
INNER JOIN tblpersona ON tblpersona.IdPersona = tblusuario.IdPersona
INNER JOIN tbltienda On tbltienda.IdPersona = tblpersona.IdPersona
WHERE tblusuario.IdUsuario=idusuario;
END$$

DROP PROCEDURE IF EXISTS `crearIdPedido`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `crearIdPedido` (IN `total` FLOAT, IN `hora` TIME, IN `fecha` DATE, IN `comentario` VARCHAR(100), IN `idusuario` VARCHAR(12), IN `idtienda` INT, IN `descripcion` VARCHAR(200))  BEGIN
	DECLARE idubi INT;
    DECLARE idcliente INT;
	INSERT INTO tblubicacionentrega (descripcion,latitud,longitud,latitudTR,longitudTR)
    VALUES(descripcion,"1","1","1","1");
    SET idubi := (SELECT MAX(IdUbicacionE) FROM tblubicacionentrega);
    SET idcliente := (SELECT tblcliente.IdCliente
						FROM tblcliente
						INNER JOIN tblpersona ON tblpersona.IdPersona = tblcliente.IdPersona
						INNER JOIN tblusuario ON tblpersona.IdPersona = tblusuario.IdPersona
						WHERE tblusuario.IdUsuario = idusuario
						);
    
    INSERT INTO tblpedido (importetotalMX,pagoconMX,cambioMX,calificTienda,calificRepartidor,hora,fecha,comentario,IdCliente,IdTienda,IdRepartidor,IdEstadoPedido,IdMetodoPago,IdUbicacionE)
    VALUES(total,"1","1","1","1",hora,fecha,comentario,idcliente,idtienda,"15","1","1",idubi);
	
    SELECT MAX(IdPedido) FROM tblpedido;

END$$

DROP PROCEDURE IF EXISTS `DetallePedidoTendero`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DetallePedidoTendero` (IN `idpedido` INT)  BEGIN
	SELECT tbldetallepedido.cantidad, tblproductosgenerales.descripcion, tbldetallepedido.preciouniMX, tbldetallepedido.subtotal
    FROM tbldetallepedido
    INNER JOIN tbltiendaproducto ON tbltiendaproducto.IdTiendaProducto = tbldetallepedido.IdTiendaProducto
	INNER JOIN tblproductosgenerales ON tblproductosgenerales.IdProductosGeneral = tbltiendaproducto.IdProductosGeneral
    WHERE tbldetallepedido.IdPedido=idpedido;
END$$

DROP PROCEDURE IF EXISTS `ListarCategoriasTiendaPorID`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ListarCategoriasTiendaPorID` (IN `idtienda` INT)  BEGIN
	SELECT distinct(tblcategoria.nombre)
	FROM tbltienda
	INNER JOIN tbltiendaproducto ON tbltiendaproducto.IdTienda = tbltienda.IdTienda
	INNER JOIN tblproductosgenerales ON tblproductosgenerales.IdProductosGeneral = tbltiendaproducto.IdProductosGeneral
	INNER JOIN tblcategoria ON tblcategoria.IdCategoria = tblproductosgenerales.IdCategoria
	WHERE tbltienda.IdTienda = idtienda;
	
END$$

DROP PROCEDURE IF EXISTS `listarhistorialpedidos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `listarhistorialpedidos` (IN `usuario` VARCHAR(12))  BEGIN
	SET @num=0;
	SELECT @num:=@num+1 AS Num ,tblpedido.fecha, tbltienda.nombre,tblpedido.importetotalMX, tblestadopedido.nombreEstado, tblpedido.IdPedido
	FROM tblpedido
	INNER JOIN tbltienda ON tbltienda.IdTienda = tblpedido.IdTienda
	INNER JOIN tblestadopedido ON tblestadopedido.IdEstadoPedido = tblpedido.IdEstadoPedido
	INNER JOIN tblcliente ON tblcliente.IdCliente = tblpedido.IdCliente
	INNER JOIN tblpersona ON tblpersona.IdPersona = tblcliente.IdPersona
	INNER JOIN tblusuario ON tblusuario.IdPersona = tblpersona.IdPersona
	WHERE tblusuario.IdUsuario = usuario;
    
END$$

DROP PROCEDURE IF EXISTS `listarProductos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `listarProductos` (IN `idusuario` VARCHAR(12))  BEGIN
	SELECT tbltienda.IdTienda, tblproductosgenerales.descripcion, tblproductosgenerales.precioVentaMX, tbltiendaproducto.descuento
    FROM tbltienda
    INNER JOIN tblpersona ON tblpersona.IdPersona = tbltienda.IdPersona
    INNER JOIN tblusuario ON tblusuario.IdPersona = tblpersona.IdPersona
    INNER JOIN tbltiendaproducto ON tbltiendaproducto.IdTienda= tbltienda.IdTienda
    INNER JOIN tblproductosgenerales ON tblproductosgenerales.IdProductosGeneral = tbltiendaproducto.IdProductosGeneral
    WHERE tblusuario.IdUsuario=idusuario;
END$$

DROP PROCEDURE IF EXISTS `listarProductosporCategoria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `listarProductosporCategoria` (IN `idcategoria` INT)  BEGIN
	SELECT tbltienda.IdTienda, tblproductosgenerales.descripcion, tblproductosgenerales.precioVentaMX, tbltiendaproducto.descuento
    FROM tbltienda
    INNER JOIN tblrubro ON tblrubro.IdRubro = tbltienda.IdRubro
	INNER JOIN tblcategoria ON tblcategoria.IdCategoria = tblproductosgenerales.IdCategoria
    INNER JOIN tblproductosgenerales On tblproductosgenerales.IdProductosGenerales=tbltiendaproducto.IdProductosGenerales
    INNER JOIN tbltiendaproducto ON tbltiendaproducto.IdProductosGenerales= tbltiendaproducto.IdProductosGenerales
    WHERE tblcategoria.IdCategoria=idcategoria;
END$$

DROP PROCEDURE IF EXISTS `listarProductosTiendaUsuario`$$
CREATE DEFINER=`uroot`@`%` PROCEDURE `listarProductosTiendaUsuario` (IN `idusuario` VARCHAR(12))  BEGIN
	SELECT tbltienda.IdTienda, tblproductosgenerales.descripcion, tblproductosgenerales.precioVentaMX, tbltiendaproducto.descuento
    FROM tbltienda
    INNER JOIN tblpersona ON tblpersona.IdPersona = tbltienda.IdPersona
    INNER JOIN tblusuario ON tblusuario.IdPersona = tblpersona.IdPersona
    INNER JOIN tbltiendaproducto ON tbltiendaproducto.IdTienda= tbltienda.IdTienda
    INNER JOIN tblproductosgenerales ON tblproductosgenerales.IdProductosGeneral = tbltiendaproducto.IdProductosGeneral
    WHERE tblusuario.IdUsuario=idusuario;
END$$

DROP PROCEDURE IF EXISTS `listarProductosTiendaUsuCat`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `listarProductosTiendaUsuCat` (IN `idusuario` VARCHAR(12), IN `idcategoria` INT)  BEGIN
	SELECT tbltienda.IdTienda, tblproductosgenerales.descripcion, tblproductosgenerales.precioVentaMX, tbltiendaproducto.descuento
    FROM tbltienda
    INNER JOIN tblpersona ON tblpersona.IdPersona = tbltienda.IdPersona
    INNER JOIN tblusuario ON tblusuario.IdPersona = tblpersona.IdPersona
    INNER JOIN tbltiendaproducto ON tbltiendaproducto.IdTienda= tbltienda.IdTienda
    INNER JOIN tblproductosgenerales ON tblproductosgenerales.IdProductosGeneral = tbltiendaproducto.IdProductosGeneral
	INNER JOIN tblcategoria ON tblcategoria.IdCategoria = tblproductosgenerales.IdCategoria
    WHERE tblusuario.IdUsuario=idusuario and tblcategoria.idcategoria=idcategoria;
END$$

DROP PROCEDURE IF EXISTS `listarsolicitudesAceptadasTendero`$$
CREATE DEFINER=`uroot`@`%` PROCEDURE `listarsolicitudesAceptadasTendero` (IN `idtienda` INT)  BEGIN
	SELECT tblpedido.IdPedido, tblpedido.importetotalMX, tblpedido.hora, tblpedido.fecha,tblpersona.nombres,tblpersona.apPaterno,tblpersona.apMaterno,tblestadopedido.nombreEstado
    FROM tblpedido
	INNER JOIN tblcliente ON tblcliente.IdCliente = tblpedido.IdCliente
    INNER JOIN tblpersona ON tblpersona.IdPersona = tblcliente.IdPersona
    INNER JOIN tblestadopedido ON tblestadopedido.IdEstadoPedido = tblpedido.IdEstadoPedido
    WHERE tblpedido.IdTienda=idtienda And tblpedido.IdEstadoPedido != 1;
    END$$

DROP PROCEDURE IF EXISTS `listarsolicitudesTendero`$$
CREATE DEFINER=`uroot`@`%` PROCEDURE `listarsolicitudesTendero` (IN `idtienda` INT)  BEGIN
	SELECT tblpedido.IdPedido, tblpedido.importetotalMX, tblpedido.hora, tblpedido.fecha,tblpersona.nombres,tblpersona.apPaterno,tblpersona.apMaterno
    FROM tblpedido
	INNER JOIN tblcliente ON tblcliente.IdCliente = tblpedido.IdCliente
    INNER JOIN tblpersona ON tblpersona.IdPersona = tblcliente.IdPersona
    WHERE tblpedido.IdTienda=idtienda and IdEstadoPedido=1;
END$$

DROP PROCEDURE IF EXISTS `listarTiendaporRubro`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `listarTiendaporRubro` (IN `idrubro` INT)  BEGIN
	SELECT tbltienda.IdTienda, tbltienda.nombre, tbltienda.descripcionubicacion, tbltienda.calificacion
    FROM tbltienda
    INNER JOIN tblrubro ON tblrubro.IdRubro = tbltienda.IdRubro
    WHERE tblrubro.IdRubro=idrubro;
END$$

DROP PROCEDURE IF EXISTS `ModificarEstadoAceptadotendero`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ModificarEstadoAceptadotendero` (IN `p_IdEstadoPedido` INT, IN `idpedido` INT)  BEGIN
    
    UPDATE  tblpedido set IdEstadoPedido=p_IdEstadoPedido
    
	where tblpedido.IdPedido=idpedido;
END$$

DROP PROCEDURE IF EXISTS `mostrarDetallePedido`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrarDetallePedido` (IN `idpedido` INT)  BEGIN
	SELECT tbldetallepedido.cantidad, tblproductosgenerales.descripcion, tbldetallepedido.subtotal
	FROM tbldetallepedido
	INNER JOIN tbltiendaproducto ON tbldetallepedido.IdTiendaProducto = tbltiendaproducto.IdTiendaProducto
	INNER JOIN tblproductosgenerales ON tbltiendaproducto.IdProductosGeneral = tblproductosgenerales.IdProductosGeneral
	INNER JOIN tblpedido ON tblpedido.IdPedido = tbldetallepedido.IdPedido
	WHERE tblpedido.IdPedido = idpedido;

END$$

DROP PROCEDURE IF EXISTS `mostrarListaPedidosPorId`$$
CREATE DEFINER=`uroot`@`%` PROCEDURE `mostrarListaPedidosPorId` (IN `idusuario` VARCHAR(12))  BEGIN
	select tblpedido.IdPedido, tbltienda.nombre, tblmetodopago.nombre, tblpedido.fecha, tblpedido.importetotalMX, tblestadopedido.nombreEstado
	from tblpedido
	inner join tbltienda on tbltienda.IdTienda = tblpedido.IdTienda
	inner join tblmetodopago on tblmetodopago.IdMetodoPago = tblpedido.IdMetodoPago
	inner join tblestadopedido on tblestadopedido.IdEstadoPedido = tblpedido.IdEstadoPedido
	inner join tblcliente on  tblcliente.IdCliente = tblpedido.IdCliente
	inner join tblpersona on tblcliente.IdPersona = tblpersona.IdPersona
	inner join tblusuario on tblusuario.IdPersona = tblpersona.IdPersona
	WHERE tblusuario.IdUsuario = idusuario;
END$$

DROP PROCEDURE IF EXISTS `mostrarProductosporCategoria`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `mostrarProductosporCategoria` (IN `idtienda` INT, IN `categoria` VARCHAR(100))  BEGIN
	SELECT tbltiendaproducto.IdTiendaProducto,tblproductosgenerales.descripcion,tbltiendaproducto.precioVTiendaMX
	FROM tbltienda
	INNER JOIN tbltiendaproducto ON tbltiendaproducto.IdTienda = tbltienda.IdTienda
	INNER JOIN tblproductosgenerales ON tbltiendaproducto.IdProductosGeneral = tblproductosgenerales.IdProductosGeneral
	INNER JOIN tblcategoria ON tblcategoria.IdCategoria = tblproductosgenerales.IdCategoria
	WHERE tbltienda.IdTienda = idtienda AND tblcategoria.nombre=categoria;
END$$

DROP PROCEDURE IF EXISTS `registrarCliente`$$
CREATE DEFINER=`uroot`@`%` PROCEDURE `registrarCliente` (IN `ap_pa` VARCHAR(50), IN `ap_ma` VARCHAR(50), IN `nom` VARCHAR(100), IN `num_id` VARCHAR(20), IN `cell` VARCHAR(20), IN `sexo` VARCHAR(20), IN `email` VARCHAR(200), IN `foto` VARCHAR(255), IN `descrip` VARCHAR(200), IN `longitud` FLOAT(10,7), IN `latitud` FLOAT(10,7), IN `id_us` VARCHAR(12), IN `pass` VARCHAR(10))  BEGIN
	DECLARE id INT;
    INSERT INTO tblpersona (apPaterno, apMaterno, nombres, nidentificacion, celular,sexo, email, foto)
	VALUES(ap_pa, ap_ma, nom, num_id, cell, sexo, email, foto);
    
    SET id := (SELECT MAX(IdPersona) FROM tblpersona);
    
    INSERT INTO tblubicacion(descripcion, longitud, latitud, IdPersona)
    VALUES(descrip, longitud, latitud, id);
    
    INSERT INTO tblcliente (longitudFrecuente, latitudFrecuente,IdPersona)
	VALUES(longitud,latitud,id);
    
    INSERT INTO tblusuario(IdUsuario,contraseña,IdNivel,IdTUsuario,IdPersona)
    VALUES(id_us,pass,2,2,id);
    
END$$

DROP PROCEDURE IF EXISTS `registrarListado`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarListado` (IN `idtiendaproducto` INT, IN `idpedido` INT, IN `cantidad` INT, IN `preciouniMX` FLOAT, IN `subtotal` FLOAT)  BEGIN
	INSERT INTO tbldetallepedido(IdTiendaProducto,IdPedido,cantidad,preciouniMX,descuento,subtotal)
    VALUES (idtiendaproducto,idpedido,cantidad,preciouniMX,0,subtotal);
END$$

DROP PROCEDURE IF EXISTS `registrarProducto`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarProducto` (IN `nom_pro` VARCHAR(50), IN `pre_ven` VARCHAR(50), IN `ima1` VARCHAR(255), IN `ima2` VARCHAR(255), IN `cat` INT, IN `pro` VARCHAR(20), IN `idtienda` INT)  BEGIN
	DECLARE id_prod INT;
    
    INSERT INTO tblproductosgenerales (descripcion, precioVentaMX, img_min, img_medium, IdCategoria)
	VALUES(nom_pro, pre_ven, ima1, ima2, cat);
        
    SET id_prod := (SELECT MAX(IdProductosGeneral) FROM tblproductosgenerales);
    
    INSERT INTO tbltiendaproducto(precioVTiendaMX,descuento,idTienda,IdProductosGeneral)
    VALUES(pre_ven,pro,idtienda,id_prod);
END$$

DROP PROCEDURE IF EXISTS `registrarTienda`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarTienda` (IN `ap_pa` VARCHAR(50), IN `ap_ma` VARCHAR(50), IN `nom` VARCHAR(100), IN `num_id` VARCHAR(20), IN `cell` VARCHAR(20), IN `sexo` VARCHAR(20), IN `email` VARCHAR(200), IN `foto` VARCHAR(255), IN `descrip` VARCHAR(200), IN `longitud` FLOAT(10,7), IN `latitud` FLOAT(10,7), IN `ruc` VARCHAR(20), IN `nombre_tienda` VARCHAR(200), IN `id_rubro` INT, IN `id_us` VARCHAR(12), IN `pass` VARCHAR(10))  BEGIN

	DECLARE id_per INT;
    INSERT INTO tblpersona (apPaterno, apMaterno, nombres, nidentificacion, celular,sexo, email, foto)
	VALUES(ap_pa, ap_ma, nom, num_id, cell, sexo, email, foto);
    
    SET id_per := (SELECT MAX(IdPersona) FROM tblpersona);
    
    INSERT INTO tblubicacion(descripcion, longitud, latitud, IdPersona)
    VALUES(descrip, longitud, latitud, id_per);
    
    INSERT INTO tbltienda(RUC,nombre,longitudTienda,latitudTienda,estadoapertura,npublicacionresta,IdRubro,IdPersona,calificacion,descripcionubicacion)
    VALUES(ruc,nombre_tienda,longitud,latitud,'ABIERTO',2,id_rubro,id_per,0.0,descrip);

    INSERT INTO tblusuario(IdUsuario,contraseña,IdNivel,IdTUsuario,IdPersona)
    VALUES(id_us,pass,2,1,id_per);
    
END$$

DROP PROCEDURE IF EXISTS `spConsultarAnunciosSeg`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spConsultarAnunciosSeg` (IN `iduser` VARCHAR(12))  select imagen,url from tblanuncios 
where fechaFinal >= NOW() AND 
fechaInicio <= NOW() AND 
categoria=(Select tblproductosgenerales.IdCategoria from tblproductosgenerales	
           INNER JOIN tblcategoria on tblcategoria.IdCategoria = tblproductosgenerales.IdCategoria 
           Inner join tbltiendaproducto ON tbltiendaproducto.IdProductosGeneral = tblproductosgenerales.IdProductosGeneral 
           INNER join tbldetallepedido ON tbltiendaproducto.IdTiendaProducto = tbldetallepedido.IdTiendaProducto INNER JOIN tblpedido ON tblpedido.IdPedido = tbldetallepedido.IdPedido INNER JOIN tblcliente ON tblcliente.IdCliente = tblpedido.IdCliente  INNER JOIN tblusuario ON tblusuario.IdPersona=tblcliente.IdPersona 
           WHERE tblusuario.IdUsuario=iduser 
           GROUP BY tblproductosgenerales.IdCategoria 
           ORDER BY COUNT(tblproductosgenerales.IdCategoria) DESC LIMIT 1)$$

DROP PROCEDURE IF EXISTS `spEncargoEnCamino`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spEncargoEnCamino` (IN `IdRepartidor` INT, IN `IdPedido` INT)  BEGIN
	DECLARE errno INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET CURRENT DIAGNOSTICS CONDITION 1 errno = MYSQL_ERRNO;
        SELECT errno AS MYSQL_ERROR;
        ROLLBACK;
    END;
	START TRANSACTION;
    SET @estadoRepartidor = 'OCUPADO';#Estado Ocupado
    SET @estadoPedido = 4;#Estado En camino

    UPDATE tblrepartidor SET tblrepartidor.estado = @estadoRepartidor
    WHERE tblrepartidor.IdRepartidor= IdRepartidor;

	UPDATE tblpedido SET tblpedido.IdEstadoPedido = @estadoPedido
	WHERE tblpedido.IdPedido= IdPedido;
    
    COMMIT WORK;
END$$

DROP PROCEDURE IF EXISTS `spEncargoFinalizado`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spEncargoFinalizado` (IN `IdRepartidor` INT, IN `IdPedido` INT)  BEGIN
	DECLARE errno INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
	GET CURRENT DIAGNOSTICS CONDITION 1 errno =	MYSQL_ERRNO;
        SELECT errno AS MYSQL_ERROR;
        ROLLBACK;
    END;
    
	START TRANSACTION;
    SET @estadoRepartidor = 'DISPONIBLE'; #Estado disponible
    SET @estadoPedido = 5; #Estado Entregado

    UPDATE tblrepartidor SET tblrepartidor.estado = @estadoRepartidor 	  WHERE tblrepartidor.IdRepartidor= IdRepartidor;
    
    UPDATE tblpedido SET tblpedido.IdEstadoPedido = @estadoPedido 	  	  WHERE tblpedido.IdPedido= IdPedido;
    
    COMMIT WORK;
END$$

DROP PROCEDURE IF EXISTS `spEncargoObtener`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spEncargoObtener` (IN `IdRepartidor` INT)  BEGIN
SET @estadoPedido = 4;
 
SELECT tblpedido.IdPedido AS id_pedido, tblpedido.hora AS hora, tblpersona.IdPersona AS id_persona, tblpersona.nombres AS nombre, tblpersona.apPaterno AS primer_apellido, 
tblpersona.apMaterno AS segundo_apellido, tblubicacionentrega.descripcion AS direccion, tblubicacionentrega.latitud AS latitud, tblubicacionentrega.longitud AS longitud, tblpedido.importetotalMX AS importe, tblpedido.pagoconMX AS tipo_pago, tblpedido.cambioMX AS cambio, tblmetodopago.nombre AS metodo_pago, tblpersona.celular AS telefono FROM tblpedido 
INNER JOIN tblcliente ON tblcliente.IdCliente = tblpedido.IdCliente 
INNER JOIN tblpersona ON tblpersona.IdPersona = tblcliente.IdPersona 
INNER JOIN tblmetodopago ON tblmetodopago.IdMetodoPago = tblpedido.IdMetodoPago 
INNER JOIN tblestadopedido ON tblestadopedido.IdEstadoPedido = tblpedido.IdEstadoPedido 
INNER JOIN tblubicacionentrega ON tblubicacionentrega.IdUbicacionE = tblpedido.IdUbicacionE WHERE tblpedido.IdRepartidor = IdRepartidor 
AND tblpedido.IdEstadoPedido = @estadoPedido LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `spEncargosListar`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spEncargosListar` (IN `IdTienda` INT)  BEGIN
	SELECT tblpedido.IdPedido,tblpedido.fecha, tblpedido.hora, tblpersona.IdPersona, tblpersona.apPaterno, tblpersona.nombres, tblubicacionentrega.descripcion, tblpedido.importetotalMX, tblpedido.pagoconMX, tblestadopedido.nombreEstado,
	tblpedido.cambioMX, tblmetodopago.nombre, tblpersona.celular, tblestadopedido.nombreEstado FROM tblpedido 
	INNER JOIN tblcliente ON tblcliente.IdCliente = tblpedido.IdCliente INNER JOIN tblpersona ON tblpersona.IdPersona = tblcliente.IdPersona 
	INNER JOIN tblmetodopago ON tblmetodopago.IdMetodoPago = tblpedido.IdMetodoPago INNER JOIN tblestadopedido ON tblestadopedido.IdEstadoPedido = tblpedido.IdEstadoPedido 
	INNER JOIN tblubicacionentrega ON tblubicacionentrega.IdUbicacionE = tblpedido.IdUbicacionE WHERE tblpedido.IdTienda = IdTienda AND tblestadopedido.nombreEstado='ACEPTADO' ORDER BY tblpedido.fecha DESC, tblpedido.hora DESC;
END$$

DROP PROCEDURE IF EXISTS `spEncargosListarHistorial`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spEncargosListarHistorial` (IN `IdTienda` INT, IN `IdRepartidor` INT)  BEGIN
	SELECT tblpedido.IdPedido,tblpedido.fecha, tblpedido.hora, tblpersona.IdPersona, tblpersona.apPaterno, tblpersona.nombres, tblubicacionentrega.descripcion, tblpedido.importetotalMX, tblpedido.pagoconMX, tblestadopedido.nombreEstado,
	tblpedido.cambioMX, tblmetodopago.nombre, tblpersona.celular, tblestadopedido.nombreEstado FROM tblpedido 
	INNER JOIN tblcliente ON tblcliente.IdCliente = tblpedido.IdCliente INNER JOIN tblpersona ON tblpersona.IdPersona = tblcliente.IdPersona 
	INNER JOIN tblmetodopago ON tblmetodopago.IdMetodoPago = tblpedido.IdMetodoPago INNER JOIN tblestadopedido ON tblestadopedido.IdEstadoPedido = tblpedido.IdEstadoPedido 
	INNER JOIN tblubicacionentrega ON tblubicacionentrega.IdUbicacionE = tblpedido.IdUbicacionE WHERE tblpedido.IdTienda = IdTienda AND 
    tblpedido.IdRepartidor=IdRepartidor AND tblestadopedido.nombreEstado='ENTREGADO' OR tblestadopedido.nombreEstado='EN CAMINO' OR tblestadopedido.nombreEstado='RECHAZADO'ORDER BY tblpedido.fecha DESC, tblpedido.hora DESC;
END$$

DROP PROCEDURE IF EXISTS `spObtenerUbicacionEntrega`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spObtenerUbicacionEntrega` (IN `idPedido` INT)  BEGIN
 
SELECT tblubicacionentrega.latitud,tblubicacionentrega.longitud from tblubicacionentrega 
INNER JOIN tblpedido 
ON tblpedido.IdUbicacionE= tblubicacionentrega.IdUbicacionE 
WHERE tblpedido.IdPedido=idPedido;
END$$

DROP PROCEDURE IF EXISTS `spRegistrarAnuncio`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spRegistrarAnuncio` (IN `cat` INT(50), IN `titulo` VARCHAR(50), IN `descr` VARCHAR(250), IN `imagen` VARCHAR(200), IN `url` VARCHAR(100), IN `fechainicio` DATETIME, IN `fechafinal` DATETIME, IN `monto` DECIMAL(10,2), IN `idper` VARCHAR(12))  BEGIN
	
    INSERT INTO tblanuncios(categoria, titulo, descripcion, imagen, url,fechaInicio, fechaFinal, montoPagado, IdUsuario)
	VALUES(cat, titulo, descr, imagen, url, fechainicio, fechafinal, monto,idper);
   
  
    
END$$

DROP PROCEDURE IF EXISTS `spRegistrarRepartidor`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spRegistrarRepartidor` (IN `ap_pa` VARCHAR(50), IN `ap_ma` VARCHAR(50), IN `nom` VARCHAR(100), IN `num_id` VARCHAR(20), IN `cell` VARCHAR(20), IN `sexo` VARCHAR(20), IN `email` VARCHAR(200), IN `nom_vehiculo` VARCHAR(50), IN `placa` VARCHAR(10), IN `id_us` VARCHAR(12), IN `pass` VARCHAR(10))  BEGIN
	DECLARE id_per INT;
    DECLARE id_ve INT;
    INSERT INTO tblpersona (apPaterno, apMaterno, nombres, nidentificacion, celular,sexo, email, foto)
	VALUES(ap_pa, ap_ma, nom, num_id, cell, sexo, email, '');
    
    SET id_per := (SELECT MAX(IdPersona) FROM tblpersona);
    
    INSERT INTO tblubicacion(descripcion, longitud, latitud, IdPersona)
    VALUES('', '', '', id_per);
    
    INSERT INTO tblvehiculo(nombreVehiculo,placa)
    VALUES(nom_vehiculo,placa);
    
	SET id_ve := (SELECT MAX(IdVehiculo) FROM tblvehiculo);
    
    INSERT INTO tblrepartidor (estado,calificaciongeneral,IdVehiculo,IdPersona)
	VALUES('DISPONIBLE',0.0,id_ve,id_per);
    
    INSERT INTO tblusuario(IdUsuario,contraseña,IdNivel,IdTUsuario,IdPersona)
    VALUES(id_us,pass,2,3,id_per);
END$$

DROP PROCEDURE IF EXISTS `spRepartidorObtenerEstado`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spRepartidorObtenerEstado` (IN `IdRepartidor` INT)  BEGIN
	SELECT tblrepartidor.estado FROM tblrepartidor WHERE tblrepartidor.IdRepartidor= IdRepartidor;
END$$

DROP PROCEDURE IF EXISTS `spRepartidorRegistrar`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spRepartidorRegistrar` (IN `ap_pa` VARCHAR(50), IN `ap_ma` VARCHAR(50), IN `nom` VARCHAR(100), IN `num_id` VARCHAR(20), IN `cell` VARCHAR(20), IN `sexo` VARCHAR(20), IN `email` VARCHAR(200), IN `nom_vehiculo` VARCHAR(50), IN `placa` VARCHAR(10), IN `id_us` VARCHAR(12), IN `pass` VARCHAR(10))  BEGIN
	DECLARE id_per INT;
    DECLARE id_ve INT;
    INSERT INTO tblpersona (apPaterno, apMaterno, nombres, nidentificacion, celular,sexo, email, foto)
	VALUES(ap_pa, ap_ma, nom, num_id, cell, sexo, email, '');
    
    SET id_per := (SELECT MAX(IdPersona) FROM tblpersona);
    
    INSERT INTO tblubicacion(descripcion, longitud, latitud, IdPersona)
    VALUES('', '', '', id_per);
    
    INSERT INTO tblvehiculo(nombreVehiculo,placa)
    VALUES(nom_vehiculo,placa);
    
	SET id_ve := (SELECT MAX(IdVehiculo) FROM tblvehiculo);
    
    INSERT INTO tblrepartidor (estado,calificaciongeneral,IdVehiculo,IdPersona)
	VALUES('DISPONIBLE',0.0,id_ve,id_per);
    
    INSERT INTO tblusuario(IdUsuario,contraseña,IdNivel,IdTUsuario,IdPersona)
    VALUES(id_us,pass,2,3,id_per);
END$$

DROP PROCEDURE IF EXISTS `spUsuarioActualizarCelular`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUsuarioActualizarCelular` (IN `IdPersona` INT, IN `celular` VARCHAR(50))  BEGIN
UPDATE tblpersona SET tblpersona.celular = celular WHERE tblpersona.IdPersona = IdPersona;
END$$

DROP PROCEDURE IF EXISTS `spUsuarioActualizarContrasena`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUsuarioActualizarContrasena` (IN `idUsuario` VARCHAR(300), IN `contrasena` VARCHAR(300))  BEGIN
UPDATE tblusuario SET tblusuario.contraseña = contrasena WHERE tblusuario.IdUsuario = idUsuario;
END$$

DROP PROCEDURE IF EXISTS `spUsuarioActualizarCorreo`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUsuarioActualizarCorreo` (IN `IdPersona` INT, IN `correo` VARCHAR(300))  BEGIN
UPDATE tblpersona SET tblpersona.email = correo WHERE tblpersona.IdPersona = IdPersona;
END$$

DROP PROCEDURE IF EXISTS `spUsuarioActualizarNombreApelidos`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUsuarioActualizarNombreApelidos` (IN `IdPersona` INT, IN `nombre` VARCHAR(50), IN `primerApellido` VARCHAR(50), IN `segundoApellido` VARCHAR(50))  BEGIN
UPDATE tblpersona SET tblpersona.nombres = nombre, tblpersona.apPaterno = primerApellido, tblpersona.apMaterno = segundoApellido WHERE tblpersona.IdPersona = IdPersona;
END$$

DROP PROCEDURE IF EXISTS `spUsuarioIniciarSesion`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUsuarioIniciarSesion` (IN `usuario` VARCHAR(50))  BEGIN

SELECT R.IdRepartidor AS id_repartidor, V.IdVehiculo AS id_vehiculo, v.nombreVehiculo AS vehiculo, U.IdPersona AS id_persona, U.contraseña AS contrasena,
	   P.nidentificacion AS idendificacion, P.nombres AS nombre, P.apPaterno AS primer_apellido, 
	   P.apMaterno AS segundo_apellido,  P.celular AS telefono, 
	   P.email AS correo, P.sexo AS sexo, P.foto AS foto,
       H.IdTienda AS id_tienda, H.estadocontrato AS contrato_tienda
       FROM  tblrepartidor R 
       INNER JOIN tblvehiculo V ON R.IdVehiculo = V.IdVehiculo
       INNER JOIN tblpersona P ON R.IdPersona = P.IdPersona
       INNER JOIN tblusuario U ON R.IdPersona = U.IdPersona
       LEFT JOIN tblhistorialrepartidor H ON R.IdRepartidor
       WHERE (P.celular = usuario AND P.IdPersona = U.IdPersona) OR (U.IdUsuario = usuario AND U.IdPersona = P.IdPersona);
       
END$$

DROP PROCEDURE IF EXISTS `spUsuarioValidarRegistro`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spUsuarioValidarRegistro` (IN `identificacion` VARCHAR(50), IN `email` VARCHAR(50), IN `celular` VARCHAR(50), IN `usuario` VARCHAR(50), OUT `EXISTS_ID` TINYINT, OUT `EXISTS_MAIL` TINYINT, OUT `EXISTS_CELULAR` TINYINT, OUT `EXISTS_USUARIO` TINYINT)  BEGIN
	# comprobar identificacion
	IF(identificacion IS NOT NULL) THEN
		SELECT COUNT(*) INTO EXISTS_ID 
        FROM tblpersona 
    	WHERE tblpersona.nidentificacion = identificacion;
    ELSE
    	SET EXISTS_ID = -1;
    END IF;
    
	# comprobar correo
	IF(email IS NOT NULL) THEN
		SELECT COUNT(*) INTO EXISTS_MAIL 
        FROM tblpersona 
    	WHERE tblpersona.email = email;
    ELSE
    	SET EXISTS_MAIL = -1;
    END IF;
    
    # comprobar celular
    IF(celular IS NOT NULL) THEN
        SELECT COUNT(*) INTO EXISTS_CELULAR 
        FROM tblpersona 
        WHERE tblpersona.celular = celular;
    ELSE
    	SET EXISTS_CELULAR = -1;
    END IF;
    
    # comprobar usuario
    IF(usuario IS NOT NULL) THEN
        SELECT COUNT(*) INTO EXISTS_USUARIO 
        FROM tblusuario 
        WHERE tblusuario.IdUsuario = usuario;
    ELSE
    	SET EXISTS_USUARIO = -1;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_muestraTiendas`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_muestraTiendas` (IN `nomRubro` VARCHAR(200))  BEGIN
		SELECT tbltienda.IdTienda,tbltienda.nombre, tblpersona.foto, tbltienda.calificacion, tbltienda.descripcionubicacion
		FROM tbltienda
		INNER JOIN tblrubro ON tblrubro.IdRubro = tbltienda.IdRubro
		INNER JOIN tblpersona ON tblpersona.IdPersona = tbltienda.IdPersona 
		WHERE  tblrubro.nombreRubro = nomRubro;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblanuncios`
--

DROP TABLE IF EXISTS `tblanuncios`;
CREATE TABLE IF NOT EXISTS `tblanuncios` (
  `IdAnuncio` int(11) NOT NULL AUTO_INCREMENT,
  `categoria` int(11) NOT NULL,
  `titulo` varchar(50) NOT NULL,
  `descripcion` varchar(250) NOT NULL,
  `imagen` varchar(200) NOT NULL,
  `url` varchar(100) NOT NULL,
  `fechaInicio` datetime NOT NULL,
  `fechaFinal` datetime NOT NULL,
  `montoPagado` decimal(10,2) NOT NULL,
  `IdUsuario` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`IdAnuncio`),
  KEY `IdUsuario` (`IdUsuario`),
  KEY `categoria` (`categoria`),
  KEY `IdUsuario_2` (`IdUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblanuncios`
--

INSERT INTO `tblanuncios` (`IdAnuncio`, `categoria`, `titulo`, `descripcion`, `imagen`, `url`, `fechaInicio`, `fechaFinal`, `montoPagado`, `IdUsuario`) VALUES
(60, 1, 'publicidad 01', 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/1.jpeg', 'http://www.google.com', '2021-11-17 17:11:00', '2021-12-31 18:11:00', '220.00', 'abc'),
(77, 5, ' Finibus Bonorum et Malorum', 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/77.jpeg', 'http://usjjsbs', '2021-11-03 18:14:00', '2021-11-05 19:14:00', '10.00', 'abc'),
(78, 6, 'isisujdj', 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/78.jpeg', 'http://usjsjjsbshyzuksbtgh', '2021-10-06 20:07:00', '2021-10-08 21:07:00', '10.00', 'abc'),
(100, 2, 'jzjdhvd', 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident.', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/98.jpeg', 'http://bzbdd', '2021-10-07 12:39:00', '2021-10-14 13:39:00', '35.00', 'abc'),
(101, 5, 'Venom y Carnage', 'Venom la pelicula', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/101.jpeg', 'http://www.marvel.com', '2021-10-06 12:20:00', '2021-10-15 13:20:00', '45.00', 'abc'),
(102, 1, 'udjdndnnf', 'jdjdjdjbekfod', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/102.jpeg', 'http://jdjjdjfbfbf', '2021-11-17 17:12:00', '2021-12-31 18:12:00', '220.00', 'abc'),
(103, 3, 'leche gloria', 'jdjdbbd', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/103.jpeg', 'http://jdjdbbhdb', '2021-11-03 18:18:00', '2021-11-30 21:18:00', '135.00', 'abc'),
(105, 7, 'Panadol', 'panadol medicina', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/105.jpeg', 'http://www.panadol com', '2021-10-13 12:21:00', '2021-10-29 23:55:00', '80.00', 'abc'),
(106, 6, 'pepsi', 'ndnsnsn fkskek', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/106.jpeg', 'http://www.pepsi.com', '2021-11-03 18:20:00', '2021-11-30 19:20:00', '135.00', 'hh'),
(107, 6, 'Coca cola', 'isksndndb dnskdd dkdkkdbf', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/107.jpeg', 'http://www.cocacola.com', '2021-11-03 18:19:00', '2021-11-30 19:19:00', '135.00', 'hh'),
(108, 1, 'Jueves de pavita', 'ldlsndn dndldldl dndkdod dndkdl dkdkdnnfkf fkfkdkd fkfkf', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/108.jpeg', 'http://www.pavita.com', '2021-10-13 16:30:00', '2022-12-29 23:55:00', '80.00', 'diego'),
(109, 3, 'jsjsjdb', 'ysyshdhjdjdj djdjkd djdjjd djdjjd djjdj', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/109.jpeg', 'http://www.google.com', '2021-10-13 21:50:00', '2021-10-29 22:50:00', '80.00', 'gg'),
(110, 5, 'Lehe ideal', 'este es un anuncio', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/110.jpeg', 'http://www.ideal.com', '2021-11-03 18:18:00', '2021-11-30 19:18:00', '135.00', 'abc'),
(111, 7, 'iskskssnw', 'msmsmsnd dkdkd', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/111.jpeg', 'http://lslsksndn', '2021-11-19 16:35:00', '2021-11-24 17:35:00', '25.00', 'abc'),
(112, 18, 'Publicidad bachata 2x1', 'promo salsa y bachata', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/112.jpeg', 'http://www.google.com.pe', '2021-11-17 17:25:00', '2021-12-31 18:25:00', '220.00', 'abc'),
(113, 18, 'ldkdndbf', 'mxmdmdnd', 'http://192.168.1.125:2020/APIS/patrocinador/uploads/113.jpeg', 'http://oslskdnd', '2021-11-17 17:57:00', '2021-11-25 18:57:00', '40.00', 'abc');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblcategoria`
--

DROP TABLE IF EXISTS `tblcategoria`;
CREATE TABLE IF NOT EXISTS `tblcategoria` (
  `IdCategoria` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `IdRubro` int(11) NOT NULL,
  PRIMARY KEY (`IdCategoria`),
  KEY `IdRubro` (`IdRubro`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblcategoria`
--

INSERT INTO `tblcategoria` (`IdCategoria`, `nombre`, `descripcion`, `IdRubro`) VALUES
(1, 'CARNES', '', 3),
(2, 'REPOSTERIA', '', 3),
(3, 'LACTEOS', '', 3),
(4, 'MASCOTA', '', 3),
(5, 'FRUTAS Y VERDURAS', '', 3),
(6, 'BEBIDAS', '', 3),
(7, 'ANTIBIÓTICOS', '', 2),
(8, 'DISPOSITIVOS MEDICOS', NULL, 2),
(9, 'DOLOR E INFLAMACIÓN', NULL, 2),
(10, 'ADULTO MAYOR', NULL, 2),
(11, 'BELLEZA', NULL, 2),
(12, 'CUIDADO PERSONAL', NULL, 2),
(13, 'CUIDADO CAPILAR', NULL, 2),
(14, 'DERMOCOSMÉTICA', NULL, 2),
(15, 'NUTRICIÓN', NULL, 2),
(16, 'CUIDADO FEMENINO', NULL, 2),
(17, 'BEBÉS Y NIÑOS', NULL, 2),
(18, 'Promociones', 'Promociones', 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblchat`
--

DROP TABLE IF EXISTS `tblchat`;
CREATE TABLE IF NOT EXISTS `tblchat` (
  `IdChat` int(11) NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `IdReceptorC` varchar(12) NOT NULL,
  `IdEmisorC` varchar(12) NOT NULL,
  PRIMARY KEY (`IdChat`),
  KEY `IdReceptorC` (`IdReceptorC`),
  KEY `IdEmisorC` (`IdEmisorC`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblchat`
--

INSERT INTO `tblchat` (`IdChat`, `fecha`, `hora`, `IdReceptorC`, `IdEmisorC`) VALUES
(1, '2021-03-30', '18:13:00', 'kevinpapi', 'dougamer'),
(2, '2021-03-30', '18:13:00', 'kevinpapi', 'tucovidvivo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblcliente`
--

DROP TABLE IF EXISTS `tblcliente`;
CREATE TABLE IF NOT EXISTS `tblcliente` (
  `IdCliente` int(11) NOT NULL AUTO_INCREMENT,
  `longitudFrecuente` float(10,7) DEFAULT NULL,
  `latitudFrecuente` float(10,7) DEFAULT NULL,
  `IdPersona` int(11) NOT NULL,
  PRIMARY KEY (`IdCliente`),
  KEY `IdPersona` (`IdPersona`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblcliente`
--

INSERT INTO `tblcliente` (`IdCliente`, `longitudFrecuente`, `latitudFrecuente`, `IdPersona`) VALUES
(1, -12.0206232, -75.2334518, 1),
(2, -13.0206232, -73.2334518, 2),
(3, -15.5213852, -10.0812483, 3),
(4, -17.1832180, -11.5351801, 4),
(5, -19.2835178, -13.5534801, 5),
(6, -24.3912258, -15.3518534, 6),
(7, -11.5335617, -13.8117476, 7),
(8, -13.2934570, -9.3912439, 8),
(9, 0.0000000, 0.0000000, 16),
(10, 0.0000000, 0.0000000, 17),
(12, 0.0000000, 0.0000000, 21),
(13, 0.0000000, 0.0000000, 22),
(14, -15.4564600, -16.1231308, 23),
(15, 0.0000000, 0.0000000, 24),
(16, 0.0000000, 0.0000000, 25),
(17, 0.0000000, 0.0000000, 26),
(18, 0.0000000, 0.0000000, 27),
(19, 0.0000000, 0.0000000, 29),
(20, 0.0000000, 0.0000000, 32),
(21, 0.0000000, 0.0000000, 33),
(22, 0.0000000, 0.0000000, 36),
(23, 0.0000000, 0.0000000, 37),
(24, 0.0000000, 0.0000000, 44),
(25, 0.0000000, 0.0000000, 45),
(26, 0.0000000, 0.0000000, 46),
(27, 0.0000000, 0.0000000, 47),
(28, 0.0000000, 0.0000000, 52),
(29, 0.0000000, 0.0000000, 55),
(30, 0.0000000, 0.0000000, 56),
(31, 0.0000000, 0.0000000, 57),
(32, 0.0000000, 0.0000000, 58),
(33, 0.0000000, 0.0000000, 59),
(34, 0.0000000, 0.0000000, 60),
(35, 0.0000000, 0.0000000, 61);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbldetallemembresia`
--

DROP TABLE IF EXISTS `tbldetallemembresia`;
CREATE TABLE IF NOT EXISTS `tbldetallemembresia` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(100) NOT NULL,
  `Descripcion` varchar(500) NOT NULL,
  `Precio` decimal(10,2) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tbldetallemembresia`
--

INSERT INTO `tbldetallemembresia` (`ID`, `Nombre`, `Descripcion`, `Precio`) VALUES
(1, 'Basico', 'Beneficios basicos', '25.00'),
(2, 'Medio', 'Beneficios MEdios', '50.00'),
(3, 'Premium', 'Beneficios Altos', '100.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbldetallepedido`
--

DROP TABLE IF EXISTS `tbldetallepedido`;
CREATE TABLE IF NOT EXISTS `tbldetallepedido` (
  `IdTiendaProducto` int(11) NOT NULL,
  `IdPedido` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `preciouniMX` float NOT NULL,
  `descuento` float NOT NULL,
  `subtotal` float NOT NULL,
  `iddetalle` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`iddetalle`),
  KEY `IdTiendaProducto` (`IdTiendaProducto`),
  KEY `IdPedido` (`IdPedido`)
) ENGINE=InnoDB AUTO_INCREMENT=118 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbldetallepedido`
--

INSERT INTO `tbldetallepedido` (`IdTiendaProducto`, `IdPedido`, `cantidad`, `preciouniMX`, `descuento`, `subtotal`, `iddetalle`) VALUES
(1, 1, 1, 149, 0, 149, 1),
(2, 1, 1, 142, 0.1, 127.8, 2),
(3, 1, 1, 107, 0, 147, 3),
(4, 1, 1, 40.6, 0, 40.6, 4),
(7, 2, 1, 20, 0.2, 16, 5),
(8, 2, 1, 22, 0, 22, 6),
(9, 2, 1, 21, 0, 21, 7),
(1, 7, 3, 5.5, 0, 16.5, 8),
(2, 10, 2, 248.5, 0, 350, 9),
(3, 10, 2, 248.5, 0, 350, 10),
(3, 10, 2, 248.5, 0, 350, 11),
(4, 10, 2, 248.5, 0, 350, 12),
(4, 10, 2, 248.5, 0, 350, 15),
(2, 1, 2, 248.5, 0, 350, 16),
(2, 10, 2, 248.5, 0, 350, 27),
(2, 10, 2, 248.5, 0, 350, 28),
(2, 10, 2, 248.5, 0, 350, 29),
(2, 10, 2, 30, 0, 100, 33),
(2, 10, 1, 15, 0, 15, 34),
(2, 10, 1, 15, 0, 15, 35),
(2, 10, 1, 15, 0, 20, 36),
(2, 10, 1, 15, 0, 15, 38),
(1, 33, 1, 149, 0, 149, 51),
(1, 34, 1, 149, 0, 149, 52),
(11, 34, 1, 5.5, 0, 5.5, 53),
(5, 34, 2, 37.4, 0, 74.8, 54),
(10, 35, 3, 23, 0, 69, 55),
(9, 35, 1, 21, 0, 21, 56),
(2, 36, 2, 142, 0, 284, 57),
(1, 37, 1, 149, 0, 149, 58),
(1, 38, 1, 149, 0, 149, 59),
(1, 39, 1, 149, 0, 149, 60),
(5, 40, 1, 37.4, 0, 37.4, 61),
(1, 41, 1, 149, 0, 149, 62),
(11, 42, 1, 5.5, 0, 5.5, 63),
(12, 42, 1, 100, 0, 100, 64),
(4, 43, 1, 40.6, 0, 40.6, 65),
(6, 43, 1, 30.5, 0, 30.5, 66),
(5, 44, 2, 37.4, 0, 74.8, 67),
(11, 45, 1, 5.5, 0, 5.5, 68),
(14, 45, 1, 10, 0, 10, 69),
(4, 46, 4, 40.6, 0, 162.4, 70),
(11, 46, 2, 5.5, 0, 11, 71),
(1, 47, 2, 149, 0, 298, 72),
(5, 79, 1, 37.4, 0, 37.4, 73),
(1, 79, 1, 149, 0, 149, 74),
(12, 79, 1, 100, 0, 100, 75),
(1, 80, 1, 149, 0, 149, 76),
(5, 80, 1, 37.4, 0, 37.4, 77),
(2, 80, 1, 142, 0, 142, 78),
(12, 80, 1, 100, 0, 100, 79),
(12, 81, 2, 100, 0, 200, 80),
(13, 81, 3, 100, 0, 300, 81),
(2, 81, 2, 142, 0, 284, 82),
(3, 82, 1, 107, 0, 107, 83),
(6, 82, 1, 30.5, 0, 30.5, 84),
(11, 82, 1, 5.5, 0, 5.5, 85),
(3, 83, 1, 107, 0, 107, 86),
(11, 83, 1, 5.5, 0, 5.5, 87),
(9, 85, 1, 21, 0, 21, 88),
(1, 86, 1, 149, 0, 149, 89),
(5, 87, 1, 37.4, 0, 37.4, 90),
(13, 88, 1, 100, 0, 100, 91),
(2, 88, 1, 142, 0, 142, 92),
(2, 89, 1, 142, 0, 142, 93),
(1, 89, 1, 149, 0, 149, 94),
(13, 89, 1, 100, 0, 100, 95),
(2, 90, 1, 142, 0, 142, 96),
(1, 90, 1, 149, 0, 149, 97),
(7, 90, 1, 20, 0, 20, 98),
(13, 90, 1, 100, 0, 100, 99),
(2, 91, 1, 142, 0, 142, 100),
(13, 91, 1, 100, 0, 100, 101),
(7, 91, 1, 20, 0, 20, 102),
(8, 92, 1, 22, 0, 22, 103),
(8, 93, 1, 22, 0, 22, 104),
(11, 94, 1, 5.5, 0, 5.5, 105),
(3, 94, 1, 107, 0, 107, 106),
(4, 94, 1, 40.6, 0, 40.6, 107),
(2, 95, 1, 142, 0, 142, 108),
(2, 95, 1, 142, 0, 142, 109),
(2, 95, 1, 142, 0, 142, 110),
(1, 95, 1, 149, 0, 149, 111),
(2, 95, 1, 142, 0, 142, 112),
(2, 95, 1, 142, 0, 142, 113),
(2, 95, 1, 142, 0, 142, 114),
(2, 95, 1, 142, 0, 142, 115),
(4, 96, 1, 40.6, 0, 40.6, 116),
(5, 96, 1, 37.4, 0, 37.4, 117);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblestadopedido`
--

DROP TABLE IF EXISTS `tblestadopedido`;
CREATE TABLE IF NOT EXISTS `tblestadopedido` (
  `IdEstadoPedido` int(11) NOT NULL AUTO_INCREMENT,
  `nombreEstado` varchar(20) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`IdEstadoPedido`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblestadopedido`
--

INSERT INTO `tblestadopedido` (`IdEstadoPedido`, `nombreEstado`, `descripcion`) VALUES
(1, 'SOLICITADO', 'Cuando el cliente solicite un pedido'),
(2, 'ACEPTADO', 'Cuando el tendero acepte un pedido'),
(3, 'RECHAZADO', 'Cuando el tendero rechaze un pedido'),
(4, 'EN CAMINO', 'Cuando el pedido se encuentre en camino'),
(5, 'ENTREGADO', 'Cuando el pedido sea entregado satisfacotriamente'),
(6, 'DENEGADO', 'Cuando el cliente rechaze el pedido'),
(7, 'RETENIDO', 'Cuando el pedido sufre algun contratiempo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblhistorialrepartidor`
--

DROP TABLE IF EXISTS `tblhistorialrepartidor`;
CREATE TABLE IF NOT EXISTS `tblhistorialrepartidor` (
  `IdRepartidor` int(11) NOT NULL,
  `IdTienda` int(11) NOT NULL,
  `fechainicio` datetime NOT NULL,
  `fechafin` datetime DEFAULT NULL,
  `estadocontrato` varchar(20) NOT NULL,
  `calificacionMedia` float NOT NULL,
  KEY `IdRepartidor` (`IdRepartidor`),
  KEY `IdTienda` (`IdTienda`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblhistorialrepartidor`
--

INSERT INTO `tblhistorialrepartidor` (`IdRepartidor`, `IdTienda`, `fechainicio`, `fechafin`, `estadocontrato`, `calificacionMedia`) VALUES
(1, 1, '2021-04-30 00:00:00', '0000-00-00 00:00:00', 'ACTIVO', 4.5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblhorarioaten`
--

DROP TABLE IF EXISTS `tblhorarioaten`;
CREATE TABLE IF NOT EXISTS `tblhorarioaten` (
  `IdHoraAten` int(11) NOT NULL AUTO_INCREMENT,
  `dia` varchar(10) DEFAULT NULL,
  `horaabre` time DEFAULT NULL,
  `horacierra` time DEFAULT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `IdTienda` int(11) NOT NULL,
  PRIMARY KEY (`IdHoraAten`),
  KEY `IdTienda` (`IdTienda`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblhorarioaten`
--

INSERT INTO `tblhorarioaten` (`IdHoraAten`, `dia`, `horaabre`, `horacierra`, `descripcion`, `IdTienda`) VALUES
(1, 'LUNES', '08:00:00', '20:00:00', 'Abierto los lunes', 1),
(2, 'MARTES', '08:00:00', '20:00:00', '', 1),
(3, 'MIERCOLES', '08:00:00', '20:00:00', '', 1),
(4, 'JUEVES', '08:00:00', '20:00:00', '', 1),
(5, 'VIERNES', '08:00:00', '20:00:00', '', 1),
(6, 'SABADO', '10:00:00', '14:00:00', '', 1),
(7, 'DOMINGO', '10:00:00', '14:00:00', '', 1),
(8, 'LUNES', '08:00:00', '20:00:00', '', 2),
(9, 'MARTES', '08:00:00', '20:00:00', '', 2),
(10, 'MIERCOLES', '08:00:00', '20:00:00', '', 2),
(11, 'JUEVES', '08:00:00', '20:00:00', '', 2),
(12, 'VIERNES', '08:00:00', '20:00:00', '', 2),
(13, 'SABADO', '10:00:00', '14:00:00', '', 2),
(14, 'DOMINGO', '10:00:00', '14:00:00', '', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblmembresias`
--

DROP TABLE IF EXISTS `tblmembresias`;
CREATE TABLE IF NOT EXISTS `tblmembresias` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Nivel` int(11) NOT NULL,
  `idUsuario` varchar(12) CHARACTER SET utf8mb4 NOT NULL,
  `fechaRegistro` date NOT NULL,
  `estado` varchar(50) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `Nivel` (`Nivel`),
  KEY `idUsuario` (`idUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tblmembresias`
--

INSERT INTO `tblmembresias` (`ID`, `Nivel`, `idUsuario`, `fechaRegistro`, `estado`) VALUES
(6, 2, 'hh', '2021-10-20', 'ACTIVO'),
(8, 1, 'abc', '2021-11-19', 'ACTIVO'),
(9, 2, 'gg', '2021-11-03', 'ACTIVO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblmensaje`
--

DROP TABLE IF EXISTS `tblmensaje`;
CREATE TABLE IF NOT EXISTS `tblmensaje` (
  `IdMensaje` int(11) NOT NULL AUTO_INCREMENT,
  `mensaje` varchar(100) NOT NULL,
  `estado` varchar(20) NOT NULL,
  `fechaenvio` datetime NOT NULL,
  `imagen_c` varchar(255) DEFAULT NULL,
  `IdUsuario` varchar(12) NOT NULL,
  `IdChat` int(11) NOT NULL,
  PRIMARY KEY (`IdMensaje`),
  KEY `IdUsuario` (`IdUsuario`),
  KEY `IdChat` (`IdChat`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblmensaje`
--

INSERT INTO `tblmensaje` (`IdMensaje`, `mensaje`, `estado`, `fechaenvio`, `imagen_c`, `IdUsuario`, `IdChat`) VALUES
(1, 'Hola!', 'enviado', '0000-00-00 00:00:00', '', 'kevinpapi', 1),
(2, 'Xd', 'recibido', '0000-00-00 00:00:00', '', 'kevinpapi', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblmetodopago`
--

DROP TABLE IF EXISTS `tblmetodopago`;
CREATE TABLE IF NOT EXISTS `tblmetodopago` (
  `IdMetodoPago` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) DEFAULT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`IdMetodoPago`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblmetodopago`
--

INSERT INTO `tblmetodopago` (`IdMetodoPago`, `nombre`, `descripcion`) VALUES
(1, 'EFECTIVO', 'Cuanado el pago del pedido es en efectivo'),
(2, 'TARJETA', 'Cuanado el pago del pedido es con tarjeta');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblnivel`
--

DROP TABLE IF EXISTS `tblnivel`;
CREATE TABLE IF NOT EXISTS `tblnivel` (
  `IdNivel` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(10) NOT NULL,
  PRIMARY KEY (`IdNivel`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblnivel`
--

INSERT INTO `tblnivel` (`IdNivel`, `nombre`) VALUES
(1, 'PREMIUM'),
(2, 'CLASICO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblnotificaciones`
--

DROP TABLE IF EXISTS `tblnotificaciones`;
CREATE TABLE IF NOT EXISTS `tblnotificaciones` (
  `IdNotificacion` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(200) NOT NULL,
  `fechacreacion` date NOT NULL,
  `horacreacion` time NOT NULL,
  `IdReceptor` varchar(12) NOT NULL,
  `IdEmisor` varchar(12) NOT NULL,
  PRIMARY KEY (`IdNotificacion`),
  KEY `IdReceptor` (`IdReceptor`),
  KEY `IdEmisor` (`IdEmisor`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblnotificaciones`
--

INSERT INTO `tblnotificaciones` (`IdNotificacion`, `descripcion`, `fechacreacion`, `horacreacion`, `IdReceptor`, `IdEmisor`) VALUES
(1, 'Reporte realizado', '2021-03-30', '18:02:00', 'kevinpapi', 'dougamer'),
(2, 'Solicitud de ingreso', '2021-03-30', '18:10:00', 'kevinpapi', 'tucovidvivo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblpedido`
--

DROP TABLE IF EXISTS `tblpedido`;
CREATE TABLE IF NOT EXISTS `tblpedido` (
  `IdPedido` int(11) NOT NULL AUTO_INCREMENT,
  `importetotalMX` float NOT NULL,
  `pagoconMX` float NOT NULL,
  `cambioMX` float NOT NULL,
  `calificTienda` float DEFAULT NULL,
  `calificRepartidor` float DEFAULT NULL,
  `hora` time NOT NULL,
  `fecha` date NOT NULL,
  `comentario` varchar(100) DEFAULT NULL,
  `IdCliente` int(11) NOT NULL,
  `IdTienda` int(11) NOT NULL,
  `IdRepartidor` int(11) NOT NULL,
  `IdEstadoPedido` int(11) NOT NULL,
  `IdMetodoPago` int(11) NOT NULL,
  `IdUbicacionE` int(11) NOT NULL,
  PRIMARY KEY (`IdPedido`),
  KEY `IdCliente` (`IdCliente`),
  KEY `IdTienda` (`IdTienda`),
  KEY `IdRepartidor` (`IdRepartidor`),
  KEY `IdEstadoPedido` (`IdEstadoPedido`),
  KEY `IdMetodoPago` (`IdMetodoPago`),
  KEY `IdUbicacionE` (`IdUbicacionE`),
  KEY `IdUbicacionE_2` (`IdUbicacionE`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblpedido`
--

INSERT INTO `tblpedido` (`IdPedido`, `importetotalMX`, `pagoconMX`, `cambioMX`, `calificTienda`, `calificRepartidor`, `hora`, `fecha`, `comentario`, `IdCliente`, `IdTienda`, `IdRepartidor`, `IdEstadoPedido`, `IdMetodoPago`, `IdUbicacionE`) VALUES
(1, 0, 0, 0, 0, 0, '13:20:00', '2021-04-11', '', 1, 1, 1, 5, 1, 1),
(2, 0, 0, 0, 0, 0, '13:20:00', '2021-04-11', '', 2, 2, 1, 2, 1, 2),
(3, 50.99, 60, 9.01, NULL, NULL, '17:22:00', '2021-05-05', 'ninguno', 1, 1, 1, 5, 1, 6),
(5, 56.99, 30, 20.01, NULL, NULL, '12:00:00', '2021-05-12', 'NN', 4, 2, 1, 2, 2, 4),
(6, 45.99, 25, 22.1, NULL, NULL, '16:00:00', '2021-03-18', 'NN', 5, 1, 1, 2, 2, 5),
(7, 4000, 0, 0, 0, 0, '14:35:00', '2021-06-16', 'Rapido plz', 2, 1, 15, 5, 1, 10),
(8, 6000, 0, 0, 0, 0, '15:35:00', '2021-06-16', 'Gaaaa', 2, 1, 15, 5, 1, 11),
(9, 2000, 0, 0, 0, 0, '15:35:00', '2021-06-16', 'Gaaaa', 2, 1, 15, 5, 1, 12),
(10, 250.2, 0, 0, 0, 0, '18:34:00', '2021-06-16', 'nada', 2, 1, 15, 2, 1, 13),
(11, 149, 0, 0, 0, 0, '18:52:03', '2021-06-16', '', 2, 1, 15, 5, 1, 14),
(12, 298, 0, 0, 0, 0, '18:53:25', '2021-06-16', 'gsa', 2, 1, 15, 5, 1, 15),
(15, 80.3, 0, 0, 0, 0, '19:39:41', '2021-06-16', 'mua', 2, 1, 15, 5, 1, 18),
(16, 100, 0, 0, 0, 0, '19:48:51', '2021-06-16', 'hajajaj', 2, 1, 15, 4, 1, 19),
(17, 100, 0, 0, 0, 0, '19:49:21', '2021-06-16', '', 2, 1, 15, 5, 1, 20),
(18, 261.5, 0, 0, 0, 0, '19:50:35', '2021-06-16', 'kskf', 2, 1, 15, 5, 1, 21),
(19, 5.5, 0, 0, 0, 0, '19:53:19', '2021-06-16', 'plin', 2, 1, 15, 4, 1, 22),
(20, 100, 0, 0, 0, 0, '20:07:30', '2021-06-16', '', 2, 1, 15, 1, 1, 23),
(21, 5.5, 0, 0, 0, 0, '20:10:26', '2021-06-16', '', 2, 1, 15, 1, 1, 24),
(22, 107, 0, 0, 0, 0, '20:12:01', '2021-06-16', '', 2, 1, 15, 1, 1, 25),
(23, 298, 0, 0, 0, 0, '20:23:37', '2021-06-16', 'A', 2, 1, 15, 1, 1, 26),
(24, 30.5, 0, 0, 0, 0, '20:29:32', '2021-06-16', 'jsjsu', 2, 10, 15, 1, 1, 27),
(25, 149, 0, 0, 0, 0, '20:44:09', '2021-06-16', 'mi', 2, 1, 15, 1, 1, 28),
(26, 107, 0, 0, 0, 0, '20:46:10', '2021-06-16', '', 2, 1, 15, 1, 1, 29),
(27, 149, 0, 0, 0, 0, '20:55:43', '2021-06-16', 'n8', 2, 1, 15, 1, 1, 30),
(28, 37.4, 0, 0, 0, 0, '21:00:32', '2021-06-16', '', 2, 10, 15, 1, 1, 31),
(29, 74.8, 0, 0, 0, 0, '21:00:42', '2021-06-16', '', 2, 1, 15, 1, 1, 32),
(30, 249.6, 0, 0, 0, 0, '21:01:11', '2021-06-16', '', 2, 1, 15, 1, 1, 33),
(31, 46.1, 0, 0, 0, 0, '21:04:32', '2021-06-16', 'nada', 2, 1, 15, 1, 1, 34),
(32, 73.4, 0, 0, 0, 0, '21:06:59', '2021-06-16', '', 2, 1, 15, 1, 1, 35),
(33, 149, 0, 0, 0, 0, '21:23:48', '2021-06-16', 'aea', 2, 1, 15, 1, 1, 36),
(34, 229.3, 0, 0, 0, 0, '21:24:31', '2021-06-16', '', 2, 1, 15, 1, 1, 37),
(35, 90, 0, 0, 0, 0, '21:27:24', '2021-06-16', 'rapido pliz', 2, 2, 15, 1, 1, 38),
(36, 284, 0, 0, 0, 0, '21:33:11', '2021-06-16', 'A ver', 2, 1, 15, 3, 1, 39),
(37, 149, 0, 0, 0, 0, '12:59:48', '2021-06-17', 'nico', 2, 1, 15, 4, 1, 40),
(38, 149, 0, 0, 0, 0, '12:59:48', '2021-06-17', 'nico', 2, 1, 15, 2, 1, 41),
(39, 149, 0, 0, 0, 0, '13:17:25', '2021-06-17', 'Plin', 2, 1, 15, 3, 1, 42),
(40, 37.4, 0, 0, 0, 0, '13:18:30', '2021-06-17', 'axaxa', 2, 1, 15, 3, 1, 43),
(41, 149, 0, 0, 0, 0, '13:21:13', '2021-06-17', 'ha', 2, 1, 15, 2, 1, 44),
(42, 105.5, 0, 0, 0, 0, '13:23:58', '2021-06-17', '', 2, 1, 15, 5, 1, 45),
(43, 71.1, 0, 0, 0, 0, '13:45:41', '2021-06-17', 'nada', 35, 1, 15, 5, 1, 46),
(44, 74.8, 0, 0, 0, 0, '13:48:50', '2021-06-17', '', 2, 1, 15, 5, 1, 47),
(45, 15.5, 0, 0, 0, 0, '15:18:59', '2021-06-17', 'que sea rapido', 2, 1, 15, 2, 1, 48),
(46, 173.4, 0, 0, 0, 0, '14:12:14', '2021-06-23', 'desearia que usen los protocolos de sanidad', 2, 1, 15, 3, 1, 49),
(47, 298, 0, 0, 0, 0, '13:43:58', '2021-08-02', '18118', 2, 1, 15, 1, 1, 50),
(48, 16, 15, 13, 12, 10, '00:00:01', '2021-02-01', ' ', 1, 1, 1, 5, 1, 51),
(49, 16, 15, 13, 12, 10, '00:00:01', '2021-02-02', ' ', 1, 1, 1, 5, 1, 52),
(50, 16, 15, 13, 12, 10, '00:00:01', '2021-02-03', ' ', 1, 1, 1, 5, 1, 53),
(51, 16, 15, 13, 12, 10, '00:00:01', '2021-02-04', ' ', 1, 1, 1, 5, 1, 54),
(52, 16, 15, 13, 12, 10, '00:00:01', '2021-02-05', ' ', 1, 1, 1, 5, 1, 55),
(53, 16, 15, 13, 12, 10, '00:00:01', '2021-02-06', ' ', 1, 1, 1, 5, 1, 56),
(54, 16, 15, 13, 12, 10, '00:00:01', '2021-02-07', ' ', 1, 1, 1, 5, 1, 57),
(55, 16, 15, 13, 12, 10, '00:00:01', '2021-02-08', ' ', 1, 1, 1, 5, 1, 58),
(56, 16, 15, 13, 12, 10, '00:00:01', '2021-02-09', ' ', 1, 1, 1, 5, 1, 59),
(57, 16, 15, 13, 12, 10, '00:00:01', '2021-02-10', ' ', 1, 1, 1, 5, 1, 60),
(58, 16, 15, 13, 12, 10, '00:00:01', '2021-02-11', ' ', 1, 1, 1, 5, 1, 61),
(59, 16, 15, 13, 12, 10, '00:00:01', '2021-02-12', ' ', 1, 1, 1, 5, 1, 62),
(60, 16, 15, 13, 12, 10, '00:00:01', '2021-02-13', ' ', 1, 1, 1, 5, 1, 63),
(61, 16, 15, 13, 12, 10, '00:00:01', '2021-02-14', ' ', 1, 1, 1, 5, 1, 64),
(62, 16, 15, 13, 12, 10, '00:00:01', '2021-02-15', ' ', 1, 1, 1, 5, 1, 65),
(63, 16, 15, 13, 12, 10, '00:00:01', '2021-02-16', ' ', 1, 1, 1, 5, 1, 66),
(64, 16, 15, 13, 12, 10, '00:00:01', '2021-02-17', ' ', 1, 1, 1, 5, 1, 67),
(65, 16, 15, 13, 12, 10, '00:00:01', '2021-02-18', ' ', 1, 1, 1, 5, 1, 68),
(66, 16, 15, 13, 12, 10, '00:00:01', '2021-02-19', ' ', 1, 1, 1, 5, 1, 69),
(67, 16, 15, 13, 12, 10, '00:00:01', '2021-02-20', ' ', 1, 1, 1, 5, 1, 70),
(68, 16, 15, 13, 12, 10, '00:00:01', '2021-02-21', ' ', 1, 1, 1, 5, 1, 71),
(69, 16, 15, 13, 12, 10, '00:00:01', '2021-02-22', ' ', 1, 1, 1, 5, 1, 72),
(70, 16, 15, 13, 12, 10, '00:00:01', '2021-02-23', ' ', 1, 1, 1, 5, 1, 73),
(71, 16, 15, 13, 12, 10, '00:00:02', '2021-02-24', ' ', 1, 1, 1, 5, 1, 74),
(72, 16, 15, 13, 12, 10, '00:00:02', '2021-02-25', ' ', 1, 1, 1, 5, 1, 75),
(73, 16, 15, 13, 12, 10, '00:00:02', '2021-02-26', ' ', 1, 1, 1, 5, 1, 76),
(74, 16, 15, 13, 12, 10, '00:00:02', '2021-02-27', ' ', 1, 1, 1, 5, 1, 77),
(75, 16, 15, 13, 12, 10, '00:00:02', '2021-02-28', ' ', 1, 1, 1, 5, 1, 78),
(76, 37.4, 1, 1, 1, 1, '10:33:31', '2021-10-13', '', 14, 1, 15, 1, 1, 80),
(77, 100, 1, 1, 1, 1, '10:47:38', '2021-10-13', '', 14, 1, 15, 1, 1, 81),
(78, 372.8, 1, 1, 1, 1, '10:52:32', '2021-10-13', '', 14, 1, 15, 1, 1, 82),
(79, 286.4, 1, 1, 1, 1, '10:56:59', '2021-10-13', '', 14, 1, 15, 1, 1, 83),
(80, 428.4, 1, 1, 1, 1, '11:02:19', '2021-10-13', '', 14, 1, 15, 1, 1, 84),
(81, 784, 1, 1, 1, 1, '12:32:41', '2021-10-13', '', 30, 1, 15, 1, 1, 85),
(82, 143, 1, 1, 1, 1, '12:45:14', '2021-10-13', '', 21, 1, 15, 1, 1, 86),
(83, 112.5, 1, 1, 1, 1, '13:03:56', '2021-10-13', '', 17, 1, 15, 1, 1, 87),
(84, 100, 1, 1, 1, 1, '11:49:57', '2021-10-19', '', 14, 1, 15, 1, 1, 88),
(85, 21, 1, 1, 1, 1, '14:37:52', '2021-10-19', '', 14, 2, 15, 1, 1, 89),
(86, 149, 1, 1, 1, 1, '14:50:27', '2021-10-19', '', 14, 1, 15, 1, 1, 90),
(87, 37.4, 1, 1, 1, 1, '15:11:10', '2021-10-19', '', 14, 1, 15, 5, 1, 91),
(88, 242, 1, 1, 1, 1, '21:44:25', '2021-10-28', '', 14, 1, 15, 1, 1, 92),
(89, 391, 1, 1, 1, 1, '21:51:00', '2021-10-28', '', 14, 1, 15, 1, 1, 93),
(90, 411, 1, 1, 1, 1, '22:05:40', '2021-10-28', '', 14, 2, 15, 1, 1, 94),
(91, 262, 1, 1, 1, 1, '22:06:29', '2021-10-28', '', 14, 1, 15, 1, 1, 95),
(92, 22, 1, 1, 1, 1, '22:43:40', '2021-10-28', '', 14, 2, 15, 1, 1, 96),
(93, 22, 1, 1, 1, 1, '21:53:05', '2021-11-04', '', 21, 2, 15, 1, 1, 97),
(94, 153.1, 1, 1, 1, 1, '17:20:01', '2021-11-17', '', 14, 1, 15, 1, 1, 98),
(95, 1143, 1, 1, 1, 1, '17:22:59', '2021-11-17', '', 14, 1, 15, 1, 1, 99),
(96, 78, 1, 1, 1, 1, '16:25:38', '2021-11-19', '', 14, 1, 15, 1, 1, 100);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblpersona`
--

DROP TABLE IF EXISTS `tblpersona`;
CREATE TABLE IF NOT EXISTS `tblpersona` (
  `IdPersona` int(11) NOT NULL AUTO_INCREMENT,
  `apPaterno` varchar(50) NOT NULL,
  `apMaterno` varchar(50) DEFAULT NULL,
  `nombres` varchar(100) NOT NULL,
  `nidentificacion` varchar(20) NOT NULL,
  `celular` varchar(20) NOT NULL,
  `sexo` varchar(20) NOT NULL,
  `email` varchar(200) DEFAULT NULL,
  `foto` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`IdPersona`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblpersona`
--

INSERT INTO `tblpersona` (`IdPersona`, `apPaterno`, `apMaterno`, `nombres`, `nidentificacion`, `celular`, `sexo`, `email`, `foto`) VALUES
(1, 'Duran', 'Forsait', 'Kevin', '45896621', '+51 999999999', 'masculino', 'kev@as.com', ''),
(2, 'Dante', 'Mikastro', 'Aligheri', '+52 85544751', '965447488', 'masculino', 'al@as.com', ''),
(3, 'Villegasñ', 'Remate', 'Plin', '9855862', '+51 985447411', 'masculino', 'bri@as.com', ''),
(4, 'Martinez', 'Jerez', 'Karinex', '1001875', '+53 75844141', 'femenino', 'kari@as.com', ''),
(5, 'Duran', 'Forsait', 'Kevin', '45896621', '+51 999999999', 'masculino', 'kev@as.com', ''),
(6, 'Dante', 'Mikastro', 'Aligheri', '+52 85544751', '965447488', 'masculino', 'al@as.com', ''),
(7, 'Briceño', 'Remate', 'Plin', '9855862', '+51 985447411', 'masculino', 'bri@as.com', ''),
(8, 'Martinez', 'Jerez', 'Karinex', '1001875101', '+53 75844141', 'femenino', 'kari@as.com', ''),
(9, 'Duran', 'Forsait', 'Kevin', '45896621', '+51 999999999', 'masculino', 'kev@as.com', ''),
(10, 'Dante', 'Mikastro', 'Aligheri', '+52 85544751', '965447488', 'masculino', 'al@as.com', ''),
(11, 'Briceño', 'Remate', 'Plin', '9855862', '+51 985447411', 'masculino', 'bri@as.com', ''),
(12, 'Martinez', 'Jerez', 'Karinex', '1001875100', '+53 75844141', 'femenino', 'kari@as.com', ''),
(13, 'FFF', 'GGG', 'zzz', '75855610', '956888475', '', 'a@fas', NULL),
(14, 'x', 'y', 'z', '123456', '945789871', '', '123@s', ''),
(15, 'x', 'y', 'z', '123456', '945789871', '', '123@s', ''),
(16, 'x', 'y', 'z', '123456', '945789871', '', '123@s', ''),
(17, 'a', 'a', 'a', '123', '945789000', '', '123@ass', ''),
(18, 'Martinez', '', 'Karina', '2456', '94572656', '', 'kari@ass', ''),
(19, 'Fernandes', 'Soto', 'Demian', '658548', '95886412', '', 'emian@ass', ''),
(21, '', '', '', '', '', '', '', ''),
(22, '', '', '', '', '', '', '', ''),
(23, 'fabian', 'Rodríguez ', 'Martínez ', '123', '55555', '', '@ajduejd', ''),
(24, 'a', 'a', 'a', 'a', 'a', '', '', ''),
(25, 'a', 'a', 'a', 'a', 'a', '', '', ''),
(26, 'll', 'll', 'll', 'll', 'll', '', '', ''),
(27, 'pp', 'pp', 'pp', 'pp', 'pp', '', '', ''),
(28, 'fara', 'fara', 'fara', '123', '945789000', '', '123@acc', ''),
(29, 'xxx', 'xxx', 'xxx', 'xxx', 'xxx', '', '', ''),
(30, 'bb', 'bb', 'bb', 'bb', 'bb', '', '', ''),
(31, 'bb', 'bb', 'bb', 'bb', 'bb', '', '', ''),
(32, 'ja', 'ja', 'ja', '1234', '27737', '', '@@', ''),
(33, 'ra', 'ra', 'rq', '11', '1', '', '@', ''),
(34, 'meneses', 'moralñe', 'over', '265468978', '12345678', 'masculino', 'javi@gmail.com', ''),
(35, 'ppp', 'ppp', 'ppp', 'ppp', 'ppp', '', '', ''),
(36, 'Castillo', '', 'Alfonso', '97879', '86587', '', '123@yt', ''),
(37, 'Castillo', '', 'Alfonso', '97879', '86587', '', '123@yt', ''),
(38, 'meneses', 'martinez', 'javith', '185478', '46489798', 'Masculino', 'wefewrwe', ''),
(39, 'burgos', 'martinez', 'leiner', '25641', '3215010966', 'Masculino', 'joidjowi', ''),
(40, 'quintero', 'diaz', 'keiner', '4646', '3561200159', 'Masculino', 'doejdopwe', ''),
(41, 'quintero', 'martinez', 'kevin', '1235874157', '1236548', 'Masculino', '', ''),
(42, 'quintero', 'martinez', 'keysi', '1254698', '32569874', 'Femenino', 'sa,lskalo', ''),
(43, 'kkkk', 'kkk', 'kkkk', '1568559898', '1285988768', 'Femenino', 'kkk', ''),
(44, 'Gutierrez ', '', 'Camilo', '93749', '9274859', '', '@123', ''),
(45, 'p', '', 'pablo', '34', '3t', '', '@123', ''),
(46, 'H', '', 'miguel', '577', '767', '', '12@12', ''),
(47, 'Guerrero', '', 'mora', '77294', '928384', '', '@hdhf', ''),
(48, 'ggg', 'ggg', 'ggg', 'ggg', 'ggg', '', '', ''),
(49, 'uuu', 'uuu', 'uuu', 'uuu', 'uuu', '', '', ''),
(50, 'Vilchez', 'Barzola', 'Luis', '12345678', '987654321', '', '', ''),
(51, 'Lisarga', 'Vayola', 'Karen', '11234231', '987654321', '', '', ''),
(52, 'Lopez', '', 'Guillermo', '873848599', '98764584', '', 'akddj@123', ''),
(53, 'Chacón ', 'moreno ', 'jorge', '64846494', '1234567890', 'Masculino', 'Jorge@hotmail.com', ''),
(54, 'cedeño', 'jerez', 'Juan', '1192766341', '3105010243', 'Masculino', 'jc815695@gmail.com', ''),
(55, 'Guiterrez', 'Miraval', 'Guillermo', '7364849', '0283840', '', 'guill@123.com', ''),
(56, 'Cardenas ', 'Contreras', 'Diego', '72849947', '9128749947', '', '123@ajdj', ''),
(57, 'ghj', 'asd', 'jgh', '132453647', '987654321', '', 'gvsernbebvaerb', ''),
(58, 'khnfafh', ' hi nkgvy', 'kekek', '555555555', '98765432', '', 'afgdjfkgjdh', ''),
(59, 'ooooooooo', 'oooooooo', 'ooooo', '626262626', '123454341', '', 'jejejejejgm@hmail.com', ''),
(60, 'default', 'default', 'default', 'default', 'default', 'default', 'default', ''),
(61, 'Piñas', '', 'Nigel', '717389289', '918399489', '', '@12e', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblproductosgenerales`
--

DROP TABLE IF EXISTS `tblproductosgenerales`;
CREATE TABLE IF NOT EXISTS `tblproductosgenerales` (
  `IdProductosGeneral` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(200) NOT NULL,
  `precioVentaMX` float NOT NULL,
  `img_min` varchar(255) DEFAULT NULL,
  `img_medium` varchar(255) DEFAULT NULL,
  `IdCategoria` int(11) NOT NULL,
  PRIMARY KEY (`IdProductosGeneral`),
  KEY `IdCategoria` (`IdCategoria`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblproductosgenerales`
--

INSERT INTO `tblproductosgenerales` (`IdProductosGeneral`, `descripcion`, `precioVentaMX`, `img_min`, `img_medium`, `IdCategoria`) VALUES
(1, 'Botella de vino (calidad media)', 149, '', '', 18),
(2, 'Ternera (1 kg) (cadera o similar)', 142, '', '', 18),
(3, 'Queso fresco (1 kg)', 107, '', '', 3),
(4, 'Manzanas (1 kg)', 40.6, '', '', 5),
(5, 'Cerveza importada (33 cl)', 37.4, '', '', 6),
(6, 'Pan (1 kg)', 30.5, '', '', 2),
(7, 'Huevos (1 kg)', 29.7, '', '', 2),
(8, 'Tomates (1 kg)', 23.9, '', '', 5),
(9, 'Patatas (1 kg)', 23.1, '', '', 18),
(10, 'Manzanas (1 kg)', 40.6, '', '', 5),
(11, 'Cebollas (1kg)', 22.6, '', '', 5),
(12, 'Cerveza nacional (0,5 litros)', 21, '', '', 2),
(13, 'Arroz (1 kg)', 20.4, '', '', 5),
(14, 'Naranjas (1 kg)', 19.9, '', '', 5),
(15, 'Panadol Forte 1 tab', 20, '', '', 7),
(16, 'Antigripal 1 tab', 22, '', '', 7),
(17, 'Raquitirina 50 gr', 21, '', '', 7),
(18, 'Coca Cola 120ml', 10.5, NULL, NULL, 6),
(19, 'Coca Cola 240ml', 10.5, NULL, NULL, 6),
(20, 'Huggies Supreme E1 38 piezas', 130, NULL, NULL, 17),
(21, 'Huggies Supreme E2 38 piezas', 144, NULL, NULL, 17),
(22, 'Huggies Supreme RN 38 piezas', 118, NULL, NULL, 17),
(23, 'Huggies Supreme E3 Niño 36 piezas', 153, NULL, NULL, 17),
(24, 'Huggies Supreme E3 Niña 36 piezas', 153, NULL, NULL, 17),
(25, 'Huggies Supreme E4 Niño 36 piezas', 179, NULL, NULL, 17),
(26, 'Huggies Supreme E4 Niña 36 piezas', 179, NULL, NULL, 17),
(27, 'Jabón Ricitos De Oro Milk 90 g', 15, NULL, NULL, 17),
(28, 'Babysons tubo de 30 g', 33, NULL, NULL, 17),
(29, 'Nivea Baby Toallitas Soft & Cream 63 piezas', 41, NULL, NULL, 17),
(30, 'Nan-Ha 1 Formula Lactea Polvo 800 g', 547, NULL, NULL, 17),
(31, 'Vick Baby Balsamo 12 g', 20, NULL, NULL, 17),
(32, 'Vaselina Baby Rosa 100 g', 14, NULL, NULL, 17),
(33, 'Vicky Baby Balm Tarro 50 g', 81, NULL, NULL, 17),
(34, 'Shampoo Pantene 500 mml', 500, NULL, NULL, 8),
(35, 'Tocino', 10, '', '', 1),
(36, 'Tocino', 10, '', '', 1),
(37, 'Leche Gloria 500 ml', 4.5, '', '', 3),
(38, 'Leche de soya 200ml', 5.5, '', '', 3),
(39, 'Leche de soya 200ml', 5.5, '', '', 3),
(40, 'Leche de soya 200ml', 5.5, '', '', 3),
(42, 'Lomo', 100, ' ', ' ', 1),
(43, 'Lomo', 100, ' ', ' ', 1),
(44, 'Filete pesacado', 10, '', '', 1),
(45, 'Filete pesacado', 10, '', '', 1),
(49, 'Salchicha', 10, ' ', ' ', 1),
(57, 'Cerdo', 10, ' ', ' ', 1),
(61, 'Res', 20, 'null', 'null', 1),
(62, 'milanesa', 3, 'null', 'null', 1),
(63, 'Pavo', 15, 'null', 'null', 1),
(64, 'Pescado parrillero', 15, 'null', 'null', 1),
(65, 'Jamonada', 5, 'null', 'null', 1),
(66, 'Jarabe tos', 120, NULL, NULL, 7),
(67, 'costillas de cordero', 109, 'null', 'null', 1),
(68, 'jarabe vick', 800, 'null', 'null', 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblpromociones`
--

DROP TABLE IF EXISTS `tblpromociones`;
CREATE TABLE IF NOT EXISTS `tblpromociones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Titulo` varchar(200) NOT NULL,
  `fecha` date NOT NULL,
  `fechafin` date DEFAULT NULL,
  `imagen` varchar(400) NOT NULL,
  `Estado` varchar(50) NOT NULL,
  `idTienda` int(11) NOT NULL,
  `idCategoria` int(11) NOT NULL,
  `idProducto` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `tblpromociones`
--

INSERT INTO `tblpromociones` (`id`, `Titulo`, `fecha`, `fechafin`, `imagen`, `Estado`, `idTienda`, `idCategoria`, `idProducto`) VALUES
(1, 'PROMOCION 2X1 EN HELADOS', '2021-10-28', '2021-12-30', 'http://192.168.1.125:2020/APIS/tienda/Uploads/promo01.jpg', 'ACTIVO', 1, 5, 6),
(2, 'Promo 40% de descuento en Yogurts', '2021-10-28', '2021-12-30', 'http://192.168.1.125:2020/APIS/tienda/Uploads/promo02.jpg', 'ACTIVO', 2, 5, 6),
(3, 'Llevate el Cuarto Cereal a solo $ 1.99', '2021-10-28', '2021-12-19', 'http://192.168.1.125:2020/APIS/tienda/Uploads/promo03.png', 'ACTIVO', 2, 5, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblpublicaciones`
--

DROP TABLE IF EXISTS `tblpublicaciones`;
CREATE TABLE IF NOT EXISTS `tblpublicaciones` (
  `IdPublicacion` int(11) NOT NULL AUTO_INCREMENT,
  `imagen` varchar(255) NOT NULL,
  `cantlikes` int(11) DEFAULT NULL,
  `catndislikes` int(11) DEFAULT NULL,
  `fechainicio` datetime NOT NULL,
  `fechafin` datetime NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `titulo` varchar(50) DEFAULT NULL,
  `IdTienda` int(11) NOT NULL,
  PRIMARY KEY (`IdPublicacion`),
  KEY `IdTienda` (`IdTienda`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblpublicaciones`
--

INSERT INTO `tblpublicaciones` (`IdPublicacion`, `imagen`, `cantlikes`, `catndislikes`, `fechainicio`, `fechafin`, `descripcion`, `titulo`, `IdTienda`) VALUES
(1, '', 2, 10, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Productos para ti', 'Promocion', 1),
(2, '', 22, 1, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Helados de todos lo sabores', 'Oferta!', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblrepartidor`
--

DROP TABLE IF EXISTS `tblrepartidor`;
CREATE TABLE IF NOT EXISTS `tblrepartidor` (
  `IdRepartidor` int(11) NOT NULL AUTO_INCREMENT,
  `estado` varchar(15) NOT NULL,
  `calificaciongeneral` float DEFAULT NULL,
  `IdVehiculo` int(11) NOT NULL,
  `IdPersona` int(11) NOT NULL,
  PRIMARY KEY (`IdRepartidor`),
  KEY `IdVehiculo` (`IdVehiculo`),
  KEY `IdPersona` (`IdPersona`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblrepartidor`
--

INSERT INTO `tblrepartidor` (`IdRepartidor`, `estado`, `calificaciongeneral`, `IdVehiculo`, `IdPersona`) VALUES
(1, 'DISPONIBLE', 4.1, 1, 4),
(2, 'OCUPADO', 5, 2, 9),
(3, 'OCUPADO', 3, 3, 10),
(4, 'DISPONIBLE', 0, 6, 18),
(5, 'DISPONIBLE', 0, 7, 19),
(6, 'DISPONIBLE', 0, 8, 34),
(7, 'DISPONIBLE', 0, 9, 38),
(8, 'DISPONIBLE', 0, 10, 39),
(9, 'DISPONIBLE', 0, 11, 40),
(10, 'DISPONIBLE', 0, 12, 41),
(11, 'DISPONIBLE', 0, 13, 42),
(12, 'DISPONIBLE', 0, 14, 43),
(13, 'DISPONIBLE', 0, 15, 53),
(14, 'DISPONIBLE', 0, 16, 54),
(15, 'OCUPADO', NULL, 1, 60);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblreporte`
--

DROP TABLE IF EXISTS `tblreporte`;
CREATE TABLE IF NOT EXISTS `tblreporte` (
  `IdReporte` int(11) NOT NULL AUTO_INCREMENT,
  `nombreReporte` varchar(100) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`IdReporte`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblreporte`
--

INSERT INTO `tblreporte` (`IdReporte`, `nombreReporte`, `descripcion`) VALUES
(1, 'Producto dañado', 'Cuando el producto esta abierto, dañado o vencido'),
(2, 'Producto equivocado', 'Cuando el producto no es el requerido');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblreportepedido`
--

DROP TABLE IF EXISTS `tblreportepedido`;
CREATE TABLE IF NOT EXISTS `tblreportepedido` (
  `IdReportePedido` int(11) NOT NULL AUTO_INCREMENT,
  `IdReporte` int(11) NOT NULL,
  `IdPedido` int(11) NOT NULL,
  `comentario` varchar(100) DEFAULT NULL,
  `imagen` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`IdReportePedido`),
  KEY `IdReporte` (`IdReporte`),
  KEY `IdPedido` (`IdPedido`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblreportepedido`
--

INSERT INTO `tblreportepedido` (`IdReportePedido`, `IdReporte`, `IdPedido`, `comentario`, `imagen`) VALUES
(1, 1, 1, 'El pedido presenta signos de ser abierto', ''),
(2, 2, 2, 'El pedido no es el solicitadi', '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblrubro`
--

DROP TABLE IF EXISTS `tblrubro`;
CREATE TABLE IF NOT EXISTS `tblrubro` (
  `IdRubro` int(11) NOT NULL AUTO_INCREMENT,
  `nombreRubro` varchar(200) NOT NULL,
  PRIMARY KEY (`IdRubro`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblrubro`
--

INSERT INTO `tblrubro` (`IdRubro`, `nombreRubro`) VALUES
(1, 'FERRETERIA'),
(2, 'FARMACIA'),
(3, 'BODEGA'),
(4, 'RESTAURANTE');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbltienda`
--

DROP TABLE IF EXISTS `tbltienda`;
CREATE TABLE IF NOT EXISTS `tbltienda` (
  `IdTienda` int(11) NOT NULL AUTO_INCREMENT,
  `RUC` varchar(20) NOT NULL,
  `nombre` varchar(200) NOT NULL,
  `longitudTienda` float(10,7) NOT NULL,
  `latitudTienda` float(10,7) NOT NULL,
  `estadoapertura` varchar(15) NOT NULL,
  `npublicacionresta` int(11) DEFAULT NULL,
  `IdRubro` int(11) NOT NULL,
  `IdPersona` int(11) NOT NULL,
  `calificacion` float DEFAULT NULL,
  `descripcionubicacion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`IdTienda`),
  KEY `IdRubro` (`IdRubro`),
  KEY `IdPersona` (`IdPersona`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbltienda`
--

INSERT INTO `tbltienda` (`IdTienda`, `RUC`, `nombre`, `longitudTienda`, `latitudTienda`, `estadoapertura`, `npublicacionresta`, `IdRubro`, `IdPersona`, `calificacion`, `descripcionubicacion`) VALUES
(1, '45658751204', 'Bodeguita de Don Pepe', -10.0206232, -12.0206232, 'ABIERTO', NULL, 3, 3, 4.2, 'Psj. 10 de Agosto 576, Chavin de Huantar'),
(2, '45658751204', 'Don Pepe', -10.0206232, -12.0206232, 'ABIERTO', 2, 2, 1, 4.5, 'Psj. Santa Beatriz, Centro Federal'),
(3, '152489', 'La colorada', 0.0000000, 0.0000000, 'ABIERTO', 2, 3, 28, 0, 'plin'),
(4, 'bb', 'bb', 0.0000000, 0.0000000, 'ABIERTO', 2, 3, 30, 0, ''),
(5, 'bb', 'bb', 0.0000000, 0.0000000, 'ABIERTO', 2, 3, 31, 0, ''),
(9, '98765432123456789', 'HELLO', 0.0000000, 0.0000000, 'ABIERTO', 2, 3, 50, 0, ''),
(10, '12345678987654', 'OKmexico', 0.0000000, 0.0000000, 'ABIERTO', 2, 3, 57, 0, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbltiendaproducto`
--

DROP TABLE IF EXISTS `tbltiendaproducto`;
CREATE TABLE IF NOT EXISTS `tbltiendaproducto` (
  `IdTiendaProducto` int(11) NOT NULL AUTO_INCREMENT,
  `precioVTiendaMX` float NOT NULL,
  `descuento` float DEFAULT NULL,
  `IdTienda` int(11) NOT NULL,
  `IdProductosGeneral` int(11) NOT NULL,
  PRIMARY KEY (`IdTiendaProducto`),
  KEY `IdProductosGeneral` (`IdProductosGeneral`),
  KEY `IdTienda` (`IdTienda`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbltiendaproducto`
--

INSERT INTO `tbltiendaproducto` (`IdTiendaProducto`, `precioVTiendaMX`, `descuento`, `IdTienda`, `IdProductosGeneral`) VALUES
(1, 149, 0, 1, 1),
(2, 142, 0.1, 1, 2),
(3, 107, 0, 1, 3),
(4, 40.6, 0, 1, 4),
(5, 37.4, 0, 1, 5),
(6, 30.5, 0, 1, 6),
(7, 20, 0.2, 2, 15),
(8, 22, 0, 2, 16),
(9, 21, 0, 2, 17),
(10, 23, 0, 2, 34),
(11, 5.5, 0.2, 1, 40),
(12, 100, 10, 1, 42),
(13, 100, 10, 1, 43),
(14, 10, 5, 1, 49),
(15, 10, 5, 1, 57),
(16, 20, 0, 1, 61),
(17, 3, 0, 1, 62),
(18, 15, 10, 1, 63),
(19, 15, 15, 1, 64),
(20, 5, 10, 1, 65),
(21, 120, 100, 2, 66),
(22, 120, 0, 2, 66),
(23, 109, 10, 2, 67),
(24, 800, 800, 1, 68);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tbltipousuario`
--

DROP TABLE IF EXISTS `tbltipousuario`;
CREATE TABLE IF NOT EXISTS `tbltipousuario` (
  `IdTUsuario` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(20) NOT NULL,
  PRIMARY KEY (`IdTUsuario`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tbltipousuario`
--

INSERT INTO `tbltipousuario` (`IdTUsuario`, `descripcion`) VALUES
(1, 'TENDERO'),
(2, 'CLIENTE'),
(3, 'REPARTIDOR');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblubicacion`
--

DROP TABLE IF EXISTS `tblubicacion`;
CREATE TABLE IF NOT EXISTS `tblubicacion` (
  `IdUbicacion` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(200) NOT NULL,
  `longitud` float(10,7) NOT NULL,
  `latitud` float(10,7) NOT NULL,
  `IdPersona` int(11) NOT NULL,
  PRIMARY KEY (`IdUbicacion`),
  KEY `IdPersona` (`IdPersona`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblubicacion`
--

INSERT INTO `tblubicacion` (`IdUbicacion`, `descripcion`, `longitud`, `latitud`, `IdPersona`) VALUES
(9, 'Santiago Huancayo', -12.0206232, -75.2334518, 1),
(10, 'Notaria Giraldez', -12.0741501, -75.2118073, 2),
(11, 'Jirón Puno 209, Huancayo', -12.0667953, -75.2083511, 3),
(12, 'Av. Daniel Alcides Carrion, Huancayo', -12.0747690, -75.2235718, 4),
(14, 'Av. xd', 25.2548409, 10.2223320, 13),
(15, 'Av. zzz', 12.2548418, 11.2223320, 8),
(16, 'cesar vallejo', 0.0000000, 0.0000000, 16),
(17, 'plin', 0.0000000, 0.0000000, 17),
(18, 'bogota', 0.0000000, 0.0000000, 18),
(19, '', 0.0000000, 0.0000000, 19),
(21, '', 0.0000000, 0.0000000, 21),
(22, '', 0.0000000, 0.0000000, 22),
(23, '', 0.0000000, 0.0000000, 23),
(24, '', 0.0000000, 0.0000000, 24),
(25, '', 0.0000000, 0.0000000, 25),
(26, '', 0.0000000, 0.0000000, 26),
(27, '', 0.0000000, 0.0000000, 27),
(28, 'plin', 0.0000000, 0.0000000, 28),
(29, '', 0.0000000, 0.0000000, 29),
(30, '', 0.0000000, 0.0000000, 30),
(31, '', 0.0000000, 0.0000000, 31),
(32, '', 0.0000000, 0.0000000, 32),
(33, '', 0.0000000, 0.0000000, 33),
(34, '', 0.0000000, 0.0000000, 34),
(35, '', 0.0000000, 0.0000000, 35),
(36, '', 0.0000000, 0.0000000, 36),
(37, '', 0.0000000, 0.0000000, 37),
(38, '', 0.0000000, 0.0000000, 38),
(39, '', 0.0000000, 0.0000000, 39),
(40, '', 0.0000000, 0.0000000, 40),
(41, '', 0.0000000, 0.0000000, 41),
(42, '', 0.0000000, 0.0000000, 42),
(43, '', 0.0000000, 0.0000000, 43),
(44, '', 0.0000000, 0.0000000, 44),
(45, '', 0.0000000, 0.0000000, 45),
(46, '', 0.0000000, 0.0000000, 46),
(47, '', 0.0000000, 0.0000000, 47),
(48, '', 0.0000000, 0.0000000, 48),
(49, '', 0.0000000, 0.0000000, 49),
(50, '', 0.0000000, 0.0000000, 50),
(51, '', 0.0000000, 0.0000000, 51),
(52, '', 0.0000000, 0.0000000, 52),
(53, '', 0.0000000, 0.0000000, 53),
(54, '', 0.0000000, 0.0000000, 54),
(55, '', 0.0000000, 0.0000000, 55),
(56, '', 0.0000000, 0.0000000, 56),
(57, '', 0.0000000, 0.0000000, 57),
(58, '', 0.0000000, 0.0000000, 58),
(59, '', 0.0000000, 0.0000000, 59),
(60, '', 0.0000000, 0.0000000, 60),
(61, '', 0.0000000, 0.0000000, 61);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblubicacionentrega`
--

DROP TABLE IF EXISTS `tblubicacionentrega`;
CREATE TABLE IF NOT EXISTS `tblubicacionentrega` (
  `IdUbicacionE` int(11) NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(200) DEFAULT NULL,
  `latitud` float(10,7) NOT NULL,
  `longitud` float(10,7) NOT NULL,
  `latitudTR` float(10,7) DEFAULT NULL,
  `longitudTR` float(10,7) DEFAULT NULL,
  PRIMARY KEY (`IdUbicacionE`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblubicacionentrega`
--

INSERT INTO `tblubicacionentrega` (`IdUbicacionE`, `descripcion`, `latitud`, `longitud`, `latitudTR`, `longitudTR`) VALUES
(1, 'LUGAR 1', 41.8964005, -87.6610031, 41.8964005, -87.6610031),
(2, 'LUGAR 2', 41.9244003, -87.7154007, 41.9244003, -87.7154007),
(3, 'LUGAR 3', 41.8945007, -87.6178970, 41.8945007, -87.6178970),
(4, 'LUGAR 4', 41.9029999, -87.6975021, 41.9029999, -87.6975021),
(5, 'JIRON CALLE REAL 120 - HUANCAYO', 41.8902016, -87.6261978, 41.8902016, -87.6261978),
(6, 'LUGAR 6', 41.8969002, -87.6216965, 41.8969002, -87.6216965),
(7, 'LUGAR 7', 41.8922997, -87.6119995, 41.8922997, -87.6119995),
(8, 'LUGAR 8', 41.8665009, -87.6847000, 41.8665009, -87.6847000),
(9, 'LUGAR 9', 41.8949013, -87.6323013, 41.8949013, -87.6323013),
(10, 'LUGAR 10', 41.8846016, -87.7062988, 41.8846016, -87.7062988),
(11, 'LUGAR 11', 41.9096985, -87.7165985, 41.9096985, -87.7165985),
(12, 'LUGAR 12', 41.8983994, -87.6865997, 41.8983994, -87.6865997),
(13, 'LUGAR 13', 41.8983994, -87.6865997, 41.8983994, -87.6865997),
(14, 'LUGAR 14', 41.8983994, -87.6865997, 41.8983994, -87.6865997),
(15, 'LUGAR 15', 41.8708000, -87.6257019, 41.8708000, -87.6257019),
(16, 'LUGAR 16', 41.8708000, -87.6257019, 41.8708000, -87.6257019),
(17, 'LUGAR 17', 41.8708000, -87.6257019, 41.8708000, -87.6257019),
(18, 'LUGAR 18', 41.8288002, -87.6806030, 41.8288002, -87.6806030),
(19, 'LUGAR 19', 41.9156990, -87.6345978, 41.9156990, -87.6345978),
(20, 'LUGAR 20', 41.8748016, -87.6498032, 41.8748016, -87.6498032),
(21, 'LUGAR 21', 41.7916985, -87.5839005, 41.7916985, -87.5839005),
(22, 'LUGAR 22', 41.9506989, -87.6687012, 41.9506989, -87.6687012),
(23, 'LUGAR 23', 41.8819008, -87.6488037, 41.8819008, -87.6488037),
(24, 'LUGAR 24', 41.9691010, -87.6742020, 41.9691010, -87.6742020),
(25, 'LUGAR 25', 41.9482002, -87.6639023, 41.9482002, -87.6639023),
(26, 'LUGAR 26', 41.9482002, -87.6639023, 41.9482002, -87.6639023),
(27, 'LUGAR 27', 41.9482002, -87.6639023, 41.9482002, -87.6639023),
(28, 'LUGAR 28', 42.0569992, -87.6865997, 42.0569992, -87.6865997),
(29, 'LUGAR 29', 41.9258995, -87.6492996, 41.9258995, -87.6492996),
(30, 'LUGAR 30', 41.8804016, -87.6555023, 41.8804016, -87.6555023),
(31, 'LUGAR 31', 41.8821983, -87.6410980, 41.8821983, -87.6410980),
(32, 'LUGAR 32', 41.8828011, -87.6612015, 41.8828011, -87.6612015),
(33, 'LUGAR 33', 41.8804016, -87.6555023, 41.8804016, -87.6555023),
(34, 'LUGAR 34', 41.8804016, -87.6555023, 41.8804016, -87.6555023),
(35, 'LUGAR 35', 41.9325981, -87.6363983, 41.9325981, -87.6363983),
(36, 'LUGAR 36', 41.8956985, -87.6201019, 41.8956985, -87.6201019),
(37, 'LUGAR 37', 41.8955002, -87.6819992, 41.8955002, -87.6819992),
(38, 'LUGAR 38', 41.8712997, -87.6736984, 41.8712997, -87.6736984),
(39, 'LUGAR 39', 41.8958015, -87.6259003, 41.8958015, -87.6259003),
(40, 'LUGAR 40', 41.8841019, -87.6568985, 41.8841019, -87.6568985),
(41, 'JIRON CALLE NUEVA 120 - EL TAMBO', 41.9255981, -87.6537018, 41.9255981, -87.6537018),
(42, 'LUGAR 42', 41.8857994, -87.6354980, 41.8857994, -87.6354980),
(43, 'LUGAR 43', 41.8420982, -87.6169968, 41.8420982, -87.6169968),
(44, 'JIRON LOS MANZANOS 110 - CHILCA', 41.8306999, -87.6472015, 41.8306999, -87.6472015),
(45, 'LUGAR 45', 41.8703003, -87.6395035, 41.8703003, -87.6395035),
(46, 'LUGAR 46', 41.8306999, -87.6559982, 41.8306999, -87.6559982),
(47, 'LUGAR 47', 41.8306999, -87.6472015, 41.8306999, -87.6472015),
(48, 'AVENIDA CALLE VIEJA 200 - EL TAMBO', 41.8671989, -87.6259995, 41.8671989, -87.6259995),
(49, 'LUGAR 49', 41.9366989, -87.6368027, 41.9366989, -87.6368027),
(50, 'LUGAR 50', 41.9366989, -87.6368027, 41.9366989, -87.6368027),
(51, 'LUGAR 51', 41.9323997, -87.6527023, 41.9323997, -87.6527023),
(52, 'LUGAR 52', 41.9508018, -87.6592026, 41.9508018, -87.6592026),
(53, 'LUGAR 53', 41.9258995, -87.6389999, 41.9258995, -87.6389999),
(54, 'LUGAR 54', 41.9295006, -87.6430969, 41.9295006, -87.6430969),
(55, 'LUGAR 55', 41.8903999, -87.6175003, 41.8903999, -87.6175003),
(56, 'LUGAR 56', 41.9543991, -87.6480026, 41.9543991, -87.6480026),
(57, 'LUGAR 57', 41.9068985, -87.6261978, 41.9068985, -87.6261978),
(58, 'LUGAR 58', 41.8940010, -87.6293030, 41.8940010, -87.6293030),
(59, 'LUGAR 59', 41.8855019, -87.6522980, 41.8855019, -87.6522980),
(60, 'LUGAR 60', 41.8708000, -87.6257019, 41.8708000, -87.6257019),
(61, 'LUGAR 61', 41.9902000, -87.6933975, 41.9902000, -87.6933975),
(62, 'LUGAR 62', 41.9105988, -87.6493988, 41.9105988, -87.6493988),
(63, 'LUGAR 63', 41.9617004, -87.6546021, 41.9617004, -87.6546021),
(64, 'LUGAR 64', 41.9579010, -87.6494980, 41.9579010, -87.6494980),
(65, 'LUGAR 65', 41.9183006, -87.6362991, 41.9183006, -87.6362991),
(66, 'LUGAR 66', 41.8916016, -87.6483994, 41.8916016, -87.6483994),
(67, 'LUGAR 67', 41.8945999, -87.6533966, 41.8945999, -87.6533966),
(68, 'LUGAR 68', 41.8945999, -87.6533966, 41.8945999, -87.6533966),
(69, 'LUGAR 69', 41.8604012, -87.6258011, 41.8604012, -87.6258011),
(70, 'LUGAR 70', 41.9691010, -87.6742020, 41.9691010, -87.6742020),
(71, 'LUGAR 71', 41.9436989, -87.6490021, 41.9436989, -87.6490021),
(72, 'LUGAR 72', 41.9579010, -87.6494980, 41.9579010, -87.6494980),
(73, 'LUGAR 73', 41.8839989, -87.6247025, 41.8839989, -87.6247025),
(74, 'LUGAR 74', 41.9029999, -87.6313019, 41.9029999, -87.6313019),
(75, 'LUGAR 75', 41.8722000, -87.6614990, 41.8722000, -87.6614990),
(76, 'LUGAR 76', 41.9690018, -87.6959991, 41.9690018, -87.6959991),
(77, 'LUGAR 77', 41.9068985, -87.6261978, 41.9068985, -87.6261978),
(78, 'LUGAR 78', 41.7916985, -87.5839005, 41.7916985, -87.5839005),
(79, 'LUGAR 79', 41.9183998, -87.6521988, 41.9183998, -87.6521988),
(80, 'LUGAR 80', 41.9253006, -87.6658020, 41.9253006, -87.6658020),
(81, 'LUGAR 81', 41.8576012, -87.6614990, 41.8576012, -87.6614990),
(82, 'LUGAR 82', 41.8958015, -87.6259003, 41.8958015, -87.6259003),
(83, 'LUGAR 83', 41.9029999, -87.6313019, 41.9029999, -87.6313019),
(84, 'LUGAR 84', 41.7952003, -87.5807037, 41.7952003, -87.5807037),
(85, 'LUGAR 85', 41.9323997, -87.6527023, 41.9323997, -87.6527023),
(86, 'LUGAR 86', 41.8816986, -87.6395035, 41.8816986, -87.6395035),
(87, 'LUGAR 87', 41.8759003, -87.6306000, 41.8759003, -87.6306000),
(88, 'jjdjdndn dndkkd', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(89, 'jdjsjdjd', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(90, 'jiron nueva calle', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(91, 'jdkd dkdkd dkfkf fk', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(92, 'ksksnbs', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(93, 'kzldndn', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(94, 'kdkdnf', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(95, 'kzksnd', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(96, 'ydjdhh', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(97, 'nsnsbbd', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(98, 'kskks dkdkd dkdkd dkd ', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(99, 'jdjdud fjjfif fjf', 1.0000000, 1.0000000, 1.0000000, 1.0000000),
(100, 'jiron nueva calle 150', 1.0000000, 1.0000000, 1.0000000, 1.0000000);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblusuario`
--

DROP TABLE IF EXISTS `tblusuario`;
CREATE TABLE IF NOT EXISTS `tblusuario` (
  `IdUsuario` varchar(12) NOT NULL,
  `contraseña` varchar(10) NOT NULL,
  `IdNivel` int(11) NOT NULL,
  `IdTUsuario` int(11) NOT NULL,
  `IdPersona` int(11) NOT NULL,
  PRIMARY KEY (`IdUsuario`),
  KEY `IdNivel` (`IdNivel`),
  KEY `IdTUsuario` (`IdTUsuario`),
  KEY `IdPersona` (`IdPersona`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblusuario`
--

INSERT INTO `tblusuario` (`IdUsuario`, `contraseña`, `IdNivel`, `IdTUsuario`, `IdPersona`) VALUES
('1234', '1234', 2, 1, 57),
('abc', '123', 2, 2, 23),
('aligue', '123456', 2, 2, 2),
('antony', 'macaco', 2, 1, 13),
('asa', 'fff', 1, 3, 13),
('axaxa', 'axaxa', 2, 2, 17),
('bb', 'bb', 2, 1, 30),
('diego', 'diego', 2, 2, 56),
('dougamer', '1234', 1, 1, 3),
('duran', '12345', 2, 1, 1),
('emian', '123', 2, 3, 19),
('ga', 'ga', 2, 1, 28),
('gg', 'gg', 2, 2, 33),
('guillermo', 'guillermo', 2, 2, 52),
('hello', '123456789', 2, 2, 24),
('hh', 'hh', 2, 2, 26),
('hu', 'hu', 2, 2, 47),
('javi97', '4498495', 2, 3, 34),
('javith88', '66', 2, 3, 38),
('jorge22', '123456', 2, 3, 53),
('juan', 'juandaniel', 2, 3, 54),
('kamilo', 'kamilo', 2, 2, 46),
('karina', '123', 2, 3, 18),
('keiner14', '', 2, 3, 40),
('kevinpapi', 'escorpio', 2, 2, 1),
('keysi89', '', 2, 3, 42),
('kkk', '', 2, 3, 43),
('leiner15', '', 2, 3, 39),
('luis123', 'luis123', 2, 1, 50),
('mi', 'mi', 2, 2, 32),
('miau', 'miau', 2, 2, 36),
('mu', 'mu', 2, 2, 16),
('nigel', 'nigel', 2, 2, 60),
('pepe', 'pepe', 2, 1, 51),
('pp', 'pp', 2, 2, 27),
('qwerty', '12345', 2, 2, 55),
('tucovidvivo', '12345', 2, 3, 4),
('xxx', 'xxx', 2, 2, 29);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tblvehiculo`
--

DROP TABLE IF EXISTS `tblvehiculo`;
CREATE TABLE IF NOT EXISTS `tblvehiculo` (
  `IdVehiculo` int(11) NOT NULL AUTO_INCREMENT,
  `nombreVehiculo` varchar(50) NOT NULL,
  `placa` varchar(10) NOT NULL,
  PRIMARY KEY (`IdVehiculo`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tblvehiculo`
--

INSERT INTO `tblvehiculo` (`IdVehiculo`, `nombreVehiculo`, `placa`) VALUES
(1, 'MOTOCICLETA', 'XYZ-120'),
(2, 'BICICLETA', 'XYY-12A'),
(3, 'AUTO', 'XXZ-100'),
(4, 'SIN VEHICULO', '0'),
(5, 'AUTO', 'XXA-025'),
(6, 'SIN VEHICULO', ''),
(7, 'MOTOCICLETA', 'FFF-FFF'),
(8, '2', '1'),
(9, 'Motocicleta', 'wewqeeqw'),
(10, 'Carro', '25545'),
(11, 'Carro', 'ufgriueyfi'),
(12, 'carro', ''),
(13, 'motocicleta', 'dsadas'),
(14, 'carro', 'yjyhtg'),
(15, 'carro', 'gaajakka'),
(16, 'carro', 'PLC45Q');

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `tblanuncios`
--
ALTER TABLE `tblanuncios`
  ADD CONSTRAINT `tblanuncios_ibfk_1` FOREIGN KEY (`categoria`) REFERENCES `tblcategoria` (`IdCategoria`),
  ADD CONSTRAINT `tblanuncios_ibfk_2` FOREIGN KEY (`IdUsuario`) REFERENCES `tblusuario` (`IdUsuario`);

--
-- Filtros para la tabla `tblcategoria`
--
ALTER TABLE `tblcategoria`
  ADD CONSTRAINT `tblcategoria_ibfk_1` FOREIGN KEY (`IdRubro`) REFERENCES `tblrubro` (`IdRubro`);

--
-- Filtros para la tabla `tblchat`
--
ALTER TABLE `tblchat`
  ADD CONSTRAINT `tblchat_ibfk_1` FOREIGN KEY (`IdReceptorC`) REFERENCES `tblusuario` (`IdUsuario`),
  ADD CONSTRAINT `tblchat_ibfk_2` FOREIGN KEY (`IdEmisorC`) REFERENCES `tblusuario` (`IdUsuario`);

--
-- Filtros para la tabla `tblcliente`
--
ALTER TABLE `tblcliente`
  ADD CONSTRAINT `tblcliente_ibfk_1` FOREIGN KEY (`IdPersona`) REFERENCES `tblpersona` (`IdPersona`);

--
-- Filtros para la tabla `tbldetallepedido`
--
ALTER TABLE `tbldetallepedido`
  ADD CONSTRAINT `tbldetallepedido_ibfk_1` FOREIGN KEY (`IdTiendaProducto`) REFERENCES `tbltiendaproducto` (`IdTiendaProducto`),
  ADD CONSTRAINT `tbldetallepedido_ibfk_2` FOREIGN KEY (`IdPedido`) REFERENCES `tblpedido` (`IdPedido`);

--
-- Filtros para la tabla `tblhistorialrepartidor`
--
ALTER TABLE `tblhistorialrepartidor`
  ADD CONSTRAINT `tblhistorialrepartidor_ibfk_1` FOREIGN KEY (`IdRepartidor`) REFERENCES `tblrepartidor` (`IdRepartidor`),
  ADD CONSTRAINT `tblhistorialrepartidor_ibfk_2` FOREIGN KEY (`IdTienda`) REFERENCES `tbltienda` (`IdTienda`);

--
-- Filtros para la tabla `tblhorarioaten`
--
ALTER TABLE `tblhorarioaten`
  ADD CONSTRAINT `tblhorarioaten_ibfk_1` FOREIGN KEY (`IdTienda`) REFERENCES `tbltienda` (`IdTienda`);

--
-- Filtros para la tabla `tblmembresias`
--
ALTER TABLE `tblmembresias`
  ADD CONSTRAINT `tblmembresias_ibfk_1` FOREIGN KEY (`Nivel`) REFERENCES `tbldetallemembresia` (`ID`),
  ADD CONSTRAINT `tblmembresias_ibfk_2` FOREIGN KEY (`idUsuario`) REFERENCES `tblusuario` (`IdUsuario`);

--
-- Filtros para la tabla `tblmensaje`
--
ALTER TABLE `tblmensaje`
  ADD CONSTRAINT `tblmensaje_ibfk_1` FOREIGN KEY (`IdUsuario`) REFERENCES `tblusuario` (`IdUsuario`),
  ADD CONSTRAINT `tblmensaje_ibfk_2` FOREIGN KEY (`IdChat`) REFERENCES `tblchat` (`IdChat`);

--
-- Filtros para la tabla `tblnotificaciones`
--
ALTER TABLE `tblnotificaciones`
  ADD CONSTRAINT `tblnotificaciones_ibfk_1` FOREIGN KEY (`IdReceptor`) REFERENCES `tblusuario` (`IdUsuario`),
  ADD CONSTRAINT `tblnotificaciones_ibfk_2` FOREIGN KEY (`IdEmisor`) REFERENCES `tblusuario` (`IdUsuario`);

--
-- Filtros para la tabla `tblpedido`
--
ALTER TABLE `tblpedido`
  ADD CONSTRAINT `tblpedido_ibfk_1` FOREIGN KEY (`IdCliente`) REFERENCES `tblcliente` (`IdCliente`),
  ADD CONSTRAINT `tblpedido_ibfk_2` FOREIGN KEY (`IdTienda`) REFERENCES `tbltienda` (`IdTienda`),
  ADD CONSTRAINT `tblpedido_ibfk_3` FOREIGN KEY (`IdRepartidor`) REFERENCES `tblrepartidor` (`IdRepartidor`),
  ADD CONSTRAINT `tblpedido_ibfk_4` FOREIGN KEY (`IdEstadoPedido`) REFERENCES `tblestadopedido` (`IdEstadoPedido`),
  ADD CONSTRAINT `tblpedido_ibfk_5` FOREIGN KEY (`IdMetodoPago`) REFERENCES `tblmetodopago` (`IdMetodoPago`),
  ADD CONSTRAINT `tblpedido_ibfk_6` FOREIGN KEY (`IdUbicacionE`) REFERENCES `tblubicacionentrega` (`IdUbicacionE`);

--
-- Filtros para la tabla `tblproductosgenerales`
--
ALTER TABLE `tblproductosgenerales`
  ADD CONSTRAINT `tblproductosgenerales_ibfk_1` FOREIGN KEY (`IdCategoria`) REFERENCES `tblcategoria` (`IdCategoria`);

--
-- Filtros para la tabla `tblpublicaciones`
--
ALTER TABLE `tblpublicaciones`
  ADD CONSTRAINT `tblpublicaciones_ibfk_1` FOREIGN KEY (`IdTienda`) REFERENCES `tbltienda` (`IdTienda`);

--
-- Filtros para la tabla `tblrepartidor`
--
ALTER TABLE `tblrepartidor`
  ADD CONSTRAINT `tblrepartidor_ibfk_1` FOREIGN KEY (`IdVehiculo`) REFERENCES `tblvehiculo` (`IdVehiculo`),
  ADD CONSTRAINT `tblrepartidor_ibfk_2` FOREIGN KEY (`IdPersona`) REFERENCES `tblpersona` (`IdPersona`);

--
-- Filtros para la tabla `tblreportepedido`
--
ALTER TABLE `tblreportepedido`
  ADD CONSTRAINT `tblreportepedido_ibfk_1` FOREIGN KEY (`IdReporte`) REFERENCES `tblreporte` (`IdReporte`),
  ADD CONSTRAINT `tblreportepedido_ibfk_2` FOREIGN KEY (`IdPedido`) REFERENCES `tblpedido` (`IdPedido`);

--
-- Filtros para la tabla `tbltienda`
--
ALTER TABLE `tbltienda`
  ADD CONSTRAINT `tbltienda_ibfk_1` FOREIGN KEY (`IdRubro`) REFERENCES `tblrubro` (`IdRubro`),
  ADD CONSTRAINT `tbltienda_ibfk_2` FOREIGN KEY (`IdPersona`) REFERENCES `tblpersona` (`IdPersona`);

--
-- Filtros para la tabla `tbltiendaproducto`
--
ALTER TABLE `tbltiendaproducto`
  ADD CONSTRAINT `tbltiendaproducto_ibfk_1` FOREIGN KEY (`IdProductosGeneral`) REFERENCES `tblproductosgenerales` (`IdProductosGeneral`),
  ADD CONSTRAINT `tbltiendaproducto_ibfk_2` FOREIGN KEY (`IdTienda`) REFERENCES `tbltienda` (`IdTienda`);

--
-- Filtros para la tabla `tblubicacion`
--
ALTER TABLE `tblubicacion`
  ADD CONSTRAINT `tblubicacion_ibfk_1` FOREIGN KEY (`IdPersona`) REFERENCES `tblpersona` (`IdPersona`);

--
-- Filtros para la tabla `tblusuario`
--
ALTER TABLE `tblusuario`
  ADD CONSTRAINT `tblusuario_ibfk_1` FOREIGN KEY (`IdNivel`) REFERENCES `tblnivel` (`IdNivel`),
  ADD CONSTRAINT `tblusuario_ibfk_2` FOREIGN KEY (`IdTUsuario`) REFERENCES `tbltipousuario` (`IdTUsuario`),
  ADD CONSTRAINT `tblusuario_ibfk_3` FOREIGN KEY (`IdPersona`) REFERENCES `tblpersona` (`IdPersona`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
