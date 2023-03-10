/*
 * FUNCI?N QUE CALCULA EL MONTO NETO A PAGARLE AL EMPLEADO.
 */
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_CALCULAR_SALARIO_NETO (P_EMPLEADO_ID IN NUMBER)
RETURN NUMBER 
IS 
v_OTROS NUMBER;
v_DESPIDO NUMBER;
BEGIN

v_OTROS  :=  G4_PROYECTO_USUARIO_4.FN_OBTIENE_SALARIO_MINIMO (P_EMPLEADO_ID);

    IF G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID) > 0 THEN
        IF G4_PROYECTO_USUARIO_4.FN_CALCULA_BONI_RETRIBUCION_EMPLEADO (P_EMPLEADO_ID) > 25000 THEN
            v_OTROS := 25000;
            v_OTROS := v_OTROS + G4_PROYECTO_USUARIO_4.FN_OBTIENE_SALARIO_MINIMO (P_EMPLEADO_ID);
        ELSE 
            v_OTROS  := G4_PROYECTO_USUARIO_4.FN_CALCULA_BONI_RETRIBUCION_EMPLEADO (P_EMPLEADO_ID) + G4_PROYECTO_USUARIO_4.FN_OBTIENE_SALARIO_MINIMO (P_EMPLEADO_ID);
        END IF;
    END IF;
    
     IF G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID) < 0 THEN
        IF G4_PROYECTO_USUARIO_4.FN_CALCULA_REDU_RETRIBUCION_EMPLEADO(P_EMPLEADO_ID)  > 10000 THEN
            v_OTROS := 10000;
            v_OTROS := G4_PROYECTO_USUARIO_4.FN_OBTIENE_SALARIO_MINIMO (P_EMPLEADO_ID) - v_OTROS;
        ELSE 
            v_OTROS  := G4_PROYECTO_USUARIO_4.FN_OBTIENE_SALARIO_MINIMO (P_EMPLEADO_ID) - G4_PROYECTO_USUARIO_4.FN_CALCULA_REDU_RETRIBUCION_EMPLEADO(P_EMPLEADO_ID);
        END IF;
    END IF;
    
    IF G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID) < 0 THEN
    
        SELECT REDU_DESPIDO
            INTO v_DESPIDO 
                FROM G4_PROYECTO_USUARIO_3.REDUCCION
                    WHERE CALIFICACION = G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID);
                
        IF v_DESPIDO = 1 THEN 
            UPDATE G4_PROYECTO_USUARIO_2.EMPLEADO
                    SET EMPLEADO.EMPL_CARGO_ID = 4
                        WHERE EMPLEADO.EMPL_ID = P_EMPLEADO_ID;
            v_OTROS :=  0;
        END IF;
        
    END IF;
    
    
   
RETURN v_OTROS;
END;
--> PRUEBA DE LA FUNCI?N.
SELECT G4_PROYECTO_USUARIO_4.FN_CALCULAR_SALARIO_NETO(1) 
FROM DUAL; 