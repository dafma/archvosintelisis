ALTER PROCEDURE [dbo].[spCFDICobroParcialRegenerarPDF]
	@Estacion			INT, 
	@Modulo				VARCHAR(5),
	@ID					INT
	
AS 
BEGIN
	
	DECLARE @AlmacenarRuta			VARCHAR(255)
		

	
	DELETE FROM CFDICobroParcial WHERE Estacion = @Estacion
	DELETE FROM CFDICobroParcialPDF WHERE Estacion = @Estacion
	
	IF @Modulo = 'CXC'
	BEGIN
		
		SELECT @AlmacenarRuta = REPLACE(Direccion, '.pdf','') FROM AnexoMov
		WHERE Rama = @Modulo AND ID = @ID AND Icono = 745
	
		INSERT INTO CFDICobroParcial(Estacion, ID, Mov, MovID, Empresa, Sucursal, FechaEmision, FechaOriginal, LugarExpedicion, Cliente, 
							FormaPago, NumOperacion, ClaveMoneda, TipoCambio, Monto, ClaveBancoEmisor, CuentaBancariaCte, ClaveBanco, CuentaBancaria,Modulo)
		SELECT @Estacion, A.ID, A.Mov, A.MovID, A.Empresa, A.Sucursal, A.FechaEmision, NULLIF(A.FechaOriginal, ''), ISNULL(G.CodigoPostal, H.CodigoPostal), A.Cliente, 
					ISNULL(A.FormaCobro, cc.InfoFormaPago), A.Referencia, ISNULL(E.Clave, 'XXX'), A.TipoCambio, A.Importe + A.Impuestos, ISNULL(NULLIF(F.ClaveBanco, ''), NULLIF(cc.BancoCta, '')), 
					ISNULL(NULLIF(F.CtaBanco, ''), NULLIF(cc.Cta, '')), NULLIF(D.ClaveSAT, ''), NULLIF(C.NumeroCta, ''),@Modulo
		FROM Cxc A
			LEFT JOIN CtaDinero C ON A.CtaDinero = C.CtaDinero
			LEFT JOIN CFDINominaInstitucionFin D ON C.BancoSucursal = D.Institucion
			INNER JOIN Mon E ON A.Moneda = E.Moneda
			INNER JOIN Cte F ON F.Cliente = A.Cliente
			LEFT JOIN CteCFD AS cc ON cc.Cliente = F.Cliente
			INNER JOIN Sucursal G ON G.Sucursal = A.Sucursal 
			INNER JOIN Empresa H ON A.Empresa = H.Empresa
		WHERE A.ID = @ID 
	
	END
	
	INSERT CFDICobroParcialPDF (Estacion, ID,  Modulo, IDModulo, Ruta)
	SELECT						@Estacion, 1, @Modulo, @ID,		@AlmacenarRuta
	
	
END
