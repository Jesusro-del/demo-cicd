# OWASP ZAP (Reto 1 del LAB-04)

`deploy-dev` corre un *baseline scan* de ZAP contra DEV. Esta carpeta se monta en el contenedor de ZAP:
- `reglas.conf`: qué hace ZAP con cada alerta (FAIL, WARN o IGNORE) y por qué. Lo que no está aquí queda en WARN y pone el job en rojo.
- El informe (`informe.html`, `informe.json`) se genera en cada run y se sube como artefacto; no se versiona.
