--------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- AuthorUpdate:leonardo do Prado Gomes
-- Create date: 20/06/2018
-- Update Date: 26/04/2024
-- Description:  Adi‡ao e altera‡ao de registro de Lista de Picking
-- DescriptionUpdate: Melhoria na Contagem de OC, aplicado CASE para tratar valor Nulo.
-- Documento: Picking 
-- GLPI ID:5261
-- GLPI ID Atualiza‡ao:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '156') and (@transaction_type in ('A','U'))--'156' = Picking
BEGIN
DECLARE @OCNum Nvarchar (10) = 0

DECLARE @U_Veiculo_Placa  Nvarchar (10)
DECLARE @U_Transportadora  Nvarchar (max)
DECLARE @U_Valor_Frete  Numeric
DECLARE @U_Tipo_Veiculo_Nome  Nvarchar (max)
DECLARE @U_Itinerario_Nome  Nvarchar (max)
DECLARE @U_Peso_Estimado numeric
DECLARE @U_Peso_Pedidos numeric
DECLARE @U_Quantidade_Entrega numeric
DECLARE @U_Valor_Seguro numeric(10,3)
DECLARE @U_Valor_Total_Frete numeric (10,3)
DECLARE @U_TotalTaxaEntrega numeric (10,3)

	IF((SELECT COUNT(U_OC_num) FROM (
				SELECT CASE 
							WHEN T1.U_OC_num IS NULL THEN 1  -----MELHORIA APLICADA NESTE BLOCO
							ELSE T1.U_OC_num 
					  END AS 'U_OC_num'
				FROM PKL1 T0
				INNER JOIN RDR1 T1 ON T0.OrderEntry = T1.DocEntry AND T0.OrderLine = T1.LineNum
				WHERE AbsEntry = @list_of_cols_val_tab_del			
				Group by T1.U_OC_num)A) = 1 ) --Se s¢ houver 1 oc entra no if
	BEGIN
	SET @OCNum = (SELECT T1.U_OC_num FROM PKL1 T0
				INNER JOIN RDR1 T1 ON T0.OrderEntry = T1.DocEntry AND T0.OrderLine = T1.LineNum
				WHERE AbsEntry = @list_of_cols_val_tab_del	
				Group by T1.U_OC_num) 


		SET @U_Veiculo_Placa = (SELECT U_Veiculo_Placa FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_Transportadora = (SELECT U_Transportadora FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_Valor_Frete = (SELECT U_Valor_Frete FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_Tipo_Veiculo_Nome = (SELECT U_Tipo_Veiculo_Nome FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_Itinerario_Nome = (SELECT U_Itinerario_Nome FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_Peso_Estimado = (SELECT U_Peso_Estimado FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_Peso_Pedidos = (SELECT U_Peso_Estimado - U_Peso_Estimado_Pallets FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_Quantidade_Entrega = (SELECT U_Quantidade_Entrega FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_Valor_Seguro = (SELECT U_Valor_Seguro FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_TotalTaxaEntrega = (SELECT  U_Valor_Taxa_entrega FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)
		SET @U_Valor_Total_Frete = (SELECT U_Valor_Total_Frete FROM [@BIM_ORDEMCARGA] WHERE DocEntry = @OCNum)

		Update OPKL SET U_PlacaVeiculo = @U_Veiculo_Placa,U_Transportadora = @U_Transportadora,
		U_ValorFrete =  @U_Valor_Frete,U_TipoVeiculo = @U_Tipo_Veiculo_Nome,U_Itinerario = @U_Itinerario_Nome,
		U_PesoSuportado = @U_Peso_Estimado, U_PesoPedidos = @U_Peso_Pedidos,U_Entrega = @U_Quantidade_Entrega,
		U_TaxaEntrega = @U_Valor_Seguro, U_TotalTaxaEntrega= @U_TotalTaxaEntrega, U_ValorTotalFrete = @U_Valor_Total_Frete 
		WHERE AbsEntry = @list_of_cols_val_tab_del;		


	END
END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
