DECLARE    
    CURSOR C_STG_FUN IS
        SELECT FUN.CD_FUNCIONARIO, 
                             FUN.NM_FUNCIONARIO,
                             CAR.CD_CARGO,
                             CAR.NM_CARGO,
                             FUN.CD_GERENTE,
                             GER.NM_FUNCIONARIO NM_GERENTE,
                             FUN.DS_SEXO_FUNCIONARIO,
							 FUN.DT_NASC_FUNCIONARIO,
                             FUN.DT_ADMISSAO,
                             FUN.DT_DEMISSAO
FROM STG_T_FUNCIONARIO FUN
                           INNER JOIN STG_T_FUNCIONARIO GER ON FUN.CD_GERENTE = GER.CD_FUNCIONARIO
                           INNER JOIN STG_T_CARGO CAR ON FUN.CD_CARGO = CAR.CD_CARGO
ORDER BY FUN.CD_FUNCIONARIO;
        
    TYPE ARRAY_FUN IS TABLE OF
        C_STG_FUN%ROWTYPE
        INDEX BY PLS_INTEGER;
        
    AR_FUN ARRAY_FUN;        
    
 v_ARRAY_POS                 NUMBER(38);
 v_NK_CARGO                  DIM_FUNCIONARIO.NK_CARGO_FUNCIONARIO%TYPE;
 v_NK_GERENTE                DIM_FUNCIONARIO.NK_GERENTE%TYPE;
 v_DT_DEMISSAO               VARCHAR2(15);
 
BEGIN
    
    OPEN C_STG_FUN;
        FETCH C_STG_FUN BULK COLLECT INTO AR_FUN;   
        FOR I IN 1..AR_FUN.COUNT
        LOOP
         BEGIN
                   
                     SELECT NK_CARGO_FUNCIONARIO, NK_GERENTE, DT_DEMISSAO
                              INTO v_NK_CARGO, v_NK_GERENTE, v_DT_DEMISSAO
                     FROM DIM_FUNCIONARIO
                              WHERE NK_FUNCIONARIO = AR_FUN(I).CD_FUNCIONARIO AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_FUNCIONARIO WHERE NK_FUNCIONARIO = AR_FUN(I).CD_FUNCIONARIO);
                              
                     IF  v_NK_CARGO <> AR_FUN(I).CD_CARGO    OR
                          v_NK_GERENTE <> AR_FUN(I).CD_GERENTE OR
                          v_DT_DEMISSAO <> AR_FUN(I).DT_DEMISSAO THEN
                          
                          UPDATE DIM_FUNCIONARIO
                          SET DT_FIM = (SYSDATE - 1)
                          WHERE NK_FUNCIONARIO = AR_FUN(I).CD_FUNCIONARIO
                          AND DT_FIM = (SELECT MAX(DT_FIM) FROM DIM_FUNCIONARIO WHERE NK_FUNCIONARIO = AR_FUN(I).CD_FUNCIONARIO) LOG ERRORS REJECT LIMIT UNLIMITED;
               
                      INSERT INTO DIM_FUNCIONARIO (SK_FUNCIONARIO,     
                                       NK_FUNCIONARIO,      
                                       NM_FUNCIONARIO,
                                       NK_CARGO_FUNCIONARIO,
                                       DS_CARGO_FUNCIONARIO,
                                       NK_GERENTE,
                                       NM_GERENTE,
                                       DS_SEXO,
									   DT_NASC_FUNCIONARIO,
                                       DT_CONTRATACAO,
                                       DT_DEMISSAO,
                                       DT_INI,
                                       DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_FUNCIONARIO.nextval,
                                       AR_FUN(I).CD_FUNCIONARIO, 
                                       AR_FUN(I).NM_FUNCIONARIO, 
                                       AR_FUN(I).CD_CARGO,
                                       AR_FUN(I).NM_CARGO,
                                       AR_FUN(I).CD_GERENTE,
                                       AR_FUN(I).NM_GERENTE,
                                       AR_FUN(I).DS_SEXO_FUNCIONARIO,
									   AR_FUN(I).DT_NASC_FUNCIONARIO,
                                       AR_FUN(I).DT_ADMISSAO,
                                       AR_FUN(I).DT_DEMISSAO,
                                       (SYSDATE - 1),
                                       TO_DATE('01/01/2050', 'dd/mm/yyyy')) LOG ERRORS REJECT LIMIT UNLIMITED;
                                      
              END IF;      
           
          EXCEPTION
          WHEN no_data_found THEN
          
          INSERT INTO DIM_FUNCIONARIO (SK_FUNCIONARIO,     
                                       NK_FUNCIONARIO,      
                                       NM_FUNCIONARIO,
                                       NK_CARGO_FUNCIONARIO,
                                       DS_CARGO_FUNCIONARIO,
                                       NK_GERENTE,
                                       NM_GERENTE,
                                       DS_SEXO,
									   DT_NASC_FUNCIONARIO,
                                       DT_CONTRATACAO,
                                       DT_DEMISSAO,
                                       DT_INI,
                                       DT_FIM
                                       )
                                       
                                VALUES(SQ_DIM_FUNCIONARIO.nextval,
                                       AR_FUN(I).CD_FUNCIONARIO, 
                                       AR_FUN(I).NM_FUNCIONARIO, 
                                       AR_FUN(I).CD_CARGO,
                                       AR_FUN(I).NM_CARGO,
                                       AR_FUN(I).CD_GERENTE,
                                       AR_FUN(I).NM_GERENTE,
                                       AR_FUN(I).DS_SEXO_FUNCIONARIO,
									   AR_FUN(I).DT_NASC_FUNCIONARIO,
                                       AR_FUN(I).DT_ADMISSAO,
                                       AR_FUN(I).DT_DEMISSAO,
                                       TO_DATE('01/01/2016', 'dd/mm/yyyy'),  
                                       TO_DATE('01/01/2050', 'dd/mm/yyyy')) LOG ERRORS REJECT LIMIT UNLIMITED;
          
             
  
          
          end;
           
             
            END LOOP;
             dbms_output.put_line('Cursor: '||C_STG_FUN%ROWCOUNT);
        CLOSE C_STG_FUN;
             
        UPDATE DIM_FUNCIONARIO SET DT_DEMISSAO =  TO_DATE('01/01/2050', 'dd/mm/yyyy') WHERE DT_DEMISSAO IS NULL LOG ERRORS REJECT LIMIT UNLIMITED;
        
        COMMIT;
END;
/
