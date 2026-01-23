




CREATE PROC [dbo].[SBO_SP_TransactionNotification] 

@object_type nvarchar(20), 				-- SBO Object Type
@transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
@num_of_cols_in_key int,
@list_of_key_cols_tab_del nvarchar(255),
@list_of_cols_val_tab_del nvarchar(255)

AS

begin

-- Return values
declare @error  int				-- Result (0 for no error)
declare @error_message nvarchar (200) 		-- Error string to be displayed
select @error = 0
select @error_message = N'Ok'


--------------------------------------------------------------------------------------------------------------------------------
--	ADD	YOUR	CODE	HERE
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 12/12/2025
-- Description: Bloco criado para PREENCHER o campo do CclassTrib direto na DEV. NOTA FISCAL DE ENTRADA
-- GLPI IDs: -
---------------------------------------------------------------------------------------------------------------------------------
IF(@object_type = '19') and (@transaction_type in ('A','U'))
BEGIN

	
	DECLARE @ControllerInt121220253 INT;
	SET @ControllerInt121220253 = 0;

	DECLARE @QtyLines121220253 INT
	SET @QtyLines121220253 = (SELECT COUNT(T0.DocEntry) FROM RPC1 T0 WHERE T0.DocEntry =  @list_of_cols_val_tab_del)

	DECLARE @CodImposto121220253 NVARCHAR(80);
	DECLARE @CstCodeIn121220253 NVARCHAR(80);

	WHILE (@ControllerInt121220253 < @QtyLines121220253)
	BEGIN
		
		SET @CodImposto121220253 = (SELECT RTRIM(LTRIM(T0.TaxCode))
										FROM RPC1 T0 
										WHERE T0.DocEntry =  @list_of_cols_val_tab_del
										AND T0.LineNum = @ControllerInt121220253);

			SET @CstCodeIn121220253 = NULL;  --limpando  antes de atribuir valor

			SET @CstCodeIn121220253 = (SELECT "CstCodeIn"
							FROM STC1
							WHERE "STCCode" = @CodImposto121220253
							AND "STAType" = 32
							AND "STCCode" LIKE '%R') ---PEGANDO SOMENTE CÓDIGOS DA REFORMA.

			IF(@CstCodeIn121220253 IS NOT NULL AND @CstCodeIn121220253 <> '')
			BEGIN

				UPDATE RPC1
				SET U_SKILL_CTIBSCBS = @CstCodeIn121220253
				WHERE DocEntry = @list_of_cols_val_tab_del
				AND LineNum = @ControllerInt121220253;

			END

			SET @ControllerInt121220253 = @ControllerInt121220253 + 1


	END






END




--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 12/12/2025
-- Description: Bloco criado para PREENCHER o campo do CclassTrib direto na NOTA FISCAL DE ENTRADA E NOTA FISCAL DE RECEBIMENTO FUTURO
-- GLPI IDs: -
---------------------------------------------------------------------------------------------------------------------------------
IF(@object_type = '18') and (@transaction_type in ('A','U'))
BEGIN
	
	DECLARE @ControllerInt121220252 INT;
	SET @ControllerInt121220252 = 0;

	DECLARE @QtyLines121220252 INT
	SET @QtyLines121220252 = (SELECT COUNT(T0.DocEntry) FROM PCH1 T0 WHERE T0.DocEntry =  @list_of_cols_val_tab_del)

	DECLARE @CodImposto121220252 NVARCHAR(80);
	DECLARE @CstCodeIn121220252 NVARCHAR(80);

	WHILE (@ControllerInt121220252 < @QtyLines121220252)
	BEGIN

			
			SET @CodImposto121220252 = (SELECT RTRIM(LTRIM(T0.TaxCode))
										FROM PCH1 T0 
										WHERE T0.DocEntry =  @list_of_cols_val_tab_del
										AND T0.LineNum = @ControllerInt121220252);

			SET @CstCodeIn121220252 = NULL;  --limpando  antes de atribuir valor

			SET @CstCodeIn121220252 = (SELECT "CstCodeIn"
							FROM STC1
							WHERE "STCCode" = @CodImposto121220252
							AND "STAType" = 32
							AND "STCCode" LIKE '%R') ---PEGANDO SOMENTE CÓDIGOS DA REFORMA.

			IF(@CstCodeIn121220252 IS NOT NULL AND @CstCodeIn121220252 <> '')
			BEGIN

				UPDATE PCH1
				SET U_SKILL_CTIBSCBS = @CstCodeIn121220252
				WHERE DocEntry = @list_of_cols_val_tab_del
				AND LineNum = @ControllerInt121220252;

			END

			SET @ControllerInt121220252 = @ControllerInt121220252 + 1

	END


END


--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 12/12/2025
-- Description: Bloco criado para PREENCHER o campo do CclassTrib direto no DEVOLUÇÃO DE MERCADORIA
-- GLPI IDs: -
---------------------------------------------------------------------------------------------------------------------------------
IF(@object_type = '21') and (@transaction_type in ('A','U'))
BEGIN


	DECLARE @ControllerInt121220251 INT;
	SET @ControllerInt121220251 = 0;

	DECLARE @QtyLines121220251 INT
	SET @QtyLines121220251 = (SELECT COUNT(T0.DocEntry) FROM RPD1 T0 WHERE T0.DocEntry =  @list_of_cols_val_tab_del)

	DECLARE @CodImposto121220251 NVARCHAR(80);
	DECLARE @CstCodeIn121220251 NVARCHAR(80);

	WHILE (@ControllerInt121220251 < @QtyLines121220251)
	BEGIN


		SET @CodImposto121220251 = (SELECT RTRIM(LTRIM(T0.TaxCode))
										FROM RPD1 T0 
										WHERE T0.DocEntry =  @list_of_cols_val_tab_del
										AND T0.LineNum = @ControllerInt121220251);

			SET @CstCodeIn121220251 = NULL;  --limpando  antes de atribuir valor

			SET @CstCodeIn121220251 = (SELECT "CstCodeIn"
							FROM STC1
							WHERE "STCCode" = @CodImposto121220251
							AND "STAType" = 32
							AND "STCCode" LIKE '%R') ---PEGANDO SOMENTE CÓDIGOS DA REFORMA.

			IF(@CstCodeIn121220251 IS NOT NULL AND @CstCodeIn121220251 <> '')
			BEGIN

				UPDATE RPD1
				SET U_SKILL_CTIBSCBS = @CstCodeIn121220251
				WHERE DocEntry = @list_of_cols_val_tab_del
				AND LineNum = @ControllerInt121220251;

			END

			SET @ControllerInt121220251 = @ControllerInt121220251 + 1

	END

END

--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 12/12/2025
-- Description: Bloco criado para PREENCHER o campo do CclassTrib direto no RECEBIMENTO DE MERCADORIA
-- GLPI IDs: -
---------------------------------------------------------------------------------------------------------------------------------
IF(@object_type = '20') and (@transaction_type in ('A','U'))
BEGIN

	DECLARE @ControllerInt12122025 INT;
	SET @ControllerInt12122025 = 0;

	DECLARE @QtyLines12122025 INT
	SET @QtyLines12122025 = (SELECT COUNT(T0.DocEntry) FROM PDN1 T0 WHERE T0.DocEntry =  @list_of_cols_val_tab_del)

	DECLARE @CodImposto12122025 NVARCHAR(80);
	DECLARE @CstCodeIn12122025 NVARCHAR(80);

	WHILE (@ControllerInt12122025 < @QtyLines12122025)
	BEGIN

			SET @CodImposto12122025 = (SELECT RTRIM(LTRIM(T0.TaxCode))
										FROM PDN1 T0 
										WHERE T0.DocEntry =  @list_of_cols_val_tab_del
										AND T0.LineNum = @ControllerInt12122025);

			SET @CstCodeIn12122025 = NULL;  --limpando  antes de atribuir valor

			SET @CstCodeIn12122025 = (SELECT "CstCodeIn"
							FROM STC1
							WHERE "STCCode" = @CodImposto12122025
							AND "STAType" = 32
							AND "STCCode" LIKE '%R') ---PEGANDO SOMENTE CÓDIGOS DA REFORMA.

			IF(@CstCodeIn12122025 IS NOT NULL AND @CstCodeIn12122025 <> '')
			BEGIN

				UPDATE PDN1
				SET U_SKILL_CTIBSCBS = @CstCodeIn12122025
				WHERE DocEntry = @list_of_cols_val_tab_del
				AND LineNum = @ControllerInt12122025;

			END

			SET @ControllerInt12122025 = @ControllerInt12122025 + 1

	END

END
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 20/12/2025
-- Description: Bloco criado para PREENCHER o campo do CclassTrib direto na DEV. nota fiscal de saida
-- GLPI IDs: -
---------------------------------------------------------------------------------------------------------------------------------
IF(@object_type = '14') and (@transaction_type in ('A','U'))
BEGIN

DECLARE @ControllerInt201220251 INT;
	SET @ControllerInt201220251 = 0;

	DECLARE @QtyLines201220251 INT
	SET @QtyLines201220251 = (SELECT COUNT(T0.DocEntry) FROM RIN1 T0 WHERE T0.DocEntry =  @list_of_cols_val_tab_del)

	DECLARE @CodImposto201220251 NVARCHAR(80);
	DECLARE @CstCodeIn201220251 NVARCHAR(80);

	WHILE (@ControllerInt201220251 < @QtyLines201220251)
	BEGIN

		SET @CodImposto201220251 = (SELECT RTRIM(LTRIM(T0.TaxCode))
									FROM RIN1 T0 
									WHERE T0.DocEntry =  @list_of_cols_val_tab_del
									AND T0.LineNum = @ControllerInt201220251);


	    SET @CstCodeIn201220251 = NULL;  --limpando  antes de atribuir valor

		SET @CstCodeIn201220251 = (SELECT "CstCodeIn"
									FROM STC1
									WHERE "STCCode" = @CodImposto201220251
									AND "STAType" = 32
									AND "STCCode" LIKE '%R') ---PEGANDO SOMENTE CÓDIGOS DA REFORMA.
		

		IF(@CstCodeIn201220251 IS NOT NULL AND @CstCodeIn201220251 <> '')
		BEGIN

			UPDATE RIN1
			SET U_SKILL_CTIBSCBS = @CstCodeIn201220251
			WHERE DocEntry = @list_of_cols_val_tab_del
			AND LineNum = @ControllerInt201220251;

		END


		SET @ControllerInt201220251 = @ControllerInt201220251 + 1

	END


END





--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 20/12/2025
-- Description: Bloco criado para PREENCHER o campo do CclassTrib direto na nota fiscal de saida
-- GLPI IDs: -
---------------------------------------------------------------------------------------------------------------------------------
IF(@object_type = '13') and (@transaction_type in ('A','U'))
BEGIN

	DECLARE @ControllerInt20122025 INT;
	SET @ControllerInt20122025 = 0;

	DECLARE @QtyLines20122025 INT
	SET @QtyLines20122025 = (SELECT COUNT(T0.DocEntry) FROM INV1 T0 WHERE T0.DocEntry =  @list_of_cols_val_tab_del)

	DECLARE @CodImposto20122025 NVARCHAR(80);
	DECLARE @CstCodeIn20122025 NVARCHAR(80);

	WHILE (@ControllerInt20122025 < @QtyLines20122025)
	BEGIN

		SET @CodImposto20122025 = (SELECT RTRIM(LTRIM(T0.TaxCode))
									FROM INV1 T0 
									WHERE T0.DocEntry =  @list_of_cols_val_tab_del
									AND T0.LineNum = @ControllerInt20122025);


	    SET @CstCodeIn20122025 = NULL;  --limpando  antes de atribuir valor

		SET @CstCodeIn20122025 = (SELECT "CstCodeIn"
									FROM STC1
									WHERE "STCCode" = @CodImposto20122025
									AND "STAType" = 32
									AND "STCCode" LIKE '%R') ---PEGANDO SOMENTE CÓDIGOS DA REFORMA.
		

		IF(@CstCodeIn20122025 IS NOT NULL AND @CstCodeIn20122025 <> '')
		BEGIN

			UPDATE INV1
			SET U_SKILL_CTIBSCBS = @CstCodeIn20122025
			WHERE DocEntry = @list_of_cols_val_tab_del
			AND LineNum = @ControllerInt20122025;

		END


		SET @ControllerInt20122025 = @ControllerInt20122025 + 1

	END


END

--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 09/12/2025
-- Description: Bloco criado para PREENCHER o campo do CclassTrib direto no pedido
-- GLPI IDs: -
---------------------------------------------------------------------------------------------------------------------------------

IF(@object_type = '17') and (@transaction_type in ('A','U'))
BEGIN
	
	DECLARE @ControllerInt09122025 INT;
	SET @ControllerInt09122025 = 0;

	DECLARE @QtyLines09122025 INT
	SET @QtyLines09122025 = (SELECT COUNT(T0.DocEntry) FROM RDR1 T0 WHERE T0.DocEntry =  @list_of_cols_val_tab_del)

	DECLARE @CodImposto09122025 NVARCHAR(80);
	DECLARE @CstCodeIn09122025 NVARCHAR(80);

	WHILE (@ControllerInt09122025 < @QtyLines09122025)
	BEGIN

		SET @CodImposto09122025 = (SELECT RTRIM(LTRIM(T0.TaxCode))
									FROM RDR1 T0 
									WHERE T0.DocEntry =  @list_of_cols_val_tab_del
									AND T0.LineNum = @ControllerInt09122025);


	    SET @CstCodeIn09122025 = NULL;  --limpando  antes de atribuir valor

		SET @CstCodeIn09122025 = (SELECT "CstCodeIn"
									FROM STC1
									WHERE "STCCode" = @CodImposto09122025
									AND "STAType" = 32
									AND "STCCode" LIKE '%R') ---PEGANDO SOMENTE CÓDIGOS DA REFORMA.
		

		IF(@CstCodeIn09122025 IS NOT NULL AND @CstCodeIn09122025 <> '')
		BEGIN

			UPDATE RDR1
			SET U_SKILL_CTIBSCBS = @CstCodeIn09122025
			WHERE DocEntry = @list_of_cols_val_tab_del
			AND LineNum = @ControllerInt09122025;

		END


		SET @ControllerInt09122025 = @ControllerInt09122025 + 1

	END


END





--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 11/11/2025
-- Description: Bloco criado para travar qualquer fatura de adiantamento que não venha de um pedido de compras
-- GLPI IDs: 19287
---------------------------------------------------------------------------------------------------------------------------------

IF(@object_type = '204') and (@transaction_type in ('A'))
BEGIN
	

	IF NOT EXISTS(
	SELECT 
		T0.DocEntry,
		T0.UserSign,
		T1.Department
	FROM ODPO T0
	INNER JOIN OUSR T1
	   ON T1.USERID = T0.UserSign
	WHERE T1.Department IN(9,13)
	AND T0.DocEntry = @list_of_cols_val_tab_del
	)
	BEGIN
		
		IF NOT EXISTS(
		SELECT T1.BaseEntry,
		T1.BaseType
		FROM ODPO T0
		INNER JOIN DPO1 T1
		   ON T1.DocEntry = T0.DocEntry
		WHERE T0.DocEntry = @list_of_cols_val_tab_del
		AND T1.BaseType = 22)
		BEGIN	

			SET @error = -11112025
			SET @error_message = 'Não é possivel lançar este adiantamento, contate o administrador!';
			SELECT @error, @error_message;


		END


	END


	



END



--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 06/07/2025
-- Description: Bloco criado para criar travas somente em campos especificos de documentos.
-- GLPI IDs: 18689, 18570
---------------------------------------------------------------------------------------------------------------------------------


--// - INICIO - CONTROLE DE CAMPOS PARA A DEVOLUÇÃO DE NOTA FISCAL DE SAIDA//--
---TABELA DE CONTROLE


IF (@object_type = '14') and (@transaction_type in ('A'))
BEGIN
	
	IF EXISTS(SELECT 
					 T0.DocDueDate,
					 GETDATE() AS 'Hoje',
					 T0.U_CorrecaoContabil
				FROM ORIN T0 
				WHERE T0.DocEntry = @list_of_cols_val_tab_del
				AND CAST(T0.DocDueDate AS DATE) < CAST(GETDATE() AS DATE)
				AND (T0.U_CorrecaoContabil <> 'Y' OR T0.U_CorrecaoContabil IS NULL)
				)
	BEGIN
		
		SET @error = -01082025
		SET @error_message = 'Atenção data de Vencimento divergente da data de Hoje, Contate o administrador!';
		SELECT @error, @error_message;

	END
	ELSE
	BEGIN

		/*INSERE O REGISTRO ATUAL*/
		INSERT INTO FAL_ORIN_CONTROLLER(
		DocEntry,
		CardCode,
		CardName,
		CreateDate,
		DocDate,
		DocDueDate,
		TaxDate,
		DocStatus,
		UserSign
		)
		SELECT 
		DocEntry,
		CardCode,
		CardName,
		CreateDate,
		DocDate,
		DocDueDate,
		TaxDate,
		DocStatus,
		UserSign
		FROM ORIN T0
		WHERE T0.DocEntry = @list_of_cols_val_tab_del;

	END
	
	
	 
END


--TRANSACTION DE VERIFICAÇÃO DE ALTERAÇÃO DO CAMPO
IF (@object_type = '14') and (@transaction_type in ('U'))
BEGIN
		
		
		IF NOT EXISTS(SELECT T0.DocDueDate,
							   T1.DocDueDate
						FROM ORIN T0
						INNER JOIN FAL_ORIN_CONTROLLER T1 
						   ON T1.DocEntry = T0.DocEntry
						   AND T1.DocDueDate = T0.DocDueDate
						WHERE T0.DocEntry = @list_of_cols_val_tab_del
		)
		BEGIN
			
			IF NOT EXISTS(
			SELECT T0.DocDueDate
			FROM ORIN T0
			WHERE T0.DocEntry = @list_of_cols_val_tab_del
			AND (T0.DocDueDate >= GETDATE() OR T0.U_CorrecaoContabil = 'Y'))
			BEGIN
				
					SET @error = -01082025
					SET @error_message = 'Atenção data de Vencimento divergente da data de Hoje ou retroativa, Contate o administrador!';
					SELECT @error, @error_message;

			END


		END



		IF EXISTS(SELECT * 
		FROM FAL_ORIN_CONTROLLER T1
		WHERE T1.DocEntry IN (SELECT T0.DocEntry
								FROM ORIN T0
								WHERE T0.DocStatus = 'C'))
		BEGIN
			
			DELETE 
			FROM FAL_ORIN_CONTROLLER 
			WHERE DocEntry IN (SELECT T0.DocEntry
								FROM ORIN T0
								WHERE T0.DocStatus = 'C')


		END


END




--// - FIM - CONTROLE DE CAMPOS PARA A DEVOLUÇÃO DE NOTA FISCAL DE SAIDA//--

--// - INICIO - CONTROLE DE CAMPOS PARA A NOTA FISCAL DE ENTRADA

IF (@object_type = '18') and (@transaction_type in ('A'))
BEGIN

	
	IF EXISTS(
				SELECT 
					 T0.DocDueDate,
					 T1.DueDate,
					 GETDATE() AS 'Hoje',
					 T0.U_CorrecaoContabil
				FROM OPCH T0 
				INNER JOIN PCH6 T1
				   ON T1.DocEntry = T0.DocEntry
				WHERE (CAST(T0.DocDueDate AS DATE) < CAST(GETDATE() AS DATE) OR (T1.DueDate < CAST(GETDATE() AS DATE) AND T1.Status = 'O'))
				AND T0.DocEntry = @list_of_cols_val_tab_del
				AND (T0.U_CorrecaoContabil <> 'Y' OR T0.U_CorrecaoContabil IS NULL)

				)
	BEGIN


		SET @error = -01082025
		SET @error_message = 'Atenção data de Vencimento divergente da data de Hoje, Contate o administrador!';
		SELECT @error, @error_message;

	END
	ELSE
	BEGIN
		
		/*INSERE O REGISTRO ATUAL*/
		INSERT INTO FAL_OPCH_CONTROLLER(
		DocEntry,
		CardCode,
		CardName,
		CreateDate,
		DocDate,
		DocDueDate,
		TaxDate,
		DocStatus,
		UserSign,
		DataParcela
		)
		SELECT 
		T0.DocEntry,
		T0.CardCode,
		T0.CardName,
		T0.CreateDate,
		T0.DocDate,
		T0.DocDueDate,
		T0.TaxDate,
		T0.DocStatus,
		T0.UserSign,
		T1.DueDate AS 'DataParcela'
		FROM OPCH T0
		INNER JOIN PCH6 T1
	    ON T1.DocEntry = T0.DocEntry
		WHERE T0.DocEntry = @list_of_cols_val_tab_del;

	END


END

IF (@object_type = '18') and (@transaction_type in ('U'))
BEGIN	


		/*VERIFICA SE HOUVE ALTERAÇÃO NOS CAMPOS DE DATA DE VENCIMENTO/PARCELA */
		IF NOT EXISTS(SELECT T0.DocDueDate,
							   T1.DocDueDate,
							    T2.DueDate
						FROM OPCH T0
						INNER JOIN PCH6 T2
						   ON T2.DocEntry = T0.DocEntry
						INNER JOIN FAL_OPCH_CONTROLLER T1 
						   ON T1.DocEntry = T0.DocEntry
						   AND T1.DocDueDate = T0.DocDueDate
						   AND T1.DataParcela = T2.DueDate
						WHERE T0.DocEntry = @list_of_cols_val_tab_del
		)



		BEGIN

			IF NOT EXISTS(

			SELECT *
			FROM OPCH T0
			WHERE T0.DocEntry = @list_of_cols_val_tab_del
			AND T0.DocStatus = 'C'
			AND T0.U_CorrecaoContabil = 'Y'

			
			)
			BEGIN

				/*SE AS DATAS (PARCELA/VENCIMENTO) FOREM MAIOR QUE A DATA DE HOJE, DEIXA PASSAR */
				IF NOT EXISTS(
				SELECT T0.DocDueDate
				FROM OPCH T0
				INNER JOIN PCH6 T1
				   ON T1.DocEntry = T0.DocEntry
				WHERE T0.DocEntry = @list_of_cols_val_tab_del

				AND ((T0.DocDueDate >= GETDATE() 
				AND T1.DueDate >= GETDATE()) OR  T0.U_CorrecaoContabil = 'Y')

				)
				BEGIN
				
						SET @error = -01082025
						SET @error_message = 'Atenção data de Vencimento divergente da data de Hoje ou retroativa, Contate o administrador!';
						SELECT @error, @error_message;

				END



			END



			


		END

		
		IF EXISTS(SELECT * 
		FROM FAL_OPCH_CONTROLLER T1
		WHERE T1.DocEntry IN (SELECT T0.DocEntry
								FROM OPCH T0
								WHERE T0.DocStatus = 'C'))
		BEGIN
			
			DELETE 
			FROM FAL_OPCH_CONTROLLER 
			WHERE DocEntry IN (SELECT T0.DocEntry
								FROM OPCH T0
								WHERE T0.DocStatus = 'C')


		END


END



--// - FIM - CONTROLE DE CAMPOS PARA A DEVOLUÇÃO DE NOTA FISCAL DE SAIDA//--


--// - INICIO - CONTROLE DE CAMPOS PARA FATURA DE ADIANTAMENTO

IF (@object_type = '204') and (@transaction_type in ('A'))
BEGIN	

	
	IF EXISTS(
				SELECT 
					 T0.DocDueDate,
					 T1.DueDate,
					 GETDATE() AS 'Hoje',
					 T0.U_CorrecaoContabil
				FROM ODPO T0 
				INNER JOIN DPO6 T1
				   ON T1.DocEntry = T0.DocEntry
				WHERE (CAST(T0.DocDueDate AS DATE) < CAST(GETDATE() AS DATE) OR (T1.DueDate < CAST(GETDATE() AS DATE) AND T1.Status = 'O'))
				AND T0.DocEntry = @list_of_cols_val_tab_del
				AND (T0.U_CorrecaoContabil <> 'Y' OR T0.U_CorrecaoContabil IS NULL)

				)
	BEGIN


		SET @error = -30092025
		SET @error_message = 'Atenção data de Vencimento divergente da data de Hoje, Contate o administrador!';
		SELECT @error, @error_message;

	END
	ELSE	
	BEGIN


		/*INSERE O REGISTRO ATUAL*/
		INSERT INTO FAL_ODPO_CONTROLLER(
		DocEntry,
		CardCode,
		CardName,
		CreateDate,
		DocDate,
		DocDueDate,
		TaxDate,
		DocStatus,
		UserSign,
		DataParcela
		)
		SELECT 
		T0.DocEntry,
		T0.CardCode,
		T0.CardName,
		T0.CreateDate,
		T0.DocDate,
		T0.DocDueDate,
		T0.TaxDate,
		T0.DocStatus,
		T0.UserSign,
		T1.DueDate AS 'DataParcela'
		FROM ODPO T0
		INNER JOIN DPO6 T1
	    ON T1.DocEntry = T0.DocEntry
		WHERE T0.DocEntry = @list_of_cols_val_tab_del;



	END

END

IF (@object_type = '204') and (@transaction_type in ('U'))
BEGIN	

/*VERIFICA SE HOUVE ALTERAÇÃO NOS CAMPOS DE DATA DE VENCIMENTO/PARCELA */
		IF NOT EXISTS(SELECT T0.DocDueDate,
							   T1.DocDueDate,
							    T2.DueDate
						FROM ODPO T0
						INNER JOIN DPO6 T2
						   ON T2.DocEntry = T0.DocEntry
						INNER JOIN FAL_ODPO_CONTROLLER T1 
						   ON T1.DocEntry = T0.DocEntry
						   AND T1.DocDueDate = T0.DocDueDate
						   AND T1.DataParcela = T2.DueDate
						WHERE T0.DocEntry = @list_of_cols_val_tab_del
		)



		BEGIN

			IF NOT EXISTS(

			SELECT *
			FROM ODPO T0
			WHERE T0.DocEntry = @list_of_cols_val_tab_del
			AND T0.DocStatus = 'C'
			AND T0.U_CorrecaoContabil = 'Y'

			
			)
			BEGIN

				/*SE AS DATAS (PARCELA/VENCIMENTO) FOREM MAIOR QUE A DATA DE HOJE, DEIXA PASSAR */
				IF NOT EXISTS(
				SELECT T0.DocDueDate
				FROM ODPO T0
				INNER JOIN DPO6 T1
				   ON T1.DocEntry = T0.DocEntry
				WHERE T0.DocEntry = @list_of_cols_val_tab_del

				AND ((T0.DocDueDate >= GETDATE() 
				AND T1.DueDate >= GETDATE()) OR  T0.U_CorrecaoContabil = 'Y')

				)
				BEGIN
				
						SET @error = -01082025
						SET @error_message = 'Atenção data de Vencimento divergente da data de Hoje ou retroativa, Contate o administrador!';
						SELECT @error, @error_message;

				END



			END



			


		END

		
		IF EXISTS(SELECT * 
		FROM FAL_ODPO_CONTROLLER T1
		WHERE T1.DocEntry IN (SELECT T0.DocEntry
								FROM ODPO T0
								WHERE T0.DocStatus = 'C'))
		BEGIN
			
			DELETE 
			FROM FAL_ODPO_CONTROLLER 
			WHERE DocEntry IN (SELECT T0.DocEntry
								FROM ODPO T0
								WHERE T0.DocStatus = 'C')


		END


END






--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author: Bruno Cassiano 
-- Create date: 10/06/2025
-- Update 		27/06/2025
-- Description: Trava UNIFICADA para impedir a inserção ou atualização de documentos fiscais com data de vencimento retroativa,
--              incluindo validação de prestações individuais e exceção para usuário específico (279).
-- GLPI IDs: 18689, 18570
---------------------------------------------------------------------------------------------------------------------------------

/*
IF @object_type IN (N'18', N'19', N'14') AND @transaction_type IN (N'A', N'U')
BEGIN
    DECLARE @DocDueDateA DATE;
    DECLARE @DocTypeName NVARCHAR(100);
    DECLARE @CurrentUserID_A INT;

    
    IF @object_type = N'18'
    BEGIN
        SELECT @DocDueDateA = T0.DocDueDate, @CurrentUserID_A = IIF(@transaction_type = 'A', T0.UserSign, T0.UserSign2) FROM OPCH T0 WHERE T0.DocEntry = @list_of_cols_val_tab_del;
        SET @DocTypeName = N'Fatura de Fornecedor';
    END
    ELSE IF @object_type = N'19'
    BEGIN
        SELECT @DocDueDateA = T0.DocDueDate, @CurrentUserID_A = IIF(@transaction_type = 'A', T0.UserSign, T0.UserSign2) FROM ORPC T0 WHERE T0.DocEntry = @list_of_cols_val_tab_del;
        SET @DocTypeName = N'Nota de Crédito de Compra';
    END
    ELSE IF @object_type = N'14'
    BEGIN
        SELECT @DocDueDateA = T0.DocDueDate, @CurrentUserID_A = IIF(@transaction_type = 'A', T0.UserSign, T0.UserSign2) FROM ORIN T0 WHERE T0.DocEntry = @list_of_cols_val_tab_del;
        SET @DocTypeName = N'Nota de Crédito de Venda';
    END;

    
    IF (@DocDueDateA < CAST(GETDATE() AS DATE) AND (@CurrentUserID_A <> 276 OR @CurrentUserID_A <> 283))
    BEGIN
        SET @error = -110;
        SET @error_message = N'Não é permitido inserir/atualizar um(a) ' + @DocTypeName + N' com data de vencimento inferior à data atual.';
        SELECT @error, @error_message;
    END;
END;






IF @object_type IN (N'13', N'18', N'19', N'14') AND @transaction_type IN (N'A', N'U')
BEGIN
    DECLARE @Vencidas INT = 0;
    DECLARE @DocInstallmentTypeName NVARCHAR(100);
    DECLARE @CurrentUserID_B INT;

    
    IF @object_type = N'13' 
    BEGIN
        SELECT @Vencidas = COUNT(*) FROM INV6 WHERE DocEntry = @list_of_cols_val_tab_del AND DueDate < CAST(GETDATE() AS DATE);
        SELECT @CurrentUserID_B = IIF(@transaction_type = 'A', UserSign, UserSign2) FROM OINV WHERE DocEntry = @list_of_cols_val_tab_del;
        SET @DocInstallmentTypeName = N'Fatura de Cliente';
    END
    ELSE IF @object_type = N'18' 
    BEGIN
        SELECT @Vencidas = COUNT(*) FROM PCH6 WHERE DocEntry = @list_of_cols_val_tab_del AND DueDate < CAST(GETDATE() AS DATE);
        SELECT @CurrentUserID_B = IIF(@transaction_type = 'A', UserSign, UserSign2) FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del;
        SET @DocInstallmentTypeName = N'Fatura de Fornecedor';
    END
    ELSE IF @object_type = N'19' 
    BEGIN
        SELECT @Vencidas = COUNT(*) FROM RPC6 WHERE DocEntry = @list_of_cols_val_tab_del AND DueDate < CAST(GETDATE() AS DATE);
        SELECT @CurrentUserID_B = IIF(@transaction_type = 'A', UserSign, UserSign2) FROM ORPC WHERE DocEntry = @list_of_cols_val_tab_del;
        SET @DocInstallmentTypeName = N'Nota de Crédito de Compra';
    END
    ELSE IF @object_type = N'14' 
    BEGIN
        SELECT @Vencidas = COUNT(*) FROM RIN6 WHERE DocEntry = @list_of_cols_val_tab_del AND DueDate < CAST(GETDATE() AS DATE);
        SELECT @CurrentUserID_B = IIF(@transaction_type = 'A', UserSign, UserSign2) FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del;
        SET @DocInstallmentTypeName = N'Nota de Crédito de Venda';
    END;

    
    IF (@Vencidas > 0 AND (@CurrentUserID_B <> 276 OR @CurrentUserID_B <> 283))
    BEGIN
        SET @error = -111;
        SET @error_message = N'Não é permitido criar/atualizar ' + @DocInstallmentTypeName + N' com prestações com data de vencimento inferior à data atual.';
        SELECT @error, @error_message;
    END;
END;



*/
/*
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo Gomes
-- Create date: 20/05/2025
-- Description:	trava criada para quando o SAC Lançar o pedido não deixar lançar no deposito 02.03
-- GLPI ID:  18530
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '17') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas
BEGIN


	IF EXISTS(

	SELECT T3.WhsCode
	FROM ORDR T0
	INNER JOIN OUSR T1
	   ON T1.USERID = T0.UserSign
	INNER JOIN OUSR T2
	   ON T2.USERID = T0.UserSign
	INNER JOIN RDR1 T3
	   ON T3.DocEntry = T0.DocEntry
	WHERE T0.DocEntry = @list_of_cols_val_tab_del
	AND ((T1.Department = 12 OR T2.Department = 12) AND T3.WhsCode = '02.03')
	
	)

	BEGIN

	
		SET @error = -18530;
		SET @error_message = 'Atenção! Depósito não é permitido para o usuário de lançamento!';
		SELECT @error, @error_message;


	END
	

END 

*/
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo Gomes
-- Create date: 17/04/2025
-- Description:	trava criada para quando o SAC Lançar o pedido, informe o canal de atendimento na ABA SAC
-- GLPI ID:  ---
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A'))--'17' = Pedido de Vendas
BEGIN


	DECLARE @UserSingSAC170425 INT;
	SET @UserSingSAC170425 = (SELECT T0.UserSign
						FROM ORDR T0
						WHERE T0.DocEntry = @list_of_cols_val_tab_del)

	DECLARE @DepartmentSAC170425 INT;
	SET @DepartmentSAC170425 = (SELECT T0.Department
							FROM OUSR T0
							WHERE T0.USERID = @UserSingSAC170425)	

	IF(@DepartmentSAC170425 = 12)
	BEGIN
	
					IF NOT EXISTS(SELECT T0.U_CanalAtendimento
					FROM ORDR T0
					WHERE T0.DocEntry = @list_of_cols_val_tab_del
					AND T0.U_CanalAtendimento IS NOT NULL)
					BEGIN 
					
						SET @error = -18108;
						SET @error_message = 'Atenção! informe o Canal de Atendimento na aba SAC para prosseguir com o pedido.';
						SELECT @error, @error_message;

					END



	END

END

--------------------------------------------------------------------------------------------------------------------------------
-- END 
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo
-- Create date: 17/02/2025
-- Description:	trava criada para quando o cliente flegar SN URGENTE ser obrigatório o preenchimento do campo grau de urgencia na solicitação DE compra
-- GLPI ID:  18108
--------------------------------------------------------------------------------------------------------------------------------

IF @transaction_type IN ('A', 'U') AND  @object_type = '1470000113' 
BEGIN

				IF EXISTS(

				SELECT T0.U_RAL_Urgente,
					   T0.U_RAL_GRAU_URGENCIA
				FROM OPRQ T0 
				WHERE T0.DocEntry = @list_of_cols_val_tab_del
				AND T0.U_RAL_Urgente = 'Y'
				AND T0.U_RAL_GRAU_URGENCIA NOT IN(0,3)
				
				)

				BEGIN 

				
					SET @error = -18108;
					SET @error_message = 'Atenção! Documento Definido com Urgencia, Necessario Definir um Grau para prosseguir.';
					SELECT @error, @error_message;


				END 
				
				
END

--------------------------------------------------------------------------------------------------------------------------------
-- END 
---------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo/Henrique
-- Create date: 01/10/2024
-- Description:	trava criada para impedir a inserção de documentos com valores divergentes em KG, se baseando na nota fiscal de saida, se não houver documento referenciado, considera o preço de lista
-- GLPI ID:  17552
--------------------------------------------------------------------------------------------------------------------------------

--IF @transaction_type IN ('A', 'U') AND @object_type = '14' 
--BEGIN

	
--	IF EXISTS (
--					SELECT *
--FROM (
--					--traz somente Devoluções que não tem nf de venda referenciada
--					SELECT
--					T0.ItemCode, 
--					T1.ItmsGrpCod,
--					T0.Quantity,
--					T0.Price,
--					T0.Weight1 'Peso Linha', 
--					t2.Weight1 'Peso UDM',
--					T0.Price/ NULLIF(T2.Weight1,0) 'Preço KG NF', 
--					T6.Price 'Preço de Lista',
--					T1.SWeight1,
--					t6.Price / NULLIF(t1.SWeight1,0) 'Preço por kg Lista',
--					(((T0.Price/ NULLIF(T2.Weight1,0)) / NULLIF((t6.Price / NULLIF(t1.SWeight1,0)),0)  ) * 100) - 100 AS 'Porcentagem',
--					null 'RefDoc',null 'Preço por kg venda' 	
--					FROM RIN1 T0
--					INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
--					INNER JOIN OUOM T2 ON T0.UomCode = T2.UomCode
--					INNER JOIN ORIN T3 on T0.DocEntry = T3.DocEntry
--					INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
--					INNER JOIN OPLN T5 ON T4.ListNum = T5.ListNum
--					INNER JOIN ITM1 T6 on T5.ListNum = T6.PriceList AND T0.ItemCode = T6.ItemCode
--					LEFT JOIN RIN21 T7 on T0.DocEntry = T7.DocEntry
--					WHERE T0.DocEntry = @list_of_cols_val_tab_del  AND T7.RefDocEntr is null
 
--					UNION ALL
--					---TRAZ SOMENTE AS DEVOLUÇõES COM NF REFERENCIADA
--					SELECT
--					T0.ItemCode, 
--					T1.ItmsGrpCod,
--					T0.Quantity,
--					T0.Price,
--					T0.Weight1 'Peso Linha', 
--					t2.Weight1 'Peso UDM',
--					T0.Price/ NULLIF(T2.Weight1,0) 'Preço KG NF', 
--					T6.Price 'Preço de Lista',
--					T1.SWeight1,
--					t6.Price / NULLIF(t1.SWeight1,0) 'Preço po25r kg Lista',
--					(((T0.Price/ NULLIF(T2.Weight1,0)) / COALESCE(T9.price /NULLIF(T10.weight1,0),NULLIF((t6.Price / NULLIF(t1.SWeight1,0)),0))   ) * 100) - 100 AS 'Porcentagem',
--					T7.RefDocNum,T9.price /NULLIF(T10.weight1,0) 'Preço por kg venda'
--					FROM RIN1 T0
--					INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
--					INNER JOIN OUOM T2 ON T0.UomCode = T2.UomCode
--					INNER JOIN ORIN T3 on T0.DocEntry = T3.DocEntry
--					INNER JOIN OCRD T4 ON T3.CardCode = T4.CardCode
--					INNER JOIN OPLN T5 ON T4.ListNum = T5.ListNum
--					INNER JOIN ITM1 T6 on T5.ListNum = T6.PriceList AND T0.ItemCode = T6.ItemCode
--					INNER JOIN RIN21 T7 ON T0.DocEntry = T7.DocEntry
--					INNER JOIN OINV T8 ON T7.RefDocNum = T8.DocEntry
--					INNER JOIN INV1 T9 ON T8.DocEntry = T9.DocEntry AND T0.ItemCode = T9.ItemCode
--					INNER JOIN OUOM T10 ON T9.UomCode = T10.UomCode
--					WHERE T0.DocEntry = @list_of_cols_val_tab_del
--					) A
--					WHERE (A.ItmsGrpCod = 117 AND (A.Porcentagem >= 40 OR A.Porcentagem <= -40)) 
--					OR (A.ItmsGrpCod <> 117 AND (A.Porcentagem >= 10 OR A.Porcentagem <= -10))
 

--		)
--		BEGIN 

		
--			SET @error = -17552;
--			SET @error_message = 'Documento com Divergencia em 10% ou 40% Referente ao Preço de Liste ou Nota Referenciada em KG';
--			SELECT @error, @error_message;

--		END 

	
--END

--------------------------------------------------------------------------------------------------------------------------------
-- END 
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo Prado
-- Create date: 19/09/2024
-- Description:	Trava criada para impedir que o documento seja atualizado se houver vinculo com remessa no bankplus
-- GLPI ID:  17516
--------------------------------------------------------------------------------------------------------------------------------
/*
IF ((@object_type = '14') AND (@transaction_type IN ('U','D','C'))) -- DEVOLUÇÃO DE NOTA FISCAL DE SAIDA
BEGIN

	DECLARE @val_NR_Transf VARCHAR(254);
	DECLARE @val_Arc_Vinc VARCHAR(254);
	
	IF EXISTS (

		SELECT * 
		FROM (
		SELECT 
			   T1.NumeroInterno,
			   T2.NrTransferencia,
			   (SELECT T0.NomeDoArquivo
					FROM [dbo].[IV_IB_OrdemDePagamento] T0
					WHERE T0.Codigo = T2.CodigoDaOrdemDePagamento) AS 'ArquivoVinculado',
				(SELECT T0.Status
					FROM [dbo].[IV_IB_OrdemDePagamento] T0
					WHERE T0.Codigo = T2.CodigoDaOrdemDePagamento) AS 'Status'
		FROM [dbo].[IV_IB_TransferenciaParaCliente] T0
		INNER JOIN [dbo].[IV_IB_TransferenciaParaClienteParcela] T1
		   ON T1.TransferenciaId = T0.Id
		INNER JOIN [dbo].[IV_IB_PagamentosDaOrdemDePagamento] T2
		   ON T2.TecId = T1.TransferenciaId)T100
		WHERE T100.NumeroInterno = @list_of_cols_val_tab_del
		AND T100.Status = 2
	)

	BEGIN

		SET @val_NR_Transf = (SELECT T100.NrTransferencia
								FROM (
								SELECT 
									   T1.NumeroInterno,
									   T2.NrTransferencia,
									   (SELECT T0.NomeDoArquivo
											FROM [dbo].[IV_IB_OrdemDePagamento] T0
											WHERE T0.Codigo = T2.CodigoDaOrdemDePagamento) AS 'ArquivoVinculado',
										(SELECT T0.Status
											FROM [dbo].[IV_IB_OrdemDePagamento] T0
											WHERE T0.Codigo = T2.CodigoDaOrdemDePagamento) AS 'Status'
								FROM [dbo].[IV_IB_TransferenciaParaCliente] T0
								INNER JOIN [dbo].[IV_IB_TransferenciaParaClienteParcela] T1
								   ON T1.TransferenciaId = T0.Id
								INNER JOIN [dbo].[IV_IB_PagamentosDaOrdemDePagamento] T2
								   ON T2.TecId = T1.TransferenciaId)T100
								WHERE T100.NumeroInterno = @list_of_cols_val_tab_del
								AND T100.Status = 2)

		SET @val_Arc_Vinc = (SELECT T100.ArquivoVinculado
								FROM (
								SELECT 
									   T1.NumeroInterno,
									   T2.NrTransferencia,
									   (SELECT T0.NomeDoArquivo
											FROM [dbo].[IV_IB_OrdemDePagamento] T0
											WHERE T0.Codigo = T2.CodigoDaOrdemDePagamento) AS 'ArquivoVinculado',
										(SELECT T0.Status
											FROM [dbo].[IV_IB_OrdemDePagamento] T0
											WHERE T0.Codigo = T2.CodigoDaOrdemDePagamento) AS 'Status'
								FROM [dbo].[IV_IB_TransferenciaParaCliente] T0
								INNER JOIN [dbo].[IV_IB_TransferenciaParaClienteParcela] T1
								   ON T1.TransferenciaId = T0.Id
								INNER JOIN [dbo].[IV_IB_PagamentosDaOrdemDePagamento] T2
								   ON T2.TecId = T1.TransferenciaId)T100
								WHERE T100.NumeroInterno = @list_of_cols_val_tab_del
								AND T100.Status = 2)


		SET @error = -17516;
		SET @error_message = CONCAT('Atenção! Este Documento possui vinculo com Remessa no BankPlus, Transferencia: ', @val_NR_Transf, ', Arquivo: ', @val_Arc_Vinc, ', Contate o Financeiro.');
		SELECT @error, @error_message;

	END	


END
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo Prado
-- Create date: 12/09/2024
-- Description:	Trava criada para impedir que seja cadastrado ou alterado os itinerarios por outros usuarios se nao os permitidos.
-- GLPI ID: 17490
--------------------------------------------------------------------------------------------------------------------------------

--IF ((@object_type = 'BIM_ITINERARIO') AND (@transaction_type IN ('A','U','D','C','L'))) -- ORDEM DE CARGA - ITINERARIO
--BEGIN

--	DECLARE @UserCad INT;

--	-- Busca o UserSign do documento
--	SET @UserCad = (SELECT T1.UserSign
--						FROM [@BIM_ITINERARIO] T0
--						INNER JOIN [@ABIM_ITINERARIO] T1
--						   ON T1.DocEntry = T0.DocEntry
--						WHERE T0.DocEntry =  @list_of_cols_val_tab_del
--						AND T1.LogInst IN(SELECT MAX(T1x.LogInst)
--											FROM [@BIM_ITINERARIO] T0x
--											INNER JOIN [@ABIM_ITINERARIO] T1x
--											   ON T1x.DocEntry = T0x.DocEntry
--											WHERE T0x.DocEntry = T0.DocEntry));

--	-- Verifica se @UserCad não é NULL e não está na lista de usuários permitidos
--	IF (@UserCad IS NULL OR @UserCad NOT IN
--		(SELECT T0.USERID
--			FROM OUSR T0
--			WHERE T0.USER_CODE LIKE '%kely.carneiro%' 
--				OR T0.USER_CODE LIKE '%ronaldo.azevedo%'))
--	BEGIN 
--		SET @error = -17490;
--		SET @error_message = 'Atenção! Este Documento so pode ser Criado/Atualizado/Deletado/Cancelado por usuários com permissão! Contate o administrador.';
--		SELECT @error, @error_message;
--	END;

--END;


--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo Prado
-- Create date: 01/08/2024
-- Description:	Trava criada para impedir que documentos com a mesma Nf sejam Lançados na Fatura de adiantamento de contas a pagar
-- GLPI ID: 17252
--------------------------------------------------------------------------------------------------------------------------------
IF ((@object_type = '204') AND (@transaction_type IN ('A','U'))) -- CONTROLE DE DEVOLUÇÕES ARM
BEGIN

	DECLARE @NF_Compra INT;
	DECLARE @Quantidade INT;
	DECLARE @Doc_Vinculado INT;

	SET @NF_Compra = (SELECT T0.U_NF_Compra
					  FROM ODPO T0
					  WHERE T0.DocEntry = @list_of_cols_val_tab_del);

	SET @Quantidade = (SELECT COUNT(*) AS Quantidade
					   FROM ODPO T1
					   WHERE T1.U_NF_Compra = @NF_Compra
					   AND T1.DocEntry <> @list_of_cols_val_tab_del);

	
	IF (@Quantidade >= 1)

	BEGIN

		SET @Doc_Vinculado = (SELECT MAX(T1.DocEntry)
		FROM ODPO T1
		WHERE T1.U_NF_Compra = @NF_Compra)


		SET @Error = -17252;
		SET @Error_Message = CONCAT('Atenção! Existe Documento vinculado a esta Nota Fiscal Informada, Verifique o valor do campo "Nota Fiscal de Compra" ou o Documento: ', @Doc_Vinculado);
		SELECT @Error, @Error_Message;
	

	END 


END

-------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo Prado
-- Create date: 18/07/2024
-- Description:	Trava criada para impedir que haja divergencia do lançamento do controle x Dev Nfe
-- GLPI ID:
--------------------------------------------------------------------------------------------------------------------------------

IF ((@object_type = 'CTRLARM') AND (@transaction_type IN ('A','U'))) -- CONTROLE DE DEVOLUÇÕES ARM
BEGIN

	IF EXISTS (SELECT * 
				FROM (
				SELECT T0.ItemCode AS 'ItemCodeNf',
					   T2.U_ItemCode AS 'ItemCodeControl'
				FROM RIN1 T0
				INNER JOIN [@RAL_CONTROLE_DEVOL] T1
				   ON T1.U_Nf_Devolucao = T0.DocEntry
				LEFT JOIN [@RAL_CONTROLE_DEVOL1] T2
				   ON T2.DocEntry = T1.DocEntry AND T2.U_ItemCode = T0.ItemCode
				WHERE T1.DocEntry = @list_of_cols_val_tab_del
				)T100
				WHERE T100.ItemCodeControl IS NULL) 
	BEGIN

        SET @Error = -1
        SET @Error_Message = 'Atenção! Divergencia de Lançamento, Verifique a quantidades de Item na Nota X Controle de Devolução ou Referencie o item e Preencha o campo Observações' 
        SELECT @Error, @Error_Message

	END 

END



-- Author: Bruno Cassiano
-- Create date: 24/05/2024
-- Description:	Trava criada para impedir produtos com valor acima de 30% ao preço de lista
-- GLPI ID:16972
--------------------------------------------------------------------------------------------------------------------------------
/*
IF ((@object_type = '17') AND (@transaction_type IN ('A','U'))) -- PEDIDO DE VENDA
BEGIN
    IF EXISTS (
        SELECT *
        FROM (
            SELECT 
                T1.ItemCode,
                T1.Price AS 'PrecoVenda',
                T3.PriceList,
                T3.Price AS 'PrecoLista',
                T1.Price - T3.Price AS 'ConvertPrice',
                CAST(CASE WHEN T3.Price <> 0 THEN (T1.Price / T3.Price) * 100 ELSE NULL END AS NUMERIC(10,2)) AS 'Porcent'
             
            FROM ORDR T0
            INNER JOIN RDR1 T1 ON T1.DocEntry = T0.DocEntry
            INNER JOIN OCRD T2 ON T2.CardCode = T0.CardCode
            INNER JOIN ITM1 T3 ON T3.PriceList = T2.ListNum AND T3.ItemCode = T1.ItemCode
            WHERE 
                T0.DocEntry = @list_of_cols_val_tab_del 
               
        ) T100
        WHERE 
            (T100.Porcent > 130)  -- Verifica se o preço de venda é mais de 30% acima do preço de lista
           
    )
    BEGIN
        -- SETANDO A MENSAGEM DE ERRO NA TELA
        SET @Error = -16972
        SET @Error_Message = 'Preço de venda maior que 30% acima do preço de lista. Verifique!' 
        SELECT @Error, @Error_Message
    END
END
*/
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Create date: 15/05/2024
-- Description:	Trava criada para impedir a inserção de notas fiscais de entrada com valor 0
-- GLPI ID:16506
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '18') and (@transaction_type in ('A','U'))--'18' = Nota Fiscal Entrada
BEGIN

	DECLARE @Utilizacao16506 INT

	SET @Utilizacao16506 = (SELECT DISTINCT T0.Usage ----DISTINCT USADO SOMENTE POR CONTA DE TRANSFERENCIAS! DOCUMENTOS DE TRASFERENCIAS OU SÃO 60 PARA TODAS AS LINHAS OU 61
						    FROM PCH1 T0
							WHERE T0.DocEntry = @list_of_cols_val_tab_del
							AND T0.Usage IN(60,61))
	
	IF @Utilizacao16506 IN (60, 61)
	BEGIN 

		IF EXISTS(SELECT T1.LineTotal
				  FROM (SELECT T0.LineTotal
						FROM PCH1 T0
						WHERE T0.DocEntry = @list_of_cols_val_tab_del)T1
				  WHERE T1.LineTotal <= 0)

		BEGIN
			SET @Error =-16506
			SET @Error_Message = 'Atenção, Linha com valor 0 ou Nulo. insira um valor valido para prosseguir!' 
			SELECT @error, @error_message	

		END
	END

END

--------------------------------------------------------------------------------------------------------------------------------
-- Author: Leonardo do Prado Gomes
-- Author Update: Bruno Cassiano
-- Create date: 15/05/2024
-- Update Date: 23/09/2024
-- Description: Trava criada para barrar preços com mais de 5% de 
---desconto baseado no preço de lista do PN(apenas cadastros manuais, edi esta fora da regra)
-- Acrescentado regra para desconsiderar a kelly.
-- Retirado usuário de Larissa
-- Documentos: Cotação
-- GLPI ID : 16908
--------------------------------------------------------------------------------------------------------------------------------
IF ((@object_type = '23') AND (@transaction_type IN ('A','U'))) ----COTACAO DE VENDA
BEGIN 

  IF EXISTS(SELECT * 
          	FROM (
          	SELECT T1.ItemCode,
              		  T1.Price AS 'PrecoVenda',
              		  T3.PriceList,
              		  T3.Price AS 'PrecoLista',
              		  T3.Price - T1.Price AS 'ConvertPrice',
              		  CAST(CASE WHEN T3.Price <> 0 THEN (T1.Price / T3.Price) * 100 ELSE NULL END AS NUMERIC(10,2)) AS 'Porcent',
              		 T0.Comments,
              		  T0.U_SPS_ID_NEOGRID 
          	  FROM OQUT T0
          	  INNER JOIN QUT1 T1 ON T1.DocEntry = T0.DocEntry 
          	  INNER JOIN OCRD T2 ON T2.CardCode = T0.CardCode
          	  INNER JOIN ITM1 T3 ON T3.PriceList = T2.ListNum AND T3.ItemCode = T1.ItemCode
          	  WHERE T0.DocEntry = @list_of_cols_val_tab_del
          	  AND T0.U_AHS_SapUserCode = 'None'
			  AND T0.UserSign <> 14
			  AND T0.UserSign2 <> 14
			  AND T0.UserSign <> 260
			  AND T0.UserSign2 <> 260
			  )T100
          	  WHERE (T100.Porcent < 95 OR T100.Porcent IS NULL)
          	  AND (T100.Comments NOT LIKE '%Gerado via integração EDI%' OR T100.Comments IS NULL OR T100.U_SPS_ID_NEOGRID IS NULL)

  ) ---FIM DO IF EXISTIS

  BEGIN

    ----------SETANDO A MENSAGEM DE ERRO NA TELA
    SET @Error =-16908
    SET @Error_Message = 'Linha com desconto maior que 5% Verifique!' 
    SELECT @error, @error_message

  END


END
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 05/10/2023
-- Update date: 13/11/2023
-- Description:	Atualizar o campo U_DescFinBP para ajustar o desconto financeiro no bankplus
-- Comentado por conta da nova versão do add-on em produção. (WMS)
-- GLPI ID:
-- GLPI ID Atualizações:
--------------------------------------------------------------------------------------------------------------------------------
/*
IF (@object_type = '13') and (@transaction_type in ('A','U'))--'13' = Nota Fiscal Saida
BEGIN
	DECLARE @CardCodeNF NVarchar (20)
	
	DECLARE @DescontoFinanceiroNF Decimal(10,2) SET @DescontoFinanceiroNF = 0
	

	SET @CardCodeNF  = (SELECT CardCode FROM OINV WHERE DocEntry = @list_of_cols_val_tab_del)
	
	SET @DescontoFinanceiroNF = (SELECT U_MW_DESFIN FROM OCRD WHERE CardCode = @CardCodeNF)
	
		BEGIN			
			UPDATE OINV 
				SET   U_DescFinBP  = @DescontoFinanceiroNF,U_MW_DESCONTO  = @DescontoFinanceiroNF  WHERE DocEntry = @list_of_cols_val_tab_del
		END 
		
END;
*/

--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:	Bruno Cassiano
-- Create date: 14/10/2022
-- Update Date: 
-- Description: Trava de data de 5 dias de vencimento para apólice de seguro da transportadora.
-- Documentos: Ordem de Carga
-- GLPI ID : 14240
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = 'BIM_ORDEMCARGA') and (@transaction_type in ('U')) --'BIM_ORDEMCARGA' = ORDEM DE CARGA
BEGIN

DECLARE @CodTransportadora Varchar(10) = (SELECT U_Transportadora FROM [@BIM_ORDEMCARGA] WHERE Docentry = @list_of_cols_val_tab_del)
DECLARE @DiasRestantesApolice Numeric = 0

	IF (@CodTransportadora IS NOT NULL AND @CodTransportadora <>'') 
	BEGIN
	
	SET @DiasRestantesApolice = (SELECT DATEDIFF(DAY, GETDATE(), U_DataApoliceFinal) FROM OCRD WHERE CardCode = @CodTransportadora)
	
		IF(@DiasRestantesApolice IS NOT NULL AND @DiasRestantesApolice <= 5)
		BEGIN
	
			SET @Error =-14240
			SET @Error_Message = 'A transportadora selecionada, está com data da apólice vencida ou a vencer!' 
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
-- Description: Trava de pedido com valor minimo por região
-- Documentos: Pedido de Venda 
-- GLPI ID : 14141

-- Author:	Vinicius Palmagnani Faria
-- Update date: 18/10/2022
-- Description: Bloquear apenas o departamento de vendas, nos itens PA e utilização VENDA-REVENDA 

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
									SET @Error_Message = 'Valor mínimo para o pedido é ' + cast(@ValorMinReg14141 as varchar)
									SELECT @error, @error_message

							END--VALOR MÍNIMO

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
-- Description: Utilização USO E CONSUMO obrigatório preenchimento dos CSTs
-- Documentos: NF de Entrada 
-- GLPI ID : 13504
-- GLPI ID atualização:
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '18') and (@transaction_type in ('A','U')) --'18' = Nota Fiscal Entrada

BEGIN

DECLARE @Linhas13504 Numeric = (SELECT Count(*)FROM PCH1 WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Cont13504 Numeric = 0

WHILE(@Cont13504 < @Linhas13504)
	BEGIN
		IF EXISTS (SELECT T2.Usage,T0.CSTCode,T0.CSTfIPI,T0.CSTfPIS,CSTfCOFINS
					FROM PCH1 T0
					INNER JOIN OUSG T2 ON T2.ID = T0.Usage
					WHERE T0.Usage IN (27,26,29,51,31,32,33,23,62,24,25,50,28,18,41,19,20,21,63)
					AND (T0.CSTCode IS NULL OR T0.CSTfIPI IS NULL OR T0.CSTfPIS IS NULL OR CSTfCOFINS IS NULL)
					AND T0.DocEntry = @list_of_cols_val_tab_del AND T0.LineNum = @Cont13504)

			BEGIN
				SET @Error =-13504
				SET @Error_Message = 'Favor revisar o preenchimento do CST'
				SELECT @error, @error_message
			END

		SET @Cont13504 = @Cont13504 +1
	END
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:	Vinicius Palmagnani
-- Create date: 18/05/2022
-- Update Date: 01/06/2022
-- Description: Grupo de itens MAQUINAS OPERACIONAIS é obrigatorio preenchimento da utilização "OPE" 
-- Documentos: NF de Entrada 
-- GLPI ID : 13410
-- GLPI ID atualização: 13518,13598
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '18') and (@transaction_type in ('A','U')) --'18' = Nota Fiscal Entrada

BEGIN

	IF EXISTS (SELECT T0.DocEntry,T1.ItmsGrpCod,T0.OcrCode
				FROM PCH1 T0
				INNER JOIN OITM T1 ON T1.ItemCode = T0.ItemCode
				WHERE T1.ItmsGrpCod = 174
				AND T0.OcrCode IN ('01.0001', '01.0002','01.0005')
				AND T0.Usage NOT IN (19,21,31,32)
				AND T0.DocEntry = @list_of_cols_val_tab_del)

		BEGIN

			SET @Error =-13410
			SET @Error_Message = 'Favor revisar o preenchimento do campo "Utilização"'
			SELECT @error, @error_message

		END


END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Dalmir Pompeu Ponzo Junior
-- Create date: 28/10/2021
-- Update Date:
-- Description: Travar alterações e cancelamentos em Cotações de Vendas para vendedores
-- Documento: Cotação de Vendas
-- GLPI ID: 12179
-- GLPI IG Atualização: 
--------------------------------------------------------------------------------------------------------------------------------
/*
IF (@object_type = '23') and (@transaction_type in ('U' , 'D' , 'C' , 'L'))
BEGIN

DECLARE @UserSign12179C int = (SELECT UserSign2 FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Dep12179C int SET @Dep12179C = (SELECT Department FROM OUSR WHERE USERID = @UserSign12179C)


IF(@Dep12179C = 1)
BEGIN


SET @error = -12179
SET @error_message = 'Não é permitido alterar ou cancelar o documento. Favor entrar em contato com Administração de Vendas.'
SELECT @error, @error_message
END
END

--------------------------------------------------------------------------------------------------------------------------------
--END 
--------------------------------------------------------------------------------------------------------------------------------
*/


--------------------------------------------------------------------------------------------------------------------------------
-- Author: Dalmir Pompeu Ponzo Junior
-- Create date: 27/10/2021
-- Update Date:
-- Description: Travar alterações e cancelamentos em Pedidos de Vendas para vendedores
-- Documento: Pedido de Vendas
-- GLPI ID: 12179
-- GLPI ID Atualização:16900
-- UpdateAuthor: Leonardo do Prado Gomes
-- Description: Acrescentado novo parametro para travar cancelamento do pedido de vendas.
-- UpdateDate: 09/05/2024
--------------------------------------------------------------------------------------------------------------------------------


IF (@object_type = '17') and (@transaction_type in ('U' , 'D' , 'C' , 'L'))
BEGIN

DECLARE @UserSign12179V int = (SELECT UserSign2 FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Dep12179V int SET @Dep12179V = (SELECT Department FROM OUSR WHERE USERID = @UserSign12179V)
DECLARE @UserAprov12179 INT;
SET @UserAprov12179 = (SELECT T1.UserID
							FROM OWDD T0
							INNER JOIN WDD1 T1
							   ON T1.WddCode = T0.WddCode
							WHERE T1.UserID = 279
							AND T0.DocEntry = @list_of_cols_val_tab_del
							GROUP BY T1.UserID)

IF(@Dep12179V = 1 AND @UserAprov12179 <> 279)
BEGIN

	SET @error = -12179
	SET @error_message = 'Não é permitido alterar ou cancelar o documento. Favor entrar em contato com Administração de Vendas.'
	SELECT @error, @error_message
	END

END

-------------------------------------------------------------------------

IF (@object_type = '17') and (@transaction_type in ('C'))
BEGIN

DECLARE @UserSign16900V int = (SELECT UserSign2 FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Dep16900V int SET @Dep16900V = (SELECT Department FROM OUSR WHERE USERID = @UserSign16900V)
DECLARE @UserAprov16900 INT;
SET @UserAprov16900 = (SELECT T1.UserID
							FROM OWDD T0
							INNER JOIN WDD1 T1
							   ON T1.WddCode = T0.WddCode
							WHERE T1.UserID = 279
							AND T0.DocEntry = @list_of_cols_val_tab_del)



IF(@Dep16900V <> 2 AND @UserAprov16900 <> 279)
BEGIN


SET @error = -12179
SET @error_message = 'Não é permitido alterar ou cancelar o documento. Favor entrar em contato com Administração de Vendas.'
SELECT @error, @error_message

END

END


--------------------------------------------------------------------------------------------------------------------------------
--END 
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Vinicius Palmagnani Faria
-- Create date: 12/08/2021
-- Description:	Bloquear cadastro de placas com mais de sete caracteres
-- Documento: Cadastro de veículo (add-on Ruston - periféricos)
-- GLPI ID: 11712
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = 'RAL_VEICULO') and (@transaction_type in ('A', 'U'))

BEGIN

DECLARE @PLACA11712 NVARCHAR(10) = (SELECT U_PLACA FROM [@RAL_VEICULO] WHERE DocEntry = @list_of_cols_val_tab_del)

IF LEN(@PLACA11712) > 7

SET @Error =-11712
SET @Error_Message = 'Quantidade incorreta de caracteres na placa do veículo. Favor revisar o preenchimento do campo.'
SELECT @error, @error_message

END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- SPS CONSULTORIA
-- Author: Cristiana Maria
-- Create date: 15/06/2021
-- Description:	Nao permitir lancamento contabil negativo
-- Documento: Lancamento contábil manual
-- GLPI ID: 11332
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = N'30') and (@transaction_type in ('A', 'U'))
Begin 

if (select count (transid) from jdt1 where debit < 0 and TransId =  @list_of_cols_val_tab_del) >0
begin
	set @Error =-11332
    set @Error_Message = 'Lançamento contábil com valor negativo.'
	SELECT @error, @error_message
end

END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:	Fabricio Consiglio	
-- Create date: 18/02/2021
-- Description:	Preencher campo "Observação do diário" em importação de CTE de Venda
-- Documento: NF-Entrada
--------------------------------------------------------------------------------------------------------------------------------
IF ((	
		@object_type = N'18')
	AND @transaction_type IN ('A'))

BEGIN
	EXEC [dbo].[SPS_SP_OBS] @object_type, @list_of_cols_val_tab_del	
END

--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 18/01/2021
-- Description:	Não permitir pedido de Vendas com parceiro Lead (ESBOÇO)
-- Documento: Pedido de Vendas
-- GLPI ID:9768
-- GLPI IG Atualização:10260
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'112') and (@transaction_type in ('A'))--'17' = Pedido de Vendas

BEGIN

DECLARE @CardType9768E char = (SELECT T1.CardType FROM ODRF T0
INNER JOIN OCRD T1 on T0.CardCode = T1.CardCode
WHERE T0.ObjType = 17 AND T0.DocEntry = @list_of_cols_val_tab_del)

	IF(@CardType9768E ='L')
		BEGIN
			SET @error = -9768
			SET @error_message = 'Não é permitido enviar Pedido com cliente Lead - esboço'		
			SELECT @error, @error_message
		END	
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Vinicius Palmagnani Faria
-- Create date: 10/09/2020
-- Description: Impossibilitar adição de documento sem regra de distribuição
-- Documentos: Lançamento de estoque
-- GLPI ID: 9450
-- GLPI ID Atualizações:
------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '10000071') and (@transaction_type in ('A','U'))--'10000071' = Lançamento de estoque
 
BEGIN
 DECLARE @DocEntryLE int = @list_of_cols_val_tab_del
 DECLARE @DocTypeLE char = (SELECT DataSource FROM OIQR WHERE DocEntry = @DocEntryLE)
 
 ----Regra de Distribuição
 IF EXISTS (SELECT OL.OcrCode FROM OIQR O INNER JOIN IQR1 OL ON O.DocEntry = ol.DocEntry
 	WHERE o.DocEntry = @DocEntryLE AND (OL.OcrCode IS NULL OR OL.OcrCode = ''))

 	BEGIN
		SET @error = -9450
		SET @error_message = 'Lançamento de estoque - Não foi possível concluir. É necessário definir a Regra de Distribuição.'
		SELECT @error, @error_message
    END
 
END;
 
---------------------------------ESBOÇO
IF (@object_type = N'112') and (@transaction_type in ('A','U'))--N'112' = ESBOÇO
 
BEGIN
 DECLARE @DocEntryESBLE int = @list_of_cols_val_tab_del
 DECLARE @DocTypeESBLE char = (SELECT DocType FROM ODRF WHERE objtype = 10000071 AND DocEntry = @DocEntryESBLE)
 
 IF EXISTS (SELECT OL.OcrCode FROM ODRF O INNER JOIN DRF1 OL ON O.DocEntry = ol.DocEntry
 WHERE o.objtype = 10000071 AND o.DocEntry = @DocEntryESBLE AND OL.OcrCode IS NULL)

	 BEGIN
	   SET @error = -9450
	   SET @error_message = 'Esboço - Não foi possível concluir. É necessário definir a Regra de Distribuição.'
	   SELECT @error, @error_message
	 END

END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Vinicius Palmagnani
-- Create date: 04/12/2020
-- Update Date: 
-- Description: Travar atualização de PN para vendedores/representantes com parceiro Cliente 
-- Documento: Parceiro de Negocios
-- GLPI ID: 10063
-- GLPI IG Atualização:
--------------------------------------------------------------------------------------------------------------------------------
/*IF (@object_type = '2') and (@transaction_type in ('U')) --'2' = Parceiro de Negocios
BEGIN

DECLARE @UserSign10063 int = (SELECT UserSign2 FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del)
DECLARE @Dep10063 int SET @Dep10063 = (SELECT Department FROM OUSR WHERE USERID = @UserSign10063)
DECLARE @CardType10063 char = (SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del)

IF(@Dep10063 = 1)	
	BEGIN
	
	IF(@CardType10063 <> 'L')
		BEGIN
			SET @error = -10063
			SET @error_message = 'Não é permitido atualizar os cadastros do PN.'		
			SELECT @error, @error_message
		END
	END
END

--------------------------------------------------------------------------------------------------------------------------------
--END */
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 10/11/20
-- Update Date: 
-- Description: Não permitir pedido de Vendas com parceiro Lead
-- Documento: Pedido de Vendas
-- GLPI ID:9768
-- GLPI IG Atualização:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A'))--'2' = Pedido de Vendas
BEGIN

DECLARE @CardType9768P char = (SELECT T1.CardType FROM ORDR T0
INNER JOIN OCRD T1 on T0.CardCode = T1.CardCode
WHERE T0.DocEntry = @list_of_cols_val_tab_del)

	IF(@CardType9768P ='L')
		BEGIN
			SET @error = -9768
			SET @error_message = 'Não é permitido enviar Pedido com cliente Lead.'		
			SELECT @error, @error_message
		END	
END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 10/11/20
-- Update Date: 
-- Description: Não permitir cotação de Vendas com parceiro Lead
-- Documento: Cotação de Vendas
-- GLPI ID:9768
-- GLPI IG Atualização:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '23') and (@transaction_type in ('A' ))--'2' = Cotação de vendas
BEGIN

DECLARE @CardType9768C char = (SELECT T1.CardType FROM OQUT T0
INNER JOIN OCRD T1 on T0.CardCode = T1.CardCode
WHERE T0.DocEntry = @list_of_cols_val_tab_del)

	IF(@CardType9768C ='L')
		BEGIN
			SET @error = -9768
			SET @error_message = 'Não é permitido enviar Cotação com cliente Lead.'		
			SELECT @error, @error_message
		END	
END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 10/11/20
-- Update Date: 
-- Description: Travar cadastro de pn feito por vendedores sem Nome, telefone, email e cnpj 
-- Documento: Parceiro de Negocios
-- GLPI ID:9768
-- GLPI IG Atualização:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '2') and (@transaction_type in ('A','U'))--'2' = Parceiro de NEgocios
BEGIN

DECLARE @UserSign9768 int = (SELECT UserSign FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del)

DECLARE @Dep9768 int SET @Dep9768 = (SELECT Department FROM OUSR WHERE USERID = @UserSign9768)

DECLARE @CardName9768 NVARCHAR(MAX) = (select CardName from OCRD where CardCode = @list_of_cols_val_tab_del)

DECLARE @Telefone9768 NVARCHAR(MAX) = (select Phone1 from OCRD where CardCode = @list_of_cols_val_tab_del)
DECLARE @Email9768 NVARCHAR(MAX) = (select E_mail from OCRD where CardCode = @list_of_cols_val_tab_del)
DECLARE @CNPJ9768 NVARCHAR(MAX) = (SELECT DISTINCT  T1.TaxId0 FROM OCRD T0 
									INNER JOIN CRD7 T1 ON T0.CardCode = T1.CardCode AND T0.ShipToDef = T1.Address
									WHERE T0.CardCode = 'C001965' AND T1.TaxId0 IS NOT NULL)
DECLARE @UserPortal9768 INT
SET @UserPortal9768 = (SELECT T1.Department
							FROM OUSR T1
							WHERE T1.USER_CODE IN(SELECT T0.U_AHS_SapUserCode
													FROM OCRD T0
													WHERE T0.CardCode = @list_of_cols_val_tab_del))

IF(@UserPortal9768 <> 17) ----EQUIPE DE COMPRAS(SUPRIMENTO)
BEGIN

	IF(@Dep9768 = 1)	
	BEGIN
	
		IF(@CardName9768 is null OR @CardName9768 ='')
			BEGIN
				SET @error = -9768
				SET @error_message = 'Campo NOME é obrigatório. Verifique!.'		
				SELECT @error, @error_message
			END
		IF(@Telefone9768 is null OR @Telefone9768 ='')
			BEGIN
				SET @error = -9768
				SET @error_message = 'Campo TELEFONE é obrigatório. Verifique!.'		
				SELECT @error, @error_message
			END
		IF(@Email9768 is null OR @Email9768 ='')
			BEGIN
				SET @error = -9768
				SET @error_message = 'Campo E-MAIL é obrigatório. Verifique!.'		
				SELECT @error, @error_message
			END
		IF(@CNPJ9768 is null OR @CNPJ9768 ='')
			BEGIN
				SET @error = -9768
				SET @error_message = 'Campo CNPJ é obrigatório. Verifique!.'		
				SELECT @error, @error_message
			END	
		END	

	END

END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 03/11/2020
-- Update Date: 
-- Description: Campos Grupo UF Cliente e Grupo fornecedores são obrigatorios
-- Documento: Parceiro de Negocios
-- GLPI ID:9709
-- GLPI IG Atualização:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '2') and (@transaction_type in ('A','U'))--'2' = Parceiro de NEgocios
BEGIN


DECLARE @CardType9709 char = (SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del)
DECLARE @GruCli NVARCHAR(MAX) = (SELECT U_MW_GRUCLI FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del)
DECLARE @GruFor NVARCHAR(MAX) = (SELECT U_MW_GRUFOR FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del)
DECLARE @UserPortal9709 INT
SET @UserPortal9709 = (SELECT T1.Department
							FROM OUSR T1
							WHERE T1.USER_CODE IN(SELECT T0.U_AHS_SapUserCode
													FROM OCRD T0
													WHERE T0.CardCode = @list_of_cols_val_tab_del))

IF(@UserPortal9709 <> 17) ----EQUIPE DE COMPRAS(SUPRIMENTO)
BEGIN
	IF(@CardType9709 = 'C' AND (@GruCli is null OR @GruCli ='' OR @GruCli = 'DEFINIR'))	
		BEGIN
			SET @error = -9709
			SET @error_message = 'O preenchimento do campo Grupo UF de Cliente é Obrigatório. Verifique!.'		
			SELECT @error, @error_message
		END	
	ELSE IF(@CardType9709 = 'S' AND (@GruFor is null OR @GruFor ='' OR @GruFor = 'DEFINIR'))	
		BEGIN
			SET @error = -9709
			SET @error_message = 'O preenchimento do campo Grupo Fornecedores é Obrigatório. Verifique!.'		
			SELECT @error, @error_message
		END	
	END
END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------
---- Author:Henrique Truyts
---- Create date: 21/10/2020
---- Update Date: 
---- Description: Trava para evitar alteração da OC em caso de divergencias de quantidade da oc com o pedido
---- Documento: Ordem de Carga
---- GLPI ID:9173
---- GLPI IG Atualização: 15004
----------------------------------------------------------------------------------------------------------------------------------
--IF (@object_type = 'BIM_ORDEMCARGA') and (@transaction_type in ('A','U'))--'2' = Ordem de Carga
--BEGIN	
--	IF EXISTS (
--	----COMPARAÇÂO ENTRE TOTAIS DA OC E TOTAIS DOS PEDIDOS DA OC
--	----SE O CAMPO DIFERENÇA FOR MAIOR QUE ZERO DEVE-SE REFAZER A OC
--	SELECT *FROM (
--		SELECT 
--			T100.U_Codigo,SUM(T100.U_Quantidade_Pedido) 'Qtd OC',
--			(--totais do pedido
--			SELECT 
--				SUM(T1.Quantity)
--			FROM ORDR T0
--			INNER JOIN RDR1 T1 on T0.DocEntry = T1.DocEntry
--			WHERE CANCELED = 'N' AND T1.U_OC_num = T100.DocEntry AND ItemCode = U_Codigo
--			GROUP BY T1.ItemCode
--			)'Totais do Pedido',
--			SUM
--				(U_Quantidade_Pedido) -
--				(--totais do pedido
--				SELECT 
--					SUM(T1.Quantity)
--				FROM ORDR T0
--				INNER JOIN RDR1 T1 on T0.DocEntry = T1.DocEntry
--				WHERE CANCELED = 'N' AND T1.U_OC_num = T100.DocEntry AND ItemCode = U_Codigo
--				GROUP BY T1.ItemCode
--			)'Diferença'
--		FROM [@BIM_ORDEMCARGA_1]  T100
--		WHERE T100.DocEntry =  @list_of_cols_val_tab_del
--		GROUP BY T100.U_Codigo,T100.DocEntry
--	)A WHERE Diferença > 0

--	)
--	BEGIN
--		SET @error = -9173
--		SET @error_message =  'Divergência entre as quantidades da OC e do pedido, favor refazer a OC!'
--		SELECT @error, @error_message
--	END	
--END
----------------------------------------------------------------------------------------------------------------------------------
----END
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 25/01/2018
-- Update Date: 13/08/2020
-- Update Date: 21/12/2023
-- Description:	PREENCHIMENTO DOS CAMPOS DE OC NA ENTREGA
-- Description: 14/12/2023 - Atualizado para colocarmos informação de horario de recebimento do parceiro no pedido.
-- Documentos: Entrega
-- GLPI ID:4103
---- GLPI ID Atualizações:9231
---- GLPI ID Atualizações:16244
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '15') and (@transaction_type in ('A','U'))--'15' = ENTREGA
BEGIN
IF EXISTS((SELECT *FROM (
		SELECT 
			T0.U_OC_NUM ,T0.DocEntry,T0.U_dtPreventregainicial,T0.U_dtPreventregafinal,T0.U_Status
		FROM
			DLN1 T0 
		WHERE 
			T0.DocEntry = @list_of_cols_val_tab_del AND U_Status <>'Liberada')A))
	BEGIN
			SET @error = -4103
			SET @error_message = 'OC não está liberada para a Entrega. Verifique.'
			SELECT @error, @error_message			
	END
	IF ((SELECT Count(*)FROM    (
		SELECT 
			T0.U_OC_NUM ,T0.DocEntry,T0.U_dtPreventregainicial,T0.U_dtPreventregafinal,T0.U_Status
		FROM
			DLN1 T0 
		WHERE 
			T0.DocEntry = @list_of_cols_val_tab_del
		GROUP BY 
			T0.U_OC_NUM,T0.DocEntry,T0.U_dtPreventregainicial,T0.U_dtPreventregafinal,T0.U_Status) A) <> 1)
	BEGIN
			SET @error = -4103
			SET @error_message = 'Existe linhas da Entrega sem alocação de OC ou com OC distintas. Verifique!'
			SELECT @error, @error_message			
	END
	ELSE IF((SELECT T0.U_OC_NUM FROM DLN1 T0 WHERE T0.DocEntry = @list_of_cols_val_tab_del GROUP BY T0.U_OC_NUM ) IS NOT NULL)
	BEGIN
			DECLARE @DocEntryOC NVARCHAR (254) = (SELECT T0.U_OC_NUM FROM DLN1 T0 WHERE DocEntry = @list_of_cols_val_tab_del and VisOrder = 0)

--ALTERAÇÃO REALIZADA AQUI
--UPDATE ENTREGA
	UPDATE ODLN SET 
		U_OC_NUM = (SELECT T0.U_OC_NUM FROM DLN1 T0 WHERE DocEntry = @list_of_cols_val_tab_del and VisOrder = 0),
		U_dtPreventregainicial = (SELECT T0.U_dtPreventregainicial FROM DLN1 T0 WHERE DocEntry = @list_of_cols_val_tab_del and VisOrder = 0),
		U_dtPreventregafinal = (SELECT T0.U_dtPreventregafinal FROM DLN1 T0 WHERE DocEntry = @list_of_cols_val_tab_del and VisOrder = 0),
		U_Status = (SELECT T0.U_Status FROM DLN1 T0 WHERE DocEntry = @list_of_cols_val_tab_del and VisOrder = 0),
		Header = ('Pedido: '+ 
	(SELECT Convert(NVarchar(MAX),BaseEntry) FROM DLN1 WHERE DocEntry = @list_of_cols_val_tab_del and VisOrder = 0) +
			', Oc: ' + (SELECT T0.U_OC_NUM FROM DLN1 T0 WHERE DocEntry = @list_of_cols_val_tab_del and VisOrder = 0)+ char(13) + 
			'Pn: ' + (SELECT CardCode FROM ODLN WHERE DocEntry = @list_of_cols_val_tab_del) + ',' + (SELECT [dbo].[PNHorarioEntrega]((SELECT CardCode FROM ODLN WHERE DocEntry = @list_of_cols_val_tab_del))) + ', Entr: ' + (SELECT Convert(NVARCHAR(MAX),DocNum) FROM ODLN WHERE DocEntry = @list_of_cols_val_tab_del) +char(13) + 
		(SELECT CASE WHEN ( U_LocalEntregaLabel IS NOT NULL AND U_LocalEntregaLabel<>'') THEN (
		SELECT 'Local de Entrega:'+ 
		CASE WHEN U_tipoLogradouro IS NOT NULL THEN U_tipoLogradouro ELSE '' END +' '+ 
		CASE WHEN U_Logradouro IS NOT NULL THEN U_Logradouro ELSE '' END +','+ 
		CASE WHEN U_Numero IS NOT NULL THEN U_Numero ELSE '' END +' -'+
		CASE WHEN U_Bairro IS NOT NULL THEN U_Bairro ELSE '' END +' - '+
		CASE WHEN U_Municipio IS NOT NULL THEN U_Municipio ELSE '' END +'/'+
		CASE WHEN U_Estado IS NOT NULL THEN U_Estado ELSE '' END+' - CEP '+
		CASE WHEN U_Cep IS NOT NULL THEN  U_Cep ELSE '' END
		FROM [@RAL_LOCALENTREGA1] t0
		INNER JOIN [@RAL_LOCALENTREGA] T1 On t0.DocEntry = T1.DocEntry
		WHERE U_IDEndereco = (
		SELECT U_LocalEntregaLabel FROM ORDR WHERE DocEntry = (SELECT BaseEntry FROM DLN1 WHERE DocEntry =@list_of_cols_val_tab_del and VisOrder = 0))	
		 AND T1.U_CardCode = (
		SELECT cardCode FROM ORDR WHERE DocEntry = (SELECT BaseEntry FROM DLN1 WHERE DocEntry =@list_of_cols_val_tab_del and VisOrder = 0))
		GROUP BY U_IDEndereco ,U_tipoLogradouro ,U_Logradouro,U_Numero,U_Bairro,U_Municipio,U_Estado,U_Cep
		) ELSE '' END		
		 FROM ORDR WHERE DocEntry = (SELECT BaseEntry FROM DLN1 WHERE DocEntry = @list_of_cols_val_tab_del and VisOrder = 0))+ char(13)+
		(SELECT CASE WHEN Header IS NOT NULL THEN Convert(NVARCHAR(MAX),Header) ELSE '' END FROM ODLN WHERE DocEntry = @list_of_cols_val_tab_del))		
				WHERE DocEntry = @list_of_cols_val_tab_del;



			UPDATE DLN12 SET Carrier = (SELECT U_Transportadora FROM [@BIM_ORDEMCARGA] WHERE DocEntry =  @DocEntryOC),
						 QOP = (SELECT SUM(T0.QUANTITY) FROM DLN1 T0 WHERE T0.DocEntry = @list_of_cols_val_tab_del),
						 PackDesc =  (SELECT dbo.DescricaoEmbalagensEntrega(@list_of_cols_val_tab_del)),
						 Brand='Ruston',
						 grsweight = (SELECT SUM (CAST(REPLACE(t1.U_MW_PESO_BRUTO,',','.') AS float) * T0.QUANTITY)
						 FROM DLN1 T0  INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode WHERE T0.[DocEntry] = @list_of_cols_val_tab_del),
						 vehicle = (SELECT U_Placa FROM [@RAL_Veiculo] WHERE DocEntry = (SELECT U_Veiculo FROM [@BIM_ORDEMCARGA] WHERE DocEntry =  @DocEntryOC)),
						 Incoterms = (SELECT U_Frete FROM [@BIM_ORDEMCARGA] WHERE DocEntry =  @DocEntryOC),
						 VidState = (SELECT  U_Estado_Veiculo FROM [@RAL_Veiculo] WHERE DocEntry = (SELECT U_Veiculo FROM [@BIM_ORDEMCARGA] WHERE DocEntry =  @DocEntryOC))
						 WHERE DocEntry = @list_of_cols_val_tab_del;

			UPDATE ODLN SET 
							U_EmailEnvDanfe = (SELECT T2.E_Mail
												FROM ODLN T0
												INNER JOIN DLN12 T1 ON T1.DocEntry = T0.DocEntry
												INNER JOIN OCRD T2 ON T2.CardCode = T1.Carrier
												WHERE T0.DocEntry = @list_of_cols_val_tab_del)
				WHERE DocEntry = @list_of_cols_val_tab_del;

	END

END;--END GERAL
----------------------------------------------------------------------------------------------------------------------------------
---- END
----------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
---- Author: SPS
---- Create date: 02/07/2020
---- Description: Barrar no coletor as ocorrências de duplicidade
---- Documentos:  Entrada de mercadorias
---- GLPI ID: 8984
---- GLPI ID Atualizações:
-------------------------------------------------------------------------------------------------------------------------

if(@object_type = 'R_IA' AND @transaction_type IN ('A','U'))
begin

declare @count int= 0
declare @tipoPallet int = 0

select @tipoPallet = U_TpPallet from [@RAL_IA]
where code = @list_of_cols_val_tab_del

if(@tipoPallet = 0)
begin

	select @count = COUNT(DocEntry) 
	FROM OIGN 
	WHERE U_NumIA = @list_of_cols_val_tab_del
	
	-- DIEGO 27/07/2022
	--if(@count > 1)
	--begin
	--	set @error = -8984
	--	set @error_message = 'Pallet já possui uma entrada'
	--end

end

end 


-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
---- Author: Douglas Dias - SPS
---- Create date: 02/06/2020
---- Description: Travar OP sem preenchimento Custo componente item real
---- Documentos:  Ordem de Produção
---- GLPI ID: 8700
---- GLPI ID Atualizações:
-------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '202') and (@transaction_type in ('U'))--'202' = Ordem de Produção
BEGIN
DECLARE @OPStatusF NVarchar(1) SET @OPStatusF = (select Status From OWOR where DocEntry = @list_of_cols_val_tab_del)

IF(@OPStatusF = 'L')
BEGIN
	IF NOT EXISTS(SELECT * FROM OWOR WHERE DocEntry IN (select top 1 BaseEntry from IGE1 where BaseEntry = @list_of_cols_val_tab_del)) --VERIFICA SE A OP ESTÁ SENDO FECHADA SEM SAÍDA DE INSUMO (QUE APLICA O CUSTO DO ITEM)
	BEGIN
		SET @error = -8700
		SET @error_message = 'É obrigatório o lançamento da Saída de Insumo para contabilizar o Custo componente item!'
		SELECT @error, @error_message
	END
END

END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 28/05/2020
-- Update Date: 30/04/2022
-- Description:	Travar Local de Entrega duplicado por parceiro de negocios
-- Documentos:  Local de Entrega
-- GLPI ID: 8813
-----------------------------------------------------------------------------------------------------------------------
IF (@object_type = 'CadLocalEntrega') and (@transaction_type in ('A'))--'CadLocalEntrega' = Local de Entrega
BEGIN
DECLARE @CodigoCliente NVARCHAR(10) = (select U_CardCode from [@RAL_LOCALENTREGA] WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Filial8813 numeric = (select U_BPLId from [@RAL_LOCALENTREGA] WHERE DocEntry = @list_of_cols_val_tab_del)

		IF EXISTS(
			select *from [@RAL_LOCALENTREGA] where U_BPLId = @Filial8813 AND U_CardCode = @CodigoCliente AND DocEntry <>@list_of_cols_val_tab_del
			)
			BEGIN
				SET @error = -8813
				SET @error_message = 'Não é possivel concluir! Já existe cadastro de local de entrega para esse parceiro!'
				SELECT @error, @error_message	
			END
	
END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 16/08/2019
-- Update Date: 28/02/2020
-- Description:	Preencher informações de Classificação e lote na Linha da entrega - Informações vão para NF - WMS
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '15') and (@transaction_type in ('A','U'))--'15' =ENTREGA 

BEGIN
	DECLARE @ContadorEnt2 int = 0	
	DECLARE @ClassificacaoEnt2 nvarchar (255)
	DECLARE @DocEntryEnt2 int = @list_of_cols_val_tab_del
	DECLARE @QtyLinesEnt2  int = (SELECT MAX(LineNum) FROM DLN1 WHERE DocEntry =  @DocEntryEnt2)	
	
	WHILE(@ContadorEnt2 < @QtyLinesEnt2+1)

		BEGIN
			--SET @ClassificacaoEnt2 = (SELECT [dbo].[Preench_LoteClassif_Entrega](@DocEntryEnt2,@ContadorEnt2))

			SET @ClassificacaoEnt2 = (SELECT [dbo].[Preench_LotepeloPick_Entrega](@DocEntryEnt2,@ContadorEnt2)) ---REMOVIDO 02/12/2025

			if(@ClassificacaoEnt2 is null OR @ClassificacaoEnt2 = '')
			BEGIN

				SET @ClassificacaoEnt2 = (SELECT [dbo].[Preench_LoteClassif_Entrega](@DocEntryEnt2,@ContadorEnt2))

			END

			if (@ClassificacaoEnt2 is not null AND @ClassificacaoEnt2 <> '')
				BEGIN
				
					UPDATE DLN1	SET U_SKILL_InfAdItem = @ClassificacaoEnt2 WHERE DocEntry = @DocEntryEnt2 AND LineNum =  @ContadorEnt2					
					
				END;
		
			SET @ContadorEnt2 = @ContadorEnt2 + 1
		END;

END;--END GERAL



--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create Date: 21/01/2020
-- Update Date: 
-- Description:	Bloquear campos Rendimento
-- GLPI ID: 8272
-- GLPI ID Atualizações:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = 'Rendimento') and (@transaction_type in ('A','U'))-- RENDIMENTOS
BEGIN 
--Validar BBranco - 
	IF EXISTS(select Code,U_BBranco From [@RA_RENDIMENTO] where U_BBranco > 99.99 
	AND code = @list_of_cols_val_tab_del)
	BEGIN
		SET @error = -8272
		SET @error_message = 'BBranco não pode ser maior que 99.99'
		SELECT @error, @error_message
	END
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
---- Author: Vinicius Palmagnani 
---- Create date: 14/01/2020
---- Update date: 21/07/2020
---- Description: Travar documento sem preenchimento Nº Requisição/Nº Chamado
---- Documentos:  Saída de Mercadorias
---- GLPI ID: 8239
---- GLPI ID Atualizações:9070
-------------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'60') and (@transaction_type in ('A'))--N'60' = OIGE
BEGIN
	DECLARE @NumReq VARCHAR(MAX) = ''
	DECLARE @NumCha VARCHAR(MAX) = ''
	DECLARE @QtyLines8239  int = (SELECT MAX(LineNum) FROM IGE1 WHERE DocEntry = @list_of_cols_val_tab_del)	
	DECLARE @Cont8239 int = 0

	IF EXISTS(SELECT * FROM 
			  OIGE T0 INNER JOIN IGE1 T1 ON T1.DocEntry = T0.DocEntry
			  WHERE T0.DocEntry = @list_of_cols_val_tab_del AND T0.DataSource <> 'A' AND T0.RelatedTyp <> 59
					AND T1.WhsCode = '02.07' AND T1.BaseType <> 202)
		BEGIN

			WHILE (@Cont8239 <= @QtyLines8239)
			BEGIN

			IF EXISTS (SELECT * FROM IGE1 
			WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum = @Cont8239)
				BEGIN

					SET @NumReq = (SELECT U_NumRequisicao FROM IGE1 
					WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum = @Cont8239)

					SET @NumCha = (SELECT U_NumChamado FROM IGE1 
					WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum = @Cont8239)

						IF (@NumReq is null or @NumReq = '')
						BEGIN
							SET @error = -8239
							SET @error_message = 'O preenchimento do campo "Nº Requisição" é obrigatório'
							SELECT @error, @error_message
						END

						IF (@NumCha is null or @NumCha = '')
						BEGIN
							SET @error = -8239
							SET @error_message = 'O preenchimento do campo "Nº Chamado" é obrigatório'
							SELECT @error, @error_message
						END
				END
			SET @Cont8239 = @Cont8239 +1
			END
		END
END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
---- Author: Henrique Truyts 
---- Create date: 06/01/2020
---- Update Date: 
---- Description: Atualizar o campo Comissao do assistente na Linha do Pedido 
----              Com base no cadastro de comissao do assistente
---- Documentos:  Pedido de Venda
---- GLPI ID: 7452
---- GLPI ID Atualizações:

--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas

BEGIN
	DECLARE @ContAssist int = 0	
	DECLARE @ComissaoAssistente float = 0
	DECLARE @DocEntryAssist int = @list_of_cols_val_tab_del
	DECLARE @CardCodeComAssist Nvarchar (20) = (SELECT CardCode FROM ORDR WHERE DocEntry = @DocEntryAssist)
	DECLARE @ComAssistPN float = 0
	DECLARE @QtyLinesAssist  int = (SELECT MAX(LineNum) FROM rdr1 WHERE DocEntry = @DocEntryAssist)	


	Set @ComAssistPN = (SELECT Coalesce(U_ComissaoAssistente,0) FROM OCRD WHERE CardCode = @CardCodeComAssist)
		
	WHILE(@ContAssist < @QtyLinesAssist+1)
		BEGIN
			IF(@ComAssistPN is not null AND @ComAssistPN >0)
				BEGIN
					SET @ComissaoAssistente = @ComAssistPN
				END
			ELSE 
				BEGIN
					SET @ComissaoAssistente = (
						SELECT 
							T0.U_Comissao
						FROM	
						[@RAL_ComAssist1] T0
						INNER JOIN [@RAL_ComAssist] T1 ON T1.Code = T0.Code
						INNER JOIN OSLP T2 ON T2.SlpCode = T1.U_SlpCode
						INNER JOIN OCRD T5 ON T5.U_Assistente = T2.SlpName
						INNER JOIN ORDR T3 ON T3.CardCode = T5.CardCode  
						INNER JOIN RDR1 T4 ON T4.DocEntry = T3.DocEntry AND T0.U_ItemCode = T4.ItemCode
						WHERE T3.DocNum = @DocEntryAssist AND T4.LineNum = @ContAssist)
				END

			if (@ComissaoAssistente > 0)
				BEGIN
					UPDATE RDR1	SET U_ComissaoAssistente = @ComissaoAssistente WHERE DocEntry = @DocEntryAssist AND LineNum =  @ContAssist
					
				END;
		
			SET @ContAssist = @ContAssist + 1
		END;
		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 04/04/2019
-- Update date: 10/12/2019
-- Update date: 05/10/2020
-- Description:	Gravar o Preço de Lista do PN ao adicionar o pedido
-- GLPI ID:6659
-- GLPI ID Atualizações:8127
-- GLPI ID Atualizações: 9608 - Aplicar desconto no Preço de Lista
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas

BEGIN
	
DECLARE @PrecoDeLista Numeric(10,2) = 0
DECLARE @CodigoItem6659 NVARCHAR(10)
DECLARE @TotalLinhas6659 Numeric = (SELECT Max(LineNum) FROM RDR1 WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Cont6659 Numeric = 0
DECLARE @PrecoExistente Numeric = 0
DECLARE @Desconto9608 NUMERIC = 0

WHILE(@Cont6659 < @TotalLinhas6659 + 1)
	BEGIN
		IF EXISTS( SELECT *FROM RDR1 WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum = @Cont6659)
		BEGIN
			SELECT 
			@CodigoItem6659 = T1.ItemCode,
			@PrecoDeLista  = T5.price,
			@PrecoExistente = (case when T1.U_PrecoDeLista is null then 0 else T1.U_PrecoDeLista end),
			@Desconto9608 = T1.DiscPrcnt
			FROM ORDR T0
			INNER JOIN RDR1 T1 ON T0.DocEntry = T1.DocEntry 
			INNER JOIN OCRD T3 ON T0.CardCode = T3.CardCode
			INNER JOIN OPLN T4 ON T3.ListNum = T4.ListNum
			INNER JOIN ITM1 T5 ON T4.ListNum = T5.PriceList AND T1.ItemCode = T5.ItemCode
			WHERE  T0.DocEntry = @list_of_cols_val_tab_del AND T1.LineNum = @Cont6659

			IF ( (@CodigoItem6659  is not null AND @CodigoItem6659 <> '')
					 AND (@PrecoDeLista is not null AND @PrecoDeLista > 0)
						AND (@PrecoExistente is null OR @PrecoExistente = 0))
				BEGIN
					UPDATE RDR1	SET U_PrecoDeLista = @PrecoDeLista - (@PrecoDeLista * @Desconto9608 / 100)
						WHERE DocEntry = @list_of_cols_val_tab_del AND ItemCode = @CodigoItem6659 AND LineNum =  @Cont6659					
				END;

		END 
		SET @Cont6659 = @Cont6659 + 1
	END;
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 21/11/2017
-- Update Date: 11/11/2019
-- Description:	TRAVA DE CAMPOS ATENDIMENTO
-- GLPI ID: 3873,7718
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'DWU_atend') and (@transaction_type in ('A'))--N'C1_atend' = ATENDIMENTO
BEGIN
--@VERDADEIRO > 0 se for igual a 2 ou 7, e o usuário de criação do Atendimento for do departamento "Vendas"


DECLARE @TotalLinhasAtend INT = (SELECT COUNT(*)FROM [@DWU_ATEND_ITENS] WHERE DocEntry = @list_of_cols_val_tab_del) 
DECLARE @ContAtend int = 0

	IF EXISTS( SELECT  *FROM [@DWU_ATENDIMENTO] T0 
							INNER JOIN OUSR T1 ON T0.UserSign = T1.USERID
							WHERE T1.Department = 1 AND T0.U_CodTipoAtendimento IN (2,7) 
							AND T0.DocEntry = @list_of_cols_val_tab_del )
	BEGIN
		WHILE(@ContAtend < @TotalLinhasAtend )
		BEGIN
			IF EXISTS(SELECT U_Motivo FROM [@DWU_ATEND_ITENS] WHERE 
				DocEntry = @list_of_cols_val_tab_del AND LineId =@ContAtend +1 AND (U_MOTIVO IS NULL OR U_MOTIVO ='')  )
			BEGIN
				SET @error = -1
				SET @error_message = 'Obrigatório preencher o campo MOTIVO na aba dos Itens !'
				SELECT @error, @error_message
			END--END IF U_MOTIVO
			IF EXISTS(SELECT U_Ref1 FROM [@DWU_ATEND_ITENS] WHERE 
				DocEntry = @list_of_cols_val_tab_del AND LineId =@ContAtend +1 AND (U_Ref1 IS NULL OR U_Ref1 ='') )
			BEGIN
				SET @error = -1
				SET @error_message = 'Obrigatório preencher o campo LOTE na aba dos Itens !'
				SELECT @error, @error_message
			END--END IF U_Ref1
			IF EXISTS(SELECT U_Ref2 FROM [@DWU_ATEND_ITENS] WHERE 
					DocEntry = @list_of_cols_val_tab_del AND LineId =@ContAtend +1 AND (U_Ref2 IS NULL OR U_Ref2 ='') )
			BEGIN
				SET @error = -1
				SET @error_message = 'Obrigatório preencher o campo DATA FABRICAÇÃO na aba dos Itens !'
				SELECT @error, @error_message
			END--END IF U_Ref2 
			IF EXISTS(SELECT U_Ref3 FROM [@DWU_ATEND_ITENS] WHERE 
				DocEntry = @list_of_cols_val_tab_del AND LineId =@ContAtend +1 AND (U_Ref3 IS NULL OR U_Ref3 ='') )
			BEGIN
			    SET @error = -1
				SET @error_message = 'Obrigatório preencher o campo DATA VALIDADE na aba dos Itens !'
				SELECT @error, @error_message
			END--END IF U_Ref3
			SET @ContAtend = @ContAtend +1
		END --END WHILE
	END--end if verdadeiro
	
END;
--------------------------------------------------------------------------------------------------------------------------------
--END - TRAVA DE CAMPOS ATENDIMENTO CRM- ID 3873
--------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
---- Author: Henrique Truyts 
---- Create date: 11/10/2019
---- Update Date: 
---- Description: Travar OP sem Classificação de OP
---- Documentos:  Ordem de Produção
---- GLPI ID: 7790
---- GLPI ID Atualizações:
-------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '202') and (@transaction_type in ('U'))--'202' = Ordem de Produção
BEGIN
DECLARE @OPStatus NVarchar(1) SET @OPStatus = (select Status From OWOR where DocEntry = @list_of_cols_val_tab_del)

IF(@OPStatus = 'L')
BEGIN
	IF EXISTS(select Status From OWOR where DocEntry = @list_of_cols_val_tab_del and (U_ClassOP is null or U_ClassOP =''))
	BEGIN
		SET @error = -7790
		SET @error_message = 'É obrigatório o preenchimento do campo Classificação de OP, verifique!'
		SELECT @error, @error_message
	END
END

END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------
---- Author:		Henrique Truyts 
---- Create date: 29/01/2018
---- Update Date: 27/09/2019
---- Description: Travar Documentos sem RA preenchido 
---- Documentos:  Solicitação de Compra,Oferta de Compra, Saida de mercadorias
---- GLPI ID: 6345
---- GLPI ID Atualizações: 9451
---- Description: Retirar a trava de RA dos documentos saída de mercadoria e entrada de mercadoria em 13/09/2020
-------------------------------------------------------------------------------------------------------------------------
--IF (@object_type = '1470000113') and (@transaction_type in ('A'))--'1470000113' = Solicitação de Compra
--BEGIN
--	IF EXISTS(SELECT * FROM PRQ1 WHERE DocEntry = @list_of_cols_val_tab_del AND (U_RAL_CadastroRA IS NULL OR  U_RAL_CadastroRA = ''))
--	BEGIN
--		SET @error = -6345
--		SET @error_message = 'É obrigatório o preenchimento do campo Cadastro RA, verifique!'
--		SELECT @error, @error_message
--	END
--END
------------------------------OFERTA DE COMPRA
--IF (@object_type = '540000006') and (@transaction_type in ('A'))--'540000006' = Oferta de Compra
--BEGIN
--	IF EXISTS(SELECT * FROM PQT1 WHERE DocEntry =@list_of_cols_val_tab_del  AND (U_RAL_CadastroRA IS NULL OR  U_RAL_CadastroRA = ''))
--	BEGIN
--		SET @error = -6345
--		SET @error_message = 'É obrigatório o preenchimento do campo Cadastro RA, verifique!'
--		SELECT @error, @error_message
--	END
--END
--------------------------------SAÍDA DE MERCADORIAS
--IF (@object_type = '60') and (@transaction_type in ('A'))--'60' = Saida de mercadorias
--BEGIN
--	IF EXISTS(SELECT * FROM IGE1 WHERE BaseType <>202 AND DocEntry =@list_of_cols_val_tab_del  AND (U_RAL_CadastroRA IS NULL OR  U_RAL_CadastroRA = ''))
--	BEGIN
--		SET @error = -6345
--		SET @error_message = 'É obrigatório o preenchimento do campo Cadastro RA, verifique!'
--		SELECT @error, @error_message
--	END
--END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 31/01/2017
-- Update date: 23/09/2019
-- Update date: 15/05/2024
-- Description:	Travar Solicitações de compras com data necessaria inferior ao prazo de solicitação
-- Bruno pediu para adicionar a ação ao atualizar em 23/09/2019
-- DescriptionUpdate: acrescentado nova regra para que o colaborador william (compras) não caia na regra e consiga atualizar o campo de status da solicitacao
-- Documentos: Solicitação de Compras
-- GLPI ID : 4768
-- GLPI Update ID : 16926
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '1470000113') and (@transaction_type in ('A','U'))--'1470000113' = Solicitação de Compras
BEGIN
DECLARE @TotLinhas4768 Numeric SET @TotLinhas4768 =  (SELECT Count(*) FROM PRQ1 WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Cont4768 Numeric = 0
DECLARE @ReqDate4768 DATETIME = null
DECLARE @PrazoDias Numeric = 0
DECLARE @DataAtual Datetime SET @DataAtual = (SELECT GETDATE())
DECLARE @Urgente Char(1) SET @Urgente =(SELECT U_Ral_Urgente FROM OPRQ WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @User16926 Varchar(254)

SET @User16926 = (SELECT T0.UserSign2
				 FROM OPRQ T0
				 WHERE T0.DocEntry = @list_of_cols_val_tab_del)

	IF (@User16926 <> 230)
	BEGIN

		IF(@Urgente = 'N')
		BEGIN
		WHILE(@Cont4768 <@TotLinhas4768)
		BEGIN
			SET @ReqDate4768 = (SELECT PQTReqDate FROM PRQ1 WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum = @Cont4768)
		
			SET @PrazoDias = ISNULL(( SELECT U_RAL_Prazo FROM [@RAL_PrazoSolCompras] WHERE  U_RAL_GrupoItensID = 
				(SELECT ITMsGrpCod FROM OITM WHERE ItemCode = 
					(SELECT ItemCode FROM PRQ1 WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum = @Cont4768))),0)

			
					IF(@PrazoDias > 0 AND (@ReqDate4768 <(@DataAtual + @PrazoDias)))
					BEGIN
						SET @error = - 4768
						SET @error_message = 'O prazo mínimo para data necessária é '+Convert(Nvarchar,((@DataAtual + @PrazoDias)+1),103)+'. Verifique.'
						SELECT @error, @error_message
					END
			SET @Cont4768 = @Cont4768  +1
		END--END WHILE
		END--END IF
	END
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 19/01/2017
-- Update date: 17/08/2019
-- Description:	Atualizar o campo Classificação na Linha da NF Com ORIGEM ENTREGA
--------------------------------------------------------------------------------------------------------------------------------
--IF (@object_type = '13') and (@transaction_type in ('A','U'))--'13' = Nota Fiscal 

--BEGIN
--	DECLARE @ContadorEnt int = 0	
--	DECLARE @ClassificacaoEnt nvarchar (255)
--	DECLARE @DocEntryEnt int = @list_of_cols_val_tab_del
--	DECLARE @QtyLinesEnt  int = (SELECT MAX(LineNum) FROM INV1 WHERE DocEntry = @DocEntryEnt)	
--	DECLARE @BaseTypeENT int = (SELECT BaseType FROM INV1 WHERE DocEntry= @DocEntryEnt GROUP BY  BaseType)

--IF(@BaseTypeENT = 15)
--BEGIN
--	WHILE(@ContadorEnt < @QtyLinesEnt+1)
--		BEGIN
--			SET @ClassificacaoEnt = (SELECT [dbo].RAL_CLASSIFICACAO_ENTREGA(@DocEntryEnt,@ContadorEnt))

--			if  EXISTS(select *from inv1 WHERE DocEntry = @DocEntryEnt AND LineNum =  @ContadorEnt and (U_SKILL_InfAdItem is null OR Convert(nvarchar(max),U_SKILL_InfAdItem)=' / LT:'))
--			BEGIN
--				if (@ClassificacaoEnt is not null AND @ClassificacaoEnt <> '')
--				BEGIN
				
--					UPDATE INV1	SET U_SKILL_InfAdItem = @ClassificacaoEnt WHERE DocEntry = @DocEntryEnt AND LineNum =  @ContadorEnt					
					
--				END;
--			END

		
		
--			SET @ContadorEnt = @ContadorEnt + 1
--		END;
--END--END IF		
--END;--END GERAL
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 13/01/2017
-- Update Date: 13/08/2018
-- Description:	Atualizar o campo Classificação na Linha da NF
--------------------------------------------------------------------------------------------------------------------------------
--IF (@object_type = '13') and (@transaction_type in ('A','U'))--'13' = Nota Fiscal 

--BEGIN
--	DECLARE @Contador1 int = 0	
--	DECLARE @Classificacao nvarchar (255)
--	DECLARE @DocEntry1 int = @list_of_cols_val_tab_del
--	DECLARE @QtyLinesS  int = (SELECT MAX(LineNum) FROM INV1 WHERE DocEntry = @DocEntry1)	
--	DECLARE @BaseType int = (SELECT BaseType FROM INV1 WHERE DocEntry= @DocEntry1 GROUP BY  BaseType)

--IF(@BaseType<>15)
--BEGIN

--	WHILE(@Contador1 < @QtyLinesS+1)
--		BEGIN
--			SET @Classificacao = 
--			(
--			SELECT  
--	COALESCE(
--		(SELECT 
				
--		 CONCAT (' ',CL0.Name,'-',CL2.U_MW_TIPO,'-',CL2.U_MW_CLASSE,'- LT:',CL1.U_MW_LOTE,'- T:',CL2.U_MW_TIPO) as class
				
--			FROM
--				INV1 NFL
--				INNER JOIN IBT1 LL ON  NFL.DocEntry = LL.BaseEntry
--				AND NFL.LineNum  = LL.BaseLinNum       
--				AND NFL.ItemCode = LL.ItemCode
--				AND NFL.WhsCode  = LL.WhsCode
--				AND LL.BaseType  = NFL.ObjType
--				INNER JOIN OBTN L ON LL.BatchNum = L.DistNumber AND LL.ItemCode = L.ItemCode
--				INNER JOIN [@MW_CLASS] CL0 ON L.U_MW_CLASSIFICACAO = CL0.Name
--				INNER JOIN [@MW_CLAS1] CL1 ON CL0.Code = CL1.Code 
--				INNER JOIN [@MW_CLAS2] CL2 ON CL1.Code = CL2.Code
--			WHERE CL1.U_MW_VALIDADE >= GETDATE() AND NFL.DocEntry = @DocEntry1 and NFL.LineNum = @Contador1
--		 FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(MAX)'), '') AS Classificacao
--FROM (
--SELECT 		nfl.ItemCode,			
--		 CONCAT (CL0.Name,'-',CL2.U_MW_TIPO,'-',CL2.U_MW_CLASSE,'- LT:',CL1.U_MW_LOTE,'- T:',CL2.U_MW_TIPO) as class
				
--			FROM
--				INV1 NFL
--				INNER JOIN IBT1 LL ON  NFL.DocEntry = LL.BaseEntry
--				AND NFL.LineNum  = LL.BaseLinNum       
--				AND NFL.ItemCode = LL.ItemCode
--				AND NFL.WhsCode  = LL.WhsCode
--				AND LL.BaseType  = NFL.ObjType
--				INNER JOIN OBTN L ON LL.BatchNum = L.DistNumber AND LL.ItemCode = L.ItemCode
--				INNER JOIN [@MW_CLASS] CL0 ON L.U_MW_CLASSIFICACAO = CL0.Name
--				INNER JOIN [@MW_CLAS1] CL1 ON CL0.Code = CL1.Code 
--				INNER JOIN [@MW_CLAS2] CL2 ON CL1.Code = CL2.Code
--			WHERE CL1.U_MW_VALIDADE >= GETDATE() AND NFL.DocEntry = @DocEntry1 and NFL.LineNum = @Contador1
--)AS C
--Group by ItemCode

--			)

--			if (@Classificacao is not null AND @Classificacao <> '')
--				BEGIN
				
--					UPDATE INV1	SET U_SKILL_InfAdItem = @Classificacao WHERE DocEntry = @DocEntry1 AND LineNum =  @Contador1					
					
--				END;
		
--			SET @Contador1 = @Contador1 + 1
--		END;
--END--end if		
--END;--END GERAL
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 02/01/2017
-- Update Date: 07/08/2019
-- Description:	Atualizar os campos Macro, Micro,Desconto financeiro,Detalhes de entrega e Cidade com Base no cadastro de PN
-- Houve acrescimo do campo U_DescFinBP para ajustar o desconto financeiro no bankplus
-- GLPI ID:
-- GLPI ID Atualizações: 6708, 6468, 7373
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '17') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas
BEGIN
	DECLARE @CardCodeFromOrder NVarchar (20)
	DECLARE @Macro NVARCHAR (255)
	DECLARE @Micro NVARCHAR (255)
	DECLARE @Cidade NVARCHAR (255)
	DECLARE @DescontoFinanceiro Decimal(10,2) SET @DescontoFinanceiro = 0
	DECLARE @R_EntregaAgendada CHAR (1) SET @R_EntregaAgendada = 'N'
	DECLARE @R_Encarte  CHAR (1) SET @R_Encarte = 'N'
	DECLARE @DetalhesEntrega NVARCHAR (MAX)
	DECLARE @Paletizada  CHAR (1) SET @Paletizada = 'N'
	DECLARE @Batida  CHAR (1) SET @Batida = 'N'
	DECLARE @U_RAL_Reentrega  CHAR (1) SET @U_RAL_Reentrega = 'N'
	DECLARE @U_RAL_Retira  CHAR (1) SET @U_RAL_Retira = 'N'
	DECLARE @CaracteristicasEntregaPN NVARCHAR(MAX)

	SET @CardCodeFromOrder  = (SELECT CardCode FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)
	SET @Macro = (SELECT U_MW_MACRO FROM OCRD WHERE CardCode = @CardCodeFromOrder)
	SET @Micro = (SELECT U_MW_MICRO FROM OCRD WHERE CardCode = @CardCodeFromOrder)
	SET @Cidade = (SELECT U_MW_CIDADE FROM OCRD WHERE CardCode = @CardCodeFromOrder)
	SET @DescontoFinanceiro = (SELECT U_MW_DESFIN FROM OCRD WHERE CardCode = @CardCodeFromOrder)
	SET @Paletizada = (SELECT QryGroup22 FROM OCRD WHERE CardCode = @CardCodeFromOrder)
 	SET @Batida  = (SELECT QryGroup23 FROM OCRD WHERE CardCode = @CardCodeFromOrder)

	SET @R_Encarte = (SELECT U_R_Encarte FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)
	SET @R_EntregaAgendada = (SELECT U_R_EntregaAgendada FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)
	SET @U_RAL_Reentrega = (SELECT U_RAL_Reentrega FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)	
	SET @U_RAL_Retira = (SELECT U_RAL_Retira FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)
	SET @CaracteristicasEntregaPN = (select [dbo].[NomedasCaracteristicasPN](@CardCodeFromOrder) )

	IF(@R_EntregaAgendada = 'Y')
		BEGIN
			SET @DetalhesEntrega = 'AGENDADA '
		END
	IF(@R_Encarte = 'Y')
		BEGIN		
			SET @DetalhesEntrega = concat(@DetalhesEntrega,'ENCARTE ')
		END
	IF(@U_RAL_Reentrega = 'Y')
		BEGIN		
			SET @DetalhesEntrega = concat(@DetalhesEntrega,'REENTREGA ')
		END
	IF(@U_RAL_Retira = 'Y')
		BEGIN
			SET @DetalhesEntrega = concat(@DetalhesEntrega,'RETIRA ')
		END
	IF(@Batida = 'Y')
		BEGIN
			SET @DetalhesEntrega = concat(@DetalhesEntrega,'CARGA BATIDA ')
		END
	IF(@Paletizada = 'Y')
		BEGIN
			SET @DetalhesEntrega = concat(@DetalhesEntrega,'CARGA PALETIZADA ')
		END
	IF(@CaracteristicasEntregaPN is NOT null AND @CaracteristicasEntregaPN <> '')
	BEGIN
		SET @DetalhesEntrega = concat(@DetalhesEntrega,@CaracteristicasEntregaPN)
	END	

		BEGIN			
			UPDATE ORDR 
				SET  U_MW_MICRO = @Micro, U_MW_MACRO = @Macro, U_MW_CIDADE = @Cidade,
				 U_DescFinBP  = @DescontoFinanceiro,U_MW_DESCONTO  = @DescontoFinanceiro, U_RA_DetalhesEntrega = @DetalhesEntrega  WHERE DocEntry = @list_of_cols_val_tab_del
		END 

		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 22/07/2019
-- Update Date: 
-- Description: Bloquear Função Copiar para Pedido a partir da cotação
-- Documento: Pedido de Vendas
-- GLPI ID: 7321
-- GLPI IG Atualização:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A'))--'17' = Pedido de Vendas
BEGIN

DECLARE @UserSign27321 Nvarchar(10) = (SELECT  UserSign2 FROM ORDR where docentry = @list_of_cols_val_tab_del)

DECLARE @Dep7321 int SET @Dep7321 = (SELECT Department FROM OUSR WHERE USERID = @UserSign27321)

IF EXISTS (SELECT BaseEntry FROM RDR1 WHERE DocEntry = @list_of_cols_val_tab_del AND BaseEntry IS NOT NULL)
BEGIN
	IF(@Dep7321 = 1)--Departamento de vendas
	BEGIN
		SET @error = -7321
		SET @error_message = 'A ação "Copiar para Pedido" não é permitida!'
		SELECT @error, @error_message
	END				
			
END--END IF EXISTS
END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 27/06/2019
-- Update date: 07/10/2020
-- Description:	Gravar o Preço de Lista do PN ao adicionar o pedido
-- GLPI ID:7208
-- GLPI ID Atualizações:9608 - Aplicar desconto no Preço de Lista
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '14') and (@transaction_type in ('A','U'))--'14' = Dev NF de saida

BEGIN
	
DECLARE @PrecoDeListaDev Numeric(10,2) = 0
DECLARE @CodigoItemDev NVARCHAR(10)
DECLARE @TotalLinhasDev Numeric = (SELECT Count(LineNum) FROM RIN1 WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @ContDev Numeric = 0
DECLARE @PrecoExistenteDev Numeric = 0
DECLARE @DescontoDev NUMERIC = 0

WHILE(@ContDev < @TotalLinhasDev + 1)
	BEGIN
		IF EXISTS( SELECT *FROM RIN1 WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum = @ContDev)
		BEGIN
			SELECT 
			@CodigoItemDev = T1.ItemCode,
			@PrecoDeListaDev  = T5.price, 
			@PrecoExistenteDev = (case when T1.U_PrecoDeLista is null then 0 else T1.U_PrecoDeLista end),
			@DescontoDev = T1.DiscPrcnt
			FROM ORIN T0
			INNER JOIN RIN1 T1 ON T0.DocEntry = T1.DocEntry 
			INNER JOIN OCRD T3 ON T0.CardCode = T3.CardCode
			INNER JOIN OPLN T4 ON T3.ListNum = T4.ListNum
			INNER JOIN ITM1 T5 ON T4.ListNum = T5.PriceList AND T1.ItemCode = T5.ItemCode
			WHERE  T0.DocEntry = @list_of_cols_val_tab_del AND T1.LineNum = @ContDev

			IF ( (@CodigoItemDev  is not null AND @CodigoItemDev <> '')
					 AND (@PrecoDeListaDev is not null AND @PrecoDeListaDev > 0)
						AND (@PrecoExistenteDev is null OR @PrecoExistenteDev = 0))
				BEGIN
					UPDATE RIN1	SET U_PrecoDeLista = @PrecoDeListaDev - (@PrecoDeListaDev * @DescontoDev / 100)
						WHERE DocEntry = @list_of_cols_val_tab_del AND ItemCode = @CodigoItemDev AND LineNum =  @ContDev					
				END;

		END 
		SET @ContDev = @ContDev + 1
	END;
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------
------ Author: Henrique Truyts 
------ Create date: 17/06/2019
------ Documentos:  Cotação de vendas
------ GLPI ID: 6734
------ GLPI ID Atualizações: 
-- Description:	Bloquear cotação de vendas sem  Código de imposto
---------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '23') and (@transaction_type in ('A'))--'17' = Cotação

BEGIN		
	--Código de imposto
	IF EXISTS(
			SELECT 
				OL.TaxCode
			FROM 
				OQUT O
			    INNER JOIN QUT1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @list_of_cols_val_tab_del AND OL.TaxCode IS NULL)
	BEGIN
		SET @error = -1
		SET @error_message = 'Cotação de Venda - Não foi possível concluir. É necessário definir o Código de Imposto.'
		SELECT @error, @error_message
	END
		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 17/06/2019
-- Update Date: 
-- Description: Trava para evitar alteração de DocEntry da OC
-- Documento: Ordem de Carga
-- GLPI ID:7147
-- GLPI IG Atualização:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = 'BIM_ORDEMCARGA') and (@transaction_type in ('A','U'))--'2' = Ordem de Carga
BEGIN	
	IF EXISTS (
	SELECT DocNum FROM [@BIM_ORDEMCARGA]  WHERE DocEntry = @list_of_cols_val_tab_del AND DocNum<>DocEntry
	)
	BEGIN
		SET @error = -7147
		SET @error_message =  'Número da Ordem de Carga não pode ser modificado.Verifique!'+ ' - ' +
		Convert(nvarchar,@list_of_cols_val_tab_del)
		SELECT @error, @error_message
	END	
END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 11/06/2019
-- Update Date: 
-- Description: Vendedor só pode cadastrar clientes pelo APP caso o cliente seja Lead
-- Documento: Parceiro de Negocios
-- GLPI ID:6942
-- GLPI IG Atualização:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '2') and (@transaction_type in ('A'))--'2' = Parceiro de NEgocios
BEGIN

DECLARE @UserSign6942 int = (SELECT UserSign FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del)
DECLARE @CardTypeL char = (SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del)
DECLARE @Series80 int = (SELECT Series FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del)
DECLARE @Dep6942 int SET @Dep6942 = (SELECT Department FROM OUSR WHERE USERID = @UserSign6942)
DECLARE @UserPortal6942 INT
SET @UserPortal6942 = (SELECT T1.Department
							FROM OUSR T1
							WHERE T1.USER_CODE IN(SELECT T0.U_AHS_SapUserCode
													FROM OCRD T0
													WHERE T0.CardCode = @list_of_cols_val_tab_del))

IF(@UserPortal6942 <> 17) ----EQUIPE DE COMPRAS(SUPRIMENTO)
BEGIN
	IF(@Dep6942 = 1 AND ( @Series80 <> 80 OR @CardTypeL <> 'L'))	
		BEGIN
			SET @error = -6942
			SET @error_message = 'Só é permitido o cadastramento de cliente potencial. Verifique!.'		
			SELECT @error, @error_message
		END	
	END
END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 10/06/2019
-- Update Date: 
-- Description:	Trava para Clientes Bloqueados (caracteristica 24) Esboço
-- Documents: Pedido de Vendas e Cotação de vendas
-- GLPI ID: 
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'112') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas (DepCB = departamentos Clientes Bloqueados
BEGIN

DECLARE @DepCBEsb int SET @DepCBEsb = (SELECT u.Department From ODRF O 
								INNER JOIN OUSR U ON O.UserSign = U.USERID
								WHERE O.ObjType = 17 AND O.DocEntry = @list_of_cols_val_tab_del)
DECLARE @ObjTypeEsb int = 0
SET @ObjTypeEsb = (SELECT Distinct ObjType FROM ODRF WHERE ObjType = 17 AND DocEntry = @list_of_cols_val_tab_del )

 IF(@DepCBEsb = 1 AND @ObjTypeEsb = 17)	
	BEGIN
		IF  EXISTS (
		SELECT
		t0.QryGroup25,T0.CardCode
		FROM OCRD T0
		WHERE T0.QryGroup25 = 'N' AND T0.QryGroup24 = 'Y' 
		AND T0.CardCode  = ( SELECT Distinct CardCode FROM ODRF WHERE ObjType = 17 AND DocEntry =  @list_of_cols_val_tab_del )
		
		) BEGIN	
				SET @error = -1
				SET @error_message = 'Cliente Bloqueado, não é possível adicionar o Pedido. Entrar em contato com o setor de Crédito e Cobrança ou Adm. de Vendas!'
				SELECT @error, @error_message
		  END;
	
	END;
END;--END PRINCIPAL
-------------------------COTAÇÂO DE VENDAS--------------------------------------------------------------------------------------
IF (@object_type = N'112') and (@transaction_type in ('A','U'))--'23' = Cotação de Vendas (DepCB = departamentos Clientes Bloqueados
BEGIN

DECLARE @DepCBQEsb int SET @DepCBQEsb = (SELECT u.Department From ODRF O 
								INNER JOIN OUSR U ON O.UserSign = U.USERID
								WHERE O.ObjType = 23 AND O.DocNum = @list_of_cols_val_tab_del)
DECLARE @ObjTypeEsbQ int = 0
SET @ObjTypeEsbQ = (SELECT Distinct ObjType FROM ODRF WHERE ObjType = 23 AND DocEntry = @list_of_cols_val_tab_del )

 IF(@DepCBQEsb = 1 AND @ObjTypeEsbQ = 23)	
	BEGIN
		IF  EXISTS (
		SELECT
		t0.QryGroup25,T0.CardCode
		FROM OCRD T0
		WHERE T0.QryGroup25 = 'N' AND T0.QryGroup24 = 'Y' 
		AND T0.CardCode  = ( SELECT Distinct CardCode FROM ODRF WHERE ObjType = 23 AND DocEntry =  @list_of_cols_val_tab_del )
		
		) BEGIN	
				SET @error = -1
				SET @error_message = 'Cliente Bloqueado, não é possível adicionar a Cotação. Entrar em contato com o setor de Crédito e Cobrança ou Adm. de Vendas!'
				SELECT @error, @error_message
		  END;
	
	END;
END;--END PRINCIPAL

--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 04/04/2019
-- Update date: 07/10/2020
-- Description:	Gravar o Preço de Lista do PN ao adicionar a cotação
-- GLPI ID: 6659
-- GLPI ID Atualizações: 9608 - Aplicar desconto no Preço de Lista
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '23') and (@transaction_type in ('A','U'))--'23' = Cotação de Vendas

BEGIN
	
DECLARE @PrecoDeListaQ Numeric(10,2) = 0
DECLARE @CodigoItem6659Q NVARCHAR(10)
DECLARE @TotalLinhas6659Q Numeric = (SELECT Count(LineNum) FROM QUT1 WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Cont6659Q Numeric = 0
DECLARE @PrecoExistenteQ Numeric = 0
DECLARE @DescontoQ NUMERIC = 0

WHILE(@Cont6659Q < @TotalLinhas6659Q + 1)
	BEGIN
		IF EXISTS( SELECT *FROM QUT1 WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum = @Cont6659Q)
		BEGIN
			SELECT 
			@CodigoItem6659Q = T1.ItemCode,
			@PrecoDeListaQ  = T5.price, 
			@PrecoExistenteQ = (case when T1.U_PrecoDeLista is null then 0 else T1.U_PrecoDeLista end),
			@DescontoQ = T1.DiscPrcnt
			FROM OQUT T0
			INNER JOIN QUT1 T1 ON T0.DocEntry = T1.DocEntry 
			INNER JOIN OCRD T3 ON T0.CardCode = T3.CardCode
			INNER JOIN OPLN T4 ON T3.ListNum = T4.ListNum
			INNER JOIN ITM1 T5 ON T4.ListNum = T5.PriceList AND T1.ItemCode = T5.ItemCode
			WHERE  T0.DocEntry = @list_of_cols_val_tab_del AND T1.LineNum = @Cont6659Q

			IF ( (@CodigoItem6659Q  is not null AND @CodigoItem6659Q <> '')
					 AND (@PrecoDeListaQ is not null AND @PrecoDeListaQ > 0)
						AND (@PrecoExistenteQ is null OR @PrecoExistenteQ = 0))
				BEGIN
					UPDATE QUT1	SET U_PrecoDeLista = @PrecoDeListaQ - (@PrecoDeListaQ * @DescontoQ / 100)
						WHERE DocEntry = @list_of_cols_val_tab_del AND ItemCode = @CodigoItem6659Q AND LineNum =  @Cont6659Q					
				END;

		END 
		SET @Cont6659Q = @Cont6659Q + 1
	END;
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 03/07/2018
-- Update Date: 07/05/2019
-- Description: Bloquear atualização e cancelamento Se todas as linhas do PV estiverem com vinculo em OC (campo Número OC preenchido)
-- Documento: Pedido de Vendas
-- GLPI ID:5046
-- GLPI IG Atualização:41118,6908


--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('U','C','L'))--'17' = Pedido de Vendas
BEGIN
DECLARE @TotaldeLinhasLog int = (SELECT COUNT(*)FROM (SELECT  LineNum from ADO1  WHERE ObjType = 17 AND DocEntry = @list_of_cols_val_tab_del GROUP BY LineNum)A )
DECLARE @TotalLinhascomOC int = (SELECT COUNT(*) FROM RDR1 WHERE DocEntry=@list_of_cols_val_tab_del AND (U_OC_num IS NOT NULL AND U_OC_num <> ''))

DECLARE @Status5046 Nvarchar (10) = ( SELECT DocStatus FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)

DECLARE @UserSign2 Nvarchar(10) = (SELECT  UserSign2 FROM ORDR where docentry = @list_of_cols_val_tab_del)

DECLARE @Dep5046 int SET @Dep5046 = (SELECT Department FROM OUSR WHERE USERID = @UserSign2)

IF( @Status5046 IN('O','C'))
BEGIN
	IF(@Dep5046 = 1 OR @Dep5046 = 2)	
	BEGIN
		IF(@TotaldeLinhasLog = @TotalLinhascomOC)			
		BEGIN	
			SET @error = -5046
			SET @error_message = 'Não é possível modificação do PV pois o mesmo tem vinculo na OC do processo logístico.'		
			SELECT @error, @error_message
		END
	END	
END

END 


--------------------------------------------------------------------------------------------------------------------------------
--END 
--------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------
------ Author: Henrique Truyts 
------ Create date: 25/02/2019
------ Documentos:Saida de Mercadoria
------ GLPI ID: 6313
------ GLPI ID Atualizações: 
---------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '60') and (@transaction_type in ('A'))--'60' = Saida de Mercadoria (SM)
BEGIN
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
--Ao adicionar a saida - Padrão /Especial / Desmontagem
--Peso do Item do cabeçalho da OP deve bater com a somatoria da quantidade base das linhas da op (IGNORAR EM)
-------------------------------------------------------------------------------------------------------------------------
DECLARE @PesoItemOpSM Numeric(10,3) SET @PesoItemOpSM = (
						SELECT T1.SWeight1 FROM OWOR T0 
						INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
						WHERE T0.DocEntry = (
								SELECT DISTINCT BaseEntry FROM IGE1 WHERE DocEntry = @list_of_cols_val_tab_del	)	)

DECLARE @QtdeBaseOpSM Numeric(10,3) SET @QtdeBaseOpSM = (
								SELECT SUM(T1.SWeight1*T0.BaseQty) FROM WOR1 T0 
								INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
								WHERE SUBSTRING( T0.ItemCode,1,2) <> 'EM' AND T0.DocEntry =	(
									SELECT DISTINCT BaseEntry FROM IGE1 WHERE DocEntry = @list_of_cols_val_tab_del	)	)

DECLARE @TotalPesoMinimoSM Numeric(10,3) = @PesoItemOpSM - ((@PesoItemOpSM*1)/100)

DECLARE @TotalPesoMaximoSM Numeric(10,3) = @PesoItemOpSM + ((@PesoItemOpSM*1)/100)

IF(@QtdeBaseOpSM > @TotalPesoMaximoSM OR @QtdeBaseOpSM < @TotalPesoMinimoSM)
BEGIN
	SET @error = -6313	
	SET @error_message = 'Não foi possivel salvar a OP, quantidade base menor/Maior em 1% em relação ao peso do produto principal na Ordem de Produção'
	SELECT @error, @error_message
END
-------------------------------------------------------------------------------------------------------------------------
--Ao adicionar a saida - Padrão /Especial 
--A somatoria das quantidades das linhas das saidas existentes não pode superar a quantidade planejada das linhas da OP (IGNORAR EM)
-------------------------------------------------------------------------------------------------------------------------
DECLARE @TypeOpSM Char (1)= (SELECT Type FROM OWOR WHERE DocEntry = 
							(SELECT DISTINCT BaseEntry FROM IGE1 WHERE DocEntry = @list_of_cols_val_tab_del	))

							
--IF ( @TypeOpSM <> 'D')
--	BEGIN
--	IF EXISTS(
--		SELECT *FROM (
--		SELECT T0.ItemCode 'ItemCodeSaida',SUM(T0.Quantity)'QtdSaida',T1.ItemCode 'ItemCodeLinhaOp',T1.PlannedQty'QtdPlanejada',
--		T1.PlannedQty - ((T1.PlannedQty*1)/100)'QtdPlanejadaMinima',T1.PlannedQty + ((T1.PlannedQty*1)/100)'QtdPlanejadaMaxima'
--		FROM IGE1 T0
--		INNER JOIN WOR1 T1 ON T0.BaseEntry = T1.DocEntry AND T0.ItemCode = T1.ItemCode
--		WHERE T1.DocEntry = (SELECT Distinct BaseEntry FROM IGE1 WHERE DocEntry = @list_of_cols_val_tab_del)
--		AND SUBSTRING( T0.ItemCode,1,2) <> 'EM' AND SUBSTRING( T1.ItemCode,1,2) <> 'EM'
--		GROUP BY T0.ItemCode,T1.ItemCode,T1.PlannedQty
--		)A
--		WHERE QtdSaida > QtdPlanejadaMaxima
--		)
--		BEGIN
--			SET @error = -6313
--			SET @error_message = 'Não foi possivel salvar a OP, a soma das saídas é maior em 1% que a quantidade planejada indicada nas linhas da OP'
--			SELECT @error, @error_message
--		END
--	END
---------------------------------------------------------------------------------------------------------------------------
--Ao adicionar a saida - Desmontagem
--A somatoria das quantidades das linhas das saidas existentes não pode superar a quantidade planejada do cabeçalho da OP 
-------------------------------------------------------------------------------------------------------------------------
	IF ( @TypeOpSM = 'D')
	BEGIN
		IF EXISTS(
		SELECT *FROM (
		SELECT SUM(T0.Quantity) 'QtdEntrada',T1.ItemCode'ItemCodeOp',T1.PlannedQty'QtdPlanejada',
		T1.PlannedQty - ((T1.PlannedQty*1)/100)'QtdPlanejadaMinima',T1.PlannedQty + ((T1.PlannedQty*1)/100)'QtdPlanejadaMaxima'
		FROM IGE1 T0
		INNER JOIN OWOR T1 ON T0.BaseEntry = T1.DocEntry AND T0.ItemCode = T1.ItemCode
			WHERE T1.DocEntry = (SELECT Distinct  BaseEntry FROM IGE1 WHERE DocEntry = @list_of_cols_val_tab_del) 
		GROUP BY T1.ItemCode,T1.PlannedQty	)	A
		WHERE QtdEntrada > QtdPlanejadaMaxima
		)
		BEGIN
			SET @error = -6313
			SET @error_message = 'Não foi possivel salvar a OP, a soma das saídas é maior em 1% que a quantidade planejada na OP'
			SELECT @error, @error_message
		END	
	END

END
---------------------------------------------------------------------------------------------------------------------------
----END
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
------ Author: Henrique Truyts 
------ Create date: 25/02/2019
------ Documentos:Entrada de Produto acabado
------ GLPI ID: 6313
------ GLPI ID Atualizações:
---------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '59') and (@transaction_type in ('A'))--'59' = Entrada de Produto acabado (EPA)
BEGIN
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
--Ao adicionar a entrada - Padrão /Especial / Desmontagem
--Peso do Item do cabeçalho da OP deve bater com a somatoria da quantidade base das linhas da op (IGNORAR EM)
-------------------------------------------------------------------------------------------------------------------------
DECLARE @PesoItemOpEPA Numeric(10,3) SET @PesoItemOpEPA = (
						SELECT T1.SWeight1 FROM OWOR T0 
						INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
						WHERE T0.DocEntry = (
								SELECT DISTINCT BaseEntry FROM IGN1 WHERE DocEntry = @list_of_cols_val_tab_del	)	)

DECLARE @QtdeBaseOpEpa Numeric(10,3) SET @QtdeBaseOpEpa = (
								SELECT SUM(T1.SWeight1*T0.BaseQty) FROM WOR1 T0 
								INNER JOIN OITM T1 ON T0.ItemCode = T1.ItemCode
								WHERE SUBSTRING( T0.ItemCode,1,2) <> 'EM' AND T0.DocEntry =	(
									SELECT DISTINCT BaseEntry FROM IGN1 WHERE DocEntry = @list_of_cols_val_tab_del	)	)

DECLARE @TotalPesoMinimo Numeric(10,3) = @PesoItemOpEPA - ((@PesoItemOpEPA*1)/100)

DECLARE @TotalPesoMaximo Numeric(10,3) = @PesoItemOpEPA + ((@PesoItemOpEPA*1)/100)

IF(@QtdeBaseOpEpa > @TotalPesoMaximo OR @QtdeBaseOpEpa < @TotalPesoMinimo)
BEGIN
	SET @error = -6313	
	SET @error_message = 'Não foi possivel salvar a OP, quantidade base menor/Maior em 1% em relação ao peso do produto principal na Ordem de Produção'
	SELECT @error, @error_message
END
-------------------------------------------------------------------------------------------------------------------------
--Ao adicionar a entrada - Padrão /Especial 
--A somatoria das quantidades das linhas das entradas existentes não pode superar a quantidade planejada do cabeçalho da OP
-------------------------------------------------------------------------------------------------------------------------
DECLARE @TypeOpEPA Char (1)= (SELECT Type FROM OWOR WHERE DocEntry = 
							(SELECT DISTINCT BaseEntry FROM IGN1 WHERE DocEntry = @list_of_cols_val_tab_del	))

							
--IF ( @TypeOpEPA <> 'D')
--	BEGIN
--		IF EXISTS(
--		SELECT *FROM (
--		SELECT SUM(T0.Quantity) 'QtdEntrada',T1.ItemCode'ItemCodeOp',T1.PlannedQty'QtdPlanejada',
--		T1.PlannedQty - ((T1.PlannedQty*1)/100)'QtdPlanejadaMinima',T1.PlannedQty + ((T1.PlannedQty*1)/100)'QtdPlanejadaMaxima'
--		FROM IGN1 T0
--		INNER JOIN OWOR T1 ON T0.BaseEntry = T1.DocEntry AND T0.ItemCode = T1.ItemCode
--			WHERE T1.DocEntry = (SELECT Distinct BaseEntry FROM IGN1 WHERE DocEntry = @list_of_cols_val_tab_del) 
--		GROUP BY T1.ItemCode,T1.PlannedQty	)	A
--		WHERE QtdEntrada > QtdPlanejadaMaxima
--		)
--		BEGIN
--			SET @error = -6313
--			SET @error_message = 'Não foi possivel salvar a OP, a soma das entradas é maior em 1% que a quantidade planejada na OP'
--			SELECT @error, @error_message
--		END
	
--	END
-------------------------------------------------------------------------------------------------------------------------
--Ao adicionar a entrada - Desmontagem
--A somatoria das quantidades das linhas das entradas existentes não pode superar a quantidade planejada das linhas da OP (IGNORAR EM)
-------------------------------------------------------------------------------------------------------------------------
	IF ( @TypeOpEPA = 'D')
	BEGIN
	IF  EXISTS(
		SELECT *FROM (
		SELECT T0.ItemCode 'ItemCodeSaida',SUM(T0.Quantity)'QtdSaida',T1.ItemCode 'ItemCodeLinhaOp',T1.PlannedQty'QtdPlanejada',
		T1.PlannedQty - ((T1.PlannedQty*1)/100)'QtdPlanejadaMinima',T1.PlannedQty + ((T1.PlannedQty*1)/100)'QtdPlanejadaMaxima'
		FROM IGN1 T0
		INNER JOIN WOR1 T1 ON T0.BaseEntry = T1.DocEntry AND T0.ItemCode = T1.ItemCode
		WHERE T1.DocEntry = (SELECT Distinct  BaseEntry FROM IGN1 WHERE DocEntry = @list_of_cols_val_tab_del)
		AND SUBSTRING( T0.ItemCode,1,2) <> 'EM' AND SUBSTRING( T1.ItemCode,1,2) <> 'EM'
		GROUP BY T0.ItemCode,T1.ItemCode,T1.PlannedQty
		)A
		WHERE QtdSaida > QtdPlanejadaMaxima
		)
		BEGIN
			SET @error = -6313
			SET @error_message = 'Não foi possivel salvar a OP, a soma das Entradas é maior em 1% que a quantidade planejada indicada nas linhas da OP'
			SELECT @error, @error_message
		END
	END
	


-------------------------------------------------------------------------------------------------------------------------
--Ao adicionar a entrada e se a op tiver itens negativos
--A somatoria das quantidades das linhas das entradas existentes não pode superar a quantidade planejada das linhas da OP (IGNORAR EM)
-------------------------------------------------------------------------------------------------------------------------
--IF EXISTS(
--	SELECT *FROM (
--		SELECT T0.ItemCode 'ItemCodeSaida',SUM(T0.Quantity)'QtdSaida',T1.ItemCode 'ItemCodeLinhaOp',T1.PlannedQty'QtdPlanejada',
--		(T1.PlannedQty - ((T1.PlannedQty*1)/100))*-1'QtdPlanejadaMinima',(T1.PlannedQty + ((T1.PlannedQty*1)/100))*-1'QtdPlanejadaMaxima'
--		FROM IGN1 T0
--		INNER JOIN WOR1 T1 ON T0.BaseEntry = T1.DocEntry AND T0.ItemCode = T1.ItemCode
--		WHERE T1.DocEntry = (SELECT Distinct  BaseEntry FROM IGN1 WHERE DocEntry = @list_of_cols_val_tab_del)
--		AND SUBSTRING( T0.ItemCode,1,2) <> 'EM' AND SUBSTRING( T1.ItemCode,1,2) <> 'EM' AND
--		T1.PlannedQty < 0
--		GROUP BY T0.ItemCode,T1.ItemCode,T1.PlannedQty
--		)A
--		WHERE QtdSaida > QtdPlanejadaMaxima

--	)
--	BEGIN
--		SET @error = -6313
--		SET @error_message = 'Não foi possivel salvar a OP, a soma das Entradas é maior em 1% que a quantidade planejada indicada nas linhas da OP'
--		SELECT @error, @error_message
--	END
End
---------------------------------------------------------------------------------------------------------------------------
----END
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
------ Author: Henrique Truyts 
------ Create date: 25/02/2019
------ Documentos:Ordem de Produção Padrão, Especial e Desmontagem
------ GLPI ID: 6313
------ GLPI ID Atualizações:
---------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '202') and (@transaction_type in ('U'))--'202' = Ordem de Produção
BEGIN
------------------------------------------------VARIAVEIS GERAIS---------------------------------------------------------
DECLARE @StatusOP NVARCHAR SET @StatusOP = (
							SELECT Status FROM OWOR WHERE DocEntry = @list_of_cols_val_tab_del	)

DECLARE @TypeOP Char (1)= (
					SELECT Type FROM OWOR WHERE DocEntry = @list_of_cols_val_tab_del	)
-------------------------------------------------------------------------------------------------------------------------
--FECHAMENTO DA OP (ESPECIAL E PADRAO) - SAIDA
--Verificar a somatoria das saidas (Linhas campo quantidade) que deve ser igual a quantidade planejada na linha da op (IGNORAR O EM)
-------------------------------------------------------------------------------------------------------------------------
	--IF (@StatusOP = 'L' AND @TypeOP <> 'D')
	--BEGIN
	--	IF NOT EXISTS(
	--	SELECT *FROM (
	--	SELECT T0.ItemCode 'ItemCodeSaida',SUM(T0.Quantity)'QtdSaida',T1.ItemCode 'ItemCodeLinhaOp',T1.PlannedQty'QtdPlanejada',
	--	T1.PlannedQty - ((T1.PlannedQty*1)/100)'QtdPlanejadaMinima',T1.PlannedQty + ((T1.PlannedQty*1)/100)'QtdPlanejadaMaxima'
	--	FROM IGE1 T0
	--	INNER JOIN WOR1 T1 ON T0.BaseEntry = T1.DocEntry AND T0.ItemCode = T1.ItemCode
	--	WHERE T1.DocEntry = @list_of_cols_val_tab_del 
	--	AND SUBSTRING( T0.ItemCode,1,2) <> 'EM' AND SUBSTRING( T1.ItemCode,1,2) <> 'EM'
	--	GROUP BY T0.ItemCode,T1.ItemCode,T1.PlannedQty
	--	)A
	--	WHERE QtdSaida >= QtdPlanejadaMinima AND QtdSaida <=QtdPlanejadaMaxima
	--	)
	--	BEGIN
	--		SET @error = -6313
	--		SET @error_message = 'Não foi possivel salvar a OP, a soma das saídas é maior/menor em 1% que a quantidade planejada indicada nas linhas da OP'
	--		SELECT @error, @error_message
	--	END
	--END
	
-------------------------------------------------------------------------------------------------------------------------
--FECHAMENTO DA OP  (ESPECIAL E PADRAO) - ENTRADA
--Verificar a somatoria das entradas (Linhas campo quantidade) que deve ser igual a quantidade planejada no cabeçalho da op
-------------------------------------------------------------------------------------------------------------------------
	--IF (@StatusOP = 'L' AND @TypeOP <> 'D')
	--BEGIN
	--	IF NOT EXISTS(
	--	SELECT *FROM (
	--	SELECT SUM(T0.Quantity) 'QtdEntrada',T1.ItemCode'ItemCodeOp',T1.PlannedQty'QtdPlanejada',
	--	T1.PlannedQty - ((T1.PlannedQty*1)/100)'QtdPlanejadaMinima',T1.PlannedQty + ((T1.PlannedQty*1)/100)'QtdPlanejadaMaxima'
	--	FROM IGN1 T0
	--	INNER JOIN OWOR T1 ON T0.BaseEntry = T1.DocEntry AND T0.ItemCode = T1.ItemCode
	--	WHERE T1.DocEntry = @list_of_cols_val_tab_del
	--	GROUP BY T1.ItemCode,T1.PlannedQty	)	A
	--	WHERE QtdEntrada >= QtdPlanejadaMinima AND QtdEntrada <=QtdPlanejadaMaxima
	--	)
	--	BEGIN
	--		SET @error = -6313
	--		SET @error_message = 'Não foi possivel salvar a OP, a soma das entradas é maior/menor em 1% que a quantidade planejada na OP'
	--		SELECT @error, @error_message
	--	END
	
	--END
-------------------------------------------------------------------------------------------------------------------------
--FECHAMENTO DA OP (Desmontagem) - SAIDA
--Verificar a somatoria das saidas(Linhas campo quantidade) que deve ser igual a quantidade planejada no cabeçalho da op
-------------------------------------------------------------------------------------------------------------------------
	IF (@StatusOP = 'L' AND @TypeOP = 'D')
	BEGIN
	IF NOT EXISTS(
		SELECT *FROM (
		SELECT SUM(T0.Quantity) 'QtdEntrada',T1.ItemCode'ItemCodeOp',T1.PlannedQty'QtdPlanejada',
		T1.PlannedQty - ((T1.PlannedQty*1)/100)'QtdPlanejadaMinima',T1.PlannedQty + ((T1.PlannedQty*1)/100)'QtdPlanejadaMaxima'
		FROM IGE1 T0
		INNER JOIN OWOR T1 ON T0.BaseEntry = T1.DocEntry AND T0.ItemCode = T1.ItemCode
		WHERE T1.DocEntry = @list_of_cols_val_tab_del
		GROUP BY T1.ItemCode,T1.PlannedQty	)	A
		WHERE QtdEntrada >= QtdPlanejadaMinima AND QtdEntrada <=QtdPlanejadaMaxima
		)
		BEGIN
			SET @error = -6313
			SET @error_message = 'Não foi possivel salvar a OP, a soma das Saidas é maior/menor em 1% que a quantidade planejada na OP'
			SELECT @error, @error_message
		END
	END
-------------------------------------------------------------------------------------------------------------------------
--FECHAMENTO DA OP (Desmontagem) - Entrada
--Verificar a somatoria das entradas (Linhas campo quantidade) que deve ser igual a quantidade planejada na linha da op (IGNORAR O EM)
-------------------------------------------------------------------------------------------------------------------------
--	IF (@StatusOP = 'L' AND @TypeOP = 'D')
--	BEGIN
--	IF NOT EXISTS(
--		SELECT *FROM (
--		SELECT T0.ItemCode 'ItemCodeSaida',SUM(T0.Quantity)'QtdSaida',T1.ItemCode 'ItemCodeLinhaOp',T1.PlannedQty'QtdPlanejada',
--		T1.PlannedQty - ((T1.PlannedQty*1)/100)'QtdPlanejadaMinima',T1.PlannedQty + ((T1.PlannedQty*1)/100)'QtdPlanejadaMaxima'
--		FROM IGN1 T0
--		INNER JOIN WOR1 T1 ON T0.BaseEntry = T1.DocEntry AND T0.ItemCode = T1.ItemCode
--		WHERE T1.DocEntry = @list_of_cols_val_tab_del 
--		AND SUBSTRING( T0.ItemCode,1,2) <> 'EM' AND SUBSTRING( T1.ItemCode,1,2) <> 'EM'
--		GROUP BY T0.ItemCode,T1.ItemCode,T1.PlannedQty
--		)A
--		WHERE QtdSaida >= QtdPlanejadaMinima AND QtdSaida <= QtdPlanejadaMaxima
--		)
--		BEGIN
--			SET @error = -6313
--			SET @error_message = 'Não foi possivel salvar a OP, a soma das Entradas é maior/menor em 1% que a quantidade planejada indicada nas linhas da OP'
--			SELECT @error, @error_message
--		END
--	END
END
---------------------------------------------------------------------------------------------------------------------------
----END
---------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 26/02/2017
-- Update Date: 22/02/2019
-- Description: Trava NF ENTRADA e Solicitação de compra - Aquisições para Projeto Ativo Fixo
-- Documentos: NF ENTRADA e Solicitação de compra
-- GLPI ID : 4572
---- GLPI ID Atualizações:6527
--------------------------------------------------------------------------------------------------------------------------------
--------------------------NF ENTRADA--------------------------------------------------------------
IF (@object_type = '18') and (@transaction_type in ('A','U'))--'18' = NF ENTRADA
BEGIN
DECLARE @Linhas4572E int = (SELECT MAX(LineNum)FROM PCH1  WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Cont4572E int = 0
DECLARE @Deposito4572E Nvarchar (10)
DECLARE @Util4572E int
DECLARE @ProjetoE NVarchar (100) = null
WHILE(@Cont4572E <  @Linhas4572E + 1) -- percorrendo todas as linhas do Pedido
  BEGIN
  
   SET @Deposito4572E = (SELECT WhsCode FROM PCH1 WHERE LineNum = @Cont4572E AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha
   SET @Util4572E = (SELECT Usage FROM PCH1 WHERE LineNum = @Cont4572E AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha
   SET @ProjetoE = (SELECT rtrim(ltrim(Project)) FROM PCH1 WHERE LineNum = @Cont4572E AND DocEntry = @list_of_cols_val_tab_del)-- pegando projeto de cada linha

		
		IF(@ProjetoE IS NOT NULL AND 	@ProjetoE<>'')
		BEGIN

			IF( @Deposito4572E <> '02.98' AND @Deposito4572E <> '02.94'  )
			BEGIN
				SET @error = -4572
				SET @error_message = 'Obrigatorio depósito 02.98 ou 02.94!'
				SELECT @error, @error_message
			END
			--32 = Compra de Ativo ST 31- Compra de Ativo 45 - Compra Serviço ISS
			ELSE IF(@Util4572E <> 32 AND @Util4572E <> 31 AND @Util4572E <> 45)
			BEGIN
				SET @error = -4572
				SET @error_message = 'O campo utilização nao pode ser diferente de compra de ativo, compra ativo st ou compra serviço iss quando depósito for = 02.98!'
				SELECT @error, @error_message
			END
			
		END
		
	Set @Cont4572E =  @Cont4572E + 1
  END--END while
END

--------------------------SOLICITAÇÃO DE COMPRA--------------------------------------------------------------
IF (@object_type = '1470000113') and (@transaction_type in ('A','U'))--'1470000113' = SOLICITAÇÃO DE COMPRA
BEGIN
DECLARE @Linhas4572S int = (SELECT MAX(LineNum)FROM PRQ1   WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Cont4572S int = 0
DECLARE @Deposito4572S Nvarchar (10)
DECLARE @Util4572S int
DECLARE @ProjetoS NVarchar (100) = null
WHILE(@Cont4572S <  @Linhas4572S + 1) -- percorrendo todas as linhas do Pedido
  BEGIN
  
   SET @Deposito4572S = (SELECT WhsCode FROM PRQ1 WHERE LineNum = @Cont4572S AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha
   SET @Util4572S = (SELECT Usage FROM PRQ1 WHERE LineNum = @Cont4572S AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha
   SET @ProjetoS = (SELECT (rtrim(ltrim(Project))) FROM PRQ1 WHERE LineNum = @Cont4572S AND DocEntry = @list_of_cols_val_tab_del)-- pegando projeto de cada linha

		IF(@ProjetoS IS NOT NULL AND 	@ProjetoS<>'')
		BEGIN

			IF( @Deposito4572S <> '02.98' AND @Deposito4572S <> '02.94')
			BEGIN
				SET @error = -4572
				SET @error_message = 'Obrigatorio depósito 02.98 ou 02.94!'
				SELECT @error, @error_message
			END
			--32 = Compra de Ativo ST 31- Compra de Ativo 45 - Compra Serviço ISS
			ELSE IF(@Util4572S <> 32 AND @Util4572S <> 31 AND @Util4572S <> 45)
			BEGIN
				SET @error = -4572
				SET @error_message = 'O campo utilização nao pode ser diferente de compra de ativo, compra ativo st ou compra serviço iss quando depósito for = 02.98!'
				SELECT @error, @error_message
			END
			
		END
		
	Set @Cont4572S =  @Cont4572S + 1
  END--END while
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 18/02/2019
-- Update Date:
-- Description:	Travar adicionar linhas com cidades duplicadas na macro regiao
-- GLPI ID: 6500
-- GLPI ID Atualizações:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = 'CadMacroRegiao') and (@transaction_type in ('A','U'))--CadMacroRegiao
BEGIN

IF EXISTS(
SELECT *FROM(
SELECT A.U_Estado,COUNT(A.U_MUNICIPIO)'cidades' FROM(
 SELECT T0.U_Estado, LineId,T0.U_Municipio FROM [@RAL_MACROREGIAO1] T0 
 INNER JOIN [@RAL_MACROREGIAO] T1 ON T1.DocEntry= T0.DocEntry 
 WHERE T0.DocEntry = @list_of_cols_val_tab_del
 ) A
 GROUP BY A.U_ESTADO,A.U_Municipio) B WHERE cidades > 1 )
 BEGIN
	SET @error = -6500
	SET @error_message = 'Existe duplicidade de cidades, Verifique!'
	SELECT @error, @error_message

 END
 END;
 --------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------
---- Author:		Henrique Truyts 
---- Create date: 15/02/2019
---- Description: Travar Documentos sem RA preenchido  - ESBOÇO
---- Documentos:  Solicitação de Compra,Oferta de Compra, Saida de mercadorias
---- GLPI ID: 6345
---- GLPI ID Atualizações: 9451
---- Description: Retirar a trava de RA dos documentos saída de mercadoria e entrada de mercadoria em 13/09/2020
-------------------------------------------------------------------------------------------------------------------------
--IF (@object_type = N'112') and (@transaction_type in ('A'))--N'112' = ESBOÇO
--BEGIN

--	IF EXISTS(SELECT * FROM DRF1 WHERE ObjType='1470000113' 
--		AND (U_RAL_CadastroRA IS NULL OR  U_RAL_CadastroRA = '') AND DocEntry = @list_of_cols_val_tab_del  )
--	BEGIN
--		SET @error = -6345
--		SET @error_message = 'É obrigatório o preenchimento do campo Cadastro RA, verifique!'
--		SELECT @error, @error_message
--	END
------------------------------OFERTA DE COMPRA
--IF EXISTS(SELECT * FROM DRF1 WHERE ObjType='540000006' 
--		AND (U_RAL_CadastroRA IS NULL OR  U_RAL_CadastroRA = '') AND DocEntry = @list_of_cols_val_tab_del  )
--	BEGIN
--		SET @error = -6345
--		SET @error_message = 'É obrigatório o preenchimento do campo Cadastro RA, verifique!'
--		SELECT @error, @error_message
--	END
--------------------------------SAÍDA DE MERCADORIAS
--IF EXISTS(SELECT * FROM DRF1 WHERE ObjType='60' 
--		AND (U_RAL_CadastroRA IS NULL OR  U_RAL_CadastroRA = '') AND DocEntry = @list_of_cols_val_tab_del  )
--	BEGIN
--		SET @error = -6345
--		SET @error_message = 'É obrigatório o preenchimento do campo Cadastro RA, verifique!'
--		SELECT @error, @error_message
--	END
--END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Henrique Truyts
-- Create date: 04/01/2018
-- Update Date: 07/05/2018
-- Description:	Bloquear OP caso o produto da lista não exista no cadastro de base de produtos
-- Documentos: Ordem de Produção
-- GLPI ID: 4012
-- GLPI ID Atualizações:5115
--------------------------------------------------------------------------------------------------------------------------------
--IF (@object_type = '202') and (@transaction_type in ('A','U'))--'202' = Ordem de Produção - OWOR
--BEGIN
--	DECLARE @ItemCode4012 NVARCHAR (20)  = (SELECT ItemCode FROM OWOR WHERE DocEntry = @list_of_cols_val_tab_del)
--	DECLARE @TotalProdutos4012 INT = (SELECT Count(DISTINCT ItemCode) FROM WOR1 WHERE DocEntry = @list_of_cols_val_tab_del)
--	DECLARE @ProdExistentesBase INT = (
--	--se o total de linhas desse select for menor que a conta de itens da wor1 tem q bloquear
--			 SELECT COUNT(DISTINCT U_ItemCode) FROM [@RAL_BASEPRODUTOS1] WHERE Code 
--			 IN(SELECT Code FROM [@RAL_BASEPRODUTOS] WHERE  U_ItemCode =  @ItemCode4012 )
--			 AND U_ItemCode IN(SELECT ItemCode FROM WOR1 WHERE DocEntry = @list_of_cols_val_tab_del))

--	--OP ESPECIAL (TYPE ='P' não passa pela validação)
--	DECLARE @OPType CHAR (1) = (SELECT  Type FROM OWOR WHERE DocEntry = @list_of_cols_val_tab_del)

--	IF(@OPType <> 'P')
--	BEGIN
--		IF(@ProdExistentesBase < @TotalProdutos4012)
--		BEGIN
--			SET @error = -1
--			SET @error_message = 'Estrutura inválida, verifique os componentes da OP!'
--			SELECT @error, @error_message
--		END
--	END
--END;--END GERAL
----------------------------------------------------------------------------------------------------------------------------------
---- END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 07/01/2019
-- Update Date:
-- Description:	Travar Pedidos de Vendas com condição de pagamento diferente da condição do pn 
-- GLPI ID: 6271
-- GLPI ID Atualizações:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('U'))--'17' = Pedido de Vendas
BEGIN

DECLARE @Dep6271 int SET @Dep6271 = (SELECT u.Department From ORDR O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)

DECLARE @CondPagtoPN Int = (SELECT GroupNum FROM OCRD WHERE CardCode = 
	(SELECT O.CardCode FROM ORDR O WHERE O.DocNum = @list_of_cols_val_tab_del))

DECLARE @CondPagtoPedido Int = (SELECT O.GroupNum FROM ORDR O WHERE O.DocNum = @list_of_cols_val_tab_del)

 IF(@Dep6271 = 1 AND @CondPagtoPN <>@CondPagtoPedido)	
	BEGIN
		SET @error = -6271
		SET @error_message = 'Não é possivel atualizar o pedido, a condição de pagamento do pedido diverge da condição de pagamento cadastrada no parceiro!'
		SELECT @error, @error_message

	END;
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 16/11/2018
-- Update date: 30/04/2022
-- Description:	Travar Pedido caso a data de entrega coincida com agendamento de Bloqueio
-- Documentos:  Pedido de Vendas
-- GLPI ID: 5915
-- GLPI ID Atualizações:
-----------------------------------------------------------------------------------------------------------------------

IF (@object_type = '17') and (@transaction_type in ('A'))--'17' = Pedido de Vendas
BEGIN

DECLARE @DataEntregaAGBloq DATETIME SET @DataEntregaAGBloq = (SELECT DocDueDate FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))
DECLARE @CodigoPNAGBloq nvarchar(10) =(SELECT CardCode FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))
DECLARE @Filial5915 Numeric = (SELECT BPLId FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del )

IF EXISTS(
SELECT  U_RAL_CardCode,U_RAL_CardName,U_RAL_DataInicial,U_RAL_DataFinal	
FROM [@RAL_AGENDACLIENTES]
WHERE U_BPLId = @Filial5915 AND U_RAL_StatusEntrega = 'Bloqueada'  AND 
(@DataEntregaAGBloq between U_RAL_DataInicial AND U_RAL_DataFinal ) 
AND 
(@DataEntregaAGBloq between U_RAL_DataInicial AND U_RAL_DataFinal ) 
AND U_RAL_CardCode = @CodigoPNAGBloq
)
BEGIN
	SET @error = -1
	SET @error_message = 'Não foi possivel salvar o pedido, existe um bloqueio para a data de entrega :'+
	replace(convert(char(11),@DataEntregaAGBloq,113),' ','-')
	SELECT @error, @error_message
END
END

-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 16/11/2018
-- Update date: 30/04/2022
-- Description:	Travar Pedido caso a data de entrega coincida com feriado e nao possua agendamento de autorização
-- Documentos:  Pedido de Vendas
-- GLPI ID: 5915
-- GLPI ID Atualizações:
-----------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A'))--'17' = Pedido de Vendas
BEGIN

DECLARE @Pais nvarchar(30)
DECLARE @Estado nvarchar(30)
DECLARE @Municipio nvarchar(30)
DECLARE @Mes INT =  (SELECT DATEPART ( MONTH ,(SELECT DocDueDate FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)) )
DECLARE @Dia INT = (SELECT DATEPART ( DAY ,(SELECT DocDueDate FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)) )
DECLARE @DataEntrega DATETIME SET @DataEntrega = (SELECT DocDueDate FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))
DECLARE @CodigoPN nvarchar(10) =(SELECT CardCode FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))
DECLARE @Filial5915A Numeric = (SELECT BPLId FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del )

--primeiro tem que pegar os dados do local de entrega(Pais, estado, municipio)
SELECT 
@Municipio = (CASE WHEN T8.U_Municipio IS NULL OR T8.U_Municipio = '' THEN T3.Name ELSE T8.U_Municipio END) ,
@Estado = (CASE WHEN T8.U_Estado IS NULL OR T8.U_Estado = '' THEN T3.State ELSE T8.U_Estado END),
@Pais=T3.Country
FROM OCRD T0 
INNER JOIN OCRG T1 ON T0.GroupCode = T1.GroupCode
INNER JOIN CRD1 T2 ON T0.CardCode = T2.CardCode
INNER JOIN OCNT T3 ON T2.County = T3.AbsId
LEFT JOIN [@RAL_MACROREGIAO1] T4 ON T4.U_Municipio = T3.Name
LEFT JOIN [@RAL_MACROREGIAO] T5 ON T5.DocEntry= T4.DocEntry 
LEFT JOIN ORDR T6 ON T6.CardCode = T0.CardCode 
LEFT JOIN [@RAL_LOCALENTREGA] T7 on T6.U_LocalEntregaId = T7.DocEntry  AND t7.U_BPLId = T6.BPLId
LEFT JOIN [@RAL_LOCALENTREGA1] T8 on T8.DocEntry = T7.DocEntry 
WHERE T2.Address='FATURAMENTO' AND T0.CardCode = @CodigoPN
AND T6.DocEntry = @list_of_cols_val_tab_del


--Depois deve-se verificar com base nos dados do local de entrega, se existe algum feriado nacional, estadual ou municipal
IF EXISTS(
--Verificar apenas feriados nacionais
SELECT T0.DocEntry,T1.U_RAL_Mes,T1.U_RAL_Dia,T1.U_RAL_Descricao,'Nacional' as 'Tipo' FROM [@RAL_FERIADOS] T0 
INNER JOIN [@RAL_FERIADOS1] T1 ON T0.DocEntry = T1.DocEntry 
WHERE T0.U_BPLId = @Filial5915A AND T0.U_RAL_Pais = @Pais AND T0.U_RAL_Estado IS NULL AND T0.U_RAL_Municipio IS NULL 
AND (T1.U_RAL_Dia >= @Dia AND T1.U_RAL_Dia <= @Dia )AND( T1.U_RAL_Mes>= @Mes AND T1.U_RAL_Mes<= @Mes) 
UNION
--Verificar apenas feriados estaduais
SELECT T0.DocEntry,T1.U_RAL_Mes,T1.U_RAL_Dia,T1.U_RAL_Descricao,'Estadual' as 'Tipo' FROM [@RAL_FERIADOS] T0 
INNER JOIN [@RAL_FERIADOS1] T1 ON T0.DocEntry = T1.DocEntry
WHERE T0.U_BPLId = @Filial5915A AND T0.U_RAL_Pais = @Pais AND T0.U_RAL_Estado =@Estado  AND T0.U_RAL_Municipio IS NULL 
AND (T1.U_RAL_Dia >= @Dia AND T1.U_RAL_Dia <= @Dia )AND( T1.U_RAL_Mes>=@Mes AND T1.U_RAL_Mes<=@Mes) 
UNION 
--verificar apenas feriados municipais
SELECT T0.DocEntry,T1.U_RAL_Mes,T1.U_RAL_Dia,T1.U_RAL_Descricao,'Municipal' as 'Tipo' FROM [@RAL_FERIADOS] T0 
INNER JOIN [@RAL_FERIADOS1] T1 ON T0.DocEntry = T1.DocEntry 
WHERE T0.U_BPLId = @Filial5915A AND T0.U_RAL_Pais = @Pais AND T0.U_RAL_Estado =@Estado AND T0.U_RAL_Municipio = @Municipio 
AND (T1.U_RAL_Dia >= @Dia AND T1.U_RAL_Dia <= @Dia )AND( T1.U_RAL_Mes>=@Mes AND T1.U_RAL_Mes<=@Mes)
)
--caso exista algum feriado, deve verificar se existe agendamento de autorização
BEGIN
	--se nao existe agendamento de autorização , o sistema trava a entrada do pedido
	IF NOT EXISTS(
			SELECT  U_RAL_CardCode,U_RAL_CardName,U_RAL_DataInicial,U_RAL_DataFinal	,U_RAL_StatusEntrega
		    FROM [@RAL_AGENDACLIENTES]
		    WHERE U_BPLId = @Filial5915A AND U_RAL_StatusEntrega = 'Autorizada' AND
		    (@DataEntrega between U_RAL_DataInicial AND U_RAL_DataFinal )
		    AND 
		    (@DataEntrega between U_RAL_DataInicial AND U_RAL_DataFinal ) 
		    AND U_RAL_CardCode = @CodigoPN
	)
	BEGIN
		SET @error = -1
		SET @error_message = 'Não foi possivel salvar o pedido, existe um feriado que coincide com a data de entrega :'+
		replace(convert(char(11),@DataEntrega,113),' ','-')
		SELECT @error, @error_message
		 
	END
	
END
END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 16/11/2018
-- Update date: 30/04/2022
-- Description:	Travar cotação caso a data de entrega coincida com agendamento de Bloqueio
-- Documentos:  Cotação
-- GLPI ID: 5915
-- GLPI ID Atualizações:
-----------------------------------------------------------------------------------------------------------------------
--IF (@object_type = '23') and (@transaction_type in ('A'))--'23' = Cotação de Vendas
--BEGIN

--DECLARE @DataEntregaAGBloqCOT DATETIME SET @DataEntregaAGBloqCOT = (SELECT DocDueDate FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))
--DECLARE @CodigoPNAGBloqCOT nvarchar(10) =(SELECT CardCode FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))
--DECLARE @Filial5915COT Numeric = (SELECT BPLId FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del )

--IF EXISTS(
--SELECT  U_RAL_CardCode,U_RAL_CardName,U_RAL_DataInicial,U_RAL_DataFinal	
--FROM [@RAL_AGENDACLIENTES]
--WHERE U_BPLId = @Filial5915COT AND U_RAL_StatusEntrega = 'Bloqueada'  AND 
--(@DataEntregaAGBloqCOT between U_RAL_DataInicial AND U_RAL_DataFinal ) 
--AND 
--(@DataEntregaAGBloqCOT between U_RAL_DataInicial AND U_RAL_DataFinal ) 
--AND U_RAL_CardCode = @CodigoPNAGBloqCOT
--)
--BEGIN
--	SET @error = -5915
--	SET @error_message = 'Não foi possivel salvar o pedido, existe um bloqueio para a data de entrega :'+
--	replace(convert(char(11),@DataEntregaAGBloqCOT,113),' ','-')
--	SELECT @error, @error_message
--END
--END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 16/11/2018
-- Update date: 30/04/2022
-- Description:	Travar Cotação caso a data de entrega coincida com feriado e nao possua agendamento de autorização
-- Documentos:  Cotação de Vendas
-- GLPI ID: 5915
-- GLPI ID Atualizações: --comentei a trava em 11/10/2023 para evitar que bloqueie pedidos do edi
-----------------------------------------------------------------------------------------------------------------------
--IF (@object_type = '23') and (@transaction_type in ('A'))--'23' = Cotação de Vendas
--BEGIN

--DECLARE @PaisCOT nvarchar(30)
--DECLARE @EstadoCOT nvarchar(30)
--DECLARE @MunicipioCOT nvarchar(30)
--DECLARE @MesCOT INT =  (SELECT DATEPART ( MONTH ,(SELECT DocDueDate FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del)) )
--DECLARE @DiaCOT INT = (SELECT DATEPART ( DAY ,(SELECT DocDueDate FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del)) )
--DECLARE @DataEntregaCOT DATETIME SET @DataEntregaCOT = (SELECT DocDueDate FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))
--DECLARE @CodigoPNCOT nvarchar(10) =(SELECT CardCode FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))
--DECLARE @Filial5915COTB Numeric = (SELECT BPLId FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del )

----primeiro tem que pegar os dados do local de entrega(Pais, estado, municipio)
--SELECT 
--@MunicipioCOT = (CASE WHEN T8.U_Municipio IS NULL OR T8.U_Municipio = '' THEN T3.Name ELSE T8.U_Municipio END) ,
--@EstadoCOT = (CASE WHEN T8.U_Estado IS NULL OR T8.U_Estado = '' THEN T3.State ELSE T8.U_Estado END),
--@PaisCOT=T3.Country
--FROM OCRD T0 
--INNER JOIN OCRG T1 ON T0.GroupCode = T1.GroupCode
--INNER JOIN CRD1 T2 ON T0.CardCode = T2.CardCode
--INNER JOIN OCNT T3 ON T2.County = T3.AbsId
--LEFT JOIN [@RAL_MACROREGIAO1] T4 ON T4.U_Municipio = T3.Name
--LEFT JOIN [@RAL_MACROREGIAO] T5 ON T5.DocEntry= T4.DocEntry 
--LEFT JOIN OQUT T6 ON T6.CardCode = T0.CardCode 
--LEFT JOIN [@RAL_LOCALENTREGA] T7 on T6.U_LocalEntregaId = T7.DocEntry AND t7.U_BPLId = T6.BPLId
--LEFT JOIN [@RAL_LOCALENTREGA1] T8 on T8.DocEntry = T7.DocEntry 
--WHERE T2.Address='FATURAMENTO' AND T0.CardCode = @CodigoPNCOT
--AND T6.DocEntry = @list_of_cols_val_tab_del


----Depois deve-se verificar com base nos dados do local de entrega, se existe algum feriado nacional, estadual ou municipal
--IF EXISTS(
----Verificar apenas feriados nacionais
--SELECT T0.DocEntry,T1.U_RAL_Mes,T1.U_RAL_Dia,T1.U_RAL_Descricao,'Nacional' as 'Tipo' FROM [@RAL_FERIADOS] T0 
--INNER JOIN [@RAL_FERIADOS1] T1 ON T0.DocEntry = T1.DocEntry 
--WHERE T0.U_BPLId = @Filial5915COTB AND T0.U_RAL_Pais = @PaisCOT AND T0.U_RAL_Estado IS NULL AND T0.U_RAL_Municipio IS NULL 
--AND (T1.U_RAL_Dia >= @DiaCOT AND T1.U_RAL_Dia <= @DiaCOT )AND( T1.U_RAL_Mes>= @MesCOT AND T1.U_RAL_Mes<= @MesCOT) 
--UNION
----Verificar apenas feriados estaduais
--SELECT T0.DocEntry,T1.U_RAL_Mes,T1.U_RAL_Dia,T1.U_RAL_Descricao,'Estadual' as 'Tipo' FROM [@RAL_FERIADOS] T0 
--INNER JOIN [@RAL_FERIADOS1] T1 ON T0.DocEntry = T1.DocEntry
--WHERE T0.U_BPLId = @Filial5915COTB AND T0.U_RAL_Pais = @PaisCOT AND T0.U_RAL_Estado =@EstadoCOT AND T0.U_RAL_Municipio IS NULL 
--AND (T1.U_RAL_Dia >= @DiaCOT AND T1.U_RAL_Dia <= @DiaCOT )AND( T1.U_RAL_Mes>=@MesCOT AND T1.U_RAL_Mes<=@MesCOT) 
--UNION 
----verificar apenas feriados municipais
--SELECT T0.DocEntry,T1.U_RAL_Mes,T1.U_RAL_Dia,T1.U_RAL_Descricao,'Municipal' as 'Tipo' FROM [@RAL_FERIADOS] T0 
--INNER JOIN [@RAL_FERIADOS1] T1 ON T0.DocEntry = T1.DocEntry 
--WHERE T0.U_BPLId = @Filial5915COTB AND T0.U_RAL_Pais = @PaisCOT AND T0.U_RAL_Estado =@EstadoCOT AND T0.U_RAL_Municipio = @MunicipioCOT 
--AND (T1.U_RAL_Dia >= @DiaCOT AND T1.U_RAL_Dia <= @DiaCOT )AND( T1.U_RAL_Mes>=@MesCOT AND T1.U_RAL_Mes<=@MesCOT)
--)
----caso exista algum feriado, deve verificar se existe agendamento de autorização
--BEGIN
--	--se nao existe agendamento de autorização , o sistema trava a entrada do pedido
--	IF NOT EXISTS(
--			SELECT  U_RAL_CardCode,U_RAL_CardName,U_RAL_DataInicial,U_RAL_DataFinal	,U_RAL_StatusEntrega
--		    FROM [@RAL_AGENDACLIENTES]
--		    WHERE U_BPLId = @Filial5915COTB AND U_RAL_StatusEntrega = 'Autorizada' AND
--		    (@DataEntregaCOT between U_RAL_DataInicial AND U_RAL_DataFinal )
--		    AND 
--		    (@DataEntregaCOT between U_RAL_DataInicial AND U_RAL_DataFinal ) 
--		    AND U_RAL_CardCode = @CodigoPNCOT
--	)
--	BEGIN
--		SET @error = -5915
--		SET @error_message = 'Não foi possivel salvar a cotação, existe um feriado que coincide com a data de entrega :'+
--		replace(convert(char(11),@DataEntregaCOT,113),' ','-')
--		SELECT @error, @error_message
		 
--	END
	
--END
--END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 08/11/2018
-- Update Date: 
-- Description: Trava P/ Recebimento de mercadorias sem imposto
-- Documento: Recebimento de Mercadorias
-- GLPI ID:6038
-- GLPI ID Atualização:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '20') and (@transaction_type in ('U','A'))--Recebimento de mercadorias
BEGIN 
		IF EXISTS(SELECT *FROM  PDN1 WHERE (TaxCode IS NULL  OR TaxCode = '')
				AND DocEntry = @list_of_cols_val_tab_del)
		BEGIN
			SET @error = -6038
			SET @error_message = 'Obrigatório o preenchimento do campo Código de Imposto na linha do documento'
			SELECT @error, @error_message		
		END
	
END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 06/11/2018
-- Update Date: 
-- Description: Trava P/ Cancelamento de notas fiscais - Restrito ao Grupo Contábil/Fiscal
-- Documento: Entrega,Devolução,NF de Saída e Dev. NF de Saída
-- Recebimento de Mercadorias,Devolução de Mercadorias,Nota Fiscal de Entrada,Dev. NF de Entrada,NF Recebimento Futuro
-- GLPI ID:5953
-- GLPI ID Atualização:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '13') and (@transaction_type in ('U','A'))--Nota Fiscal de Saída
BEGIN 
DECLARE @Canceled5953NFS varchar (10) =(SELECT CANCELED FROM OINV WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @TipoNF5953NFS int = (SELECT SeqCode FROM OINV WHERE DocEntry= @list_of_cols_val_tab_del)
DECLARE @Dep5953NFS int SET @Dep5953NFS = (SELECT u.Department From OINV O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)

	IF(@Dep5953NFS <>8) --8 é o departamento contabil fiscal
	BEGIN
	-- -2 tipo NF campo seq code externo
		IF(@Canceled5953NFS = 'C' AND @TipoNF5953NFS = 27) --27 = Nfe
		BEGIN
			SET @error = -5953
			SET @error_message = 'Apenas colaboradores do setor Contábil/Fiscal possuem autorização para fazer o cancelamento desta NF'
			SELECT @error, @error_message		
		END
	END
END
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '15') and (@transaction_type in ('U','A'))--ENTREGA
BEGIN 
DECLARE @Canceled5953ENT varchar (10) =(SELECT CANCELED FROM ODLN WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @TipoNF5953ENT int = (SELECT SeqCode FROM ODLN WHERE  DocEntry= @list_of_cols_val_tab_del)
DECLARE @Dep5953ENT int SET @Dep5953ENT = (SELECT u.Department From ODLN O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)

	IF(@Dep5953ENT <>8) --8 é o departamento contabil fiscal
	BEGIN
	-- -2 tipo NF campo seq code externo
		IF(@Canceled5953ENT = 'C' AND (@TipoNF5953ENT = 27 OR @TipoNF5953ENT = -2 )) --27 = Nfe -2 externo
		BEGIN
			SET @error = -5953
			SET @error_message = 'Apenas colaboradores do setor Contábil/Fiscal possuem autorização para fazer o cancelamento desta NF'
			SELECT @error, @error_message		
		END
	END
END
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '16') and (@transaction_type in ('U','A'))--DEVOLUÇÂO
BEGIN 
DECLARE @Canceled5953DEV varchar (10) =(SELECT CANCELED FROM ORDN WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @TipoNF5953DEV int = (SELECT SeqCode FROM ORDN WHERE  DocEntry= @list_of_cols_val_tab_del)
DECLARE @Dep5953DEV int SET @Dep5953DEV = (SELECT u.Department From ORDN O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)

	IF(@Dep5953DEV <>8) --8 é o departamento contabil fiscal
	BEGIN
	-- -2 tipo NF campo seq code externo
		IF(@Canceled5953DEV = 'C' AND (@TipoNF5953DEV = 29 OR @TipoNF5953DEV = -2 )) --29 = NFe_ENT -2 = externo
		BEGIN
			SET @error = -5953
			SET @error_message = 'Apenas colaboradores do setor Contábil/Fiscal possuem autorização para fazer o cancelamento desta NF'
			SELECT @error, @error_message		
		END
	END
END

--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '14') and (@transaction_type in ('U','A'))--DEVOLUÇÂO NOTA FISCAL DE SAIDA
BEGIN 
DECLARE @Canceled5953DEVNFS varchar (10) =(SELECT CANCELED FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @TipoNF5953DEVNFS int = (SELECT SeqCode FROM ORIN WHERE  DocEntry= @list_of_cols_val_tab_del)
DECLARE @Dep5953DEVNFS int SET @Dep5953DEVNFS = (SELECT u.Department From ORIN O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)

	IF(@Dep5953DEVNFS <>8) --8 é o departamento contabil fiscal
	BEGIN
	-- -2 tipo NF campo seq code externo
		IF(@Canceled5953DEVNFS = 'C' AND (@TipoNF5953DEVNFS = 29 OR @TipoNF5953DEVNFS = -2 )) --29 = NFe_ENT -2 = externo
		BEGIN
			SET @error = -5953
			SET @error_message = 'Apenas colaboradores do setor Contábil/Fiscal possuem autorização para fazer o cancelamento desta NF'
			SELECT @error, @error_message		
		END
	END
END
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '20') and (@transaction_type in ('U','A'))--Recebimento de mercadorias
BEGIN 
DECLARE @Canceled5953RM varchar (10) =(SELECT CANCELED FROM OPDN WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @TipoNF5953RM int = (SELECT SeqCode FROM OPDN WHERE DocEntry= @list_of_cols_val_tab_del)
DECLARE @Dep5953RM int SET @Dep5953RM = (SELECT u.Department From OPDN O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)
DECLARE @Modelo5953 int = (SELECT Model FROM OPDN WHERE DocEntry = @list_of_cols_val_tab_del)
	IF(@Dep5953RM <>8) --8 é o departamento contabil fiscal
	BEGIN
	-- -2 tipo NF campo seq code externo
		IF(@Canceled5953RM = 'C' AND (@TipoNF5953RM = -2 OR @TipoNF5953RM = 29 OR @TipoNF5953RM = 28 ) 
		AND (@Modelo5953 != NULL AND @Modelo5953 >0)		) --2=externo | --28=NFE_IMP | 29=NFE_Ent
		BEGIN
			SET @error = -5953
			SET @error_message = 'Apenas colaboradores do setor Contábil/Fiscal possuem autorização para fazer o cancelamento desta NF'
			SELECT @error, @error_message		
		END
	END
END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '21') and (@transaction_type in ('U','A'))--Devolução de mercadorias
BEGIN 
DECLARE @Canceled5953DM varchar (10) =(SELECT CANCELED FROM ORPD WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @TipoNF5953DM int = (SELECT SeqCode FROM ORPD WHERE DocEntry= @list_of_cols_val_tab_del)
DECLARE @Dep5953DM int SET @Dep5953DM = (SELECT u.Department From ORPD O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)

	IF(@Dep5953DM <>8) --8 é o departamento contabil fiscal
	BEGIN
	-- -2 tipo NF campo seq code externo
		IF(@Canceled5953DM = 'C' AND (@TipoNF5953DM = -2 OR @TipoNF5953DM = 27)) --2=externo | --27=Nfe
		BEGIN
			SET @error = -5953
			SET @error_message = 'Apenas colaboradores do setor Contábil/Fiscal possuem autorização para fazer o cancelamento desta NF'
			SELECT @error, @error_message		
		END
	END
END
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '18') and (@transaction_type in ('U','A'))--Nota Fiscal de Entrada | NF Receb Futuro
BEGIN 
DECLARE @Canceled5953NFRF varchar (10) =(SELECT CANCELED FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @TipoNF5953NFRF int = (SELECT SeqCode FROM OPCH WHERE DocEntry= @list_of_cols_val_tab_del)
DECLARE @Dep5953NFRF int SET @Dep5953NFRF = (SELECT u.Department From OPCH O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)

	IF(@Dep5953NFRF <>8) --8 é o departamento contabil fiscal
	BEGIN
	-- -2 tipo NF campo seq code externo
		IF(@Canceled5953NFRF = 'C' AND (@TipoNF5953NFRF = -2 OR @TipoNF5953NFRF = 29 OR @TipoNF5953NFRF = 28))--2=externo | --28=NFE_IMP | 29=NFE_En
		BEGIN
			SET @error = -5953
			SET @error_message = 'Apenas colaboradores do setor Contábil/Fiscal possuem autorização para fazer o cancelamento desta NF'
			SELECT @error, @error_message		
		END
	END
END
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '19') and (@transaction_type in ('U','A'))--dev nota fiscal de entrada
BEGIN 
DECLARE @Canceled5953DVNFE varchar (10) =(SELECT CANCELED FROM ORPC WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @TipoNF5953DVNFE int = (SELECT SeqCode FROM ORPC WHERE DocEntry= @list_of_cols_val_tab_del)
DECLARE @Dep5953DVNFE int SET @Dep5953DVNFE = (SELECT u.Department From ORPC O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)

	IF(@Dep5953DVNFE <>8) --8 é o departamento contabil fiscal
	BEGIN
	-- -2 tipo NF campo seq code externo
		IF(@Canceled5953DVNFE = 'C' AND (@TipoNF5953DVNFE = -2 OR @TipoNF5953DVNFE = 27 ))--2=externo | --27=Nfe
		BEGIN
			SET @error = -5953
			SET @error_message = 'Apenas colaboradores do setor Contábil/Fiscal possuem autorização para fazer o cancelamento desta NF'
			SELECT @error, @error_message		
		END
	END
END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 20/10/2017
-- Update Date: 26/10/2017
-- Description:	TRAVA DE DEPÓSITO PARA DEVOLUÇÃO DE NF DE SAIDA DE ACORDO COM O GRUPO DO PRODUTO E TIPO  DE NFE - ID 3812
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '14') and (@transaction_type in ('A'))--'14' = DEVOLUÇÃO DE NF DE SAIDA 
BEGIN
DECLARE @Linhas int set @Linhas = (SELECT MAX(LineNum)FROM RIN1  WHERE DOCENTRY = @list_of_cols_val_tab_del)
DECLARE @Cont1 int = 0
DECLARE @GrupoProduto Nvarchar(255)
DECLARE @TipoNFe Nvarchar(255) SET @TipoNFe = (SELECT SeqCode FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del) 
DECLARE @Deposito Nvarchar(255)
DECLARE @SimplesNacional Nvarchar (10) SET @SimplesNacional = (SELECT  U_RA_SimplesNacional FROM OCRD WHERE
									CardCode = (SELECT CardCode FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del))

WHILE(@Cont1 <  @Linhas+1) -- percorrendo todas as linhas da nf
  BEGIN

  SET @GrupoProduto = (SELECT ItmsGrpCod FROM OITM WHERE ItemCode = (
						SELECT ItemCode FROM RIN1  WHERE LineNum = @Cont1 AND DOCENTRY = @list_of_cols_val_tab_del)) -- pegando grupo de cada produto de cada linha

  SET @Deposito = (SELECT WhsCode FROM RIN1 WHERE LineNum = @Cont1 AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha

	IF(@GrupoProduto = 106 OR @GrupoProduto = 116 OR @GrupoProduto = 117 OR @GrupoProduto = 118 )--if principal
	BEGIN
		IF(@SimplesNacional = 'S')
		BEGIN
			IF(29 = @TipoNFe AND '02.04' != @Deposito)--NFe Ent = 29
			BEGIN
				SET @error = -1
				SET @error_message = 'Devolução com NF de cliente o depósito deve ser = 02.04 em caso de cliente SIMPLES NACIONAL verificar parceiro de negócios!'
				SELECT @error, @error_message
			END
		END -- END IF SIMPLES NACIONAL
		ELSE
		BEGIN
			IF(-2 = @TipoNFe AND '02.04' != @Deposito)-- Externo = -2
			BEGIN
				SET @error = -1
				SET @error_message = 'Devolução com NF de cliente o depósito deve ser = 02.04 em caso de cliente SIMPLES NACIONAL verificar parceiro de negócios!'
				SELECT @error, @error_message
			END
			IF(29 = @TipoNFe AND ('02.03' != @Deposito AND '02.19'!= @Deposito AND '02.35'!= @Deposito))--NFe Ent = 29
			BEGIN
				SET @error = -1
				SET @error_message = 'Retorno com NF própria o depósito deve ser = 02.03, 02.19 ou 02.35!'
				SELECT @error, @error_message
			END
		END -- END ELSE IF SIMPLES NACIONAL
	END-- end if principal
	Set @Cont1 = @Cont1 +1
  END--END while
END; -- END GERAL
--------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 25/04/2018
-- Update Date: 30/04/2022
-- Description:	Preencher os campos de usuário: Local de Entrega id, Line local id.
-- Documentos:  Pedido de Venda
-- GLPI ID: 4644
-- GLPI ID Atualizações:5771
-----------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'17') and (@transaction_type in ('A','U'))--'17' = Pedido de Venda 
BEGIN
DECLARE @LocalEntregaID  Numeric = 0
DECLARE @LineLocalEntregaID NUmeric = 0
DECLARE @U_RAL_LocalEntrega NVarchar (254)
DECLARE @U_LocalEntrega Nvarchar (254)
DECLARE @U_CardCode NVARCHAR (254)
DECLARE @Filial4644 Numeric = (SELECT BPLId FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del )

	SET @U_RAL_LocalEntrega = (SELECT U_RAL_LocalEntrega FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)
	SET @U_CardCode = (SELECT CardCode FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del)

	IF(@U_RAL_LocalEntrega IS NOT NULL AND @U_RAL_LocalEntrega <> '')
	BEGIN
			--id local entrega 
			SET @LocalEntregaID = (SELECT T1.DocEntry
			FROM [@RAL_LOCALENTREGA1] T0
			INNER JOIN  [@RAL_LOCALENTREGA] T1 ON T0.DocEntry = T1.DocEntry
			WHERE T1.U_BPLId = @Filial4644 AND T0.U_IDEndereco = @U_RAL_LocalEntrega AND  T1.U_CardCode = @U_CardCode)
			--id linha local entrega
			SET  @LineLocalEntregaID =(SELECT T0.LineId	FROM [@RAL_LOCALENTREGA1] T0
			INNER JOIN  [@RAL_LOCALENTREGA] T1 ON T0.DocEntry = T1.DocEntry
			WHERE T1.U_BPLId = @Filial4644 AND T0.U_IDEndereco = @U_RAL_LocalEntrega AND  T1.U_CardCode = @U_CardCode )

			--Município local entrega 
			SET @U_LocalEntrega = (SELECT T0.U_Municipio
			FROM [@RAL_LOCALENTREGA1] T0
			INNER JOIN  [@RAL_LOCALENTREGA] T1 ON T0.DocEntry = T1.DocEntry
			WHERE T1.U_BPLId = @Filial4644 AND T0.U_IDEndereco = @U_RAL_LocalEntrega AND  T1.U_CardCode = @U_CardCode)

		

			UPDATE ORDR SET U_LineLocalId = Convert(nvarchar,@LineLocalEntregaID) , U_LocalEntregaId = Convert(NVarchar,@LocalEntregaID)
			,U_LocalEntregaLabel = @U_RAL_LocalEntrega, U_LocalEntrega = @U_LocalEntrega,U_RAL_LocalEntrega=@U_RAL_LocalEntrega,
			U_MacroRegiaoId = @U_LocalEntrega
			WHERE DocEntry = @list_of_cols_val_tab_del;
				
	END
END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 25/04/2018
-- Update Date: 30/04/2022
-- Description:	Preencher os campos de usuário: Local de Entrega id, Line local id.
-- Documentos:  Cotação de Venda
-- GLPI ID: 4644
-- GLPI ID Atualizações:5771
-----------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'23') and (@transaction_type in (N'A',N'U'))--'23' = Cotação de Venda
BEGIN
DECLARE @LocalEntregaIDQ  Numeric = 0
DECLARE @LineLocalEntregaIDQ NUmeric = 0
DECLARE @U_RAL_LocalEntregaQ NVarchar (254)
DECLARE @U_LocalEntregaQ NVarchar (254)
DECLARE @U_CardCodeQ NVARCHAR (254)
DECLARE @Filial4644Q Numeric = (SELECT BPLId FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del )

	SET @U_RAL_LocalEntregaQ = (SELECT U_RAL_LocalEntrega FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del)
	SET @U_CardCodeQ = (SELECT CardCode FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del)

	IF(@U_RAL_LocalEntregaQ IS NOT NULL AND @U_RAL_LocalEntregaQ <> '')
	BEGIN
			--id local entrega 
			SET @LocalEntregaIDQ = (SELECT T1.DocEntry
			FROM [@RAL_LOCALENTREGA1] T0
			INNER JOIN  [@RAL_LOCALENTREGA] T1 ON T0.DocEntry = T1.DocEntry
			WHERE T1.U_BPLId = @Filial4644Q AND T0.U_IDEndereco = @U_RAL_LocalEntregaQ AND  T1.U_CardCode = @U_CardCodeQ)
			--id linha local entrega
			SET  @LineLocalEntregaIDQ =(SELECT T0.LineId	FROM [@RAL_LOCALENTREGA1] T0
			INNER JOIN  [@RAL_LOCALENTREGA] T1 ON T0.DocEntry = T1.DocEntry
			WHERE T1.U_BPLId = @Filial4644Q AND T0.U_IDEndereco = @U_RAL_LocalEntregaQ AND  T1.U_CardCode = @U_CardCodeQ)

			--Município local entrega 
			SET @U_LocalEntregaQ = (SELECT T0.U_Municipio
			FROM [@RAL_LOCALENTREGA1] T0
			INNER JOIN  [@RAL_LOCALENTREGA] T1 ON T0.DocEntry = T1.DocEntry
			WHERE T1.U_BPLId = @Filial4644Q AND T0.U_IDEndereco = @U_RAL_LocalEntregaQ AND  T1.U_CardCode = @U_CardCodeQ)

			
			UPDATE OQUT SET U_LineLocalId = Convert(nvarchar,@LineLocalEntregaIDQ) , U_LocalEntregaId = Convert(NVarchar,@LocalEntregaIDQ)
			,U_LocalEntregaLabel = @U_RAL_LocalEntregaQ, U_LocalEntrega = @U_LocalEntregaQ,U_RAL_LocalEntrega=@U_RAL_LocalEntregaQ,
			U_MacroRegiaoId = @U_LocalEntregaQ
			WHERE DocEntry = @list_of_cols_val_tab_del;
				
	END
END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 04/09/2018
-- Update Date: 
-- Description: Validar o Município na Linha como obrigatório.
-- Documento: Picking 
-- GLPI ID:5724
-- GLPI ID Atualização:
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = 'CadLocalEntrega') and (@transaction_type in ('A','U'))-- Local de Entrega
BEGIN 
	DECLARE @Municipio5724 nvarchar (255) 
	DECLARE @Cont5724 INT = 1
	DECLARE @Linhas5724 INT = (SELECT Max(LineId) FROM  [@RAL_LOCALENTREGA1] WHERE  DocEntry = @list_of_cols_val_tab_del )
	
	WHILE(@Cont5724 <=@Linhas5724)
		BEGIN
			SET @Municipio5724 = (SELECT U_Municipio FROM  [@RAL_LOCALENTREGA1] 
						WHERE LineId = @Cont5724 AND DocEntry = @list_of_cols_val_tab_del)--@list_of_cols_val_tab_del)
			IF(@Municipio5724 IS NULL OR @Municipio5724 = '')
			BEGIN
				SET @error = -5724
				SET @error_message = 'É obrigatorio o preenchimento do campo município!.'
				SELECT @error, @error_message
			END

			SET @Cont5724 = @Cont5724 + 1
		END
END
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 21/12/2017
-- Update Date: 15/08/2018
-- Description:	Bloqueio de NF em Duplicidade
-- Documentos: NF de entrada,DEVOLUÇÂO NOTA FISCAL DE SAIDA
-- GLPI ID:4194
-- GLPI ID Atualização:5505,5633
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '18') and (@transaction_type in ('A'))--'18' = NF DE ENTRADA
BEGIN
	--Se N° NF for Externo
	IF((SELECT SeqCode FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del) = -2)
	BEGIN		
		IF EXISTS(SELECT * FROM [dbo].[RAL_Opch] WHERE CardCode = (SELECT CardCode FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del)
		  AND Serial  = (SELECT Serial FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del) 
		  AND DoCentry <> @list_of_cols_val_tab_del AND Canceled='N' 
		  AND Model =  (SELECT model FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del)
		  AND SeriesStr =   (SELECT [dbo].[SeriesStrOPCH]( @list_of_cols_val_tab_del)) )
		BEGIN
			SET @error = -4194
			SET @error_message = 'NF ENTRADA - Não foi possível concluir. Número de NF já existente para esse parceiro.'
			SELECT @error, @error_message
		END
	END
	
END;
--------------------------------------------------------------------------------------------------------------------------------
-- DEVOLUÇÂO NOTA FISCAL DE SAIDA 
---------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '14') and (@transaction_type in ('A'))--'14' = DEVOLUÇÂO NOTA FISCAL DE SAIDA
BEGIN
	--Se N° NF for Externo
	IF((SELECT SeqCode FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del) = -2)
	BEGIN		
		IF EXISTS(SELECT * FROM [dbo].[RAL_Orin] WHERE CardCode = (SELECT CardCode FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del)
		  AND Serial  = (SELECT Serial FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del) 
		  AND DoCentry <> @list_of_cols_val_tab_del AND Canceled='N' 
		  AND Model =  (SELECT model FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del)
		  AND SeriesStr =  (SELECT [dbo].[SeriesStrORIN]( @list_of_cols_val_tab_del)))
		BEGIN
			SET @error = -5505
			SET @error_message = 'DEV NF SAÍDA - Não foi possível concluir. Número de NF já existente para esse parceiro.'
			SELECT @error, @error_message
		END
	END
	
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- AuthorUpdate:leonardo do Prado Gomes
-- Create date: 20/06/2018
-- Update Date: 26/04/2024
-- Description:  Adição e alteração de registro de Lista de Picking
-- DescriptionUpdate: Melhoria na Contagem de OC, aplicado CASE para tratar valor Nulo.
-- Documento: Picking 
-- GLPI ID:5261
-- GLPI ID Atualização:
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
				Group by T1.U_OC_num)A) = 1 ) --Se só houver 1 oc entra no if
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
-- Author:Henrique Truyts
-- Create date: 20/06/2018
-- Update Date: 
-- Description: Atualizar dados da OC ao cancelar o Picking
-- Documento: Picking
-- GLPI ID:5261 item 2
-- GLPI ID Atualizações:
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '156') and (@transaction_type in ('U'))--'156' = Picking
BEGIN
DECLARE @PKCancelado char(1) = (SELECT U_RAL_Cancelado FROM OPKL WHERE AbsEntry = @list_of_cols_val_tab_del )

	IF(@PKCancelado = 'Y')
	BEGIN
		IF((SELECT U_Num_picking FROM [@BIM_ORDEMCARGA]  
		WHERE DocEntry IN(
			SELECT	distinct T1.U_OC_num FROM PKL1 T0 
			INNER JOIN RDR1 T1 ON T1.DocEntry = T0.OrderEntry AND T1.LineNum = T0.OrderLine
			INNER JOIN [@BIM_ORDEMCARGA] T2 ON T2.DocEntry = T1.U_OC_num
			WHERE T0.AbsEntry = @list_of_cols_val_tab_del AND  T2.U_piking_checkbox = 'Y')) = @list_of_cols_val_tab_del )


		BEGIN
		UPDATE [@BIM_ORDEMCARGA] SET U_Num_picking = null, U_RAL_NumPick = (SELECT dbo.PickingsdaOCCancelamento(@list_of_cols_val_tab_del))
		WHERE DocEntry IN(
			SELECT	distinct T1.U_OC_num FROM PKL1 T0 
			INNER JOIN RDR1 T1 ON T1.DocEntry = T0.OrderEntry AND T1.LineNum = T0.OrderLine
			INNER JOIN [@BIM_ORDEMCARGA] T2 ON T2.DocEntry = T1.U_OC_num
			WHERE T0.AbsEntry = @list_of_cols_val_tab_del AND  T2.U_piking_checkbox = 'Y');
		END
	ELSE 
		BEGIN
			UPDATE [@BIM_ORDEMCARGA] SET U_RAL_NumPick = (SELECT dbo.PickingsdaOCCancelamento(@list_of_cols_val_tab_del))
		WHERE DocEntry IN(
			SELECT	distinct T1.U_OC_num FROM PKL1 T0 
			INNER JOIN RDR1 T1 ON T1.DocEntry = T0.OrderEntry AND T1.LineNum = T0.OrderLine
			INNER JOIN [@BIM_ORDEMCARGA] T2 ON T2.DocEntry = T1.U_OC_num
			WHERE T0.AbsEntry = @list_of_cols_val_tab_del AND  T2.U_piking_checkbox = 'Y');
		END
	END--END IF
END--END GERAL
--------------------------------------------------------------------------------------------------------------------------------
--END
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 24/01/2018
-- Update Date: 20/06/2018
-- Description: Validação de Picking
-- Documento: Picking 
-- GLPI ID:4243
-- GLPI IG Atualização:5261
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '156') and (@transaction_type in ('A'))--'156' = Picking
BEGIN
	IF EXISTS(SELECT * FROM [@BIM_ORDEMCARGA] WHERE U_piking_checkbox='N' AND DocEntry in (
			SELECT	T1.U_OC_num FROM PKL1 T0 
			INNER JOIN RDR1 T1 ON T1.DocEntry = T0.OrderEntry AND T1.LineNum = T0.OrderLine
			INNER JOIN [@BIM_ORDEMCARGA] T2 ON T2.DocEntry = T1.U_OC_num
			WHERE T0.AbsEntry =  @list_of_cols_val_tab_del ))  
	BEGIN
		SET @error = -1
		SET @error_message = 'Existe OC sem liberação para Picking. Verifique.'
		SELECT @error, @error_message
	END
	ELSE 
	BEGIN
		UPDATE [@BIM_ORDEMCARGA] SET U_Num_picking = @list_of_cols_val_tab_del, U_RAL_NumPick = (SELECT dbo.PickingsdaOC(@list_of_cols_val_tab_del)) WHERE DocEntry IN(
			SELECT	distinct T1.U_OC_num FROM PKL1 T0 
			INNER JOIN RDR1 T1 ON T1.DocEntry = T0.OrderEntry AND T1.LineNum = T0.OrderLine
			INNER JOIN [@BIM_ORDEMCARGA] T2 ON T2.DocEntry = T1.U_OC_num
			WHERE T0.AbsEntry = @list_of_cols_val_tab_del AND  T2.U_piking_checkbox = 'Y');

				UPDATE OPKL SET Remarks = 'OC '+(	SELECT STUFF((SELECT Distinct	',' + CONVERT(nvarchar,T1.U_OC_num) FROM PKL1 T0 
			INNER JOIN RDR1 T1 ON T1.DocEntry = T0.OrderEntry AND T1.LineNum = T0.OrderLine
			INNER JOIN [@BIM_ORDEMCARGA] T2 ON T2.DocEntry = T1.U_OC_num
			WHERE T0.AbsEntry = @list_of_cols_val_tab_del AND  T2.U_piking_checkbox = 'Y'
		FOR XML PATH('')), 1, 1, '') ) WHERE AbsEntry = @list_of_cols_val_tab_del;

	END 
END
----------------------------------------------------------------------------------------------------------------------------------
---- END
----------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 26/10/2017
-- Update Date: 10/05/2018
-- Description: TRAVA DE MODELO E CHAVE DE ACESSO NF ENTRADA, DEVOLUÇÃO E DEV DE NF DE SAIDA - Chamado 3811
-- GLPI ID:3811
-- GLPI ID Atualização:5041
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @Model int
DECLARE @ChaveAcesso NVARCHAR(100)
DECLARE @SqCode int = 0
IF (@object_type = '18') and (@transaction_type in ('A','U'))--'13' = NOTA FISCAL DE ENTRADA
BEGIN
	SET @SqCode = (SELECT SeqCode FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del )
	IF(@SqCode = -2)
	BEGIN
		--VALIDAÇÃO MODELO DA NF
		SET @Model = (SELECT Model FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del )
		IF(@Model = 0)
		BEGIN
			SET @error = -3811
			SET @error_message = 'Obrigatório preencher o modelo da NF!'
			SELECT @error, @error_message
		END--END IF
		ELSE IF (@Model = 39 OR @Model = 44 OR @Model = 45)--NFE e Modelo CTe
		BEGIN
			--VALIDAÇÃO CHAVE DE ACESSO
			SET @ChaveAcesso = (SELECT U_chaveacesso FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del )
			IF (@ChaveAcesso IS NULL OR len(@ChaveAcesso)<>44 )
			BEGIN
				SET @error = -3811
				SET @error_message = 'Chave de Acesso incorreta!'
				SELECT @error, @error_message
			END
			--VALIDAÇÂO DA SERIE
			IF((SELECT SeriesStr FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del) IS  NULL OR 
			   (SELECT SeriesStr FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del) ='')
			BEGIN
				IF((SELECT convert(Numeric,substring(@ChaveAcesso,23,3))) <>0)
				BEGIN
					SET @error = -5041
					SET @error_message = 'Necessário o preenchimento do campo Serie da NF!'
					SELECT @error, @error_message
				END
			END
			ELSE IF( (SELECT convert(Numeric,substring(@ChaveAcesso,23,3))) <>
					 (SELECT SeriesStr FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del))
			BEGIN
				SET @error = -5041
				SET @error_message = 'Serie difere da Chave de Acesso!'
				SELECT @error, @error_message
			END
			----VALIDAÇÃO DO NUMERO DA NF
			IF((SELECT convert(Numeric,substring(@ChaveAcesso,26,9))) <>
			(SELECT Serial FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del))
			BEGIN
				SET @error = -5041
				SET @error_message = 'Número da NF difere da Chave de Acesso!'
				SELECT @error, @error_message
			END 
		END--END ELSE
	END -- IF SEQ CODE
END;-- END GERAL
----DEVOLUÇÂO DE NOTA FISCAL DE SAIDA----------------------------------------------------------------
IF (@object_type = '14') and (@transaction_type in ('A'))--'17' = DEVOLUÇÂO DE NOTA FISCAL DE SAIDA
BEGIN
	SET @SqCode = (SELECT SeqCode FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del )
	IF(-2 = @SqCode)
	BEGIN
		--VALIDAÇÃO MODELO DA NF
		SET @Model = (SELECT Model FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del )
		IF(@Model = 0)
		BEGIN
			SET @error = -3811
			SET @error_message = 'Obrigatório preencher o modelo da NF!'
			SELECT @error, @error_message
		END--END IF
		ELSE IF (@Model = 39 OR @Model = 44 OR @Model = 45)--NFE e Modelo CTe
		BEGIN
			--VALIDAÇÃO CHAVE DE ACESSO
			SET @ChaveAcesso = (SELECT U_chaveacesso FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del )
			IF (@ChaveAcesso IS NULL OR len(@ChaveAcesso)<>44 )
			BEGIN
				SET @error = -3811
				SET @error_message = 'Chave de Acesso incorreta!'
				SELECT @error, @error_message
			END
			--VALIDAÇÂO DA SERIE
			IF((SELECT SeriesStr FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del) IS  NULL OR 
			   (SELECT SeriesStr FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del) ='')
			BEGIN
				IF((SELECT convert(Numeric,substring(@ChaveAcesso,23,3))) <>0)
				BEGIN
					SET @error = -5041
					SET @error_message = 'Necessário o preenchimento do campo Serie da NF!'
					SELECT @error, @error_message
				END
			END
			ELSE IF( (SELECT convert(Numeric,substring(@ChaveAcesso,23,3))) <>
					 (SELECT SeriesStr FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del))
			BEGIN
				SET @error = -5041
				SET @error_message = 'Serie difere da Chave de Acesso!'
				SELECT @error, @error_message
			END
			--VALIDAÇÃO DO NUMERO DA NF
			IF((SELECT convert(Numeric,substring(@ChaveAcesso,26,9))) <>
			(SELECT Serial FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del))
			BEGIN
				SET @error = -5041
				SET @error_message = 'Número da NF difere da Chave de Acesso!'
				SELECT @error, @error_message
			END 
		END--END ELSE
	END -- IF SEQ CODE
END;-- END GERAL
----DEVOLUÇÂO----------------------------------------------------------------------------------------
IF (@object_type = '16') and (@transaction_type in ('A'))--'17' = DEVOLUÇÂO
BEGIN
	SET @SqCode = (SELECT SeqCode FROM ORDN WHERE DocEntry = @list_of_cols_val_tab_del )
	IF(-2 = @SqCode)
	BEGIN
		--VALIDAÇÃO MODELO DA NF
		SET @Model = (SELECT Model FROM ORDN WHERE DocEntry = @list_of_cols_val_tab_del )
		IF(@Model = 0)
		BEGIN
			SET @error = -3811
			SET @error_message = 'Obrigatório preencher o modelo da NF!'
			SELECT @error, @error_message
		END--END IF
		ELSE IF (@Model = 39 OR @Model = 44 OR @Model = 45)--NFE e Modelo CTe
		BEGIN
			--VALIDAÇÃO CHAVE DE ACESSO
			SET @ChaveAcesso = (SELECT U_chaveacesso FROM ORDN WHERE DocEntry = @list_of_cols_val_tab_del )
			IF (@ChaveAcesso IS NULL OR len(@ChaveAcesso)<>44 )
			BEGIN
				SET @error = -3811
				SET @error_message = 'Chave de Acesso incorreta!'
				SELECT @error, @error_message
			END

			--VALIDAÇÂO DA SERIE
			IF((SELECT SeriesStr FROM ORDN WHERE DocEntry = @list_of_cols_val_tab_del) IS  NULL OR 
			   (SELECT SeriesStr FROM ORDN WHERE DocEntry = @list_of_cols_val_tab_del) ='')
			BEGIN
				IF((SELECT convert(Numeric,substring(@ChaveAcesso,23,3))) <>0)
				BEGIN
					SET @error = -5041
					SET @error_message = 'Necessário o preenchimento do campo Serie da NF!'
					SELECT @error, @error_message
				END
			END
			ELSE IF( (SELECT convert(Numeric,substring(@ChaveAcesso,23,3))) <>
					 (SELECT SeriesStr FROM ORDN WHERE DocEntry = @list_of_cols_val_tab_del))
			BEGIN
				SET @error = -5041
				SET @error_message = 'Serie difere da Chave de Acesso!'
				SELECT @error, @error_message
			END
			--VALIDAÇÃO DO NUMERO DA NF
				IF((SELECT convert(Numeric,substring(@ChaveAcesso,26,9))) <>
			(SELECT Serial FROM ORDN WHERE DocEntry = @list_of_cols_val_tab_del))
			BEGIN
				SET @error = -5041
				SET @error_message = 'Número da NF difere da Chave de Acesso!'
				SELECT @error, @error_message
			END 
		END--END ELSE
	END -- IF SEQ CODE
END;-- END GERAL
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 01/02/2018
-- Update Date: 08/05/2018 
-- Description: Validação de Geração Picking
-- Documento: Picking
-- GLPI ID:4430
-- GLPI ID Atualizações:5128
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '156') and (@transaction_type in ('A'))--'156' = Picking
BEGIN
	DECLARE @LinhasPicking Numeric = ( SELECT count(*) From pkl1 WHERE AbsEntry =  @list_of_cols_val_tab_del)
	DECLARE @Cont4430 numeric = 0 
	DECLARE @QuantidadeOC Numeric = 0 
	DECLARE @RelQtty4430 Numeric = 0

	WHILE(@Cont4430 < @LinhasPicking)
	BEGIN
		SET @QuantidadeOC = (
					SELECT  CASE WHEN T1.U_Qtde_OC IS NULL THEN 0 ELSE  T1.U_Qtde_OC END
					FROM PKL1 T0 
					INNER JOIN RDR1 T1 ON T1.DocEntry = T0.OrderEntry AND T1.LineNum = T0.OrderLine	
					AND (T1.U_Qtde_OC = T0.RelQtty OR T1.U_Qtde_OC= T0.PickQtty)	-- adicionei essa linha dia 20/03
					INNER JOIN OPKL T2 ON T2.ABSENTRY =T0.AbsEntry
					WHERE T0.AbsEntry =  @list_of_cols_val_tab_del AND T0.PickEntry = @Cont4430 
					AND T2.Status <> 'C'	) 
		SET @RelQtty4430 = (
		SELECT  T0.RelQtty
					FROM PKL1 T0 
					INNER JOIN RDR1 T1 ON T1.DocEntry = T0.OrderEntry AND T1.LineNum = T0.OrderLine	
					AND (T1.U_Qtde_OC = T0.RelQtty OR T1.U_Qtde_OC= T0.PickQtty)	-- adicionei essa linha dia 20/03
					INNER JOIN OPKL T2 ON T2.ABSENTRY =T0.AbsEntry
					WHERE T0.AbsEntry =  @list_of_cols_val_tab_del AND T0.PickEntry = @Cont4430 
					AND T2.Status <> 'C'	) 

		IF(@QuantidadeOC > 0)
			BEGIN
				IF(	@RelQtty4430 <> @QuantidadeOC ) 
				BEGIN
					SET @error = -4430
					SET @error_message = ' - A liberação ('+convert(nvarchar,@RelQtty4430  )+') não pode ser diferente da quantidade da OC ('+
					convert(nvarchar,@QuantidadeOC  )+'). Verifique'
					SELECT @error, @error_message	
				END
			END

	SET @Cont4430 = @Cont4430 +1
	END
END
----------------------------------------------------------------------------------------------------------------------------------
---- END
----------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 25/04/2018
-- Update date: 30/04/2022
-- Description:	Travar Pedido caso o PN tenha Local de Entrega Obrigatorio
-- Documentos:  Pedido de Venda
-- GLPI ID: 4644 Item D
-----------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'17') and (@transaction_type in (N'A',N'U'))--'17' = Pedido de Venda 
BEGIN
DECLARE @ObrigatorioPV  Char(1)
DECLARE @Filial4644D Numeric = (SELECT BPLId FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del )

	SET @ObrigatorioPV = (SELECT U_ObrigatorioPV FROM  [@RAL_LOCALENTREGA] WHERE U_BPLId = @Filial4644D AND U_CardCode = 
							(SELECT CardCode FROM ORDR WHERE DocEntry =  @list_of_cols_val_tab_del))

	IF(@ObrigatorioPV IS NOT NULL AND @ObrigatorioPV = 'Y')
	BEGIN
		IF EXISTS(
			SELECT U_RAL_LocalEntrega, U_LocalEntregaId,U_LineLocalId FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del AND
			( (U_RAL_LocalEntrega is NULL OR  U_RAL_LocalEntrega ='') AND (U_LocalEntregaId IS NULL OR U_LocalEntregaId ='')) )
			BEGIN
				SET @error = -4644
				SET @error_message = 'É obrigatório definir o Local de Entrega para este PN. Verifique.'
				SELECT @error, @error_message	
			END
	END
END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 25/04/2018
-- Update date: 30/04/2022
-- Description:	Travar Cotação caso o PN tenha Local de Entrega Obrigatorio
-- Documentos:  Cotação de Vendas
-- GLPI ID: 4644 Item D
-- GLPI ID Atualizações:
-----------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'23') and (@transaction_type in (N'A',N'U'))--'23' = Cotação de Vendas
BEGIN

DECLARE @ObrigatorioPVQ  Char(1)
DECLARE @Filial4644QD Numeric = (SELECT BPLId FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del )

	SET @ObrigatorioPVQ = (SELECT U_ObrigatorioPV FROM  [@RAL_LOCALENTREGA] WHERE U_BPLId = @Filial4644QD AND U_CardCode = 
							(SELECT CardCode FROM OQUT WHERE DocEntry =  @list_of_cols_val_tab_del))

	IF(@ObrigatorioPVQ IS NOT NULL AND @ObrigatorioPVQ = 'Y')
	BEGIN
		IF EXISTS(
			SELECT U_RAL_LocalEntrega, U_LocalEntregaId,U_LineLocalId FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del AND
			( (U_RAL_LocalEntrega is NULL OR  U_RAL_LocalEntrega ='') AND (U_LocalEntregaId IS NULL OR U_LocalEntregaId ='')) )
			BEGIN
				SET @error = -4644
				SET @error_message = 'É obrigatório definir o Local de Entrega para este PN. Verifique.'
				SELECT @error, @error_message	
			END
	END
END
-----------------------------------------------------------------------------------------------------------------------
--END
-----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 12/03/2017
-- Update Date: 29/08/2023
-- Description: Trava solicitação de compras,Pedido de Compra e NF de Entrada 
-- Documentos: solicitação de compras e NF de Entrada 
-- GLPI ID : 4596
-- GLPI ID Atualizações:15772
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '1470000113') and (@transaction_type in ('A','U'))--'1470000113' = Solicitação de Compra
BEGIN
DECLARE @Linhas4596S Numeric = (SELECT Count(*)FROM PRQ1 WHERE DocEntry = @list_of_cols_val_tab_del) 
DECLARE @Cont4596S Numeric = 0
DECLARE @BlpID4596S Numeric = (SELECT BPLId FROM OPRQ WHERE DocEntry = @list_of_cols_val_tab_del) 

--verificar se a filial for jacarei, a trava só irá atuar na filial jacarei
IF(@BlpID4596S = 2)
BEGIN
	WHILE(@Cont4596S < @Linhas4596S)
	BEGIN
		IF EXISTS (SELECT T0.ItemCode,T0.Project ,T1.ItmsGrpCod
				FROM PRQ1 T0
				INNER JOIN OITM T1 ON T1.ItemCode = T0.ItemCode
				WHERE T0.ItemCode LIKE 'CG%' AND (T0.Project IS Null OR T0.Project ='' )AND
				T1.ItmsGrpCod IN(164,125,141,127,129,126,128,157,135,136,131,137,133,159,138,
				130,146,147,174,123,156) AND T0.DocEntry = @list_of_cols_val_tab_del AND T0.LineNum = @Cont4596S)
		BEGIN
	
		--Se o centro de custo começar com 01 o depósito tem que ser 02.97 
		IF EXISTS (SELECT DocEntry , OcrCode,WhsCode FROM PRQ1 
		WHERE OcrCode LIKE'01.%' AND DocEntry =  @list_of_cols_val_tab_del   AND WhsCode <> '02.97' AND LineNum = @Cont4596S)
		BEGIN
				SET @error = -4596
				SET @error_message = 'Obrigatório depósito 02.97!'
				SELECT @error, @error_message
		END
		--Se o centro de custo começar com 02 o depósito tem que ser 02.99 
		IF EXISTS (SELECT  DocEntry , OcrCode,WhsCode FROM PRQ1 
		WHERE OcrCode LIKE'02.%' AND DocEntry =  @list_of_cols_val_tab_del   AND WhsCode <> '02.99' AND LineNum = @Cont4596S)
		BEGIN
				SET @error = -4596
				SET @error_message = 'Obrigatório depósito 02.99!'
				SELECT @error, @error_message
		END
		--Se o centro de custo começar com 03 o depósito tem que ser 02.95 
		IF EXISTS (SELECT DocEntry , OcrCode,WhsCode FROM PRQ1
		WHERE OcrCode LIKE'03.%' AND DocEntry =  @list_of_cols_val_tab_del  AND WhsCode <> '02.95' AND LineNum = @Cont4596S)
		BEGIN
				SET @error = -4596
				SET @error_message = 'Obrigatório depósito 02.95!'
				SELECT @error, @error_message
		END
		--Se o centro de custo começar com 04 o depósito tem que ser 02.96 
		IF EXISTS (SELECT DocEntry , OcrCode,WhsCode FROM PRQ1 
		WHERE OcrCode LIKE'04.%' AND DocEntry =  @list_of_cols_val_tab_del  AND WhsCode <> '02.96' AND LineNum = @Cont4596S)
		BEGIN
				SET @error = -4596
				SET @error_message = 'Obrigatório depósito 02.96!'
				SELECT @error, @error_message
		END

		END--END IF EXISTS
		SET @Cont4596S = @Cont4596S +1
	END --END WHILE

END--END IF
END --END GERAL 
--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------Nota Fiscal Entrada--------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '18') and (@transaction_type in ('A','U'))--'18' = Nota Fiscal Entrada
BEGIN
DECLARE @Linhas4596E Numeric = (SELECT Count(*)FROM PCH1 WHERE DocEntry = @list_of_cols_val_tab_del) 
DECLARE @Cont4596E Numeric = 0
DECLARE @BlpID4596E Numeric = (SELECT BPLId FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del) 

--verificar se a filial for jacarei, a trava só irá atuar na filial jacarei
IF(@BlpID4596E = 2)
BEGIN
WHILE(@Cont4596E < @Linhas4596E)
	BEGIN
		IF EXISTS (
			SELECT T0.ItemCode,T0.Project ,T1.ItmsGrpCod
			FROM PCH1 T0
			INNER JOIN OITM T1 ON T1.ItemCode = T0.ItemCode
			WHERE T0.ItemCode LIKE 'CG%' AND (T0.Project IS Null OR T0.Project ='' ) AND
			T1.ItmsGrpCod IN(164,125,141,127,129,126,128,157,135,136,131,137,133,159,138,
			130,146,147,174,123,156) AND T0.DocEntry =  @list_of_cols_val_tab_del AND T0.LineNum = @Cont4596E)
		BEGIN
	
		--Se o centro de custo começar com 01 o depósito tem que ser 02.97 
		IF EXISTS (SELECT DocEntry , OcrCode,WhsCode FROM PCH1 
		WHERE OcrCode LIKE'01.%' AND DocEntry =  @list_of_cols_val_tab_del  AND WhsCode <> '02.97' AND LineNum = @Cont4596E)
		BEGIN
				SET @error = -4596
				SET @error_message = 'Obrigatório depósito 02.97!'
				SELECT @error, @error_message
		END
		--Se o centro de custo começar com 02 o depósito tem que ser 02.99 
		IF EXISTS (SELECT  DocEntry , OcrCode,WhsCode FROM PCH1
		WHERE OcrCode LIKE'02.%' AND DocEntry =  @list_of_cols_val_tab_del  AND WhsCode <> '02.99' AND LineNum = @Cont4596E)
		BEGIN
				SET @error = -4596
				SET @error_message = 'Obrigatório depósito 02.99!'
				SELECT @error, @error_message
		END
		--Se o centro de custo começar com 03 o depósito tem que ser 02.95 
		IF EXISTS (SELECT DocEntry , OcrCode,WhsCode FROM PCH1 
		WHERE OcrCode LIKE'03.%' AND DocEntry =  @list_of_cols_val_tab_del  AND WhsCode <> '02.95' AND LineNum = @Cont4596E)
		BEGIN
				SET @error = -4596
				SET @error_message = 'Obrigatório depósito 02.95!'
				SELECT @error, @error_message
		END
		--Se o centro de custo começar com 04 o depósito tem que ser 02.96 
		IF EXISTS (SELECT DocEntry , OcrCode,WhsCode FROM PCH1
		WHERE OcrCode LIKE'04.%' AND DocEntry =  @list_of_cols_val_tab_del  AND WhsCode <> '02.96' AND LineNum = @Cont4596E)
		BEGIN
				SET @error = -4596
				SET @error_message = 'Obrigatório depósito 02.96!'
				SELECT @error, @error_message
		END
		
		END--END IF EXISTS
		SET @Cont4596E = @Cont4596E +1
	END --END WHILE
END--END IF
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts 
-- Create date: 07/03/2018
-- Update date: 19/03/2018
-- Description:	Apagar quantidade OC pedido de venda quando adicionar nota fiscal de saída (vinculada ao pedido).
-- Documentos: Nota fiscal
-- GLPI ID: 4661
-----------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'13') and (@transaction_type in (N'A',N'U'))--'13' = Nota Fiscal 
BEGIN

DECLARE @LinhasNF Numeric = 0
DECLARE @BaseLineNF Numeric = 0
DECLARE @Cont4661 Numeric = 0
DECLARE @CANCEL4661 CHAR(1) SET @CANCEL4661 = (SELECT CANCELED FROM OINV WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @NumeroPedido Numeric =0 
DECLARE @U_Qtde_OC Numeric = 0
DECLARE @U_OC_num  Numeric = 0
DECLARE @U_dtPrevEntregaInicial Datetime 
DECLARE @U_dtPrevEntregaFinal Datetime
DECLARE @U_STATUS NVARCHAR (255)

SET @LinhasNF =  (SELECT MAX(LineNum)FROM INV1  WHERE DocEntry = 26153 )
	WHILE(@Cont4661 <  @LinhasNF+1) -- percorrendo todas as linhas 26018
	BEGIN	
		
			IF((SELECT U_qtde_OC FROM INV1 WHERE DocEntry =@list_of_cols_val_tab_del  AND LineNum = @Cont4661) IS NOT NUll AND 
				(SELECT U_qtde_OC FROM INV1 WHERE DocEntry =@list_of_cols_val_tab_del  AND LineNum = @Cont4661) > 0)
			BEGIN

				SET @NumeroPedido = (SELECT dbo.DocEntryPedido(@list_of_cols_val_tab_del, @Cont4661) )

				IF((SELECT baseType FROM INV1 WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum = @Cont4661 ) = 15)
				BEGIN
					SET @BaseLineNF = (SELECT BaseLine FROM DLN1 WHERE DocEntry = (
					SELECT BaseRef FROM INV1 WHERE DocEntry = @list_of_cols_val_tab_del  AND LineNum = @Cont4661)
					AND LineNum = (SELECT BaseLine FROM INV1 WHERE DocEntry = @list_of_cols_val_tab_del  AND LineNum = @Cont4661))
				END
				ELSE IF((SELECT baseType FROM INV1 WHERE DocEntry = @list_of_cols_val_tab_del  AND LineNum = @Cont4661 ) = 17)
				BEGIN
					SET @BaseLineNF = (SELECT BaseLine FROM INV1 WHERE DocEntry = @list_of_cols_val_tab_del  AND LineNum = @Cont4661)
				END
				
				
				IF(@CANCEL4661 = 'Y')
				BEGIN 		
				
					SET @U_Qtde_OC = (SELECT U_qtde_OC FROM INV1 WHERE DocEntry = @list_of_cols_val_tab_del  AND LineNum = @Cont4661)
					SET @U_OC_num  = (SELECT U_OC_num FROM INV1 WHERE DocEntry  = @list_of_cols_val_tab_del  AND LineNum = @Cont4661)
					SET @U_dtPrevEntregaInicial =  (SELECT U_dtPrevEntregaInicial FROM INV1 WHERE DocEntry = @list_of_cols_val_tab_del  AND LineNum = @Cont4661)
					SET @U_dtPrevEntregaFinal = (SELECT U_dtPrevEntregaFinal FROM INV1 WHERE DocEntry = @list_of_cols_val_tab_del  AND LineNum = @Cont4661)
					SET @U_STATUS = (SELECT U_Status FROM INV1 WHERE DocEntry = @list_of_cols_val_tab_del  AND LineNum = @Cont4661)
					UPDATE  RDR1 SET U_Qtde_OC = @U_Qtde_OC, U_OC_num = @U_OC_num , 
						U_dtPrevEntregaInicial = @U_dtPrevEntregaInicial, U_dtPrevEntregaFinal = @U_dtPrevEntregaFinal,
						U_Status = @U_STATUS
						WHERE DocEntry = @NumeroPedido AND LineNum = @BaseLineNF
				END
				ELSE
				BEGIN	
					UPDATE  RDR1 SET U_Qtde_OC = null, U_OC_num = null , 
					U_dtPrevEntregaInicial = null, U_dtPrevEntregaFinal = null , U_Status= null
					WHERE DocEntry = @NumeroPedido AND LineNum = @BaseLineNF
				END 
			END
			
		SET @Cont4661 = @Cont4661 +1
	END

END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 26/02/2017
-- Update Date: 
-- Description: Travar entrega com pedidos diferentes nas linhas
-- Documentos: ENTREGA
-- GLPI ID : 4738
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '15') and (@transaction_type in ('A'))--'15' = entrega
BEGIN
	IF((SELECT  Count(distinct BaseEntry) FROM DLN1 WHERE DocEntry =  @list_of_cols_val_tab_del) >1)
	BEGIN
		SET @error = -4738
		SET @error_message = 'Não é possível adicionar o documento pois uma ou mais linhas estão relacionadas a Pedidos de Venda diferentes.'
		SELECT @error, @error_message
	END
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 12/03/2017
-- Update Date: 
-- Description: Limpar dados OC ao adicionar pedido
-- Documentos: Pedido de Vendas
-- GLPI ID : 4732
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A'))--'17' = Pedido de Vendas
BEGIN
	
	IF Exists (
		SELECT U_OC_num,U_dtPrevEntregaInicial,U_dtPrevEntregaFinal,U_Status,U_Qtde_OC
		FROM RDR1 T1
		WHERE (U_OC_num IS NOT NULL OR U_dtPrevEntregaInicial IS NOT NULL OR
		U_dtPrevEntregaFinal IS NOT NULL OR U_Status IS NOT NULL OR U_Qtde_OC IS NOT NULL)
		AND DocEntry = @list_of_cols_val_tab_del)
	BEGIN
		UPDATE RDR1 SET U_OC_num = NULL, U_dtPrevEntregaInicial =NULL,U_dtPrevEntregaFinal = NULL,U_Status = NULL,U_Qtde_OC = NULL
		WHERE DocEntry = @list_of_cols_val_tab_del;
	END

	--IF Exists(SELECT header, U_RAL_LocalEntrega FROM ORDR 
	--	WHERE DocEntry = @list_of_cols_val_tab_del AND (header IS NOT NULL OR U_RAL_LocalEntrega IS NOT NULL ))
	--BEGIN
	--	UPDATE ORDR Set --header = null, 
	--	U_RAL_LocalEntrega = null WHERE  DocEntry = @list_of_cols_val_tab_del;
	--END


END
--------------------------------------------------------------------------------------------------------------------------------
-- END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 17/11/2017
-- Update Date: 16/02/2018
-- Description: ESBOÇO - TRAVA DE MODELO E CHAVE DE ACESSO NF ENTRADA, DEVOLUÇÃO E DEV DE NF DE SAIDA - Chamado 3811 
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'112') and (@transaction_type in ('A'))--N'112' = ESBOÇO
BEGIN
DECLARE @EModel int
DECLARE @EChaveAcesso NVARCHAR(100)
DECLARE @ESqCode int = 0
DECLARE @ESObjType int = 0
SET @ESObjType = (SELECT ObjType FROM ODRF WHERE DocEntry = @list_of_cols_val_tab_del )
------DEVOLUÇÂO DE NOTA FISCAL DE SAIDA----------------------------------------------------------------
	IF(@ESObjType = 14)
	BEGIN
	SET @ESqCode = (SELECT SeqCode FROM ODRF WHERE ObjType = 14 AND DocEntry = @list_of_cols_val_tab_del )
	
		IF(-2 = @ESqCode)
		BEGIN
			SET @EModel = (SELECT Model FROM ODRF WHERE ObjType = 14 AND DocEntry = @list_of_cols_val_tab_del )
			IF(@EModel = 0)
			BEGIN
				SET @error = -1
				SET @error_message = 'Obrigatório preencher o modelo da NF!'
				SELECT @error, @error_message
			END--END IF
			ELSE IF (@EModel = 39 OR @EModel = 44)--NFE e Modelo CTe
			BEGIN
				SET @EChaveAcesso = (SELECT U_chaveacesso FROM ODRF WHERE ObjType = 14 AND DocEntry = @list_of_cols_val_tab_del )
				IF (@EChaveAcesso IS NULL OR len(@EChaveAcesso)<>44 )
				BEGIN
					SET @error = -1
					SET @error_message = 'Chave de Acesso incorreta!'
					SELECT @error, @error_message
				END
			END--END ELSE
			END
		END
	END	
	

------DEVOLUÇÂO----------------------------------------------------------------------------------------
	IF(@ESObjType = 16)--'16' = DEVOLUÇÂO
	BEGIN
	SET @ESqCode = (SELECT SeqCode FROM ODRF WHERE ObjType = 16 AND DocEntry = @list_of_cols_val_tab_del )
		IF(-2 = @ESqCode)
		BEGIN
			SET @EModel = (SELECT Model FROM ODRF WHERE ObjType = 16 AND DocEntry = @list_of_cols_val_tab_del )
			IF(@EModel = 0)
			BEGIN
				SET @error = -1
				SET @error_message = 'Obrigatório preencher o modelo da NF!'
				SELECT @error, @error_message
			END--END IF
			ELSE IF (@EModel = 39 OR @EModel = 44)--NFE e Modelo CTe
			BEGIN
				SET @EChaveAcesso = (SELECT U_chaveacesso FROM ODRF WHERE ObjType = 16 AND DocEntry = @list_of_cols_val_tab_del )
				IF (@EChaveAcesso IS NULL OR len(@EChaveAcesso)<>44 )
				BEGIN
					SET @error = -1
					SET @error_message = 'Chave de Acesso incorreta!'
					SELECT @error, @error_message
				END
			END--END ELSE
		END -- IF SEQ CODE
	END
-----NF ENTRADA ---------------------------------------------------------------------------------------------------------------
	IF(@ESObjType = 18)--'18' = NF ENTRADA
	BEGIN
	SET @ESqCode = (SELECT SeqCode FROM ODRF WHERE ObjType = 18 AND DocEntry = @list_of_cols_val_tab_del )
		IF(-2 = @ESqCode)
		BEGIN
		SET @EModel = (SELECT Model FROM ODRF WHERE ObjType = 18 AND DocEntry = @list_of_cols_val_tab_del )
			IF(@EModel = 0)
			BEGIN
				SET @error = -1
				SET @error_message = 'Obrigatório preencher o modelo da NF!'
				SELECT @error, @error_message
			END--END IF
			ELSE IF (@EModel = 39 OR @EModel = 44 OR @EModel = 45)--NFE e Modelo CTe
			BEGIN
				SET @EChaveAcesso = (SELECT U_chaveacesso FROM ODRF WHERE ObjType = 18 AND DocEntry = @list_of_cols_val_tab_del )
				IF (@EChaveAcesso IS NULL OR len(@EChaveAcesso)<>44 )
				BEGIN
					SET @error = -1
					SET @error_message = 'Chave de Acesso incorreta!'
					SELECT @error, @error_message
				END
			END--END ELSE
	END
END;

--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 05/02/2018
-- Update Date: 26/07/2023
-- Description: Não permitir utilizações diferentes na mesma entrega
-- Documentos: Entrega
-- GLPI ID:4454
-- GLPI ID atualização:15618 - por conta da venda de macarrao, que possui cfop diferente, precisamos
-- ajustar a trava para passar a preencher os cfops concatenados de ambas operações
--------------------------------------------------------------------------------------------------------------------------------

IF (@object_type = '15') and (@transaction_type in ('A'))--'15' = ENTREGA
BEGIN
		IF((SELECT COUNT(*)FROM(SELECT DocEntry FROM DLN1 WHERE DocEntry = @list_of_cols_val_tab_del GROUP BY Usage,DocEntry)A) > 1)
		BEGIN
			SET @error = -4454
			SET @error_message = 'Não é permitido utilizações diferentes na mesma entrega.Verifique.'
			SELECT @error, @error_message
		END
		ELSE
		BEGIN
			 --UPDATE ODLN SET U_MW_CFOP = (SELECT Descrip FROM OCFP WHERE Code =
				--(SELECT CFOPCode FROM DLN1 WHERE DocEntry = @list_of_cols_val_tab_del GROUP BY CFOPCode) ) 
				--WHERE DocEntry = @list_of_cols_val_tab_del

		UPDATE ODLN SET U_MW_CFOP = ( 
             SELECT STUFF((SELECT ',' + CONVERT(nvarchar(max),Descrip) 
			 FROM OCFP WHERE Code in(SELECT CFOPCode FROM DLN1 
										WHERE DocEntry = @list_of_cols_val_tab_del GROUP BY CFOPCode)
				FOR XML PATH('')), 1, 1, '')
				 ) 
				WHERE DocEntry = @list_of_cols_val_tab_del
		END
END
--------------------------------------------------------------------------------------------------------------------------------
---- END
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:Henrique Truyts
-- Create date: 22/01/2018
-- Update Date: 30-04-2022
-- Description: Validação de Peso Maximo
-- Documento: Pedido de Vendas
-- GLPI ID:4102
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A','U'))--'17' = PEDIDO DE VENDA
BEGIN
	DECLARE @TotalLinhas4102 NUMERIC = (SELECT COUNT(*) FROM RDR1 WHERE DocEntry = @list_of_cols_val_tab_del )
	DECLARE @Contador4102 NUMERIC = 0
	DECLARE @Peso4102 NUMERIC  = 0	
	DECLARE @NumeroFilial Numeric = (SELECT BPLId FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del )
	DECLARE @PesoMaximo NUMERIC = (SELECT MAX(U_Capacidade_Max) FROM [@BIM_TPO_VEICULO] WHERE U_BPLId = @NumeroFilial  AND U_Prioridade =1)

	WHILE(@Contador4102 < @TotalLinhas4102)
		BEGIN
		SET @Peso4102 = (SELECT Weight1 FROM RDR1 WHERE VisOrder = @Contador4102 AND  DocEntry = @list_of_cols_val_tab_del)

		IF((SELECT dbo.PesoLinhaPedido(@Peso4102,@NumeroFilial)) = 1)
			BEGIN
				SET @error = -4102
				SET @error_message = 'Não é possível adicionar ou atualizar. O peso de uma ou mais linhas ultrapassa a capacidade máxima de cargas da logística, que é de '
				+CONVERT(NVARCHAR, (SELECT dbo.PesoMaximo(@PesoMaximo,@NumeroFilial)))+  'KG . Crie mais linhas no PV para redistribuir as quantidades!'
				SELECT @error, @error_message
			END
		SET @Contador4102 = @Contador4102 +1
		END
END;--END GERAL
----------------------------------------------------------------------------------------------------------------------------------
---- END
----------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 04/01/2018
-- Update Date: 
-- Description:	Trava de Depósito por utilização
-- Documentos: Devolução de Mercadorias, ENTREGA
-- GLPI ID:4222
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @Usage4222 NUMERIC 
DECLARE @Linhas4222 NUMERIC =0
DECLARE @Cont4222 NUMERIC = 0
DECLARE @Deposito4222 Nvarchar(255)
IF (@object_type = '21') and (@transaction_type in ('A'))--'21' = Dev de mercadoria
BEGIN
	SET @Linhas4222 =  (SELECT MAX(LineNum)FROM RPD1 WHERE DocEntry =  @list_of_cols_val_tab_del )
	WHILE(@Cont4222 <  @Linhas4222+1) -- percorrendo todas as linhas
	BEGIN
		SET @Usage4222 = ( SELECT Usage FROM RPD1 WHERE LineNum = @Cont4222 AND DocEntry = @list_of_cols_val_tab_del)
		SET @Deposito4222 = (SELECT WhsCode FROM RPD1 WHERE LineNum = @Cont4222 AND DocEntry = @list_of_cols_val_tab_del)
		--7 = REM INDUST ENCOME | 15 = REM CONSERTO | 39 = OUTRAS ENTRADAS
		IF((@Usage4222 = 7 OR @Usage4222 = 15 OR @Usage4222 = 39 ) AND @Deposito4222 <> '02.99')
		BEGIN
			SET @error = -1
			SET @error_message = 'Obrigatório depósito 02.99 para as utilizações REM INDUST ENCOME,REM CONSERTO e OUTRAS ENTRADAS!!'
			SELECT @error, @error_message
		END

		SET @Cont4222 = @Cont4222 +1
	END

END
--------------------------------------------------------------------------------------------------------------------------------
---ALTERADO NA DATA DE 22/12/2025 ACRESCENTADO NULLIF PARA TRATAR CAMPOS VAZIOS E NÃO NULOS
IF (@object_type = '15') AND (@transaction_type IN ('A','U'))--'15' = entrega
BEGIN
SET @Cont4222 = 0
SET @Linhas4222  = (SELECT MAX(LineNum)FROM DLN1 WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @U_SKILL_cEnq NUMERIC = 0
SET @Deposito4222 = null

		WHILE(@Cont4222 <  @Linhas4222+1) -- percorrendo todas as linhas
		BEGIN
			SET @Usage4222 = ( SELECT Usage FROM DLN1 WHERE LineNum = @Cont4222 AND DocEntry = @list_of_cols_val_tab_del)
			SET @Deposito4222 = (SELECT WhsCode FROM DLN1 WHERE LineNum = @Cont4222 AND DocEntry = @list_of_cols_val_tab_del)
			SET @U_SKILL_cEnq = (SELECT NULLIF(U_SKILL_cEnq,0) FROM DLN1 WHERE LineNum = @Cont4222 AND DocEntry = @list_of_cols_val_tab_del)
			----16 = REM ARMAZANAGEM
			IF(@Usage4222 = 16)
			BEGIN
				IF('02.99' <> @Deposito4222 )
				BEGIN
					SET @error = -1
					SET @error_message = 'Obrigatório depósito 02.99 para a utilização REM ARMAZENAGEM e Cód de Enquadramento de IPI - 103'
					SELECT @error, @error_message
				END
				IF(@U_SKILL_cEnq IS NULL OR @U_SKILL_cEnq <> 103)
				BEGIN
					SET @error = -1
					SET @error_message = 'Obrigatório depósito 02.99 para a utilização REM ARMAZENAGEM e Cód de Enquadramento de IPI - 103'
					SELECT @error, @error_message
				END
			END
		----11 = REM Vazilh Saca
		IF(@Usage4222 = 11  AND @Deposito4222 <> '02.99' )
		BEGIN
			SET @error = -1
			SET @error_message = 'Obrigatório depósito 02.99 para a utilização REM VASILH SACARIA!!'
			SELECT @error, @error_message
		END
		SET @Cont4222 = @Cont4222 + 1
		END	 
END




--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 14/12/2017
-- Update Date: 
-- Description: TRAVA DE DEPOSITO NF TRANSBORDO
-- Documents: RECEBIMENTOS DE MERCADORIAS
--GLPI ID:4168
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '20') and (@transaction_type in ('A'))--'20' = recebimento de mercadorias
BEGIN
DECLARE @Linhas4168 int set @Linhas4168 = (SELECT MAX(LineNum)FROM INV1  WHERE DOCENTRY = @list_of_cols_val_tab_del)
DECLARE @Cont4168 int = 0
DECLARE @Deposito4168 Nvarchar(255)
DECLARE @Util4168 Nvarchar (255)

WHILE(@Cont4168 <  @Linhas4168+1) -- percorrendo todas as linhas da nf
  BEGIN
  
   SET @Deposito4168 = (SELECT WhsCode FROM PDN1 WHERE LineNum = @Cont4168 AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha
   SET @Util4168 = (SELECT Usage FROM PDN1 WHERE LineNum = @Cont4168 AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha

		--USAGE = NF transbordo
		IF( '02.99' != @Deposito4168 AND @Util4168 = 49)
		BEGIN
			SET @error = -1
			SET @error_message = 'NF de Transbordo – utilizar depósito 02.99'
			SELECT @error, @error_message
		END
		--USAGE NF FILHA
		IF( '02.02' != @Deposito4168 AND @Util4168 = 40)
		BEGIN
			SET @error = -1
			SET @error_message = 'NF Filha – utilizar depósito 02.02'
			SELECT @error, @error_message
		END
		
	Set @Cont4168=  @Cont4168 + 1
  END--END while
END; -- END GERAL
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author: Henrique Truyts
-- Create date: 14/12/2017
-- Update Date: 
-- Description:	Preencher os campos Data Entrada/Saída e Hora Entrada e Saída NF-e
-- Documentos: ENTREGA; DEVOLUÇÃO; NF DE SAIDA; DEVOLUÇÃO DE NF DE SAIDA; 
-- RECEBIMENTO DE MERCADORIAS; DEVOLUÇÃO DE MERCADORIAS; NF DE ENTRADA; DEVOLUÇÃO DE NF DE ENTRADA; NF RECEBIMENTO FUTURO; 
-- GLPI ID: 3528
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @SeqCode3825 int = 0
IF (@object_type = '15') and (@transaction_type in ('A','U'))--'15' = ENTREGA - ODLN
BEGIN
	SET @SeqCode3825 = (SELECT SeqCode FROM ODLN WHERE DocEntry = @list_of_cols_val_tab_del)
	
	IF(@SeqCode3825 =29 OR @SeqCode3825 =28 OR @SeqCode3825 = 27 OR @SeqCode3825 = 44) -- NFE_ENT,NFE_IMP,NFE,NFENT_RJ
	BEGIN 
		UPDATE ODLN SET U_SKILL_DtSaida = SMALLDATETIMEFROMPARTS(DATEPART(YEAR,GETDATE()),DATEPART(MONTH,GETDATE()),DATEPART(DAY,GETDATE()),0,0), 
		U_SKILL_HrSaida= ((DATEPART(HOUR,GETDATE()) *100)+ DATEPART(MINUTE,GETDATE())) WHERE DocEntry = @list_of_cols_val_tab_del
	END
END;--END GERAL
IF (@object_type = '16') and (@transaction_type in ('A','U'))--'16' =  DEVOLUÇÃO - ORDN
BEGIN
	SET @SeqCode3825 = (SELECT SeqCode FROM ORDN WHERE DocEntry = @list_of_cols_val_tab_del)

	IF(@SeqCode3825 =29 OR @SeqCode3825 =28 OR @SeqCode3825 = 27 OR @SeqCode3825 = 44) -- NFE_ENT,NFE_IMP,NFE,NFENT_RJ
	BEGIN 
		UPDATE ORDN SET U_SKILL_DtSaida = SMALLDATETIMEFROMPARTS(DATEPART(YEAR,GETDATE()),DATEPART(MONTH,GETDATE()),DATEPART(DAY,GETDATE()),0,0), 
		U_SKILL_HrSaida= ((DATEPART(HOUR,GETDATE()) *100)+ DATEPART(MINUTE,GETDATE())) WHERE DocEntry = @list_of_cols_val_tab_del
	END
END;--END GERAL
IF (@object_type = '13') and (@transaction_type in ('A','U'))--'13' =  NF DE SAIDA - OINV
BEGIN
	SET @SeqCode3825 = (SELECT SeqCode FROM OINV WHERE DocEntry = @list_of_cols_val_tab_del)

	IF(@SeqCode3825 =29 OR @SeqCode3825 =28 OR @SeqCode3825 = 27 OR @SeqCode3825 = 44) -- NFE_ENT,NFE_IMP,NFE,NFENT_RJ
	BEGIN 
		UPDATE OINV SET U_SKILL_DtSaida = SMALLDATETIMEFROMPARTS(DATEPART(YEAR,GETDATE()),DATEPART(MONTH,GETDATE()),DATEPART(DAY,GETDATE()),0,0), 
		U_SKILL_HrSaida= ((DATEPART(HOUR,GETDATE()) *100)+ DATEPART(MINUTE,GETDATE())) WHERE DocEntry = @list_of_cols_val_tab_del
	END
END;--END GERAL
IF (@object_type = '14') and (@transaction_type in ('A','U'))--'14' =  DEVOLUÇÃO DE NF DE SAIDA - ORIN
BEGIN
	SET @SeqCode3825 = (SELECT SeqCode FROM ORIN WHERE DocEntry = @list_of_cols_val_tab_del)

	IF(@SeqCode3825 =29 OR @SeqCode3825 =28 OR @SeqCode3825 = 27 OR @SeqCode3825 = 44) -- NFE_ENT,NFE_IMP,NFE,NFENT_RJ
	BEGIN 
		UPDATE ORIN SET U_SKILL_DtSaida = SMALLDATETIMEFROMPARTS(DATEPART(YEAR,GETDATE()),DATEPART(MONTH,GETDATE()),DATEPART(DAY,GETDATE()),0,0), 
		U_SKILL_HrSaida= ((DATEPART(HOUR,GETDATE()) *100)+ DATEPART(MINUTE,GETDATE())) WHERE DocEntry = @list_of_cols_val_tab_del
	END
END;--END GERAL
IF (@object_type = '20') and (@transaction_type in ('A','U'))--'20' = RECEBIMENTO DE MERCADORIAS - OPDN
BEGIN
	SET @SeqCode3825 = (SELECT SeqCode FROM OPDN WHERE DocEntry = @list_of_cols_val_tab_del)

	IF(@SeqCode3825 =29 OR @SeqCode3825 =28 OR @SeqCode3825 = 27 OR @SeqCode3825 = 44) -- NFE_ENT,NFE_IMP,NFE,NFENT_RJ
	BEGIN 
		UPDATE OPDN SET U_SKILL_DtSaida = SMALLDATETIMEFROMPARTS(DATEPART(YEAR,GETDATE()),DATEPART(MONTH,GETDATE()),DATEPART(DAY,GETDATE()),0,0), 
		U_SKILL_HrSaida= ((DATEPART(HOUR,GETDATE()) *100)+ DATEPART(MINUTE,GETDATE())) WHERE DocEntry = @list_of_cols_val_tab_del
	END
END;--END GERAL
IF (@object_type = '21') and (@transaction_type in ('A','U'))--'21' =  DEVOLUÇÃO DE MERCADORIAS - ORPD
BEGIN
	SET @SeqCode3825 = (SELECT SeqCode FROM ORPD WHERE DocEntry = @list_of_cols_val_tab_del)

	IF(@SeqCode3825 =29 OR @SeqCode3825 =28 OR @SeqCode3825 = 27 OR @SeqCode3825 = 44) -- NFE_ENT,NFE_IMP,NFE,NFENT_RJ
	BEGIN 
		UPDATE ORPD SET U_SKILL_DtSaida = SMALLDATETIMEFROMPARTS(DATEPART(YEAR,GETDATE()),DATEPART(MONTH,GETDATE()),DATEPART(DAY,GETDATE()),0,0), 
		U_SKILL_HrSaida= ((DATEPART(HOUR,GETDATE()) *100)+ DATEPART(MINUTE,GETDATE())) WHERE DocEntry = @list_of_cols_val_tab_del
	END
END;--END GERAL
IF (@object_type = '18') and (@transaction_type in ('A','U'))--'18' =  NF DE ENTRADA E  NF RECEBIMENTO FUTURO - OPCH
BEGIN
	SET @SeqCode3825 = (SELECT SeqCode FROM OPCH WHERE DocEntry = @list_of_cols_val_tab_del)

	IF(@SeqCode3825 =29 OR @SeqCode3825 =28 OR @SeqCode3825 = 27 OR @SeqCode3825 = 44) -- NFE_ENT,NFE_IMP,NFE,NFENT_RJ
	BEGIN 
		UPDATE OPCH SET U_SKILL_DtSaida = SMALLDATETIMEFROMPARTS(DATEPART(YEAR,GETDATE()),DATEPART(MONTH,GETDATE()),DATEPART(DAY,GETDATE()),0,0), 
		U_SKILL_HrSaida= ((DATEPART(HOUR,GETDATE()) *100)+ DATEPART(MINUTE,GETDATE())) WHERE DocEntry = @list_of_cols_val_tab_del
	END
END;--END GERAL
IF (@object_type = '19') and (@transaction_type in ('A','U'))--'19' =  DEVOLUÇÃO DE NF DE ENTRADA - ORPC
BEGIN
	SET @SeqCode3825 = (SELECT SeqCode FROM ORPC WHERE DocEntry = @list_of_cols_val_tab_del)

	IF(@SeqCode3825 =29 OR @SeqCode3825 =28 OR @SeqCode3825 = 27 OR @SeqCode3825 = 44) -- NFE_ENT,NFE_IMP,NFE,NFENT_RJ
	BEGIN 
		UPDATE ORPC SET U_SKILL_DtSaida = SMALLDATETIMEFROMPARTS(DATEPART(YEAR,GETDATE()),DATEPART(MONTH,GETDATE()),DATEPART(DAY,GETDATE()),0,0), 
		U_SKILL_HrSaida= ((DATEPART(HOUR,GETDATE()) *100)+ DATEPART(MINUTE,GETDATE())) WHERE DocEntry = @list_of_cols_val_tab_del
	END
END;--END GERAL
----------------------------------------------------------------------------------------------------------------------------------
---- END
----------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 04/07/2017
-- Update Date: 11/12/2017
-- Description:	Trava para Clientes Bloqueados (caracteristica 24)
-- Documents: Pedido de Vendas e Cotação de vendas
-- GLPI ID: 4129 (OBS esse não é o chamado que deu origem à essa validação)
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas (DepCB = departamentos Clientes Bloqueados
BEGIN

DECLARE @DepCB int SET @DepCB = (SELECT u.Department From ORDR O 
								INNER JOIN OUSR U ON O.UserSign = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)
 IF(@DepCB = 1)	
	BEGIN
		IF  EXISTS (
		SELECT
		t0.QryGroup25,T0.CardCode
		FROM OCRD T0
		WHERE T0.QryGroup25 = 'N' AND T0.QryGroup24 = 'Y' 
		AND T0.CardCode  = ( SELECT CardCode FROM ORDR WHERE DocNum =  @list_of_cols_val_tab_del )
		
		) BEGIN	
				SET @error = -1
				SET @error_message = 'Não é possível adicionar o Pedido. Entrar em contato com o setor de Crédito e Cobrança ou Adm. de Vendas!'
				SELECT @error, @error_message
		  END;
	
	END;
END;--END PRINCIPAL
-------------------------COTAÇÂO DE VENDAS--------------------------------------------------------------------------------------
IF (@object_type = '23') and (@transaction_type in ('A','U'))--'23' = Cotação de Vendas (DepCB = departamentos Clientes Bloqueados
BEGIN

DECLARE @DepCBQ int SET @DepCBQ = (SELECT u.Department From OQUT O 
								INNER JOIN OUSR U ON O.UserSign = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)
 IF(@DepCBQ = 1)	
	BEGIN
		IF  EXISTS (
		SELECT
		t0.QryGroup25,T0.CardCode
		FROM OCRD T0
		WHERE T0.QryGroup25 = 'N' AND T0.QryGroup24 = 'Y' 
		AND T0.CardCode  = ( SELECT CardCode FROM OQUT WHERE DocEntry =  @list_of_cols_val_tab_del )
		
		) BEGIN	
				SET @error = -1
				SET @error_message = 'Não é possível adicionar a Cotação. Entrar em contato com o setor de Crédito e Cobrança ou Adm. de Vendas!'
				SELECT @error, @error_message
		  END;
	
	END;
END;--END PRINCIPAL

--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 17/11/2017
-- Update Date: 
-- Description:	Preencher o campo Grupo de Itens na linha da solicitação, para que apareça o grupo de itens no relatorio
-- de solicitação de compras - chamado ID 3991
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '1470000113') and (@transaction_type in ('A'))--'1470000113' = Solicitação de Compra
BEGIN
DECLARE @QtdLinhasSol INT SET @QtdLinhasSol = (SELECT Count(*) FROM PRQ1 WHERE DocEntry = @list_of_cols_val_tab_del )
DECLARE @ContadorSol INT = 0
DECLARE @GrupoItens INT = 0

	WHILE(@ContadorSol < @QtdLinhasSol)
	BEGIN
		SET @GrupoItens = (SELECT U_RAL_GrupoItens FROM OITM WHERE ItemCode = 
							(SELECT ItemCode FROM PRQ1 WHERE DocEntry = @list_of_cols_val_tab_del AND VisOrder = @ContadorSol))
		IF(@GrupoItens is not null OR @GrupoItens > 0)
		BEGIN
			UPDATE PRQ1 SET U_RAL_GrupoItens = @GrupoItens WHERE DocEntry = @list_of_cols_val_tab_del AND VisOrder = @ContadorSol
		END--END IF
	SET @ContadorSol = @ContadorSol + 1
	END--END WHILE
END;--END GERAL
----------------------------------------------------------------------------------------------------------------------------------
---- END
----------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 20/11/2017
-- Update Date: 
-- Description:	TRAVA DE CÓDIGO DE IMPOSTO E CFOP - ESBOÇO ADIANTAMENTOS - ID 3805
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'112') and (@transaction_type in ('A','U'))--N'112' = ESBOÇO
BEGIN
DECLARE @ESAdObjType int = 0
SET @ESAdObjType = (SELECT ObjType FROM ODRF WHERE DocEntry = @list_of_cols_val_tab_del )

--ADIANTAMENTO FORNECEDOR
	IF (@ESAdObjType = 204)--'204' = ADIANTAMENTO DE FORNECEDOR
	BEGIN

		IF NOT EXISTS( SELECT   T1.TaxCode FROM DRF1 T1	WHERE (T1.TaxCode IS NOT NULL AND T1.TaxCode<>'' ) AND T1.DocEntry = @list_of_cols_val_tab_del )
		BEGIN
			SET @error = -1
			SET @error_message = 'Obrigatório colocar o Código de Imposto!'
			SELECT @error, @error_message
		END
	
		IF NOT EXISTS( SELECT  T1.CFOPCode FROM DRF1 T1 WHERE  ( T1.CFOPCode IS NOT NULL AND  T1.CFOPCode <> '') AND T1.DocEntry = @list_of_cols_val_tab_del )
		BEGIN
			SET @error = -1
			SET @error_message = 'Obrigatório colocar o CFOP!'
			SELECT @error, @error_message
		END
	END;

--ADIANTAMENTO CLIENTE
	IF (@ESAdObjType =  '203') --'203' = ADIANTAMENTO DE CLIENTE
	BEGIN

		IF NOT EXISTS( SELECT   T1.TaxCode FROM DRF1 T1	WHERE (T1.TaxCode IS NOT NULL AND T1.TaxCode<>'' ) AND T1.DocEntry = @list_of_cols_val_tab_del )
		BEGIN
			SET @error = -1
			SET @error_message = 'Obrigatório colocar o Código de Imposto!'
			SELECT @error, @error_message
		END

		IF NOT EXISTS( SELECT  T1.CFOPCode FROM DRF1 T1 WHERE ( T1.CFOPCode IS NOT NULL AND  T1.CFOPCode <> '') AND T1.DocEntry =  @list_of_cols_val_tab_del )
		BEGIN
			SET @error = -1
			SET @error_message = 'Obrigatório colocar o CFOP!'
			SELECT @error, @error_message
		END
	END;
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 24/10/2017
-- Update Date: 09/11/2017
-- Description:	TRAVA DE DOCUMENTO REFERENCIADO - ID 3649
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @Usage int 
DECLARE @RefDocEntr int 
DECLARE @SeqCodes int

--TRANSBORDO - RECEBIMENTO DE MERCADORIA
IF (@object_type = '20') and (@transaction_type in ('A'))--'20' = RECEBIMENTO DE MERCADORIA
BEGIN
SET @Usage = (SELECT Distinct USAGE FROM PDN1 WHERE USAGE = 49 AND DocEntry = @list_of_cols_val_tab_del )
SET @RefDocEntr =
	(SELECT	COUNT(T2.RefDocEntr) FROM  OPDN T0 
		INNER JOIN PDN1 T1 ON T1.DocEntry = T0.DocEntry
		INNER JOIN PDN21 T2 ON T2.DocEntry = T0.DocEntry
		WHERE T1.Usage = 49 AND T0.DocEntry = @list_of_cols_val_tab_del)
-- usage Transbordo
IF (49 = @Usage)
BEGIN
	IF(@RefDocEntr < 1)
	BEGIN
		SET @error = -1
		SET @error_message = 'Obrigatório colocar a referência do pedido de compras!'
		SELECT @error, @error_message
	END
END
END;
--FRETE DE COMPRAS - NF ENTRADA
IF (@object_type = '18') and (@transaction_type in ('A'))--'18' = Nota Fiscal de Entrada
BEGIN
DECLARE @CG02043 Bit SET @CG02043 = (SELECT DISTINCT  CASE WHEN itemCode = 'CG02043' THEN 1 ElSE 0 END FROM PCH1 WHERE DocEntry = @list_of_cols_val_tab_del)
SET @RefDocEntr = (
	SELECT	COUNT(T2.RefDocEntr) FROM  OPCH T0 
		INNER JOIN PCH1 T1 ON T1.DocEntry = T0.DocEntry
		INNER JOIN PCH21 T2 ON T2.DocEntry = T0.DocEntry
		WHERE T1.itemCode = 'CG02043' AND T0.DocEntry = @list_of_cols_val_tab_del
)

IF (1 = @CG02043)
BEGIN
	IF(@RefDocEntr < 1)
	BEGIN
		SET @error = -1
		SET @error_message = 'Obrigatório colocar a referência da NF de origem!'
		SELECT @error, @error_message
	END
END
END;

--NOTAS COMPLEMENTARES - NF DE ENTRADA
IF (@object_type = '18') and (@transaction_type in ('A'))--'18' = Nota Fiscal de Entrada
BEGIN
SET @Usage = (SELECT Distinct USAGE FROM PCH1 WHERE USAGE = 51 AND DocEntry =  @list_of_cols_val_tab_del)

SET @RefDocEntr = (
SELECT	COUNT(DISTINCT T2.RefDocEntr) FROM  OPCH T0 
		INNER JOIN PCH1 T1 ON T1.DocEntry = T0.DocEntry
		INNER JOIN PCH21 T2 ON T2.DocEntry = T0.DocEntry
		WHERE T1.usage = 51 AND T0.DocEntry = @list_of_cols_val_tab_del
)
--usage compra complementar
	IF (51 = @Usage)
	BEGIN
		IF(@RefDocEntr < 2)
		BEGIN
			SET @error = -1
			SET @error_message = 'Obrigatório colocar a referência do Pedido e NF de origem!'
			SELECT @error, @error_message
		END		
	END
END;

--Devolução de Nota Fiscal de Entrada
IF (@object_type = '19') and (@transaction_type in ('A'))--'19' = Devolução de Nota Fiscal de Entrada
BEGIN
	SET @Usage = (	SELECT CASE WHEN	(SELECT Distinct USAGE FROM RPC1 WHERE USAGE = 22 AND DocEntry =   @list_of_cols_val_tab_del ) is  null then 
					0 else (SELECT Distinct USAGE FROM RPC1 WHERE USAGE = 22 AND  DocEntry =   @list_of_cols_val_tab_del) end  )
	SET @SeqCodes = (SELECT DISTINCT SeqCode FROM ORPC WHERE DocEntry = @list_of_cols_val_tab_del)
	
	
	SET @RefDocEntr = (
		SELECT	COUNT(DISTINCT T2.RefDocEntr) FROM  ORPC T0 
			INNER JOIN RPC1 T1 ON T1.DocEntry = T0.DocEntry
			INNER JOIN RPC21 T2 ON T2.DocEntry = T0.DocEntry
			WHERE  T0.DocEntry = @list_of_cols_val_tab_del)

-- usage BAIXA ESTOQUE não deve passar pela validação
	IF(@Usage <> 22 )
	BEGIN
		IF(@SeqCodes = 27 )
		BEGIN
			IF(@RefDocEntr < 2)
			BEGIN
				SET @error = -1
				SET @error_message = 'Obrigatório colocar a referência do Pedido e NF de origem!'
				SELECT @error, @error_message
			END		
		END
	END
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 25/10/2017
-- Update Date: 
-- Description: TRAVA DE DEPOSITO PARA UTILIZAÇÃO DOAÇÃO NF DE SAIDA
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '13') and (@transaction_type in ('A'))--'13' = Nota Fiscal de saída
BEGIN
DECLARE @LLinhas int set @LLinhas = (SELECT MAX(LineNum)FROM INV1  WHERE DOCENTRY = @list_of_cols_val_tab_del)
DECLARE @CCont1 int = 0
DECLARE @DDeposito Nvarchar(255)
DECLARE @UUtil Nvarchar (255)

WHILE(@CCont1 <  @LLinhas+1) -- percorrendo todas as linhas da nf
  BEGIN
  
   SET @DDeposito = (SELECT WhsCode FROM INV1 WHERE LineNum = @CCont1 AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha
   SET @UUtil = (SELECT Usage FROM INV1 WHERE LineNum = @CCont1 AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha


		IF( '02.19' != @DDeposito AND @UUtil = 52)
		BEGIN
			SET @error = -1
			SET @error_message = 'Para utilização DOAÇÃO/SAC o depósito deve ser 02.19'
			SELECT @error, @error_message
		END
		
	Set @CCont1=  @CCont1 + 1
  END--END while
END; -- END GERAL
----PEDIDO DE VENDA
IF (@object_type = '17') and (@transaction_type in ('A'))--'17' = Nota Fiscal de saída
BEGIN
set @LLinhas = (SELECT MAX(LineNum)FROM rdr1  WHERE DOCENTRY = @list_of_cols_val_tab_del)
Set @CCont1 = 0

WHILE(@CCont1 <  @LLinhas+1) -- percorrendo todas as linhas da nf
  BEGIN
  
   SET @DDeposito = (SELECT WhsCode FROM rdr1 WHERE LineNum = @CCont1 AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha
   SET @UUtil = (SELECT Usage FROM rdr1 WHERE LineNum = @CCont1 AND DocEntry = @list_of_cols_val_tab_del)-- pegando deposito de cada linha


		IF( '02.19' != @DDeposito AND @UUtil = 52)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo depósito nas linhas de cada item deve ser = 02.19!'
			SELECT @error, @error_message
		END
		
	Set @CCont1=  @CCont1 + 1
  END--END while
END; -- END GERAL
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 24/10/2017
-- Update Date: 
-- Description:	TRAVA DE CÓDIGO DE IMPOSTO E CFOP - ADIANTAMENTOS - ID 3805
--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

--ADIANTAMENTO FORNECEDOR
IF (@object_type = '204') and (@transaction_type in ('A'))--'204' = ADIANTAMENTO DE FORNECEDOR
BEGIN

	IF NOT EXISTS( SELECT   T1.TaxCode FROM DPO1 T1	WHERE (T1.TaxCode IS NOT NULL AND T1.TaxCode<>'' ) AND T1.DocEntry = @list_of_cols_val_tab_del )
	BEGIN
		SET @error = -1
		SET @error_message = 'Obrigatório colocar o Código de Imposto!'
		SELECT @error, @error_message
	END

	IF NOT EXISTS( SELECT  T1.CFOPCode FROM DPO1 T1 WHERE  ( T1.CFOPCode IS NOT NULL AND  T1.CFOPCode <> '') AND T1.DocEntry = @list_of_cols_val_tab_del )
	BEGIN
		SET @error = -1
		SET @error_message = 'Obrigatório colocar o CFOP!'
		SELECT @error, @error_message
	END
END;

--ADIANTAMENTO CLIENTE
IF (@object_type = '203') and (@transaction_type in ('A'))--'203' = ADIANTAMENTO DE CLIENTE
BEGIN

	IF NOT EXISTS( SELECT   T1.TaxCode FROM DPI1 T1	WHERE (T1.TaxCode IS NOT NULL AND T1.TaxCode<>'' ) AND T1.DocEntry = @list_of_cols_val_tab_del )
	BEGIN
		SET @error = -1
		SET @error_message = 'Obrigatório colocar o Código de Imposto!'
		SELECT @error, @error_message
	END

	IF NOT EXISTS( SELECT   T1.CFOPCode FROM DPI1 T1 WHERE ( T1.CFOPCode IS NOT NULL AND  T1.CFOPCode <> '') AND T1.DocEntry =  @list_of_cols_val_tab_del )
	BEGIN
		SET @error = -1
		SET @error_message = 'Obrigatório colocar o CFOP!'
		SELECT @error, @error_message
	END
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 21/09/2017
-- Update Date: 
-- Description:	atualizar Observações adicionais da nf com o valor do funrural
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '18') and (@transaction_type in ('A'))--'18' = Nota Fiscal de Entrada
BEGIN

DECLARE @ContHeader int set @ContHeader = (
SELECT count(*) FROM OPCH WHERE Header LIKE '%FUNRURAL%' AND DocEntry = @list_of_cols_val_tab_del
)

DECLARE @Funrural nvarchar (200)  set @Funrural = 
									(SELECT LTRIM(RTRIM(WTName)) FROM PCH5 T0
									INNER JOIN OPCH T1 ON T0.AbsEntry = T1.DocEntry
									INNER JOIN OWHT T2 ON T2.WTCode = T0.WTCode
									WHERE T0.WTCode = 16 AND T1.DocEntry = @list_of_cols_val_tab_del  )
	IF(@Funrural = 'FUNRURAL')
	BEGIN
			IF (@ContHeader < 1)
			BEGIN
				SET @error = -1
				SET @error_message = 'INFORMAR VALOR DO FUNRURAL NOS DADOS ADCIONAIS!'
				SELECT @error, @error_message
			END
		
	END
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 15/09/2017
-- Update Date: 
-- Description:	Travar NFS sem data e hora de entrada/saida
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @SeqCode int = 0
DECLARE @DtSaida datetime= NULL
DECLARE @HrSaida smallint = NULL

IF (@object_type = '13') and (@transaction_type in ('A'))--'13' = Nota Fiscal de saída
BEGIN
SET @SeqCode = ( SELECT SeqCode FROM OINV WHERE DocNum = @list_of_cols_val_tab_del)
SET @DtSaida = ( SELECT U_SKILL_DtSaida FROM OINV WHERE DocNum = @list_of_cols_val_tab_del)
SET @HrSaida = ( SELECT U_SKILL_HrSaida FROM OINV WHERE DocNum = @list_of_cols_val_tab_del)

	-- 27 = NFe | 28 = NFe_IMP | 29 = NFE_ENT
	IF(@SeqCode = 27 OR @SeqCode = 28 OR @SeqCode = 29)
	BEGIN
		IF(@DtSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Data de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
		IF(@HrSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Hora de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
	END
END;
IF (@object_type = '15') and (@transaction_type in ('A'))--'15' = entrega
BEGIN
SET @SeqCode = ( SELECT SeqCode FROM ODLN WHERE DocNum = @list_of_cols_val_tab_del)
SET @DtSaida = ( SELECT U_SKILL_DtSaida FROM ODLN WHERE DocNum = @list_of_cols_val_tab_del)
SET @HrSaida = ( SELECT U_SKILL_HrSaida FROM ODLN WHERE DocNum = @list_of_cols_val_tab_del)

	-- 27 = NFe | 28 = NFe_IMP | 29 = NFE_ENT
	IF(@SeqCode = 27 OR @SeqCode = 28 OR @SeqCode = 29)
	BEGIN
		IF(@DtSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Data de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
		IF(@HrSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Hora de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
	END
END;
IF (@object_type = '16') and (@transaction_type in ('A'))--'16' = Devolução
BEGIN
SET @SeqCode = ( SELECT SeqCode FROM ORDN WHERE DocNum = @list_of_cols_val_tab_del)
SET @DtSaida = ( SELECT U_SKILL_DtSaida FROM ORDN WHERE DocNum = @list_of_cols_val_tab_del)
SET @HrSaida = ( SELECT U_SKILL_HrSaida FROM ORDN WHERE DocNum = @list_of_cols_val_tab_del)

	-- 27 = NFe | 28 = NFe_IMP | 29 = NFE_ENT
	IF(@SeqCode = 27 OR @SeqCode = 28 OR @SeqCode = 29)
	BEGIN
		IF(@DtSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Data de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
		IF(@HrSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Hora de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
	END
END;
IF (@object_type = '14') and (@transaction_type in ('A'))--'14' = DEV Nota Fiscal de Saída
BEGIN
SET @SeqCode = ( SELECT SeqCode FROM ORIN WHERE DocNum = @list_of_cols_val_tab_del)
SET @DtSaida = ( SELECT U_SKILL_DtSaida FROM ORIN WHERE DocNum = @list_of_cols_val_tab_del)
SET @HrSaida = ( SELECT U_SKILL_HrSaida FROM ORIN WHERE DocNum = @list_of_cols_val_tab_del)

	-- 27 = NFe | 28 = NFe_IMP | 29 = NFE_ENT
	IF(@SeqCode = 27 OR @SeqCode = 28 OR @SeqCode = 29)
	BEGIN
		IF(@DtSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Data de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
		IF(@HrSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Hora de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
	END
END;
IF (@object_type = '20') and (@transaction_type in ('A'))--'20' = Recebimento de Mercadoria
BEGIN
SET @SeqCode = ( SELECT SeqCode FROM OPDN WHERE DocNum = @list_of_cols_val_tab_del)
SET @DtSaida = ( SELECT U_SKILL_DtSaida FROM OPDN WHERE DocNum = @list_of_cols_val_tab_del)
SET @HrSaida = ( SELECT U_SKILL_HrSaida FROM OPDN WHERE DocNum = @list_of_cols_val_tab_del)

	-- 27 = NFe | 28 = NFe_IMP | 29 = NFE_ENT
	IF(@SeqCode = 27 OR @SeqCode = 28 OR @SeqCode = 29)
	BEGIN
		IF(@DtSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Data de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
		IF(@HrSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Hora de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
	END
END;
IF (@object_type = '21') and (@transaction_type in ('A'))--'21' = Dev de mercadoria
BEGIN
SET @SeqCode = ( SELECT SeqCode FROM ORPD WHERE DocNum = @list_of_cols_val_tab_del)
SET @DtSaida = ( SELECT U_SKILL_DtSaida FROM ORPD WHERE DocNum = @list_of_cols_val_tab_del)
SET @HrSaida = ( SELECT U_SKILL_HrSaida FROM ORPD WHERE DocNum = @list_of_cols_val_tab_del)

	-- 27 = NFe | 28 = NFe_IMP | 29 = NFE_ENT
	IF(@SeqCode = 27 OR @SeqCode = 28 OR @SeqCode = 29)
	BEGIN
		IF(@DtSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Data de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
		IF(@HrSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Hora de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
	END
END;
IF (@object_type = '18') and (@transaction_type in ('A'))--'18' = Nota Fiscal de Entrada/NF Recebimento futuro
BEGIN
SET @SeqCode = ( SELECT SeqCode FROM OPCH WHERE DocNum = @list_of_cols_val_tab_del)
SET @DtSaida = ( SELECT U_SKILL_DtSaida FROM OPCH WHERE DocNum = @list_of_cols_val_tab_del)
SET @HrSaida = ( SELECT U_SKILL_HrSaida FROM OPCH WHERE DocNum = @list_of_cols_val_tab_del)

	-- 27 = NFe | 28 = NFe_IMP | 29 = NFE_ENT
	IF(@SeqCode = 27 OR @SeqCode = 28 OR @SeqCode = 29)
	BEGIN
		IF(@DtSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Data de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
		IF(@HrSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Hora de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
	END
END;
IF (@object_type = '19') and (@transaction_type in ('A'))--'19' = Dev Nota Fiscal de entrada
BEGIN
SET @SeqCode = ( SELECT SeqCode FROM ORPC WHERE DocNum = @list_of_cols_val_tab_del)
SET @DtSaida = ( SELECT U_SKILL_DtSaida FROM ORPC WHERE DocNum = @list_of_cols_val_tab_del)
SET @HrSaida = ( SELECT U_SKILL_HrSaida FROM ORPC WHERE DocNum = @list_of_cols_val_tab_del)

	-- 27 = NFe | 28 = NFe_IMP | 29 = NFE_ENT
	IF(@SeqCode = 27 OR @SeqCode = 28 OR @SeqCode = 29)
	BEGIN
		IF(@DtSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Data de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
		IF(@HrSaida IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'O campo Hora de Entrada/Saida é de preenchimento obrigatório!!'
			SELECT @error, @error_message
		END
	END
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 31/01/2017
-- Update Date: 30/08/2017
-- Description:	Travar Pedidos de Vendas com ITENS EM ABERTO (APENAS ATUALIZAR) 
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('U'))--'17' = Pedido de Vendas
BEGIN

DECLARE @DepUPV int SET @DepUPV = (SELECT u.Department From ORDR O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)
 IF(@DepUPV = 1)	
	BEGIN
		IF  EXISTS (
			SELECT 
				* 
			FROM 
				OJDT T0  
			INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId] 
			INNER JOIN OACT T2 ON T1.[Account] = T2.[AcctCode] 
			INNER JOIN OCRD T3 ON T3.CardCode = t1.ShortName
			
			WHERE 
				T2.[LocManTran] = 'Y' AND 
				T1.[BalDueDeb] <> 0   AND  T3.QryGroup25 = 'N' AND
				T1.[DueDate] <  CONVERT(DATETIME, FLOOR(CONVERT(FLOAT(24), GETDATE())))  AND 
				T1.[ShortName] = ( SELECT CardCode FROM ORDR WHERE DocNum =  @list_of_cols_val_tab_del )
				
		
		) BEGIN	
				SET @error = -1
				SET @error_message = 'Não é possivel adicionar esse pedido, cliente possui títulos vencidos!'
				SELECT @error, @error_message
		  END;
	

	END;		
		

END;

------------------------------------------------------------------------------------------------------------------------------
--END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 31/01/2017
-- Update Date: 30/08/2017
-- Description:	Travar Pedidos de Vendas com ITENS EM ABERTO  (APENAS ADICIONAR)
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A'))--'17' = Pedido de Vendas
BEGIN

DECLARE @DepCR int SET @DepCR = (SELECT u.Department From ORDR O 
								INNER JOIN OUSR U ON O.UserSign = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)
 IF(@DepCR = 1)	
	BEGIN
		IF  EXISTS (
			SELECT 
				* 
			FROM 
				OJDT T0  
			INNER JOIN JDT1 T1 ON T0.[TransId] = T1.[TransId] 
			INNER JOIN OACT T2 ON T1.[Account] = T2.[AcctCode] 
			INNER JOIN OCRD T3 ON T3.CardCode = t1.ShortName
			WHERE 
				T2.[LocManTran] = 'Y' AND 
				T1.[BalDueDeb] <> 0   AND   T3.QryGroup25 = 'N' AND
				T1.[DueDate] <  CONVERT(DATETIME, FLOOR(CONVERT(FLOAT(24), GETDATE())))  AND 
				T1.[ShortName] = ( SELECT CardCode FROM ORDR WHERE DocNum =  @list_of_cols_val_tab_del )
			
		) BEGIN	
				SET @error = -1
				SET @error_message = 'Não é possivel adicionar esse pedido, cliente possui títulos vencidos!'
				SELECT @error, @error_message
		  END;

	
	END;		
		

END;

--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 23/08/2017
-- Update Date: 
-- Description:	Bloquear ESBOÇO de Pedidos com deposito bloqueado
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'112') and (@transaction_type in ('A','U'))--N'112' = ESBOÇO

BEGIN
	IF EXISTS(
		SELECT 
			A.DocNum 'N° do Esboço',
			A.CardCode +'-'+ A.CardName 'Parceiro',
			I.ItemCode +'-'+ I.ItemName 'Produto',
			A.DocDueDate 'Data de Entrega'	,IW.Locked
		FROM 
			ODRF A 
		INNER JOIN DRF1 AL ON AL.DocEntry = A.DocEntry
		INNER JOIN OITM I ON AL.ItemCode = I.ItemCode
		INNER JOIN OITW IW ON IW.ItemCode = I.ItemCode AND IW.WhsCode = Al.WhsCode
		WHERE 
			A.ObjType = 17 AND A.DocEntry = @list_of_cols_val_tab_del AND IW.Locked = 'Y' )
		BEGIN
			SET @error = -1
			SET @error_message = 'Depósito selecionado está bloqueado para o Item'
			SELECT @error, @error_message
		END
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------




--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 13/01/2017
-- UPdate Date: 06/07/2017
-- Description:	Travar Pedidos de Vendas com Data de Validade Menor que a data atual + 2 DDL (APENAS AO ADICIONAR)
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A'))--'17' = Pedido de Vendas
BEGIN

	DECLARE @DocDueDate DATETIME SET @DocDueDate = (SELECT DocDueDate FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))	
	DECLARE @DocDate DATETIME SET @DocDate = (SELECT DocDate FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))	
	DECLARE @DDL INT  SET @DDL =2
	DECLARE @HoraAtual INT =  (SELECT DATEPART ( Hour , GETDATE() )  )
	DECLARE @MinutoAtual INT = (SELECT DATEPART ( MINUTE , GETDATE() )  )
	DECLARE @Desconto Float SET @Desconto =  (SELECT DiscPrcnt FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))
	DECLARE @diasemana INT = Convert(int,(select DatePart(WEEKDAY,GETDATE())))
	
	
IF (@diasemana = 1) --DOMINGO
	BEGIN
		SET @DDL =3
	END
ELSE IF(@diasemana between 2 AND 3) -- SEGUNDA E TERÇA
	BEGIN
		IF (@HoraAtual between 0 and 11)
		BEGIN
			IF(@HoraAtual = 11) AND (@MinutoAtual > 0)
				BEGIN
					SET @DDL =3 
				END 
			ELSE
				SET @DDL =2
		END
		ELSE IF(@HoraAtual between 11 and 24)
			BEGIN
				SET @DDL =3
			END
	END
ELSE IF (@diasemana = 4) -- QUARTA-FEIRA
	BEGIN
		IF (@HoraAtual between 0 and 11)
		BEGIN
			IF(@HoraAtual = 11) AND (@MinutoAtual > 0)
				BEGIN
					SET @DDL =5
				END 
			ELSE
				SET @DDL =2
		END
		ELSE IF(@HoraAtual between 11 and 24)
			BEGIN
				SET @DDL =5
			END
	END
ELSE IF (@diasemana between 5 AND 6) -- QUINTA E SEXTA
	BEGIN
		IF (@HoraAtual between 0 and 11)
		BEGIN
			IF(@HoraAtual = 11) AND (@MinutoAtual > 0)
				BEGIN
					SET @DDL =5
				END 
			ELSE
				SET @DDL =4
		END
		ELSE IF(@HoraAtual between 11 and 24)
			BEGIN
				SET @DDL =5
			END
	END
ELSE IF (@diasemana = 7) --SABADO
	BEGIN
		SET @DDL =4
	END

	DECLARE @dateDiff INT SET @dateDiff = (SELECT DATEDIFF(DAY,@DocDate+@DDL,@DocDueDate))
	
	DECLARE @Dep int SET @Dep = (SELECT u.Department From ORDR O 
								INNER JOIN OUSR U ON O.UserSign = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)
								 
	DECLARE @GroupNumBP INT SET @GroupNumBP = (SELECT GroupNum FROM OCRD WHERE CardCode = (SELECT CardCode FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del ))
	DECLARE @GroupNumPV INT SET @GroupNumPV = (SELECT GroupNum FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del )



IF ((@dateDiff < 0) AND @Dep NOT IN (2, 18, 12, 20))
BEGIN
    SET @error = -1
    SET @error_message = 'A validade deve ter no mínimo ' + CONVERT(VARCHAR, @DDL) + ' dias'
    SELECT @error, @error_message
END

IF ((@GroupNumBP <> @GroupNumPV) AND @Dep NOT IN (2, 18, 20))
BEGIN
    SET @error = -1
    SET @error_message = 'Não é permitido modificar a Condição de Pagamento do PN'
    SELECT @error, @error_message
END

IF ((@Desconto > 0) AND @Dep NOT IN (2, 18, 20))
BEGIN
    SET @error = -1
    SET @error_message = 'Não é permitido definir esse tipo de desconto no Pedido'
    SELECT @error, @error_message
END

END;



----------------------------------------------------------------------------------------------------------------------------------
---- END
-----------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 31/01/2017
-- Update date: 06/07/2017
-- Description:	Travar Pedidos de Vendas com Data de Validade Menor que a data atual + 2 DDL(APENAS AO ATUALIZAR)
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('U'))--'17' = Pedido de Vendas
BEGIN

	DECLARE @DocDueDateU DATETIME SET @DocDueDateU = (SELECT DocDueDate FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))	
	DECLARE @DocDateU DATETIME SET @DocDateU = (SELECT DocDate FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))	
	DECLARE @DDLU INT  SET @DDLU =2
	DECLARE @HoraAtualU INT =  (SELECT DATEPART ( Hour , GETDATE() )  )
	DECLARE @MinutoAtualU INT = (SELECT DATEPART ( MINUTE , GETDATE() )  )
	DECLARE @DescontoU Float SET @DescontoU =  (SELECT DiscPrcnt FROM ORDR WHERE (DocEntry = @list_of_cols_val_tab_del))
	DECLARE @diasemanaU INT = Convert(int,(select DatePart(WEEKDAY,GETDATE())))

	IF (@diasemanaU = 1) --DOMINGO
	BEGIN
		SET @DDLU =3
	END
ELSE IF(@diasemanaU between 2 AND 3) -- SEGUNDA E TERÇA
	BEGIN
		IF (@HoraAtualU between 0 and 11)
		BEGIN
			IF(@HoraAtualU = 11) AND (@MinutoAtualU > 0)
				BEGIN
					SET @DDLU =3 
				END 
			ELSE
				SET @DDLU =2
		END
		ELSE IF(@HoraAtualU between 11 and 24)
			BEGIN
				SET @DDLU =3
			END
	END
ELSE IF (@diasemanaU = 4) -- QUARTA-FEIRA
	BEGIN
		IF (@HoraAtualU between 0 and 11)
		BEGIN
			IF(@HoraAtualU = 11) AND (@MinutoAtualU > 0)
				BEGIN
					SET @DDLU =5
				END 
			ELSE
				SET @DDLU =2
		END
		ELSE IF(@HoraAtualU between 11 and 24)
			BEGIN
				SET @DDLU =5
			END
	END
ELSE IF (@diasemanaU between 5 AND 6) -- QUINTA E SEXTA
	BEGIN
		IF (@HoraAtualU between 0 and 11)
		BEGIN
			IF(@HoraAtualU = 11) AND (@MinutoAtualU > 0)
				BEGIN
					SET @DDLU =5
				END 
			ELSE
				SET @DDLU =4
		END
		ELSE IF(@HoraAtualU between 11 and 24)
			BEGIN
				SET @DDLU =5
			END
	END
ELSE IF (@diasemanaU = 7) --SABADO
	BEGIN
		SET @DDLU =4
	END
	DECLARE @dateDiffU INT SET @dateDiffU = (SELECT DATEDIFF(DAY,@DocDateU+@DDLU,@DocDueDateU))
	
	DECLARE @DepU int SET @DepU = (SELECT u.Department From ORDR O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)
								 
	DECLARE @GroupNumBPU INT SET @GroupNumBPU = (SELECT GroupNum FROM OCRD WHERE CardCode = (SELECT CardCode FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del ))
	DECLARE @GroupNumPVU INT SET @GroupNumPVU = (SELECT GroupNum FROM ORDR WHERE DocEntry = @list_of_cols_val_tab_del )

	
	IF ((@dateDiffU < 0) AND @DepU NOT IN (1, 2, 18, 12, 20))
		BEGIN
				SET @error = -1
				SET @error_message = 'A validade deve ter no mínimo ' + convert(Varchar,@DDLU) + ' dias'
				SELECT @error, @error_message
		END

		IF ((@GroupNumBPU <> @GroupNumPVU) AND @DepU NOT IN (1, 2, 18, 20))
		BEGIN
				SET @error = -1
				SET @error_message = 'Não é permitido modificar a Condição de Pagamento do PN'
				SELECT @error, @error_message
		END

		IF ((@DescontoU > 0) AND @DepU NOT IN (1, 2, 18, 20))
		BEGIN
				SET @error = -1
				SET @error_message = 'Não é permitido definir esse tipo de desconto no Pedido'
				SELECT @error, @error_message
		END

END;

--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 01/02/2017
-- Update date: 06/07/2017
-- Description:	Travar Cotação de Vendas com Data de Validade Menor que a data atual + 2 DDL (APENAS AO ADICIONAR)
--------------------------------------------------------------------------------------------------------------------------------
/*
IF (@object_type = '23') and (@transaction_type in ('A'))--'23' = cotação de Vendas
BEGIN

	DECLARE @DocDueDateADDQ DATETIME SET @DocDueDateADDQ = (SELECT DocDueDate FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))	
	DECLARE @DocDateADDQ DATETIME SET @DocDateADDQ = (SELECT DocDate FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))	
	DECLARE @DDLADDQ INT  SET @DDLADDQ =2
	DECLARE @HoraAtualADDQ INT =  (SELECT DATEPART ( Hour , GETDATE() )  )
	DECLARE @MinutoAtualADDQ INT = (SELECT DATEPART ( MINUTE , GETDATE() )  )
	DECLARE @DescontoADDQ Float SET @DescontoADDQ =  (SELECT DiscPrcnt FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))
	DECLARE @diasemanaADDQ INT = Convert(int,(select DatePart(WEEKDAY,GETDATE())))

	
IF (@diasemanaADDQ = 1) --DOMINGO
	BEGIN
		SET @DDLADDQ =3
	END
ELSE IF(@diasemanaADDQ between 2 AND 3) -- SEGUNDA E TERÇA
	BEGIN
		IF (@HoraAtualADDQ between 0 and 11)
		BEGIN
			IF(@HoraAtualADDQ = 11) AND (@MinutoAtualADDQ > 0)
				BEGIN
					SET @DDLADDQ =3 
				END 
			ELSE
				SET @DDLADDQ =2
		END
		ELSE IF(@HoraAtualADDQ between 11 and 24)
			BEGIN
				SET @DDLADDQ =3
			END
	END
ELSE IF (@diasemanaADDQ = 4) -- QUARTA-FEIRA
	BEGIN
		IF (@HoraAtualADDQ between 0 and 11)
		BEGIN
			IF(@HoraAtualADDQ = 11) AND (@MinutoAtualADDQ > 0)
				BEGIN
					SET @DDLADDQ =5
				END 
			ELSE
				SET @DDLADDQ =2
		END
		ELSE IF(@HoraAtualADDQ between 11 and 24)
			BEGIN
				SET @DDLADDQ =5
			END
	END
ELSE IF (@diasemanaADDQ between 5 AND 6) -- QUINTA E SEXTA
	BEGIN
		IF (@HoraAtualADDQ between 0 and 11)
		BEGIN
			IF(@HoraAtualADDQ = 11) AND (@MinutoAtualADDQ > 0)
				BEGIN
					SET @DDLADDQ =5
				END 
			ELSE
				SET @DDLADDQ =4
		END
		ELSE IF(@HoraAtualADDQ between 11 and 24)
			BEGIN
				SET @DDLADDQ =5
			END
	END
ELSE IF (@diasemanaADDQ = 7) --SABADO
	BEGIN
		SET @DDLADDQ =4
	END

	DECLARE @dateDiffADDQ INT SET @dateDiffADDQ = (SELECT DATEDIFF(DAY,@DocDateADDQ+@DDLADDQ,@DocDueDateADDQ))
	
	DECLARE @DepADDQ int SET @DepADDQ = (SELECT u.Department From OQUT O 
								INNER JOIN OUSR U ON O.UserSign = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)
								 
	DECLARE @GroupNumBPADDQ INT SET @GroupNumBPADDQ = (SELECT GroupNum FROM OCRD WHERE CardCode = (SELECT CardCode FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del ))
	DECLARE @GroupNumPVADDQ INT SET @GroupNumPVADDQ = (SELECT GroupNum FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del )

	
	IF ((@dateDiffADDQ < 0) AND @DepADDQ = 1)
		BEGIN
				SET @error = -1
				SET @error_message = 'A validade deve ter no mínimo '+convert(Varchar,@DDLADDQ)+' dias'
				SELECT @error, @error_message
		END

		IF ((@GroupNumBPADDQ <> @GroupNumPVADDQ) AND @DepADDQ = 1)
		BEGIN
				SET @error = -1
				SET @error_message = 'Não é permitido modificar a Condição de Pagamento do PN'
				SELECT @error, @error_message
		END

		IF ((@DescontoADDQ > 0) AND @DepADDQ = 1)
		BEGIN
				SET @error = -1
				SET @error_message = 'Não é permitido definir esse tipo de desconto no Pedido'
				SELECT @error, @error_message
		END

END;

--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 01/02/2017
-- Update date: 06/07/2017
-- Description:	Travar Cotação de Vendas com Data de Validade Menor que a data atual + 2 DDL(APENAS AO ATUALIZAR)
--------------------------------------------------------------------------------------------------------------------------------
/*
IF (@object_type = '23') and (@transaction_type in ('U'))--'23' = Cotação de Vendas
BEGIN

	DECLARE @DocDueDateUQ DATETIME SET @DocDueDateUQ = (SELECT DocDueDate FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))	
	DECLARE @DocDateUQ DATETIME SET @DocDateUQ = (SELECT DocDate FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))	
	DECLARE @DDLUQ INT  SET @DDLUQ =2
	DECLARE @HoraAtualUQ INT =  (SELECT DATEPART ( Hour , GETDATE() )  )
	DECLARE @MinutoAtualUQ INT = (SELECT DATEPART ( MINUTE , GETDATE() )  )
	DECLARE @DescontoUQ Float SET @DescontoUQ =  (SELECT DiscPrcnt FROM OQUT WHERE (DocEntry = @list_of_cols_val_tab_del))
	DECLARE @diasemanaUQ INT = Convert(int,(select DatePart(WEEKDAY,GETDATE())))

IF (@diasemanaUQ = 1) --DOMINGO
	BEGIN
		SET @DDLUQ =3
	END
ELSE IF(@diasemanaUQ between 2 AND 3) -- SEGUNDA E TERÇA
	BEGIN
		IF (@HoraAtualUQ between 0 and 11)
		BEGIN
			IF(@HoraAtualUQ = 11) AND (@MinutoAtualUQ > 0)
				BEGIN
					SET @DDLUQ =3 
				END 
			ELSE
				SET @DDLUQ =2
		END
		ELSE IF(@HoraAtualUQ between 11 and 24)
			BEGIN
				SET @DDLUQ =3
			END
	END
ELSE IF (@diasemanaUQ = 4) -- QUARTA-FEIRA
	BEGIN
		IF (@HoraAtualUQ between 0 and 11)
		BEGIN
			IF(@HoraAtualUQ = 11) AND (@MinutoAtualUQ > 0)
				BEGIN
					SET @DDLUQ =5
				END 
			ELSE
				SET @DDLUQ =2
		END
		ELSE IF(@HoraAtualUQ between 11 and 24)
			BEGIN
				SET @DDLUQ =5
			END
	END
ELSE IF (@diasemanaUQ between 5 AND 6) -- QUINTA E SEXTA
	BEGIN
		IF (@HoraAtualUQ between 0 and 11)
		BEGIN
			IF(@HoraAtualUQ = 11) AND (@MinutoAtualUQ > 0)
				BEGIN
					SET @DDLUQ =5
				END 
			ELSE
				SET @DDLUQ =4
		END
		ELSE IF(@HoraAtualUQ between 11 and 24)
			BEGIN
				SET @DDLUQ =5
			END
	END
ELSE IF (@diasemanaUQ = 7) --SABADO
	BEGIN
		SET @DDLUQ =4
	END
	
	
	DECLARE @dateDiffUQ INT SET @dateDiffUQ = (SELECT DATEDIFF(DAY,@DocDateUQ+@DDLUQ,@DocDueDateUQ))
	
	DECLARE @DepUQ int SET @DepUQ = (SELECT u.Department From OQUT O 
								INNER JOIN OUSR U ON O.UserSign2 = U.USERID
								WHERE O.DocNum = @list_of_cols_val_tab_del)
								 
	DECLARE @GroupNumBPUQ INT SET @GroupNumBPUQ = (SELECT GroupNum FROM OCRD WHERE CardCode = (SELECT CardCode FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del ))
	DECLARE @GroupNumPVUQ INT SET @GroupNumPVUQ = (SELECT GroupNum FROM OQUT WHERE DocEntry = @list_of_cols_val_tab_del )

	
	IF ((@dateDiffUQ < 0) AND @DepUQ = 1)
		BEGIN
				SET @error = -1
				SET @error_message = 'A validade deve ter no mínimo '+convert(nvarchar,@DDLUQ)+' dias'
				SELECT @error, @error_message
		END

		IF ((@GroupNumBPUQ <> @GroupNumPVUQ) AND @DepUQ = 1)
		BEGIN
				SET @error = -1
				SET @error_message = 'Não é permitido modificar a Condição de Pagamento do PN'
				SELECT @error, @error_message
		END

		IF ((@DescontoUQ > 0) AND @DepUQ = 1)
		BEGIN
				SET @error = -1
				SET @error_message = 'Não é permitido definir esse tipo de desconto no Pedido'
				SELECT @error, @error_message
		END

END;

--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
*/

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create Date: 23/05/2017
-- Update Date: 
-- Description:	Validações de atualizações campos Rendimento
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = 'Rendimento') and (@transaction_type in ('U'))-- RENDIMENTOS
BEGIN 
	--VALIDAR NUMERO RECEBIMENTO
	DECLARE @NRecebU NVARCHAR (15) SET @NRecebU =(SELECT U_DocNum	FROM [@RA_RENDIMENTO] 
												WHERE Code  = @list_of_cols_val_tab_del)
	IF NOT Exists(
	SELECT *FROM OPDN 
	WHERE DocNum = @NRecebU AND DocStatus IN ('O','C'))
	BEGIN
		SET @error = -1
		SET @error_message = 'Recebimento não encontrado ou cancelado. Não é possível adicionar.'
		SELECT @error, @error_message
	END

	--VALIDAR NUMERO DO ITEM
	DECLARE @NProdU NVARCHAR (15) SET @NProdU =(SELECT U_ItemCode	FROM [@RA_RENDIMENTO] 
												WHERE Code  = @list_of_cols_val_tab_del)
	IF NOT Exists(
	SELECT *FROM OITM WHERE validFor = 'Y' AND ItemCode = @NProdU )
	BEGIN
		SET @error = -1
		SET @error_message = 'Item não encontrado ou inativo. Não é possível adicionar.'
		SELECT @error, @error_message
	END

	DECLARE @RendNomeU NVARCHAR (30)
	
	--PREENCHIMENTO AUTOMATICO DO NOME
	SET @RendNomeU =(SELECT CONCAT(U_DocNum,' - ',U_ItemCode) 
							FROM [@RA_RENDIMENTO] WHERE Code  = @list_of_cols_val_tab_del )
	IF(@RendNomeU is not Null)
		BEGIN
			UPDATE [@RA_RENDIMENTO] SET NAME = @RendNomeU WHERE Code = @list_of_cols_val_tab_del
		END

	--VALIDAR NOME
	SET @RendNomeU = (SELECT Name FROM [@RA_RENDIMENTO] 
												WHERE Code  = @list_of_cols_val_tab_del)
	IF Exists(
	SELECT Name FROM [@RA_RENDIMENTO]	WHERE Name = @RendNomeU AND Code <>@list_of_cols_val_tab_del)
	BEGIN
		SET @error = -1
		SET @error_message = 'Rendimento já cadastrado. Não é possível adicionar'
		SELECT @error, @error_message
	END
	
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 09/05/2017
-- Description:	Atualizar Quantidade Real
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'20') and (@transaction_type in ('A','U'))--'20' = Recebimento de Mercadoria

BEGIN
DECLARE @QRealCab int = (SELECT U_MW_QuantReal FROM OPDN WHERE DocNum =  @list_of_cols_val_tab_del )
DECLARE @StatusImp Varchar (20) = (SELECT U_MW_STATUSIMP FROM OPDN WHERE DocNum =  @list_of_cols_val_tab_del )

	IF(@StatusImp = 'RECEBIDO' AND (@QRealCab IS NULL OR @QRealCab = 0))
	BEGIN
			SET @error = -1
			SET @error_message = 'Informar Quantidade Real'
			SELECT @error, @error_message
	END 

	IF(@QRealCab IS NOT NULL AND @QRealCab > 0)
	BEGIN
		IF(@StatusImp = 'RECEBIDO')
		BEGIN
			UPDATE  PDN1 SET U_MW_QUANTIREAL = @QRealCab WHERE DocEntry = @list_of_cols_val_tab_del;
		END 
		ELSE
			BEGIN
				SET @error = -1
				SET @error_message = 'Verificar Status Importação'
				SELECT @error, @error_message
			END
	END 
		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create Date: 18/04/2017
-- Update Date: 
-- Description:	Bloquear campos Rendimento
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = 'Rendimento') and (@transaction_type in ('A'))-- RENDIMENTOS
BEGIN 
	--VALIDAR NUMERO RECEBIMENTO
	DECLARE @NReceb NVARCHAR (15) SET @NReceb =(SELECT U_DocNum	FROM [@RA_RENDIMENTO] 
												WHERE Code  = @list_of_cols_val_tab_del)
	IF NOT Exists(
	SELECT *FROM OPDN 
	WHERE DocNum = @NReceb AND DocStatus IN ('O','C'))
	BEGIN
		SET @error = -1
		SET @error_message = 'Recebimento não encontrado ou cancelado. Não é possível adicionar.'
		SELECT @error, @error_message
	END

	--VALIDAR NUMERO DO ITEM
	DECLARE @NProd NVARCHAR (15) SET @NProd =(SELECT U_ItemCode	FROM [@RA_RENDIMENTO] 
												WHERE Code  = @list_of_cols_val_tab_del)
	IF NOT Exists(
	SELECT *FROM OITM WHERE validFor = 'Y' AND ItemCode = @NProd )
	BEGIN
		SET @error = -1
		SET @error_message = 'Item não encontrado ou inativo. Não é possível adicionar.'
		SELECT @error, @error_message
	END

	DECLARE @RendNome NVARCHAR (30)
	
	--PREENCHIMENTO AUTOMATICO DO NOME
	SET @RendNome =(SELECT CONCAT(U_DocNum,' - ',U_ItemCode) 
							FROM [@RA_RENDIMENTO] WHERE Code  = @list_of_cols_val_tab_del )
	IF(@RendNome is not Null)
		BEGIN
			UPDATE [@RA_RENDIMENTO] SET NAME = @RendNome WHERE Code = @list_of_cols_val_tab_del
		END

	--VALIDAR NOME
	SET @RendNome = (SELECT Name FROM [@RA_RENDIMENTO] 
												WHERE Code  = @list_of_cols_val_tab_del)
	IF Exists(
	SELECT Name FROM [@RA_RENDIMENTO]	WHERE Name = @RendNome AND Code <>@list_of_cols_val_tab_del)
	BEGIN
		SET @error = -1
		SET @error_message = 'Rendimento já cadastrado. Não é possível adicionar'
		SELECT @error, @error_message
	END
	
END
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 12/04/2017
-- Update Date: 
-- Description:	Bloquear Dev NF de Saída sem Regra de Distribuição,Utilização e Código de imposto
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '14') and (@transaction_type in ('A','U'))--'14' = DEV NF DE SAIDA

BEGIN
	DECLARE @DocEntryDNFS int = @list_of_cols_val_tab_del
	DECLARE @DocTypeDNFS char = (SELECT DocType FROM ORIN  WHERE DocEntry = @DocEntryDNFS)

	--Utilização
	IF EXISTS(
			SELECT 
				OL.Usage 
			FROM 
				ORIN O
			    INNER JOIN RIN1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryDNFS AND OL.OcrCode IS NULL)
		BEGIN
			IF( @DocTypeDNFS = 'I')
				BEGIN
					SET @error = -1
					SET @error_message = 'Dev NF de Saída - Não foi possível concluir. É necessário definir uma Utilização.'
					SELECT @error, @error_message
				END
		END

		--Código de imposto
		IF EXISTS(
			SELECT 
				OL.TaxCode
			FROM 
				ORIN O
			    INNER JOIN RIN1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryDNFS AND OL.OcrCode IS NULL)
		BEGIN
				SET @error = -1
				SET @error_message = 'Dev NF de Saída - Não foi possível concluir. É necessário definir o Código de Imposto.'
				SELECT @error, @error_message
		END
			
		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 12/04/2017
-- Update Date: 
-- Description:	Bloquear DEV NF ENTRADA sem Regra de Distribuição,Utilização e Código de imposto
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '19') and (@transaction_type in ('A','U'))--'19' = DEV NF DE ENTRADA

BEGIN
	DECLARE @DocEntryDNFE int = @list_of_cols_val_tab_del
	DECLARE @DocTypeDNFE char = (SELECT DocType FROM ORPC WHERE DocEntry = @DocEntryDNFE)
	--Utilização
	IF EXISTS (

			SELECT 
				OL.Usage 
			FROM 
				ORPC O
			    INNER JOIN RPC1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryDNFE AND OL.OcrCode IS NULL)		
				BEGIN
					if (@DocTypeDNFE = 'I')
					BEGIN
						SET @error = -1
						SET @error_message = 'DEV NF ENTRADA - Não foi possível concluir. É necessário definir uma Utilização.'
						SELECT @error, @error_message
					END
				END

		--Código de imposto
		IF EXISTS (

			SELECT 
				OL.TaxCode
			FROM 
				ORPC O
			    INNER JOIN RPC1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryDNFE AND OL.OcrCode IS NULL)
				BEGIN
					SET @error = -1
					SET @error_message = 'DEV NF ENTRADA - Não foi possível concluir. É necessário definir o Código de Imposto.'
					SELECT @error, @error_message
				END
			
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 12/04/2017
-- Update Date: 
-- Description:	Bloquear NF ENTRADA sem Regra de Distribuição,Utilização e Código de imposto
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '18') and (@transaction_type in ('A','U'))--'18' = NF DE ENTRADA

BEGIN
	DECLARE @DocEntryNFE int = @list_of_cols_val_tab_del
	DECLARE @DocTypeNFE char = (SELECT DocType FROM OPCH WHERE DocEntry = @DocEntryNFE)
	--Código de imposto
	IF EXISTS(
			SELECT 
				OL.TaxCode
			FROM 
				OPCH O
			    INNER JOIN PCH1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryNFE AND OL.OcrCode IS NULL)
		BEGIN
			SET @error = -1
			SET @error_message = 'NF ENTRADA - Não foi possível concluir. É necessário definir o Código de Imposto.'
			SELECT @error, @error_message
		END
		
		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 12/04/2017
-- Update Date: 
-- Description:	Bloquear NF de Saída sem Regra de Distribuição,Utilização e Código de imposto
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '13') and (@transaction_type in ('A','U'))--'13' = NF DE SAIDA

BEGIN
	
	DECLARE @DocEntryNFS int = @list_of_cols_val_tab_del
	DECLARE @DocTypeNFS char = (SELECT DocType FROM OINV WHERE DocEntry = @DocEntryNFS)

	--Utilização
	IF EXISTS(
			SELECT 
				OL.Usage 
			FROM 
				OINV O
			    INNER JOIN INV1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryNFS AND OL.OcrCode IS NULL)
				BEGIN
				if (@DocTypeNFS = 'I')
					BEGIN
						SET @error = -1
						SET @error_message = 'Não foi possível concluir. É necessário definir uma Utilização.'
						SELECT @error, @error_message
					END
				END

	--Código de imposto
	--IF EXISTS(
	--		SELECT 
	--			OL.TaxCode
	--		FROM 
	--			OINV O
	--		    INNER JOIN INV1 OL ON O.DocEntry = ol.DocEntry
	--		WHERE o.DocEntry = @DocEntryNFS AND OL.OcrCode IS NULL AND )
	--			BEGIN
	--				SET @error = -1
	--				SET @error_message = 'Não foi possível concluir. É necessário definir o Código de Imposto.'
	--				SELECT @error, @error_message
	--			END

		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 03/01/2017
-- Description:	Atualizar o campo Regra de Distribuição nas Linhas do Pedido (ESBOÇO)
-- OBS:UPDATE IRREGULAR AUTORIZADO PELO ROBSON VIA CHAMADO 2271
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = N'112') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas

BEGIN
	DECLARE @ContEsb int = 0	
	DECLARE @CentroCustosEsb NVarchar (255)
	--DECLARE @IDPedido int = @list_of_cols_val_tab_del
	DECLARE @TotalLinhasEsb  int = (SELECT MAX(LineNum) FROM DRF1 WHERE ObjType = 17 AND DocEntry = @list_of_cols_val_tab_del)	

	WHILE(@ContEsb < @TotalLinhasEsb+1)
		BEGIN
			SET @CentroCustosEsb= (
			
			SELECT  
				I.[U_MW_CENTRO]
		FROM
		DRF1 T1		
		INNER JOIN OITM I ON T1.ItemCode = I.ItemCode
		WHERE  T1.ObjType = 17 AND T1.DocEntry = @list_of_cols_val_tab_del AND T1.LineNum = @ContEsb)
		

			if ( @CentroCustosEsb  is not null AND @CentroCustosEsb <> '')
				BEGIN
					UPDATE DRF1	SET OcrCode = @CentroCustosEsb, CogsOcrCod = @CentroCustosEsb 
					WHERE ObjType = 17 AND DocEntry = @list_of_cols_val_tab_del AND LineNum =  @ContEsb
					
				END;
		
			SET @ContEsb = @ContEsb + 1
		END;
		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 16/03/2017
-- update date: 
-- Description:	Atualizar o campo Regra de Distribuição nas Linhas do Pedido de Compra 
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '22') and (@transaction_type in ('A','U'))--'22' = Pedido de compra frete

BEGIN
	DECLARE @ContOPOR int = 0	
	DECLARE @CentroCustosOPOR NVarchar (255)
	--DECLARE @IDPedido int = @list_of_cols_val_tab_del
	DECLARE @TotalLinhasOPOR  int = (SELECT MAX(LineNum) FROM POR1 WHERE DocEntry = @list_of_cols_val_tab_del)	

	WHILE(@ContOPOR < @TotalLinhasOPOR+1)
		BEGIN
			SET @CentroCustosOPOR = (
			
			SELECT  
				I.[U_MW_CENTRO]  
			FROM 
				OITM I
				INNER JOIN POR1 T1 ON I.ItemCode = T1.ItemCode
			WHERE T1.DocEntry = @list_of_cols_val_tab_del AND T1.LineNum = @ContOPOR)
		

			if ( @CentroCustosOPOR  is not null AND @CentroCustosOPOR <> '')
				BEGIN
					UPDATE POR1	SET OcrCode = @CentroCustosOPOR, CogsOcrCod = @CentroCustosOPOR WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum =  @ContOPOR
					
				END;
		
			SET @ContOPOR = @ContOPOR+ 1
		END;
		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 03/01/2017
-- update date: 15/03/2017
-- Description:	Atualizar o campo Regra de Distribuição nas Linhas do Pedido
-- OBS:UPDATE IRREGULAR AUTORIZADO PELO ROBSON VIA CHAMADO 2271
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas

BEGIN
	DECLARE @Cont int = 0	
	DECLARE @CentroCustos NVarchar (255)
	--DECLARE @IDPedido int = @list_of_cols_val_tab_del
	DECLARE @TotalLinhas  int = (SELECT MAX(LineNum) FROM rdr1 WHERE DocEntry = @list_of_cols_val_tab_del)	

	WHILE(@Cont < @TotalLinhas+1)
		BEGIN
			SET @CentroCustos = (
			
			SELECT  
				I.[U_MW_CENTRO]
			FROM 
				OITM I
				INNER JOIN RDR1 T1 ON I.ItemCode = T1.ItemCode
			WHERE T1.DocEntry = @list_of_cols_val_tab_del AND T1.LineNum = @Cont)
		

			if ( @CentroCustos  is not null AND @CentroCustos <> '')
				BEGIN
					UPDATE RDR1	SET OcrCode = @CentroCustos, CogsOcrCod = @CentroCustos WHERE DocEntry = @list_of_cols_val_tab_del AND LineNum =  @Cont
					
				END;
		
			SET @Cont = @Cont + 1
		END;
		
END;
--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
------ Author: Henrique Truyts 
------ Create date: 02/04/2019
------ Update date: 14/08/2019
------ Documentos:  Pedido de Venda, Solicitação de Compra,Pedido de Compra, Oferta de Compra E Esboços
------ GLPI ID: 6734
------ GLPI ID Atualizações: 8927 - Saída de mercadorias sendo adicionadas sem regra de distribuição
------ GLPI ID Atualizações: 13866 - Almoxarifado pode adicionar solicitação de compra sem o preenchimento dos campos
-- Description:	Bloquear Documentos sem Regra de Distribuição,Utilização e Código de imposto

---------------------------------------------------------------------------------------------------------------------------

------------------------------------------------ Pedido de Venda------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas

BEGIN
	
	DECLARE @DocEntryPV int = @list_of_cols_val_tab_del
	DECLARE @DocTypePV char = (SELECT DocType FROM ORDR WHERE DocEntry = @DocEntryPV)

	--Regra de Distribuição
	IF EXISTS(
			SELECT 
				OL.OcrCode 
			FROM 
				ORDR O
			    INNER JOIN RDR1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryPV AND OL.OcrCode IS NULL)
		BEGIN
			SET @error = -6734
			SET @error_message = 'Pedidos de Venda - Não foi possível concluir. É necessário definir a Regra de Distribuição.'
			SELECT @error, @error_message
		END
		
	--Utilização
	IF EXISTS(
			SELECT 
				OL.Usage 
			FROM 
				ORDR O
			    INNER JOIN RDR1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryPV AND OL.OcrCode IS NULL)
	BEGIN
		IF ( @DocTypePV = 'I')
		BEGIN
			SET @error = -6734
			SET @error_message = 'Pedidos de Venda - Não foi possível concluir. É necessário definir uma Utilização.'
			SELECT @error, @error_message
		END
	END

	--Código de imposto
	IF EXISTS(
			SELECT 
				OL.TaxCode
			FROM 
				ORDR O
			    INNER JOIN RDR1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryPV AND OL.OcrCode IS NULL)
	BEGIN
		SET @error = -6734
		SET @error_message = 'Pedidos de Venda - Não foi possível concluir. É necessário definir o Código de Imposto.'
		SELECT @error, @error_message
	END
		
END;
------------------------------------------------ Solicitação de Compra ------------------------------------------------
IF (@object_type = '1470000113') and (@transaction_type in ('A','U'))--'17' = Solicitação de Compra

DECLARE @UserSign6734SC int = (SELECT UserSign2 FROM OPRQ WHERE DocEntry = @list_of_cols_val_tab_del)
DECLARE @Dep6734SC int SET @Dep6734SC = (SELECT Department FROM OUSR WHERE USERID = @UserSign6734SC)

IF(@Dep6734SC NOT IN (22))
BEGIN

BEGIN 
 IF (SELECT 
		COUNT(*) 
	 FROM
		PRQ1 SC
		WHERE 
		(SC.DocEntry = @list_of_cols_val_tab_del) AND (SC.OcrCode = '' OR SC.OcrCode IS NULL)) > 0
 BEGIN
  SET @error = -6734
  SET @error_message = 'Solicitação de Compra - Não foi possível concluir. É necessário definir a Regra de Distribuição.'
  SELECT @error, @error_message
   
 END;
 --Utilização obrigatoria
 IF (SELECT 
		COUNT(*)
	 FROM
		PRQ1 SC
	WHERE 
		(SC.DocEntry = @list_of_cols_val_tab_del) AND (SC.usage = '' OR SC.usage IS NULL)) > 0
 BEGIN 
  SET @error = -6734
  SET @error_message = 'Solicitação de Compra - Não foi possível concluir. É necessário definir a Utilização.'
  SELECT @error, @error_message

 END;
END;
END

------------------------------------------------ Pedido de Compra ------------------------------------------------
IF (@object_type = '22') and (@transaction_type in ('A','U'))--'22' = Pedido de Compras

BEGIN

	DECLARE @DocEntryPC int = @list_of_cols_val_tab_del
	DECLARE @DocTypePC char = (SELECT DocType FROM OPOR WHERE DocEntry = @DocEntryPC)

	--Regra de Distribuição
	IF EXISTS(
			SELECT 
				OL.OcrCode 
			FROM 
				OPOR O
			    INNER JOIN POR1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryPC AND OL.OcrCode IS NULL)
				BEGIN
					SET @error = -6734
					SET @error_message = 'Pedidos de Compra - Não foi possível concluir. É necessário definir a Regra de Distribuição.'
					SELECT @error, @error_message
				END
		
	--Utilização
	IF EXISTS(
			SELECT 
				OL.Usage 
			FROM 
				OPOR O
			    INNER JOIN POR1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryPC AND OL.OcrCode IS NULL)
			BEGIN
				if (@DocTypePC = 'I')
					BEGIN
						SET @error = -6734
						SET @error_message = 'Pedidos de Compra - Não foi possível concluir. É necessário definir uma Utilização.'
						SELECT @error, @error_message
					END
			END

		--Código de imposto
	IF EXISTS(
			SELECT 
				OL.TaxCode
			FROM 
				OPOR O
			    INNER JOIN POR1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryPC AND OL.OcrCode IS NULL)
				BEGIN
					SET @error = -6734
					SET @error_message = 'Pedidos de Compra - Não foi possível concluir. É necessário definir o Código de Imposto.'
					SELECT @error, @error_message
				END

		
END;
------------------------------------------------ Oferta de Compra 540000006
IF (@object_type = '540000006') and (@transaction_type in ('A','U'))--' 540000006' = Oferta de Compras

BEGIN

	DECLARE @DocEntryOFC int = @list_of_cols_val_tab_del
	DECLARE @DocTypeOFC char = (SELECT DocType FROM OPQT WHERE DocEntry = @DocEntryOFC)

	--Regra de Distribuição
	IF EXISTS(
			SELECT 
				OL.OcrCode 
			FROM 
				OPQT O
			    INNER JOIN PQT1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryOFC AND OL.OcrCode IS NULL)
				BEGIN
					SET @error = -6734
					SET @error_message = 'Oferta de Compra - Não foi possível concluir. É necessário definir a Regra de Distribuição.'
					SELECT @error, @error_message
				END
		
	--Utilização
	IF EXISTS(
			SELECT 
				OL.Usage 
			FROM 
				OPQT O
			    INNER JOIN PQT1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryOFC AND OL.OcrCode IS NULL)
			BEGIN
				if (@DocTypeOFC = 'I')
					BEGIN
						SET @error = -6734
						SET @error_message = 'Oferta de Compra - Não foi possível concluir. É necessário definir uma Utilização.'
						SELECT @error, @error_message
					END
			END

		--Código de imposto
	IF EXISTS(
			SELECT 
				OL.TaxCode
			FROM 
				OPQT O
			    INNER JOIN PQT1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntryOFC AND OL.OcrCode IS NULL)
				BEGIN
					SET @error = -6734
					SET @error_message = 'OFerta de Compra - Não foi possível concluir. É necessário definir o Código de Imposto.'
					SELECT @error, @error_message
				END		
END;

------------------------------------------------ Saída de mercadorias ------------------------------------------------
IF (@object_type = '60') and (@transaction_type in ('A','U'))--'60' = Saída de mercadorias

BEGIN
	
	DECLARE @DocEntrySM int = @list_of_cols_val_tab_del
	DECLARE @DocTypeSM char = (SELECT DocType FROM OIGE WHERE DocEntry = @DocEntrySM)

	--Regra de Distribuição
	IF EXISTS(
			SELECT 
				OL.OcrCode 
			FROM 
				OIGE O
			    INNER JOIN IGE1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.DocEntry = @DocEntrySM AND (OL.OcrCode IS NULL OR OL.OcrCode = '') AND (OL.AcctCode LIKE '4%' OR OL.AcctCode LIKE '5%'))
		BEGIN
			SET @error = 6734
			SET @error_message = 'Saída de mercadorias - Não foi possível concluir. É necessário definir a Regra de Distribuição.'
			SELECT @error, @error_message
		END

END;

------------------------------------------------ Esboços Todos os Documentos acima
IF (@object_type = N'112') and (@transaction_type in ('A','U'))--N'112' = ESBOÇO

BEGIN
	DECLARE @DocEntryESB int = @list_of_cols_val_tab_del
	DECLARE @DocTypeESB char = (SELECT DocType FROM ODRF 
							WHERE objtype in (17,1470000113,22,540000006,60) AND DocEntry = @DocEntryESB)

	--Regra de Distribuição
	IF EXISTS(
			SELECT 
				OL.OcrCode 
			FROM 
				ODRF O
			    INNER JOIN DRF1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.objtype in (17,1470000113,22,540000006,60) AND o.DocEntry = @DocEntryESB AND OL.OcrCode IS NULL)
		BEGIN
			SET @error = -6734
			SET @error_message = 'Esboço - Não foi possível concluir. É necessário definir a Regra de Distribuição.'
			SELECT @error, @error_message
		END
		
	--Utilização
	IF EXISTS(
			SELECT 
				OL.Usage 
			FROM 
				ODRF O
			    INNER JOIN DRF1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.objtype in (17,1470000113,22,540000006) AND o.DocEntry = @DocEntryESB AND OL.OcrCode IS NULL)
		BEGIN
			IF(@DocTypeESB = 'I')
			BEGIN
				SET @error = -6734
				SET @error_message = 'Esboço - Não foi possível concluir. É necessário definir uma Utilização.'
				SELECT @error, @error_message
			END
		END

	--Código de imposto
	IF EXISTS(
			SELECT 
				OL.TaxCode
			FROM 
				ODRF O
			    INNER JOIN DRF1 OL ON O.DocEntry = ol.DocEntry
			WHERE o.objtype in (17,1470000113,22,540000006) AND o.DocEntry = @DocEntryESB AND OL.OcrCode IS NULL)
		BEGIN
			SET @error = -6734
			SET @error_message = 'Esboço - Não foi possível concluir. É necessário definir o Código de Imposto.'
			SELECT @error, @error_message
		END
			
END;


--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-- Author:		Henrique Truyts
-- Create date: 03/01/2017
-- Update Date: 16/02/2017
-- Description:	Atualizar o campo Comissao na Linha do Pedido Com base no cadastro de comissao do vendedor
--------------------------------------------------------------------------------------------------------------------------------
IF (@object_type = '17') and (@transaction_type in ('A','U'))--'17' = Pedido de Vendas

BEGIN
	DECLARE @Contador int = 0	
	DECLARE @Comissao float = 0
	DECLARE @DocEntry int = @list_of_cols_val_tab_del
	DECLARE @CardCodeComission Nvarchar (20) = (SELECT CardCode FROM ORDR WHERE DocEntry = @DocEntry)
	DECLARE @ComissaoEspecial float = 0
	DECLARE @QtyLines  int = (SELECT MAX(LineNum) FROM rdr1 WHERE DocEntry = @DocEntry)	


	Set @ComissaoEspecial = (SELECT U_RA_Comissao_Especial FROM OCRD WHERE CardCode = @CardCodeComission)
		
	WHILE(@Contador < @QtyLines+1)
		BEGIN
			IF(@ComissaoEspecial is not null AND @ComissaoEspecial >0)
				BEGIN
					SET @Comissao = @ComissaoEspecial
				END
			ELSE 
				BEGIN
					SET @Comissao = (
						SELECT 
							c.U_MW_PRCT
						FROM	
							[@MW_CDV1] C
						INNER JOIN [@MW_CDV0] C0 ON C0.Code = C.Code
						INNER JOIN OSLP V ON V.SlpName = C0.U_MW_SlpCode
						INNER JOIN ORDR O ON O.SlpCode = v.SlpCode
						INNER JOIN RDR1 OL ON OL.DocEntry = o.DocEntry AND c.U_MW_ItemCode = ol.ItemCode
						WHERE o.DocNum = @DocEntry AND ol.LineNum = @Contador)
				END

			if (@Comissao > 0)
				BEGIN
					UPDATE RDR1	SET U_MW_PCOM = @Comissao WHERE DocEntry = @DocEntry AND LineNum =  @Contador
					
				END;
		
			SET @Contador = @Contador + 1
		END;
		
END;




-----------------------------------------------------------------------------------------------------------
---- SPS CONSULTORIA
---- BLOQUEIA ADICIONAR PEDIDO DE VENDA QUANDO O PN POSSUI BOLETOS EM ABERTO - BANKPLUS
---- Description Update: Acrescentado mais um documento na trava, e atualizado AND com as datas.
---- Criado: GISLAINE FERNANDES
---- Atualizado: LEONARDO DO PRADO GOMES
---- Data Criação:16/11/2023
---- Data Update: 08/01/2024
-----------------------------------------------------------------------------------------------------------
/*
IF  @object_type in ('17', '23') AND @Transaction_type in ('A')
BEGIN 
	DECLARE @CardCode NVARCHAR (20)
	SET @CardCode = (select CardCode From ORDR where DocEntry = @list_of_cols_val_tab_del)
	DECLARE @BolAti INT 

	IF @object_type = 17 
		BEGIN 
			set @BolAti = (  
												SELECT 
												COUNT (*)
												FROM OINV T0
												INNER JOIN [IV_IB_BillOfExchange] T1 ON T0.Serial = T1.Document
												INNER JOIN INV6 T2 ON T0.DocEntry = T2.DocEntry
												WHERE T0.CardCode = @CardCode
												  AND T1.DocType = 13 
												  AND T2.InstlmntID = T1.InstallmentID
												  AND T1.Status in (1,3) AND T0.CANCELED = 'N'  
												  --AND t1.DueDate < GETDATE()
												  AND CONVERT(DATE, T1.DueDate) < CONVERT(DATE, GETDATE())
											  )
					  IF @BolAti > 0

						BEGIN
							SET @error = 1
							SET @error_message = N'SPS PEDIDO DE VENDAS - EXISTEM BOLETOS EM ABERTO PARA ESTE CLIENTE, GENTILEZA PROCURAR CRÉDITO E COBRANÇA!'
						END;  
			END;
	ELSE 
	   BEGIN

		   set @BolAti = (  
													SELECT 
													COUNT (*)
													FROM OINV T0
													INNER JOIN [IV_IB_BillOfExchange] T1 ON T0.Serial = T1.Document
													INNER JOIN INV6 T2 ON T0.DocEntry = T2.DocEntry
													WHERE T0.CardCode = @CardCode
													  AND T1.DocType = 13 
													  AND T2.InstlmntID = T1.InstallmentID
													  AND T1.Status in (1,3) AND T0.CANCELED = 'N'  
													  --AND t1.DueDate < GETDATE()
													  AND CONVERT(DATE, T1.DueDate) < CONVERT(DATE, GETDATE())
												  )
						  IF @BolAti > 0

							BEGIN
								SET @error = 1
								SET @error_message = N'SPS COTAÇÃO DE VENDAS - EXISTEM BOLETOS EM ABERTO PARA ESTE CLIENTE, GENTILEZA PROCURAR CRÉDITO E COBRANÇA!'
							END;  
	   END 
    
END;    



--------------------------------------------------------------------------------------------------------------------------------
-- END
---------------------------------------------------------------------------------------------------------------------------------
*/




--Start IntegrationBank
DECLARE @companyDbIntBank nvarchar(128)
SET @companyDbIntBank =  (SELECT DB_NAME())
EXEC [IV_IB_TransNotificationValidateIntBank] @companyDbIntBank, @companyDbIntBank, 'IV_IB_Setting', 'IV_IB_BillOfExchange', 'IV_IB_BillOfExchangeInstallment', 'IV_IB_CompanyLocal', @object_type, @transaction_type, @list_of_cols_val_tab_del, @error OUTPUT, @error_message OUTPUT
--End IntegrationBank--Start BankPlus
DECLARE @BancoDeDados nvarchar(128)
SET @BancoDeDados =  (SELECT DB_NAME())
EXEC [IV_IB_TransacaoValidacaoPagamentoBankPlus] @BancoDeDados, @object_type, @transaction_type, @list_of_cols_val_tab_del, @error OUTPUT, @error_message OUTPUT
--End BankPlus
-- Select the return values


select @error, @error_message

end

