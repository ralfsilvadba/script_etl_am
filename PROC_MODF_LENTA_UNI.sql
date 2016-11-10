DECLARE    
    CURSOR C_STG_UNI IS
 SELECT 
	    UNI.CD_UNIDADE,
        UNI.NM_UNIDADE, 
        (ENDE.TP_LOGRADOURO || ENDE.NM_ENDERECO || ' ' || ENDE.DS_COMPLEMENTO) DS_ENDERECO, 
		BAI.NM_BAIRRO,
		CID.NM_CIDADE,
		EST.NM_ESTADO,
		EST.NM_ESTADO NM_REGIAO,
		FUN.NM_FUNCIONARIO
	   
FROM STG_T_UNIDADE UNI

	INNER JOIN STG_T_ENDERECO 	  ENDE ON ENDE.CD_UNIDADE 	= 	UNI.CD_UNIDADE
	INNER JOIN STG_T_BAIRRO		    BAI  ON ENDE.CD_BAIRRO  	= 	BAI.CD_BAIRRO
	INNER JOIN STG_T_CIDADE   	  CID  ON BAI.CD_CIDADE   	= 	CID.CD_CIDADE
	INNER JOIN STG_T_ESTADO   	  EST  ON CID.CD_ESTADO   	= 	EST.CD_ESTADO
	INNER JOIN STG_T_FUNCIONARIO 	FUN  ON UNI.CD_UNIDADE  	= 	FUN.CD_UNIDADE
	
	WHERE FUN.CD_CARGO = 1
	
ORDER BY UNI.CD_UNIDADE;
        
    TYPE ARRAY_UNI IS TABLE OF
        C_STG_UNI%ROWTYPE
        INDEX BY PLS_INTEGER;
        
    AR_UNI ARRAY_UNI;      
    
 v_NM_UNIDADE                  			DIM_UNIDADE.NM_UNIDADE%TYPE;
 v_NM_GERENTE                   		DIM_UNIDADE.NM_GERENTE_UNIDADE%TYPE;
 
BEGIN
    
    OPEN C_STG_UNI;
        FETCH C_STG_UNI BULK COLLECT INTO AR_UNI;   
        FOR I IN 1..AR_UNI.COUNT
        LOOP
         BEGIN
                   
           SELECT NM_UNIDADE,NM_GERENTE_UNIDADE
				  INTO 
						v_NM_UNIDADE,
						
						v_NM_GERENTE
						
			FROM DIM_UNIDADE
				WHERE NK_UNIDADE = AR_UNI(I).CD_UNIDADE AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_UNIDADE WHERE NK_UNIDADE = AR_UNI(I).CD_UNIDADE);
				
				
                     IF  v_NM_UNIDADE    <> AR_UNI(I).NM_UNIDADE         OR
						 v_NM_GERENTE <> AR_UNI(I).NM_FUNCIONARIO
						 THEN
                          
                          UPDATE DIM_UNIDADE
                          SET DT_FIM = (SYSDATE - 1)
                          WHERE NK_UNIDADE = AR_UNI(I).CD_UNIDADE
                          AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_UNIDADE WHERE NK_UNIDADE = AR_UNI(I).CD_UNIDADE) LOG ERRORS REJECT LIMIT UNLIMITED;
               
                      INSERT INTO DIM_UNIDADE (
                                       SK_UNIDADE,     
                                       NK_UNIDADE,      
                                       NM_UNIDADE,    
                                       DS_ENDERECO_UNIDADE,  
                                       DS_BAIRRO_UNIDADE,  
                                       DS_CIDADE_UNIDADE,  
                                       DS_ESTADO_UNIDADE,
                                       NM_GERENTE_UNIDADE,
									   DT_INI,
									   DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_UNIDADE.nextval,     
                                       AR_UNI(I).CD_UNIDADE,      
                                       AR_UNI(I).NM_UNIDADE,  
                                       AR_UNI(I).DS_ENDERECO,  
                                       AR_UNI(I).NM_BAIRRO,  
                                       AR_UNI(I).NM_CIDADE,  
                                       AR_UNI(I).NM_ESTADO,
                                       AR_UNI(I).NM_FUNCIONARIO,                                      
									   (SYSDATE - 1),
									   TO_DATE('01/01/2050', 'dd/mm/yyyy')
                                      ) LOG ERRORS REJECT LIMIT UNLIMITED;
                                      
              END IF;      
           
          EXCEPTION
          WHEN no_data_found THEN
          
          INSERT INTO DIM_UNIDADE (
                                       SK_UNIDADE,     
                                       NK_UNIDADE,      
                                       NM_UNIDADE,    
                                       DS_ENDERECO_UNIDADE,  
                                       DS_BAIRRO_UNIDADE,  
                                       DS_CIDADE_UNIDADE,  
                                       DS_ESTADO_UNIDADE,
                                       NM_GERENTE_UNIDADE,
									   DT_INI,
									   DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_UNIDADE.nextval,     
                                       AR_UNI(I).CD_UNIDADE,      
                                       AR_UNI(I).NM_UNIDADE,  
                                       AR_UNI(I).DS_ENDERECO,  
                                       AR_UNI(I).NM_BAIRRO,  
                                       AR_UNI(I).NM_CIDADE,  
                                       AR_UNI(I).NM_ESTADO,
                                       AR_UNI(I).NM_FUNCIONARIO,                                      
									   TO_DATE('01/01/2016', 'dd/mm/yyyy'),
									   TO_DATE('01/01/2050', 'dd/mm/yyyy')
                                      ) LOG ERRORS REJECT LIMIT UNLIMITED;
          
             
  
          
          end;
           
             
            END LOOP;
             dbms_output.put_line('Cursor: '||C_STG_UNI%ROWCOUNT);
        CLOSE C_STG_UNI;
             
          
        COMMIT;
END;
/

