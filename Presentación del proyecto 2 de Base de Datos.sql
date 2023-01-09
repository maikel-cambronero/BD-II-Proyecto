/****************************************************PAGAR SALARIO ****************************************************/
 /*
 * PROCEDIMIENTO QUE INSERTA EL PAGO DE SALARIO.
 */
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.SP_PAGAR_SALARIO (P_SALARIO_ID IN NUMBER,
                                                                                                                                            P_EMPLEADO_ID IN NUMBER)
IS 
BEGIN 
    INSERT INTO G4_PROYECTO_USUARIO_1.SALARIO (SALA_ID, SALA_FECHA, SALA_EMPLEADO_ID, SALA_BONI_ID, SALA_REDU_ID, SALA_NETO)
                                                                         VALUES (P_SALARIO_ID, SYSDATE, P_EMPLEADO_ID,
                                                                         G4_PROYECTO_USUARIO_4.FN_OBTIENE_ID_BONIFICACION (P_EMPLEADO_ID), 
                                                                         G4_PROYECTO_USUARIO_4.FN_OBTIENE_ID_REDUCCION (P_EMPLEADO_ID), 
                                                                         G4_PROYECTO_USUARIO_4.FN_CALCULAR_SALARIO_NETO (P_EMPLEADO_ID)); 
                                                                         
    G4_PROYECTO_USUARIO_4.FN_OBTIENE_ID_REDUCCION (P_EMPLEADO_ID);                                                                     
    COMMIT;                                                                     
END;
--> PRUEBA DEL PROCEDIMIENTO.
EXECUTE G4_PROYECTO_USUARIO_4.SP_PAGAR_SALARIO (1,1);
SELECT * FROM G4_PROYECTO_USUARIO_1.SALARIO;
 
/*
 * FUNCI�N QUE OBTIENE EL SALARIO M�NIMO DEL EMPLADO MEDIANTE UN INNER JOIN
 */
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_OBTIENE_SALARIO_MINIMO (P_EMPLEADO_ID IN NUMBER)
RETURN NUMBER
IS
v_SALARIO_MINIMO NUMBER;
BEGIN

    SELECT CARG_SALARIO_MINIMO
        INTO v_SALARIO_MINIMO
            FROM G4_PROYECTO_USUARIO_2.EMPLEADO
                INNER JOIN G4_PROYECTO_USUARIO_2.CARGO ON 
                    EMPL_CARGO_ID = CARG_ID 
                        AND EMPL_ID = P_EMPLEADO_ID;
                        
    RETURN v_SALARIO_MINIMO;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_OBTIENE_SALARIO_MINIMO (1)
 FROM DUAL;

/*
 * FUNCION QUE RETORNA LA CALIFICACION DEL EMPLEADO.
 */
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID IN NUMBER)
 RETURN NUMBER 
 IS 
 v_CALIFICACION NUMBER;
 BEGIN 
 
    SELECT SUM (ORDENES.ORDE_CALIFICACION)
        INTO v_CALIFICACION
            FROM G4_PROYECTO_USUARIO_3.ORDENES
                WHERE ORDE_EMPLEADO_ID = P_EMPLEADO_ID;
                
    RETURN v_CALIFICACION;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT  G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (3)
 FROM DUAL;

/*
 * FUNCI�N QUE OBTINE EL MONTO NETO QUE EL EMPLEADO OBTUVO.
 */
 CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_OBTENER_MONTO_NETO (P_EMPLEADO_ID IN NUMBER)
                                                                                                                                                     --   P_FECHA1 IN DATE,
                                                                                                                                                     --   P_FECHA2 IN DATE)
 RETURN NUMBER
 IS 
 v_MONTO_NETO NUMBER;
 BEGIN 
    SELECT SUM(FACT_TOTAL)
        INTO v_MONTO_NETO
            FROM G4_PROYECTO_USUARIO_1.FACTURA
                 WHERE FACT_EMPLEADO_ID = P_EMPLEADO_ID;
                 --FACT_FECHA BETWEEN P_FECHA1 AND P_FECHA2;
    RETURN v_MONTO_NETO;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_OBTENER_MONTO_NETO (2)
 FROM DUAL;
 
/*
 * FUNCI�N QUE CALCULA LA RETRIBUCI�N DEL MONTO NETO DEL EMPLEADO.
 */
 CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_CALCULA_BONI_RETRIBUCION_EMPLEADO (P_EMPLEADO_ID IN NUMBER)
 RETURN NUMBER
 IS
 v_MONTO_PORCENTAJE NUMBER;
 v_MONTO_NETO NUMBER;
 BEGIN
     IF G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID) > 0 THEN
     
        SELECT BONI_RETRIBUCION_MONTO_PORCENTUAL
             INTO v_MONTO_PORCENTAJE
                FROM G4_PROYECTO_USUARIO_3.BONIFICACION
                    WHERE BONIFICACION.BONI_RCALIFICACION = G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID);
                    
            IF v_MONTO_PORCENTAJE = NULL OR v_MONTO_PORCENTAJE = 0 THEN
            
                SELECT BONI_RETRIBUCION_MONTO_NETO
                    INTO v_MONTO_NETO
                        FROM G4_PROYECTO_USUARIO_3.BONIFICACION
                            WHERE BONIFICACION.BONI_RCALIFICACION = G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID);
                            
                RETURN v_MONTO_NETO;
             END IF;     
                    
                  v_MONTO_PORCENTAJE := v_MONTO_PORCENTAJE * G4_PROYECTO_USUARIO_4.FN_OBTENER_MONTO_NETO (P_EMPLEADO_ID);
                  RETURN v_MONTO_PORCENTAJE;      
    END IF;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_CALCULA_BONI_RETRIBUCION_EMPLEADO (3)
 FROM DUAL;

/*
 * FUNCI�N QUE CALCULA LA RETRIBUCI�N DEL MONTO NETO DEL EMPLEADO.
 */ 
 CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_CALCULA_REDU_RETRIBUCION_EMPLEADO (P_EMPLEADO_ID IN NUMBER)
 RETURN NUMBER
 IS
 v_MONTO_PORCENTAJE NUMBER;
 v_MONTO_NETO NUMBER;
 BEGIN
    IF G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID) < 0 THEN
        SELECT RETRIBUCION_MONTO_PORCENTUAL
             INTO v_MONTO_PORCENTAJE
                FROM G4_PROYECTO_USUARIO_3.REDUCCION
                    WHERE REDUCCION.CALIFICACION = G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID);
        
        IF v_MONTO_PORCENTAJE = NULL OR v_MONTO_PORCENTAJE = 0 THEN
            
                SELECT REDU_RETRIBUCION_MONTO_NETO
                    INTO v_MONTO_NETO
                        FROM G4_PROYECTO_USUARIO_3.REDUCCION
                            WHERE REDUCCION.CALIFICACION = G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID);
                            
                RETURN v_MONTO_NETO;
         END IF;
         
         v_MONTO_PORCENTAJE := v_MONTO_PORCENTAJE * G4_PROYECTO_USUARIO_4.FN_OBTENER_MONTO_NETO (P_EMPLEADO_ID);
         
                  RETURN v_MONTO_PORCENTAJE;    
     END IF;
  
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_CALCULA_REDU_RETRIBUCION_EMPLEADO(1) 
FROM DUAL;

/*
 * FUNCI�N QUE CALCULA EL MONTO NETO A PAGARLE AL EMPLEADO.
 */
/*
 * FUNCI�N QUE CALCULA EL MONTO NETO A PAGARLE AL EMPLEADO.
 */
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_CALCULAR_SALARIO_NETO (P_EMPLEADO_ID IN NUMBER)
RETURN NUMBER 
IS 
v_OTROS NUMBER;
v_DESPIDO NUMBER;
BEGIN
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
    
    IF  G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID) = 0 OR  G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID) = NULL THEN
      v_OTROS  :=  G4_PROYECTO_USUARIO_4.FN_OBTIENE_SALARIO_MINIMO (P_EMPLEADO_ID);
    END IF;
    
RETURN v_OTROS;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_CALCULAR_SALARIO_NETO(1) 
FROM DUAL; 
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_CALCULAR_SALARIO_NETO(1) 
FROM DUAL; 

/*
 * FUNCI�N QUE OBTIENE EL ID DE LA TABLA REDUCCIONES CON EL QUE SE TRABAJA DURANTE EL PROCESO DE OBTENER EL SALARIO DEL EMPLEADO.
 */
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_OBTIENE_ID_REDUCCION (P_EMPLEADO_ID IN NUMBER)
RETURN NUMBER 
IS
v_REDU_ID NUMBER;
BEGIN

    IF G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID) < 0 THEN
        SELECT REDU_ID
            INTO v_REDU_ID
                FROM G4_PROYECTO_USUARIO_3.REDUCCION
                    WHERE REDUCCION.CALIFICACION = G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID);
        END IF;
    
RETURN v_REDU_ID;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_OBTIENE_ID_REDUCCION (1)
FROM DUAL; 

/*
 * FUNCI�N QUE OBTIENE EL ID DE LA TABLA BONIFICACIONES CON EL QUE SE TRABAJA DURANTE EL PROCESO DE OBTENER EL SALARIO DEL EMPLEADO.
 */
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_OBTIENE_ID_BONIFICACION (P_EMPLEADO_ID IN NUMBER)
RETURN NUMBER 
IS
v_BONI_ID NUMBER;
BEGIN
     IF G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID) > 0 THEN
        SELECT BONI_ID
            INTO v_BONI_ID
                FROM  G4_PROYECTO_USUARIO_3.BONIFICACION
                    WHERE BONIFICACION.BONI_RCALIFICACION = G4_PROYECTO_USUARIO_4.FN_OBTENER_CALIFICACION (P_EMPLEADO_ID);
    END IF;
    
RETURN v_BONI_ID;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_OBTIENE_ID_BONIFICACION(1)
FROM DUAL;  

/**************************************************** CREACI�N DE LA FACTURA ****************************************************/

/*
 * FUNCI�N QUE OBTINE EL ID M�XIMO DE LA TABLA FACTURAS.
 */
CREATE OR REPLACE FUNCTION  G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_FACTURA 
RETURN NUMBER 
IS 
v_CONSECUTIVO_MAXIMO NUMBER;
BEGIN 
    SELECT MAX (FACT_ID)
        INTO v_CONSECUTIVO_MAXIMO
            FROM  G4_PROYECTO_USUARIO_1.FACTURA;
            
RETURN v_CONSECUTIVO_MAXIMO;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_FACTURA
 FROM DUAL;
 
 /*
 * PROCEDIMIENTO QUE GENERA EL DETALLE DE FACTURA.
 */
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.SP_GENERAR_DETALLE_FACTURA (PID_DETALLE_FACTURA IN NUMBER,
                                                                                                                                                                  PID_FACTURA IN NUMBER,
                                                                                                                                                                  PID_MENU IN NUMBER,
                                                                                                                                                                  PCANTIDAD IN NUMBER
                                                                                                                                                                  )
IS 
v_CONSECUTIVO_DETALLE_FACRURA NUMBER;
BEGIN 
    INSERT INTO G4_PROYECTO_USUARIO_1.detalle_factura (DETA_ID, DETA_FACTURA_ID, DETA_MENU_ID, DETA_CANTIDAD, DETA_PRECIO, DETA_TOTAL)
                                                                              VALUES (PID_DETALLE_FACTURA, PID_FACTURA,PID_MENU,  PCANTIDAD,  G4_PROYECTO_USUARIO_4.FN_GET_PRECIO_PLATILLO (PID_MENU), 
                                                                                             G4_PROYECTO_USUARIO_4.FN_MONTO_TOTAL_DETALLE (PCANTIDAD, PID_MENU) );
     COMMIT;
     
    v_CONSECUTIVO_DETALLE_FACRURA := G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_DETALLE_FACTURA;  
END;
--> PRUEBA DEL PROCEDIMIENTO.
EXECUTE G4_PROYECTO_USUARIO_4.SP_GENERAR_DETALLE_FACTURA (2, 2, 2, 3);
SELECT * FROM g4_proyecto_usuario_1.DETALLE_FACTURA;
 /*
 * FUNCI�N QUE OBTINE EL ID M�XIMO DE LA TABLA DETALLE_FACTURAS.
 */
CREATE OR REPLACE FUNCTION  G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_DETALLE_FACTURA 
RETURN NUMBER 
IS 
v_CONSECUTIVO_MAXIMO NUMBER;
BEGIN 
    SELECT MAX (DETA_ID)
        INTO v_CONSECUTIVO_MAXIMO
            FROM  G4_PROYECTO_USUARIO_1.DETALLE_FACTURA;
            
RETURN v_CONSECUTIVO_MAXIMO;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_DETALLE_FACTURA
 FROM DUAL;

/*
 * FUNCI�N QUE ME RETORNA EL PRECIO DE DEL PLATILLO.
 */
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_GET_PRECIO_PLATILLO (PID_MENU IN NUMBER)
RETURN NUMBER
IS 
V_PRECIO NUMBER;
BEGIN
    SELECT MENU_PRECIO
        INTO V_PRECIO
            FROM G4_PROYECTO_USUARIO_2.MENU
                WHERE MENU_ID = PID_MENU;
    RETURN V_PRECIO;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_GET_PRECIO_PLATILLO(2)
 FROM DUAL;

/*
 * FUNCI�N CALCULA EL MONTO TOTAL DEL DETALLE FACTURA.
 */
 CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_MONTO_TOTAL_DETALLE (PCANTIDAD IN NUMBER, PMENU_ID IN NUMBER)
RETURN NUMBER
IS 
v_MONTO_TOTAL NUMBER;
BEGIN 
    v_MONTO_TOTAL := PCANTIDAD * G4_PROYECTO_USUARIO_4.FN_GET_PRECIO_PLATILLO (PMENU_ID);
    
RETURN v_MONTO_TOTAL;

END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_MONTO_TOTAL_DETALLE (3, 2)
 FROM DUAL;

/*
 * FUNCI�N QUE CALCULA EL SUBTOTAL DE LA FACTURA.
 */
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_CALCULAR_SUBTOTAL 
RETURN NUMBER
IS
v_SUBTOTAL NUMBER;
BEGIN 
   
   SELECT SUM (DETA_TOTAL)
        INTO v_SUBTOTAL
            FROM G4_PROYECTO_USUARIO_1.DETALLE_FACTURA
                WHERE DETA_ID = G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_DETALLE_FACTURA;
                                
RETURN v_SUBTOTAL;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_CALCULAR_SUBTOTAL
 FROM DUAL;

/*
 * FUNCI�N QUE CALCULA EL MONTO TOTAL DE LA FACTURA.
 */
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_TOTAL_FACTURA (p_DESCUENTO IN NUMBER, 
                                                                                                                                                  p_IVA IN NUMBER)
RETURN NUMBER
IS 
v_TOTAL NUMBER;
v_IVA_CALC NUMBER;
BEGIN 

    v_IVA_CALC := (G4_PROYECTO_USUARIO_4.FN_CALCULAR_SUBTOTAL * p_IVA);
    v_TOTAL :=  G4_PROYECTO_USUARIO_4.FN_CALCULAR_SUBTOTAL + v_IVA_CALC - p_DESCUENTO;
    
RETURN v_TOTAL;
END;
--> PRUEBA DE LA FUNCI�N.
SELECT G4_PROYECTO_USUARIO_4.FN_TOTAL_FACTURA (0, 0.13)
 FROM DUAL;

 /*
 * PROCEDIMIENTO QUE MODIFICA EL SUBTOTAL DE LA FACTURA.
 */
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.SP_MODIFICA_SUBTOTAL_FACUTURA 
IS 
v_MAX_ID NUMBER;
BEGIN
SELECT MAX (FACT_ID) INTO v_MAX_ID FROM  G4_PROYECTO_USUARIO_1.FACTURA;

    UPDATE G4_PROYECTO_USUARIO_1.FACTURA
        SET FACT_SUBTOTAL = G4_PROYECTO_USUARIO_4.FN_CALCULAR_SUBTOTAL
            WHERE FACT_ID = v_MAX_ID;
    COMMIT;
END;
--> PRUEBA DEL PROCEDIMIENTO.
EXECUTE G4_PROYECTO_USUARIO_4.SP_MODIFICA_SUBTOTAL_FACUTURA;
SELECT * FROM G4_PROYECTO_USUARIO_1.FACTURA;
 /*
 * PROCEDIMIENTO QUE MODIFICA EL TOTAL DE LA FACTURA.
 */
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.SP_MODIFICA_TOTAL_FACUTURA (p_DESCUENTO IN NUMBER, 
                                                                                                                                                                            p_IVA IN NUMBER)
IS 
v_MAX_ID NUMBER;
BEGIN
SELECT MAX (FACT_ID) INTO v_MAX_ID FROM  G4_PROYECTO_USUARIO_1.FACTURA;

    UPDATE G4_PROYECTO_USUARIO_1.FACTURA
        SET FACT_TOTAL = G4_PROYECTO_USUARIO_4.FN_TOTAL_FACTURA (p_DESCUENTO, p_IVA)
            WHERE FACT_ID = v_MAX_ID;
     COMMIT;       
END;
--> PRUEBA DEL PROCEDIMIENTO.
EXECUTE G4_PROYECTO_USUARIO_4.SP_MODIFICA_TOTAL_FACUTURA (0, 0.13);

 /*
 * PROCEDIMIENTO QUE MODIFICA EL CAMPO ORDE ATENDIDA DE LA TABLA ORDENES MEDIANTE UN CURSOR.
 */
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.MODIFICAR_ORDEN_ATENDIDA_CURSOR (P_EMPLEADO_ID IN NUMBER)
IS
CURSOR CUR_ATENDIDO
IS 
SELECT ORDE_ATENDIDO 
    FROM G4_PROYECTO_USUARIO_3.ORDENES;
BEGIN

    FOR v_REG IN CUR_ATENDIDO LOOP
           G4_PROYECTO_USUARIO_4.SP_MODIFICAR_ORDE_ATENDIDO (P_EMPLEADO_ID);
    END LOOP;
END;
EXECUTE G4_PROYECTO_USUARIO_4.MODIFICAR_ORDEN_ATENDIDA_CURSOR (3);
SELECT * FROM G4_PROYECTO_USUARIO_3.ORDENES;
 /*
 * PROCEDIMIENTO QUE MODIFICA EL CAMPO ORDE ATENDIDA DE LA TABLA ORDENES.
 */
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.SP_MODIFICAR_ORDE_ATENDIDO (P_EMPLEADO_ID IN NUMBER)
IS
v_ID_ORDENES NUMBER;
BEGIN 

    UPDATE G4_PROYECTO_USUARIO_3.ORDENES
        SET ORDENES.ORDE_ATENDIDO = 1
            WHERE ORDE_EMPLEADO_ID = P_EMPLEADO_ID;
    COMMIT;
END;
EXECUTE G4_PROYECTO_USUARIO_4.SP_MODIFICAR_ORDE_ATENDIDO (1);
 
/*
 * PROCEDIMIENTO QUE CREA LA FACTURA 
 */
  
 
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.SP_GENERAR_FACTURA(PID_FACTURA IN NUMBER,
                                                                                                                                                         PID_EMPLEADO IN NUMBER,
                                                                                                                                                         PID_CLIENTE IN NUMBER,
                                                                                                                                                         PDESCUENTO IN NUMBER,
                                                                                                                                                         PIVA IN NUMBER,
                                                                                                                                                         PID_ORDENES IN NUMBEr,
                                                                                                                                                         PID_DETALLE_FACTURA IN NUMBER,
                                                                                                                                                         PID_MENU IN NUMBER,
                                                                                                                                                         PCANTIDAD IN NUMBER,
                                                                                                                                                         P_SALARIO_ID IN NUMBER)
IS 
v_CONSECUTIVO_FACRURA NUMBER;
BEGIN
    INSERT INTO G4_PROYECTO_USUARIO_1.FACTURA (FACT_ID, FACT_FECHA, FACT_EMPLEADO_ID, FACT_CLIENTE_ID, FACT_DESCUENTO, FACT_IVA, FACT_ORDENES_ID)
                                                                          VALUES (PID_FACTURA, SYSDATE, PID_EMPLEADO, PID_CLIENTE, PDESCUENTO, PIVA, PID_ORDENES);
     COMMIT;
     
v_CONSECUTIVO_FACRURA := G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_FACTURA;                                                                      
   
 G4_PROYECTO_USUARIO_4.SP_GENERAR_DETALLE_FACTURA (PID_DETALLE_FACTURA, PID_FACTURA, PID_MENU,PCANTIDAD);
 G4_PROYECTO_USUARIO_4.SP_MODIFICA_SUBTOTAL_FACUTURA;
 G4_PROYECTO_USUARIO_4.SP_MODIFICA_TOTAL_FACUTURA (PDESCUENTO, PIVA);
  G4_PROYECTO_USUARIO_4.MODIFICAR_ORDEN_ATENDIDA_CURSOR (PID_EMPLEADO);
  G4_PROYECTO_USUARIO_4.SP_PAGAR_SALARIO (P_SALARIO_ID, PID_EMPLEADO);
END;

/* EJECUCI�N DE LOS CASOS DE PRUEBA Y LOS PROCEDIMIETOS*/

DELETE g4_proyecto_usuario_1.DETALLE_FACTURA;
DELETE g4_proyecto_usuario_1.FACTURA;
DELETE g4_proyecto_usuario_3.ORDENES;
DELETE g4_proyecto_usuario_1.SALARIO;
DELETE g4_proyecto_usuario_2.EMPLEADO;
COMMIT;

SELECT * FROM g4_proyecto_usuario_1.FACTURA;
SELECT * FROM g4_proyecto_usuario_2.EMPLEADO;
SELECT * FROM g4_proyecto_usuario_2.MENU;
SELECT * FROM g4_proyecto_usuario_3.ORDENES;
SELECT * FROM g4_proyecto_usuario_3.BONIFICACION;
SELECT * FROM g4_proyecto_usuario_3.REDUCCION;

EXECUTE G4_PROYECTO_USUARIO_4.SP_GENERAR_FACTURA(1, 1, 1, 0, 0.13, 1, 1, 1, 10, 1);  
EXECUTE G4_PROYECTO_USUARIO_4.SP_GENERAR_FACTURA(2, 2, 2, 0, 0.13, 4, 2, 3, 10, 2);  
EXECUTE G4_PROYECTO_USUARIO_4.SP_GENERAR_FACTURA(3, 3, 2, 0, 0.13, 7, 3, 1, 1, 3);
EXECUTE  G4_PROYECTO_USUARIO_4.SP_PAGAR_SALARIO (4, 4);

SELECT * FROM g4_proyecto_usuario_1.FACTURA;
SELECT * FROM g4_proyecto_usuario_1.DETALLE_FACTURA;
SELECT * FROM g4_proyecto_usuario_1.SALARIO;
SELECT * FROM g4_proyecto_usuario_3.ORDENES;
SELECT * FROM g4_proyecto_usuario_2.EMPLEADO;

/*
    
*/
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 