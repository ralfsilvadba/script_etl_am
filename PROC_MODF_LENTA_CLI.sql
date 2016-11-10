DECLARE    
    CURSOR C_STG_CLI IS
        SELECT CLI.CD_CLIENTE, 
               CLI.NM_CLIENTE, 
               CLI.DT_NASC_CLIENTE, 
               CLI.DS_SEXO, 
               (ENDER.TP_LOGRADOURO ||' ' || ENDER.NM_ENDERECO ||' '|| ENDER.DS_COMPLEMENTO) DS_ENDERECO,
               BAI.NM_BAIRRO,
               CID.NM_CIDADE,
               EST.NM_ESTADO,
               VEND.DT_VENDA
FROM STG_T_CLIENTE CLI
               INNER JOIN STG_T_VENDA VEND ON CLI.CD_CLIENTE = VEND.CD_CLIENTE
               INNER JOIN STG_T_ENDERECO ENDER ON CLI.CD_CLIENTE = ENDER.CD_CLIENTE
               INNER JOIN STG_T_BAIRRO BAI ON ENDER.CD_BAIRRO = BAI.CD_BAIRRO
               INNER JOIN STG_T_CIDADE CID ON BAI.CD_CIDADE = CID.CD_CIDADE
               INNER JOIN STG_T_ESTADO EST ON CID.CD_ESTADO = EST.CD_ESTADO
ORDER BY DT_VENDA DESC;
        
    TYPE ARRAY_CLI IS TABLE OF
        C_STG_CLI%ROWTYPE
        INDEX BY PLS_INTEGER;
        
   AR_CLI ARRAY_CLI;       
    
 v_DS_ENDERECO                  DIM_CLIENTE.DS_ENDERECO_CLIENTE%TYPE;
 v_DS_BAIRRO  					DIM_CLIENTE.DS_BAIRRO_CLIENTE%TYPE;
 v_DS_CIDADE                    DIM_CLIENTE.DS_CIDADE_CLIENTE%TYPE;
 v_DS_ESTADO                    DIM_CLIENTE.DS_ESTADO_CLIENTE%TYPE;
 
BEGIN


    
    OPEN C_STG_CLI;
        FETCH C_STG_CLI BULK COLLECT INTO AR_CLI;   
        FOR I IN 1..AR_CLI.COUNT
        LOOP
         BEGIN
                   
           SELECT DS_ENDERECO_CLIENTE , DS_BAIRRO_CLIENTE, DS_CIDADE_CLIENTE, DS_ESTADO_CLIENTE
				  INTO v_DS_ENDERECO, v_DS_BAIRRO, v_DS_CIDADE, v_DS_ESTADO
			FROM DIM_CLIENTE
				WHERE NK_CLIENTE = AR_CLI(I).CD_CLIENTE AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_CLIENTE WHERE NK_CLIENTE = AR_CLI(I).CD_CLIENTE);
				
                     IF  v_DS_ENDERECO <> AR_CLI(I).DS_ENDERECO    OR
                          v_DS_BAIRRO <> AR_CLI(I).NM_BAIRRO 	   OR
                          v_DS_CIDADE <> AR_CLI(I).NM_CIDADE	   OR 
						  v_DS_ESTADO <> AR_CLI(I).NM_ESTADO THEN
                          
                          UPDATE DIM_CLIENTE
                          SET DT_FIM = (SYSDATE - 1)
                          WHERE NK_CLIENTE = AR_CLI(I).CD_CLIENTE
                          AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_CLIENTE WHERE NK_CLIENTE = AR_CLI(I).CD_CLIENTE) LOG ERRORS REJECT LIMIT UNLIMITED;
               
                      INSERT INTO DIM_CLIENTE (
                                       SK_CLIENTE,     
                                       NK_CLIENTE,      
                                       NM_CLIENTE,  
                                       DT_NASC_CLIENTE, 
                                       NU_DIA_NASC_CLIENTE,   
                                       NU_MES_NASC_CLIENTE,  
                                       NU_ANO_NASC_CLIENTE,     
                                       DS_SEXO_CLIENTE,  
                                       DS_ENDERECO_CLIENTE,  
                                       DS_BAIRRO_CLIENTE,  
                                       DS_CIDADE_CLIENTE,  
                                       DS_ESTADO_CLIENTE,
                                       DT_ULTIMA_COMPRA,
									   DT_INI,
									   DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_CLIENTE.nextval,     
                                       AR_CLI(I).CD_CLIENTE,      
                                       AR_CLI(I).NM_CLIENTE,  
                                       AR_CLI(I).DT_NASC_CLIENTE, 
                                       TO_CHAR(AR_CLI(I).DT_NASC_CLIENTE,'DD'),   
                                       TO_CHAR(AR_CLI(I).DT_NASC_CLIENTE,'MM'),  
                                       TO_CHAR(AR_CLI(I).DT_NASC_CLIENTE,'YYYY'),     
                                       AR_CLI(I).DS_SEXO,  
                                       AR_CLI(I).DS_ENDERECO,  
                                       AR_CLI(I).NM_BAIRRO,  
                                       AR_CLI(I).NM_CIDADE,  
                                       AR_CLI(I).NM_ESTADO,
                                       AR_CLI(I).DT_VENDA,
									   (SYSDATE - 1),
									   TO_DATE('01/01/2050', 'dd/mm/yyyy')
                                        ) LOG ERRORS REJECT LIMIT UNLIMITED;
                                      
              END IF;      
           
          EXCEPTION
          WHEN no_data_found THEN
          
          INSERT INTO DIM_CLIENTE (
                                       SK_CLIENTE,     
                                       NK_CLIENTE,      
                                       NM_CLIENTE,  
                                       DT_NASC_CLIENTE, 
                                       NU_DIA_NASC_CLIENTE,   
                                       NU_MES_NASC_CLIENTE,  
                                       NU_ANO_NASC_CLIENTE,     
                                       DS_SEXO_CLIENTE,  
                                       DS_ENDERECO_CLIENTE,  
                                       DS_BAIRRO_CLIENTE,  
                                       DS_CIDADE_CLIENTE,  
                                       DS_ESTADO_CLIENTE,
                                       DT_ULTIMA_COMPRA,
									   DT_INI,
									   DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_CLIENTE.nextval,     
                                       AR_CLI(I).CD_CLIENTE,      
                                       AR_CLI(I).NM_CLIENTE,  
                                       AR_CLI(I).DT_NASC_CLIENTE, 
                                       TO_CHAR(AR_CLI(I).DT_NASC_CLIENTE,'DD'),   
                                       TO_CHAR(AR_CLI(I).DT_NASC_CLIENTE,'MM'),  
                                       TO_CHAR(AR_CLI(I).DT_NASC_CLIENTE,'YYYY'),     
                                       AR_CLI(I).DS_SEXO,  
                                       AR_CLI(I).DS_ENDERECO,  
                                       AR_CLI(I).NM_BAIRRO,  
                                       AR_CLI(I).NM_CIDADE,  
                                       AR_CLI(I).NM_ESTADO,
                                       AR_CLI(I).DT_VENDA,
									   TO_DATE('01/01/2016', 'dd/mm/yyyy'),
									   TO_DATE('01/01/2050', 'dd/mm/yyyy')
                                       ) LOG ERRORS REJECT LIMIT UNLIMITED;
          
             
  
          
          end;
           
             
            END LOOP;
             dbms_output.put_line('Cursor: '||C_STG_CLI%ROWCOUNT);
        CLOSE C_STG_CLI;
             
          
        COMMIT;
END;
/