DECLARE    
    CURSOR C_STG_PROMO IS
SELECT 
    PROM.CD_PROMOCAO, 
    PROM.NM_PROMOCAO, 
    PROM.TP_PROMOCAO, 
    PROM.DT_INICIO_PROMO, 
    PROM.DT_FIM_PROMO
    
FROM STG_T_PROMOCAO PROM

ORDER BY PROM.CD_PROMOCAO;
        
    TYPE ARRAY_PROMO IS TABLE OF
        C_STG_PROMO%ROWTYPE
        INDEX BY PLS_INTEGER;
        
    AR_PROMO ARRAY_PROMO;     
    
 v_NM_PROMOCAO                  		DIM_PROMOCAO.NM_PROMOCAO%TYPE;
 v_DT_FIM								DIM_PROMOCAO.DT_FINAL_PROMOCAO%TYPE;
 
BEGIN
    
    OPEN C_STG_PROMO;
        FETCH C_STG_PROMO BULK COLLECT INTO AR_PROMO;   
        FOR I IN 1..AR_PROMO.COUNT
        LOOP
         BEGIN
                   
           SELECT NM_PROMOCAO,DT_FINAL_PROMOCAO
				  INTO 
						v_NM_PROMOCAO,
						v_DT_FIM
						
			FROM DIM_PROMOCAO
				WHERE NK_PROMOCAO = AR_PROMO(I).CD_PROMOCAO AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_PROMOCAO WHERE NK_PROMOCAO = AR_PROMO(I).CD_PROMOCAO);
				
				
                     IF  v_NM_PROMOCAO    <> AR_PROMO(I).NM_PROMOCAO       OR
                         v_DT_FIM         <> AR_PROMO(I).DT_FIM_PROMO 	THEN
                          
                          UPDATE DIM_PROMOCAO
                          SET DT_FIM = (SYSDATE - 1)
                          WHERE NK_PROMOCAO = AR_PROMO(I).CD_PROMOCAO
                          AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_PROMOCAO WHERE NK_PROMOCAO = AR_PROMO(I).CD_PROMOCAO) LOG ERRORS REJECT LIMIT UNLIMITED;
               
                      INSERT INTO DIM_PROMOCAO (
                                       SK_PROMOCAO,     
                                       NK_PROMOCAO,      
                                       NM_PROMOCAO,  
                                       DS_TIPO_PROMOCAO,
                                       DT_INICIO_PROMOCAO,
                                       DT_FINAL_PROMOCAO,
									   DT_INI,
									   DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_PROMOCAO.nextval,     
                                       AR_PROMO(I).CD_PROMOCAO,      
                                       AR_PROMO(I).NM_PROMOCAO,
                                       AR_PROMO(I).TP_PROMOCAO,
                                       AR_PROMO(I).DT_INICIO_PROMO,
                                       AR_PROMO(I).DT_FIM_PROMO,
									   (SYSDATE - 1),
									   TO_DATE('01/01/2050', 'dd/mm/yyyy')
                                      ) LOG ERRORS REJECT LIMIT UNLIMITED;
                                      
              END IF;      
           
          EXCEPTION
          WHEN no_data_found THEN
          
          INSERT INTO DIM_PROMOCAO (
                                       SK_PROMOCAO,     
                                       NK_PROMOCAO,      
                                       NM_PROMOCAO,  
                                       DS_TIPO_PROMOCAO,
                                       DT_INICIO_PROMOCAO,
                                       DT_FINAL_PROMOCAO,
									   DT_INI,
									   DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_PROMOCAO.nextval,     
                                       AR_PROMO(I).CD_PROMOCAO,      
                                       AR_PROMO(I).NM_PROMOCAO,
                                       AR_PROMO(I).TP_PROMOCAO,
                                       AR_PROMO(I).DT_INICIO_PROMO,
                                       AR_PROMO(I).DT_FIM_PROMO,
									   TO_DATE('01/01/2016', 'dd/mm/yyyy'),
									   TO_DATE('01/01/2050', 'dd/mm/yyyy')
                                      ) LOG ERRORS REJECT LIMIT UNLIMITED;                         
								
             
  
          
          end;
           
             
            END LOOP;
             dbms_output.put_line('Cursor: '||C_STG_PROMO%ROWCOUNT);
        CLOSE C_STG_PROMO;
             
          
        COMMIT;
END;
/

