DECLARE    
    CURSOR C_STG_PROD IS
        SELECT PRD.CD_PRODUTO, 
                             PRD.NM_PRODUTO, 
                             PRD.DS_PRODUTO,
                             CAT.CD_CATEGORIA,
                             CAT.NM_CATEGORIA,
                             CAT.CD_CATEGORIA_PAI,
                             ( CASE CAT.CD_CATEGORIA_PAI     
                                  WHEN 1 THEN 'Bebidas'     
                                  WHEN 2 THEN 'Salgados'    
                                  WHEN 3 THEN 'Doces'     
                                  ELSE 'NULL'   
                                END ) NM_CATEGORIA_PAI,
                             COF.TP_TORRA,
                             COF.TP_ACIDEZ,
                             COF.TP_CORPO,
                             COF.TP_AROMA
		FROM STG_T_PRODUTO PRD
                          INNER JOIN STG_T_CATEGORIA CAT ON PRD.CD_CATEGORIA = CAT.CD_CATEGORIA
                          LEFT JOIN STG_T_CAFE COF ON PRD.CD_PRODUTO = COF.CD_PRODUTO;
        
    TYPE ARRAY_PROD IS TABLE OF
        C_STG_PROD%ROWTYPE
        INDEX BY PLS_INTEGER;
        
    AR_PROD ARRAY_PROD;      
    
 v_NK_CATEGORIA                  		DIM_PRODUTO.NK_CATEGORIA%TYPE;
 v_NK_SUBCATEGORIA  					DIM_PRODUTO.NK_SUBCATEGORIA%TYPE;
 v_NM_PROD                   		    DIM_PRODUTO.NM_PRODUTO%TYPE;
 
BEGIN
    
    OPEN C_STG_PROD;
        FETCH C_STG_PROD BULK COLLECT INTO AR_PROD;   
        FOR I IN 1..AR_PROD.COUNT
        LOOP
         BEGIN
                   
           SELECT NK_CATEGORIA , NK_SUBCATEGORIA, NM_PRODUTO
				  INTO v_NK_CATEGORIA, v_NK_SUBCATEGORIA, v_NM_PROD
			FROM DIM_PRODUTO
				WHERE NK_PRODUTO = AR_PROD(I).CD_PRODUTO AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_PRODUTO WHERE NK_PRODUTO = AR_PROD(I).CD_PRODUTO);
				
                     IF  v_NK_CATEGORIA    <> AR_PROD(I).CD_CATEGORIA               OR
                         v_NK_SUBCATEGORIA <> AR_PROD(I).CD_CATEGORIA_PAI 	      OR
                         v_NM_PROD         <> AR_PROD(I).NM_PRODUTO	     THEN
                          
                          UPDATE DIM_PRODUTO
                          SET DT_FIM = (SYSDATE - 1)
                          WHERE NK_PRODUTO = AR_PROD(I).CD_PRODUTO
                          AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_PRODUTO WHERE NK_PRODUTO = AR_PROD(I).CD_PRODUTO);
               
                      INSERT INTO DIM_PRODUTO (SK_PRODUTO,     
                                       NK_PRODUTO,      
                                       NM_PRODUTO,  
                                       DS_PRODUTO, 
                                       NK_CATEGORIA,   
                                       NM_CATEGORIA,  
                                       NK_SUBCATEGORIA,     
                                       NM_SUBCATEGORIA,  
                                       TP_TORRA_CAFE,  
                                       TP_ACIDEZ_CAFE,  
                                       TP_CORPO_CAFE,  
                                       TP_AROMA_CAFE,
									   DT_INI,
									   DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_PRODUTO.nextval,
                                       AR_PROD(I).CD_PRODUTO, 
                                       AR_PROD(I).NM_PRODUTO, 
                                       AR_PROD(I).DS_PRODUTO,
                                       AR_PROD(I).CD_CATEGORIA,
                                       AR_PROD(I).NM_CATEGORIA,
                                       AR_PROD(I).CD_CATEGORIA_PAI,
                                       AR_PROD(I).NM_CATEGORIA_PAI,
                                       AR_PROD(I).TP_TORRA,
                                       AR_PROD(I).TP_ACIDEZ,
                                       AR_PROD(I).TP_CORPO,
                                       AR_PROD(I).TP_AROMA,
									   (SYSDATE - 1),
									   TO_DATE('01/01/2050', 'dd/mm/yyyy')
                                      ) LOG ERRORS REJECT LIMIT UNLIMITED;
                                      
              END IF;      
           
          EXCEPTION
          WHEN no_data_found THEN
          
          INSERT INTO DIM_PRODUTO (SK_PRODUTO,     
                                       NK_PRODUTO,      
                                       NM_PRODUTO,  
                                       DS_PRODUTO, 
                                       NK_CATEGORIA,   
                                       NM_CATEGORIA,  
                                       NK_SUBCATEGORIA,     
                                       NM_SUBCATEGORIA,  
                                       TP_TORRA_CAFE,  
                                       TP_ACIDEZ_CAFE,  
                                       TP_CORPO_CAFE,  
                                       TP_AROMA_CAFE,
									   DT_INI,
									   DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_PRODUTO.nextval,
                                       AR_PROD(I).CD_PRODUTO, 
                                       AR_PROD(I).NM_PRODUTO, 
                                       AR_PROD(I).DS_PRODUTO,
                                       AR_PROD(I).CD_CATEGORIA,
                                       AR_PROD(I).NM_CATEGORIA,
                                       AR_PROD(I).CD_CATEGORIA_PAI,
                                       AR_PROD(I).NM_CATEGORIA_PAI,
                                       AR_PROD(I).TP_TORRA,
                                       AR_PROD(I).TP_ACIDEZ,
                                       AR_PROD(I).TP_CORPO,
                                       AR_PROD(I).TP_AROMA,
									   TO_DATE('01/01/2016', 'dd/mm/yyyy'),
									   TO_DATE('01/01/2050', 'dd/mm/yyyy')
                                       )  LOG ERRORS REJECT LIMIT UNLIMITED;
          
             
  
          
          end;
           
             
            END LOOP;
             dbms_output.put_line('Cursor: '||C_STG_PROD%ROWCOUNT);
        CLOSE C_STG_PROD;
             
          
        COMMIT;
END;
/

