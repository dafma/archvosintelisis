/****** Object:  StoredProcedure [dbo].[spCFDFlexTextoQRCodeCobro]    Script Date: 10/3/2018 2:32:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spCFDFlexTextoQRCodeCobro]
	(
	@Modulo					varchar(5),
	@ModuloID				int
    )

	--exec spCFDFlexTextoQRCodeCobro 'CXC', 332451

AS BEGIN
  DECLARE
    @Resultado				varchar(255),
	@EmisorRFC				char(13),
	@ReceptorRFC			char(13),
	@Importe				varchar(25), -- SE CAMBIO A VARCHAR, TENIA FLOAT   26 DE ENERO 2018
	@UUID					varchar(50),
	@XML					varchar(max),
	@DocumentoXML			xml,
	@PrefijoCFDI			varchar(255),
	@RutaCFDI				varchar(255),
	@iDatos					int,
    @URLAccesoCFDI          varchar(100),
    @URLAccesoRET           varchar(100),
    @URLAcceso              varchar(100),
    @Sello                  CHAR(8),
	@Fecha                  DATETIME
   
    SELECT @URLAccesoCFDI= 'https'+CHAR(58)+'//verificacfdi.facturaelectronica.sat.gob.mx/default.aspx' -- CFDI
    SELECT @URLAccesoRET = 'https'+CHAR(58)+'//prodretencionverificacion.clouda.sat.gob.mx/'            -- RETENCIONES
   
    SET @DocumentoXML = CONVERT(XML,@XML)
    SET @PrefijoCFDI = '<ns xmlns' + CHAR(58) + 'cfdi="http' + CHAR(58) + '//www.sat.gob.mx/cfd/3" xmlns' + CHAR(58) + 'tfd="http' + CHAR(58) + '//www.sat.gob.mx/TimbreFiscalDigital"/>'
   
    EXEC sp_xml_preparedocument @iDatos OUTPUT, @DocumentoXML, @PrefijoCFDI
    SET @RutaCFDI = '/cfdi' + CHAR(58) + 'Comprobante'
    SELECT
	  @Importe = Importe, @fecha = Fecha from cfd where modulo='cxc' and moduloid= @moduloid			
      --FROM OPENXML (@iDatos, @RutaCFDI, 1) WITH (Total Varchar(25))  -- SE QUITO EL FLOAT Y SE COLOCO A VARCHAR   26 ENE 2018
    SET @RutaCFDI = '/cfdi' + CHAR(58) + 'Comprobante/cfdi' + CHAR(58) + 'Receptor'
    SELECT
	 @ReceptorRFC = LTRIM(Rfc)	from cfd where modulo='cxc' and moduloid= @moduloid			
      --FROM OPENXML (@iDatos, @RutaCFDI, 1) WITH (Rfc varchar(15))
    SET @RutaCFDI = '/cfdi' + CHAR(58) + 'Comprobante/cfdi' + CHAR(58) + 'Emisor'
    SELECT
	  @EmisorRFC = 'INT990114450'
      --FROM OPENXML (@iDatos, @RutaCFDI, 1) WITH (Rfc varchar(15))

    SET @RutaCFDI = '/cfdi' + CHAR(58) + 'Comprobante/cfdi' + CHAR(58) + 'Complemento/tfd' + CHAR(58) + 'TimbreFiscalDigital'
    SELECT
	  @UUID = UUID from cfd where modulo='cxc' and moduloid= @moduloid			
    --  FROM OPENXML (@iDatos, @RutaCFDI, 1) WITH (UUID uniqueidentifier)
    EXEC sp_xml_removedocument @iDatos
    
  --SET @Resultado = ISNULL(@URLAcceso,'')+'?id='+ISNULL(@UUID,'')+'&re='+ISNULL(RTRIM(@EmisorRFC),'')+'&rr='+ISNULL(RTRIM(@ReceptorRFC),'')+'&tt='+ISNULL(CONVERT(VARCHAR(25),@Importe),'0')+'&fe='+ISNULL(@Sello,'')   // SE COMENTO PARA MODIFICAR EL @IMPORTE. ESTA LINEA ES LA ORIGINAL Y ESTABA MAL.  26 ENE 2018
    SET @Resultado = ISNULL(@URLAcceso,'')+'?id='+ISNULL(@UUID,'')+'&re='+ISNULL(RTRIM(@EmisorRFC),'')+'&rr='+ISNULL(RTRIM(@ReceptorRFC),'')+'&tt='+@Importe+'&fe='+convert(varchar(30),@fecha )
  
  SELECT @Resultado
END


