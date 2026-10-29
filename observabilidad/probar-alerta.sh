#!/usr/bin/env bash
# Prueba de la alerta TasaDeErrores5xxAlta del Reto 3, contra STAGING (http://localhost:30080).
# Uso, en Git Bash: bash observabilidad/probar-alerta.sh
#
# 1. Genera tráfico de lectura contra la API (~5 peticiones por segundo).
# 2. A los 30 s renombra la tabla mensajes: /api/mensajes y /api/estadisticas responden 500,
#    y /api/health (SELECT 1) sigue sano, así que Kubernetes no reinicia nada y Argo CD no revierte nada.
# 3. Muestra cada 10 s el estado de la alerta en Prometheus: inactive -> pending -> firing.
# 4. Devuelve la tabla a su nombre y espera a que la alerta se resuelva.
# Los datos no se tocan. Si el script se corta (error o Ctrl+C), la tabla se restaura igual (trap EXIT).
set -euo pipefail

APP="${1:-http://localhost:30080}"
CARGA_SEGUNDOS=330

restaurar() {
  kubectl -n demo-staging exec deploy/db -- psql -U app -d libro -q \
    -c 'ALTER TABLE IF EXISTS mensajes_pausa RENAME TO mensajes;' >/dev/null 2>&1 || true
  kill "${PF:-}" "${CARGA:-}" 2>/dev/null || true
}
trap restaurar EXIT

kubectl -n observabilidad port-forward svc/prometheus 9090:9090 >/dev/null 2>&1 & PF=$!
sleep 3

estado() {
  curl -s http://localhost:9090/api/v1/rules | node -e '
    let s = ""; process.stdin.on("data", d => s += d).on("end", () => {
      const r = JSON.parse(s).data.groups.flatMap(g => g.rules).find(r => r.name === "TasaDeErrores5xxAlta");
      const a = (r.alerts || [])[0];
      console.log(r.state + (a ? `  (activa desde ${a.activeAt.slice(11, 19)}, ${(Number(a.value) * 100).toFixed(1)} % de 5xx)` : ""));
    });'
}
hora() { date -u +%H:%M:%S; }

( fin=$(( $(date +%s) + CARGA_SEGUNDOS ))
  while [ "$(date +%s)" -lt "$fin" ]; do
    curl -s -o /dev/null -m 3 "$APP/api/mensajes"
    curl -s -o /dev/null -m 3 "$APP/api/estadisticas"
    sleep 0.3
  done ) & CARGA=$!

echo "$(hora) tráfico normal durante 30 s"
sleep 30
echo "$(hora) antes del fallo: $(estado)"

kubectl -n demo-staging exec deploy/db -- psql -U app -d libro -q -c 'ALTER TABLE mensajes RENAME TO mensajes_pausa;'
echo "$(hora) tabla renombrada: la API empieza a responder 500 en $APP/api/mensajes ($(curl -s -o /dev/null -w '%{http_code}' "$APP/api/mensajes"))"

for _ in $(seq 1 14); do sleep 10; echo "$(hora) $(estado)"; done

kubectl -n demo-staging exec deploy/db -- psql -U app -d libro -q -c 'ALTER TABLE mensajes_pausa RENAME TO mensajes;'
echo "$(hora) tabla restaurada ($(curl -s -o /dev/null -w '%{http_code}' "$APP/api/mensajes"))"

for _ in $(seq 1 9); do sleep 10; echo "$(hora) $(estado)"; done
echo "$(hora) fin. Total de mensajes: $(curl -s "$APP/api/estadisticas")"
