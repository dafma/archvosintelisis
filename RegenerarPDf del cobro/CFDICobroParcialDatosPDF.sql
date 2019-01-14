

CREATE VIEW [dbo].[CFDICobroParcialDatosPDF] AS
	 SELECT pdf.Estacion															AS Estacion, 
			pdf.ID																	AS ID, 
			pdf.IDModulo															AS ModuloID,
			pdf.Modulo																AS Modulo,
			e.RFC																	AS RFCEmisor,
			e.Nombre																AS Emisor,
			cpt.RFC																	AS RFCReceptor,
			c.Nombre																AS Receptor,
			cp.FechaEmision															AS FechaPago,
			cp.FormaPago															AS FormaPago,
			cp.NumOperacion															AS NumOperacion,
			cp.Sucursal                                                             As NoSucursal,                                                   
			cp.Empresa                                                              As NomEmpresa,
			cpt.Fechatimbrado                                                       As FechaTimbrado,
		    cpt.Importe                                                             As ImporteTotalCobro,
			CASE WHEN SFP.Bancarizado = 1 THEN be.Rfc ELSE NULL END					AS RFCBancoEmisor,
			CASE WHEN SFP.Bancarizado = 1 THEN bo.RFC ELSE NULL END					AS RFCBancoOrdenante,
			CASE WHEN SFP.Bancarizado = 1 THEN bo.Nombre ELSE NULL END				AS BancoOrdenante,
			CASE WHEN SFP.Bancarizado = 1 THEN cpt.CuentaBancariaCte ELSE NULL END	AS CuentaOrdenante,
			CASE WHEN SFP.Bancarizado = 1 THEN cp.CuentaBancaria ELSE NULL END		AS CuentaBeneficiaria,
			cp.Monto																AS MontoPago,
			cp.ClaveMoneda															AS MonedaPago,
			cp.TipoCambio															AS TipoCambioPago,
			cpt.CadenaOriginal														AS Cadenaoriginal,
			cpt.Sello																AS SelloEmisor,
			cpt.SelloSAT															AS SelloSAT,
			drt.UUID																AS IDDR,
			drt.Serie																AS SerieDR,
			drt.Folio																AS FolioDR,
			drt.Moneda																AS MonedaDR,
			drt.TipoCambio															AS TipoCambioDR,
			mp.Clave																AS MetodoPagoDR,
			drt.NumParcialidad														AS Parcialidad,
			drt.ImpPagado															AS ImportePagado,
			drt.ImpSaldoAnt															AS SaldoAnterior,
			drt.ImpSaldoInsoluto													AS SaldoInsoluto
	FROM CFDICobroParcialPDF AS pdf
		INNER JOIN CFDICobroParcialTimbrado AS cpt ON cpt.Modulo = pdf.Modulo AND cpt.IDModulo = pdf.IDModulo
		INNER JOIN CFDIDocRelacionadoTimbrado AS drt ON drt.Modulo = cpt.Modulo AND drt.IDModulo = cpt.IDModulo 
		INNER JOIN CFDICobroParcial AS cp ON cp.ID = pdf.IDModulo AND cp.Estacion = pdf.Estacion
		INNER JOIN Empresa AS e ON e.Empresa = cpt.Empresa
		INNER JOIN Cte AS c ON cp.Cliente = c.Cliente
		LEFT JOIN CFDINominaSATInstitucionFin AS be ON be.Clave = cpt.ClaveBancoCte
		LEFT JOIN CFDINominaSATInstitucionFin AS bo ON bo.Clave = cp.ClaveBanco
		INNER JOIN SATMetodoPago AS mp ON mp.IDClave = drt.MetodoPago
		INNER JOIN FormaPago AS fp ON fp.FormaPago = cp.FormaPago	
		INNER JOIN SATFormaPago AS sfp ON sfp.Clave = FP.ClaveSAT
	 WHERE drt.Cancelado = 0 AND cpt.Cancelado = 0



GO


