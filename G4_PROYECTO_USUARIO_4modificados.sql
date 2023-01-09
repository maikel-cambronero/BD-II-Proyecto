CREATE OR REPLACE PROCEDURE G4_PROYECTO_USUARIO_4.PRINCIPAL
IS
CURSOR CUR_ATENDIDO
IS 
SELECT  ORDE_ID, 
               ORDE_EMPLEADO_ID, 
               ORDE_CLIENTES_ID, 
               ORDE_MENU_ID, 
               ORDE_CANTIDAD
FROM G4_PROYECTO_USUARIO_3.ORDENES
where ORDE_ATENDIDO = 0;
        
BEGIN

    FOR v_REG IN CUR_ATENDIDO LOOP
    
        G4_PROYECTO_USUARIO_4.SP_GENERAR_FACTURA(,
                                                                                             v_REG.ORDE_EMPLEADO_ID,
                                                                                             v_REG.ORDE_CLIENTES_ID,
                                                                                             v_REG.ORDE_ID,
                                                                                             ,
                                                                                             v_REG.ORDE_MENU_ID,
                                                                                             v_REG.ORDE_CANTIDAD);
                                                                                             
         G4_PROYECTO_USUARIO_4.SP_MODIFICAR_ORDE_ATENDIDO (v_REG.ORDE_ID);
         
         G4_PROYECTO_USUARIO_4.SP_PAGAR_SALARIO (G4_PROYECTO_USUARIO_4.FN_CONTADOR_ID_SALARIO,
                                                                                          v_REG.ORDE_EMPLEADO_ID);
           
    END LOOP;
END;


EXECUTE G4_PROYECTO_USUARIO_4.PRINCIPAL;

DELETE G4_PROYECTO_USUARIO_1.DETALLE_FACTURA;
DELETE G4_PROYECTO_USUARIO_1.FACTURA;
DELETE G4_PROYECTO_USUARIO_1.SALARIO;
DELETE G4_PROYECTO_USUARIO_3.ORDENES;
DELETE G4_PROYECTO_USUARIO_2.EMPLEADO;
COMMIT;

SELECT * FROM G4_PROYECTO_USUARIO_1.FACTURA;
SELECT * FROM G4_PROYECTO_USUARIO_1.DETALLE_FACTURA;
SELECT * FROM G4_PROYECTO_USUARIO_1.SALARIO;
SELECT * FROM G4_PROYECTO_USUARIO_3.ORDENES;
SELECT * FROM G4_PROYECTO_USUARIO_2.EMPLEADO;


/*INSERTAR DATOS EN LA TABLA EMPLEADO*/
--> LISTO
INSERT INTO G4_PROYECTO_USUARIO_2.EMPLEADO (EMPL_ID,EMPL_NOMBRE,EMPL_CEDULA,EMPL_TELEFONO,EMPL_DIRECCION,EMPL_EMAIL,EMPL_CARGO_ID)
                                                                         VALUES(1, 'Mario Picado','208270951','88767995','Santa Gertrudis Sur','mariopicado@gmail.com',1);
INSERT INTO G4_PROYECTO_USUARIO_2.EMPLEADO (EMPL_ID,EMPL_NOMBRE,EMPL_CEDULA,EMPL_TELEFONO,EMPL_DIRECCION,EMPL_EMAIL,EMPL_CARGO_ID)
                                                                         VALUES(2, 'Eduardo Rivera','207450932','85077455','Carrillos','Edu2502@gmail.com',2);
INSERT INTO G4_PROYECTO_USUARIO_2.EMPLEADO (EMPL_ID,EMPL_NOMBRE,EMPL_CEDULA,EMPL_TELEFONO,EMPL_DIRECCION,EMPL_EMAIL,EMPL_CARGO_ID)
                                                                         VALUES(3, 'Ayleen Carranza','208320740','86483056','Grecia Centro','ayleen25@gmail.com',3);
INSERT INTO G4_PROYECTO_USUARIO_2.EMPLEADO (EMPL_ID,EMPL_NOMBRE,EMPL_CEDULA,EMPL_TELEFONO,EMPL_DIRECCION,EMPL_EMAIL,EMPL_CARGO_ID)
                                                                         VALUES(4, 'Mariano Rodriguez','208320741','86483056','Grecia Puente Piedra','mariano19@gmail.com',1);                                                                         
COMMIT;  

/*INSERTAR DATOS EN LA TABLA ORDENES*/
--> LISTO
INSERT INTO G4_PROYECTO_USUARIO_3.ORDENES(ORDE_ID, ORDE_EMPLEADO_ID, ORDE_CLIENTES_ID, ORDE_MENU_ID, ORDE_CANTIDAD, ORDE_CALIFICACION,ORDE_ATENDIDO)
                                                                       VALUES (1, 1, 1, 1, 10, -5, 0);
INSERT INTO G4_PROYECTO_USUARIO_3.ORDENES(ORDE_ID, ORDE_EMPLEADO_ID, ORDE_CLIENTES_ID, ORDE_MENU_ID, ORDE_CANTIDAD, ORDE_CALIFICACION,ORDE_ATENDIDO)
                                                                       VALUES (2, 1, 2, 2, 3, -3, 0);
INSERT INTO G4_PROYECTO_USUARIO_3.ORDENES(ORDE_ID, ORDE_EMPLEADO_ID, ORDE_CLIENTES_ID, ORDE_MENU_ID, ORDE_CANTIDAD, ORDE_CALIFICACION,ORDE_ATENDIDO)
                                                                       VALUES (3, 1, 3, 3, 5, -2, 0);    
INSERT INTO G4_PROYECTO_USUARIO_3.ORDENES(ORDE_ID, ORDE_EMPLEADO_ID, ORDE_CLIENTES_ID, ORDE_MENU_ID, ORDE_CANTIDAD, ORDE_CALIFICACION,ORDE_ATENDIDO)
                                                                       VALUES (4, 2, 3, 3, 10, 2, 0);                                                                          
INSERT INTO G4_PROYECTO_USUARIO_3.ORDENES(ORDE_ID, ORDE_EMPLEADO_ID, ORDE_CLIENTES_ID, ORDE_MENU_ID, ORDE_CANTIDAD, ORDE_CALIFICACION,ORDE_ATENDIDO)
                                                                       VALUES (5, 2, 1, 2, 10, 2, 0);                                                                        
INSERT INTO G4_PROYECTO_USUARIO_3.ORDENES(ORDE_ID, ORDE_EMPLEADO_ID, ORDE_CLIENTES_ID, ORDE_MENU_ID, ORDE_CANTIDAD, ORDE_CALIFICACION,ORDE_ATENDIDO)
                                                                       VALUES (6, 2, 2, 1, 20, 2, 0);                                                                             
INSERT INTO G4_PROYECTO_USUARIO_3.ORDENES(ORDE_ID, ORDE_EMPLEADO_ID, ORDE_CLIENTES_ID, ORDE_MENU_ID, ORDE_CANTIDAD, ORDE_CALIFICACION,ORDE_ATENDIDO)
                                                                       VALUES (7, 3, 2, 1, 1, -2, 0);                                                                          
INSERT INTO G4_PROYECTO_USUARIO_3.ORDENES(ORDE_ID, ORDE_EMPLEADO_ID, ORDE_CLIENTES_ID, ORDE_MENU_ID, ORDE_CANTIDAD, ORDE_CALIFICACION,ORDE_ATENDIDO)
                                                                       VALUES (8, 3, 3, 1, 1, -1, 0);                                                                     
COMMIT; 

create or replace FUNCTION G4_PROYECTO_USUARIO_4.FN_CONTADOR_ID_FACTURA 
RETURN NUMBER
IS
v_ID_MAX NUMBER;
BEGIN
    SELECT NVL( MAX (FACT_ID) +1 , 1 )
        INTO v_ID_MAX
            FROM G4_PROYECTO_USUARIO_1.FACTURA;
RETURN v_ID_MAX;  

EXCEPTION WHEN OTHERS THEN --> CATCH

    RETURN 1;
    
END;

create or replace FUNCTION G4_PROYECTO_USUARIO_4.FN_CONTADOR_ID_DETALLE_FACTURA 
RETURN NUMBER
IS
v_ID_MAX NUMBER;
BEGIN
    SELECT NVL( MAX (DETA_ID) +1 , 1 )
        INTO v_ID_MAX
            FROM G4_PROYECTO_USUARIO_1.DETALLE_FACTURA;
RETURN v_ID_MAX; 

EXCEPTION WHEN OTHERS THEN --> CATCH

    RETURN 1;
    
END;

create or replace FUNCTION G4_PROYECTO_USUARIO_4.FN_CONTADOR_ID_SALARIO 
RETURN NUMBER
IS
v_ID_MAX NUMBER;
BEGIN
    SELECT NVL( MAX (SALA_ID) +1 , 1 )
        INTO v_ID_MAX
            FROM G4_PROYECTO_USUARIO_1.SALARIO;
RETURN v_ID_MAX;  

EXCEPTION WHEN OTHERS THEN --> CATCH

    RETURN 1;
    
END;











