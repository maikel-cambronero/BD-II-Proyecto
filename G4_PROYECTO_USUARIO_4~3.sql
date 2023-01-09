--> SP QUE CREA LA FACTURA 
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.SP_GENERAR_FACTURA(PID_FACTURA IN NUMBER,
                                                                                                                                                         PID_EMPLEADO IN NUMBER,
                                                                                                                                                         PID_CLIENTE IN NUMBER,
                                                                                                                                                         PDESCUENTO IN NUMBER,
                                                                                                                                                         PIVA IN NUMBER,
                                                                                                                                                         PID_ORDENES IN NUMBER,
                                                                                                                                                         PID_DETALLE_FACTURA IN NUMBER,
                                                                                                                                                         PID_MENU IN NUMBER,
                                                                                                                                                         PCANTIDAD IN NUMBER)
IS 
v_CONSECUTIVO_FACRURA NUMBER;
BEGIN
    INSERT INTO G4_PROYECTO_USUARIO_1.FACTURA (FACT_ID, FACT_FECHA, FACT_EMPLEADO_ID, FACT_CLIENTE_ID, FACT_DESCUENTO, FACT_IVA, FACT_ORDENES_ID)
                                                                          VALUES (PID_FACTURA, SYSDATE, PID_EMPLEADO, PID_CLIENTE, PDESCUENTO, PIVA, PID_ORDENES);
     COMMIT;
     
v_CONSECUTIVO_FACRURA := G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_FACTURA ;                                                                      
    
 G4_PROYECTO_USUARIO_4.SP_GENERAR_DETALLE_FACTURA (PID_DETALLE_FACTURA, PID_FACTURA, PID_MENU,PCANTIDAD);
 G4_PROYECTO_USUARIO_4.SP_MODIFICA_SUBTOTAL_FACUTURA;
 G4_PROYECTO_USUARIO_4.SP_MODIFICA_TOTAL_FACUTURA (PDESCUENTO, PIVA);
END;
--> PRUEBA
EXECUTE G4_PROYECTO_USUARIO_4.SP_GENERAR_FACTURA(6, 3, 2, 0, 0.13, 1)

--> FN QUE OBTINE EL ID MÁXIMO DE LA TABLA FACTURAS.
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
--> PRUEBA
SELECT G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_FACTURA
 FROM DUAL;
 
 --> SP QUE GENERA EL DETALLE DE FACTURA.
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
--> PRUEBA
EXECUTE G4_PROYECTO_USUARIO_4.SP_GENERAR_DETALLE_FACTURA (3, 1, 3, 2);

--> FN QUE OBTINE EL ID MÁXIMO DE LA TABLA DETALLE_FACTURAS.
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
--> PRUEBA
SELECT G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_DETALLE_FACTURA
 FROM DUAL;
 
--> FN QUE ME RETORNA EL PRECIO DE DEL PLATILLO.
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
--> PRUEBA 
SELECT G4_PROYECTO_USUARIO_4.FN_GET_PRECIO_PLATILLO(4)
 FROM DUAL;
 
 --> FN CALCULA EL MONTO TOTAL DEL DETALLE FACTURA.
 CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_MONTO_TOTAL_DETALLE (PCANTIDAD IN NUMBER, PMENU_ID IN NUMBER)
RETURN NUMBER
IS 
v_MONTO_TOTAL NUMBER;
BEGIN 
    v_MONTO_TOTAL := PCANTIDAD * G4_PROYECTO_USUARIO_4.FN_GET_PRECIO_PLATILLO (PMENU_ID);
    
RETURN v_MONTO_TOTAL;

END;
--> PRUEBA 
SELECT G4_PROYECTO_USUARIO_4.FN_MONTO_TOTAL_DETALLE (3, 1)
 FROM DUAL;
 
 --> FN QUE CALCULA EL SUBTOTAL DE LA FACTURA.
CREATE OR REPLACE FUNCTION G4_PROYECTO_USUARIO_4.FN_CALCULAR_SUBTOTAL 
RETURN NUMBER
IS
v_SUBTOTAL NUMBER;
BEGIN 
   
   SELECT SUM (DETA_TOTAL)
        INTO v_SUBTOTAL
            FROM G4_PROYECTO_USUARIO_1.DETALLE_FACTURA
                WHERE DETA_FACTURA_ID = G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_FACTURA ;
                                
RETURN v_SUBTOTAL;
END;
--> PRUEBA
SELECT G4_PROYECTO_USUARIO_4.FN_CALCULAR_SUBTOTAL
 FROM DUAL;
 
 --> FN QUE CALCULA EL MONTO TOTAL DE LA FACTURA.
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
--> PRUEBA
SELECT G4_PROYECTO_USUARIO_4.FN_TOTAL_FACTURA (0, 0.13)
 FROM DUAL;
 
 --> MODIFICA EL SUBTOTAL DE LA FACTURA.
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.SP_MODIFICA_SUBTOTAL_FACUTURA 
IS 
BEGIN
    UPDATE G4_PROYECTO_USUARIO_1.FACTURA
        SET FACT_SUBTOTAL = G4_PROYECTO_USUARIO_4.FN_CALCULAR_SUBTOTAL
            WHERE FACT_ID = G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_FACTURA;
END;
EXECUTE G4_PROYECTO_USUARIO_4.SP_MODIFICA_SUBTOTAL_FACUTURA;

--> MODIFICA EL TOTAL DE LA FACTURA.
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.SP_MODIFICA_TOTAL_FACUTURA (p_DESCUENTO IN NUMBER, 
                                                                                                                                                                            p_IVA IN NUMBER)
IS 
BEGIN
    UPDATE G4_PROYECTO_USUARIO_1.FACTURA
        SET FACT_TOTAL = G4_PROYECTO_USUARIO_4.FN_TOTAL_FACTURA (p_DESCUENTO, p_IVA)
            WHERE FACT_ID = G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_FACTURA;
END;
EXECUTE G4_PROYECTO_USUARIO_4.SP_MODIFICA_TOTAL_FACUTURA (0, 0.13)

--> SP QUE MODIFICA EL CAMPO DE ATENDIDO EN LA TABLA ORDENES.
CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.MODIFICAR_ORDEN_ATENDIDA
IS
CURSOR CUR_ATENDIDO;
v_ID_ORDENES NUMBER;
BEGIN

    SELECT  FACT_ORDENES_ID
        INTO v_ID_ORDENES
            FROM G4_PROYECTO_USUARIO_1.FACTURA
                WHERE FACT_ID = G4_PROYECTO_USUARIO_4.FN_CONSECUTIVO_FACTURA;
                
     FOR ORDENES IN CUR_ATENDIDO LOOP
        UPDATE G4_PORYECTO_USUARIO_3.ORDENES
            SET ORDE_ATENDIDO = 1
                WHERE ORDE_ID = v_ID_ORDENES;
     END LOOP;
--> NOTA
--> EN EL CAMPO DE ATENDIDO EN LA TABLA ORDENES
--> 1 = ATENDIDO.
--> 0 = NO ATENDIDO.
--> NOTA;
END;










