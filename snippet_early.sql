[@BIM_ORDEMCARGA] WHERE Docentry = @list_of_cols_val_tab_del)
DECLARE @DiasRestantesApolice Numeric = 0

	IF (@CodTransportadora IS NOT NULL AND @CodTransportadora <>'') 
	BEGIN
	
	SET @DiasRestantesApolice = (SELECT DATEDIFF(DAY, GETDATE(), U_DataApoliceFinal) FROM OCRD WHERE CardCode = @CodTransportadora)
	
		IF(@DiasRestantesApolice IS NOT NULL AND @DiasRestantesApolice <= 5)
		BEGIN
	
			SET @Error =-14240
			SET @Error_Message = 'A transportadora selecionada, est  com data da ap¢lice vencida ou a vencer!' 
			SELECT @error, @error_message	

		END

	END	

END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:	Henrique Santos	
-- Create date: 19/09/2022 
-- Description: Trava de pedido com valor minimo por regiao
-- Documentos: Pedido de Venda 
-- GLPI ID : 14141

-- Author:	Vinicius Palmagnani Faria
-- Update date: 18/10/2022
-- Description: Bloquear apenas o departamento de vendas, nos itens PA e utiliza‡ao VENDA-REVENDA 

--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A','U')) --'17' = Pedido de venda

BEGIN

	DECLARE @Linhas14141 Numeric = (SELECT Count(*)FROM RDR1 WHERE DocEntry = @list_of_cols_val_tab_del)

	DECLARE @Cont14141 Numeric = 0

	DECLARE @UserSign14141 int = (SELECT UserSign FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)

	DECLARE @Dep14141 int = (SELECT Department FROM OUSR WHERE USERID = @UserSign14141)

	DECLARE @Usage14141 Nvarchar (255)

	DECLARE @GrupoItem14141 Nvarchar (255)

	DECLARE @ValorPedido14141 Numeric(10,2) = (SELECT DocTotal FROM ORDR WHERE DocNum = @list_of_cols_val_tab_del)

	DECLARE @ValorMinReg14141 Numeric(10,2) set @ValorMinReg14141 = 0

	DECLARE @RegiaoPedMin14141 Varchar (max) = (SELECT T1.Name FROM OCRD T0 INNER JOIN [@MW_MICRO] T1 ON T1.Code = T0.U_MW_MICRO 
												WHERE T0.CardCode = (SELECT CardCode FROM ORDR WHERE DocNum = @list_of_cols_val_tab_del))

		WHILE(@Cont14141 < @Linhas14141)
			BEGIN
				IF (@Dep14141 = 1)

					SET @Usage14141 = (SELECT Usage FROM RDR1 WHERE LineNum = @Cont14141 AND DocEntry = @list_of_cols_val_tab_del)
					IF (@Usage14141 = 17)
					BEGIN
						
						SET @GrupoItem14141 = (SELECT T1.ItmsGrpCod FROM RDR1 T0 INNER JOIN OITM T1 ON T1.ItemCode = T0.ItemCode
											   WHERE T0.LineNum = @Cont14141 AND T0.DocEntry = @list_of_cols_val_tab_del)
						IF @GrupoItem14141 IN (116,117,118) 
						BEGIN

							SET @ValorMinReg14141 = (SELECT U_ValorMinimo FROM [@RAL_PEDMINIMOREG] WHERE U_Regiao = @RegiaoPedMin14141)
							IF(@ValorPedido14141 < @ValorMinReg14141)
							BEGIN
									SET @Error =-14141
									SET @Error_Message = 'Valor m¡nimo para o pedido ‚ ' + cast(@ValorMinReg14141 as varchar)
									SELECT @error, @error_message

							END--VALOR MINIMO

						END--GRUPO ITEM

					END--END USAGE

			SET @Cont14141 = @Cont14141 +1
			END--END WHILE
END--END FINAL
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:	Vinicius Palmagnani
-- Create date: 30/05/2022
-- Update Date: 
-- Description: Utiliza‡ao USO E CONSUMO obrigat¢rio preenchimento dos CSTs
-- Documentos: NF de Entrada 
-- GLPI ID : 13504
-- GLPI ID
