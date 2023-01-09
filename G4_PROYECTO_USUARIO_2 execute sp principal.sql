DECLARE
  P_USUARIO_EJECUTA VARCHAR2(200);
BEGIN
  P_USUARIO_EJECUTA := 'Jason';

  G4_PROYECTO_USUARIO_4.SP_PRINCIPAL_PRINCIPAL(
    P_USUARIO_EJECUTA => P_USUARIO_EJECUTA
  );
END;





































create or replace PROCEDURE                       FACTURA (P_RAMDOM IN NUMBER, P_USUARIO_EJECUTA IN VARCHAR2)
IS
CURSOR CUR_ATENDIDO
IS 
SELECT  ORDE_ID, 
               ORDE_EMPLEADO_ID, 
               ORDE_CLIENTES_ID, 
               ORDE_MENU_ID, 
               ORDE_CANTIDAD
FROM G4_PROYECTO_USUARIO_3.ORDENES
WHERE ORDE_ATENDIDO = 0;

BEGIN 

    FOR principal IN CUR_ATENDIDO LOOP
         G4_PROYECTO_USUARIO_4.SP_CREAR_FACTURA(principal.ORDE_EMPLEADO_ID,
                                                                                          principal.ORDE_CLIENTES_ID,
                                                                                          principal.ORDE_ID);

          G4_PROYECTO_USUARIO_4.SP_CREAR_DETALLE_FACTURA (G4_PROYECTO_USUARIO_4.FN_ID_FACTURA , principal.ORDE_MENU_ID,  principal.ORDE_CANTIDAD);

          G4_PROYECTO_USUARIO_4.SP_UPDATE_SUBTOTAL_FACUTURA (G4_PROYECTO_USUARIO_4.FN_ID_FACTURA);
          G4_PROYECTO_USUARIO_4.SP_UPDATE_TOTAL_FACUTURA (G4_PROYECTO_USUARIO_4.FN_ID_FACTURA);
          G4_PROYECTO_USUARIO_4.SP_UPDATE_ORDEN_ATENDIDA (principal.ORDE_ID); 

           UPDATE G4_PROYECTO_USUARIO_3.ORDENES
                SET NUMERO_RANDOM = P_RAMDOM, USUARIO_ATENDIO = P_USUARIO_EJECUTA
                WHERE ORDE_ID = principal.ORDE_ID;
            COMMIT;

    END LOOP;
END;











































