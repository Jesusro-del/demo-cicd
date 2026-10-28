# Progreso del LAB-04

Fecha límite: 30/10/2026 23:59. Repositorio: https://github.com/Jesusro-del/demo-cicd

## Estado por ítem

| Ítem | Estado | PR | Run |
|------|--------|----|-----|
| B1 Pipeline de la guía | ✅ Hecho (falta solo tu captura) | #1–#8, #13, #17, #18 | [main ✅ STAGING](https://github.com/Jesusro-del/demo-cicd/actions/runs/40559516916) · [Dependabot ✅ STAGING](https://github.com/Jesusro-del/demo-cicd/actions/runs/40702839413) |
| B2 Dos herramientas cambiadas | ✅ Grype y TruffleHog (bitácora en el README) | [#26](https://github.com/Jesusro-del/demo-cicd/pull/26) | [verde](https://github.com/Jesusro-del/demo-cicd/actions/runs/40715089324) · [rojo TruffleHog](https://github.com/Jesusro-del/demo-cicd/actions/runs/40715235000) · [rojo Grype](https://github.com/Jesusro-del/demo-cicd/actions/runs/40715101417) |
| B3 Cuatro etapas rotas | ✅ Hecho (tabla en el README) | #20–#23 (cerrados sin merge) | 4 rojos y 4 verdes, ver abajo |
| B4 Endpoint de estadísticas | ✅ Hecho (falta tu captura de STAGING con el total) | [#24](https://github.com/Jesusro-del/demo-cicd/pull/24) | [PR ✅](https://github.com/Jesusro-del/demo-cicd/actions/runs/40706486832) · [main ✅ STAGING](https://github.com/Jesusro-del/demo-cicd/actions/runs/40707117726) |
| B5 README, badge y resumen | ✅ Hecho (falta tu captura del Summary) | [#25](https://github.com/Jesusro-del/demo-cicd/pull/25) | [main con todos los resúmenes](https://github.com/Jesusro-del/demo-cicd/actions/runs/40710466993) |
| B6 Pipeline 25 % más rápido | 🟡 −11,6 % (4:02 → 3:34); tabla y análisis en el README | [#27](https://github.com/Jesusro-del/demo-cicd/pull/27) | [antes](https://github.com/Jesusro-del/demo-cicd/actions/runs/40559516916) · [después](https://github.com/Jesusro-del/demo-cicd/actions/runs/40726077089) |

## B1: un PR por paso de la guía

| Paso | Rama | Qué agrega | PR | Run |
|------|------|------------|----|-----|
| 1 | `pipeline/lint` | Job `lint` y `.gitattributes` (scripts con LF para el runner de Windows) | [#1](https://github.com/Jesusro-del/demo-cicd/pull/1) | [✅ 18 s](https://github.com/Jesusro-del/demo-cicd/actions/runs/40548292822) |
| 2 | `pipeline/sast` | Job `sast` (Semgrep y Gitleaks), en paralelo con `lint` | [#2](https://github.com/Jesusro-del/demo-cicd/pull/2) | [✅ 25 s](https://github.com/Jesusro-del/demo-cicd/actions/runs/40548937548) |
| 3 | `pipeline/pruebas` | Jobs `test-unit` y `test-integration` (`docker compose up`: 24 s) | [#3](https://github.com/Jesusro-del/demo-cicd/pull/3) | [✅ 1 min 13 s](https://github.com/Jesusro-del/demo-cicd/actions/runs/40549435524) |
| 4 | `pipeline/package` | Jobs `package` y `security` (Trivy en `CRITICAL,HIGH`, `fail-fast: false`) | [#4](https://github.com/Jesusro-del/demo-cicd/pull/4) | [🔴 escaneo inicial](https://github.com/Jesusro-del/demo-cicd/actions/runs/40551070125) → [✅ 2 min 37 s](https://github.com/Jesusro-del/demo-cicd/actions/runs/40553045998) |
| 5 | `pipeline/deploy-dev` | Job `deploy-dev` (kind efímero). En el PR: skipped. Con `workflow_dispatch`: kind 41 s, rollout 19 s, smoke e integración 8 s | [#5](https://github.com/Jesusro-del/demo-cicd/pull/5) | [✅ PR](https://github.com/Jesusro-del/demo-cicd/actions/runs/40554232446) · [✅ dispatch con DEV](https://github.com/Jesusro-del/demo-cicd/actions/runs/40554244385) |
| 6 | `pipeline/deploy-staging` | Job `deploy-staging` (runner propio, aprobación) | [#6](https://github.com/Jesusro-del/demo-cicd/pull/6) | [✅ PR](https://github.com/Jesusro-del/demo-cicd/actions/runs/40556389792) |
| 6b | `fix/staging-shell` | Ruta 8.3 de Git Bash: el runner no admite comillas en `shell` | [#7](https://github.com/Jesusro-del/demo-cicd/pull/7) | [🔴 main sin la corrección](https://github.com/Jesusro-del/demo-cicd/actions/runs/40557928658) |
| 7 | `pipeline/dependabot` | `.github/dependabot.yml` con `cooldown` | [#8](https://github.com/Jesusro-del/demo-cicd/pull/8) | [✅ PR](https://github.com/Jesusro-del/demo-cicd/actions/runs/40562825593) · [🔴 main: 504 en el smoke](https://github.com/Jesusro-del/demo-cicd/actions/runs/40563729456) |
| 7b | `fix/api-prestop` | `preStop` de 5 s en `api` | [#17](https://github.com/Jesusro-del/demo-cicd/pull/17) | [🔴 main: 504 otra vez](https://github.com/Jesusro-del/demo-cicd/actions/runs/40696551464) |
| 7c | `fix/staging-estable` | Esperar a que se borren los pods viejos antes del smoke; `proxy_connect_timeout 3s` en nginx | [#18](https://github.com/Jesusro-del/demo-cicd/pull/18) | [✅ main con STAGING](https://github.com/Jesusro-del/demo-cicd/actions/runs/40701588355) |
| — | Dependabot | `globals` 15 → 17, mezclado por el pipeline | [#13](https://github.com/Jesusro-del/demo-cicd/pull/13) | [✅ main con STAGING](https://github.com/Jesusro-del/demo-cicd/actions/runs/40702839413) |

Ruleset `main protegida` (id 25984021): PR obligatorio, los 10 checks de `lint`, `sast`, `test-unit`, `test-integration`, `package` ×3 y `security` ×3, sin force push ni borrado.

### Trivy en CRITICAL,HIGH: de 83 HIGH a 0

| Imagen | HIGH al inicio | Origen | Decisión |
|--------|:--------------:|--------|----------|
| web | 47 | Alpine 3.23 de `nginx-unprivileged:1.29-alpine`, rama sin mantenimiento desde mayo | Base `1.30-alpine3.24` (47 → 3) y `apk upgrade --no-cache` para brotli y curl (3 → 0) |
| api | 11 | 1 en `body-parser` (vía express) y 10 en el `npm` de `node:22-alpine` | `body-parser` 1.20.9 en el lockfile; `npm` y `npx` borrados de la imagen final |
| db | 25 | Librería estándar de Go 1.24.6 dentro del binario `gosu` | `.trivyignore` con los 25 CVE, justificados (código no alcanzable) y con `exp:2027-01-31` |

### ✅ Primer run de `main` en verde, aprobado y desplegado a STAGING

**https://github.com/Jesusro-del/demo-cicd/actions/runs/40559516916** (commit `b9aafef`). Imágenes en `demo-staging`: `sha-b9aafefef9c2d2a1fde47f172daa0e0bfc07f9e4`.

`deploy-staging` necesitó tres intentos en ese run:
1. Rollout en *timeout*: `db` en CrashLoopBackOff porque el Secret `db-credenciales` se había creado en PowerShell, donde `$(openssl rand -hex 16)` da vacío. Se recreó en Git Bash.
2. `exceeded its progress deadline`: con la misma imagen, el `apply` no crea pods nuevos y los viejos seguían con la contraseña vacía. `kubectl rollout restart` de `db` y `api`.
3. Verde: rollout y smoke contra `http://localhost:30080`.

Hecho: paquetes públicos, environment `staging` con revisor (sin *prevent self-review*), runner `FM_AD_ICB_DT_08` registrado, namespace y Secret de `demo-staging`.

### El 504 del smoke de STAGING (27 y 28/10)

Después del primer despliegue, cada despliegue nuevo a STAGING fallaba en el smoke con `POST /api/mensajes devolvió 504`. nginx registraba `upstream timed out ... while connecting to upstream` hacia el Service `api`.
1. Primera hipótesis: el Service seguía enviando conexiones a un pod viejo de `api` ya apagado. Se agregó `preStop` de 5 s (#17). **No bastó**: el 504 se repitió.
2. Reproducción con una sonda (`GET /api/mensajes` cada 0,5 s) durante un reinicio de los tres Deployments: unos 10 s de errores (6 × 500 mientras `db` se recrea con `Recreate`, 2 conexiones fallidas al cambiar `web`) y todo 200 al terminar los rollouts. El smoke arrancaba justo cuando `rollout status` devolvía el control, con pods viejos todavía borrándose.
3. Solución (#18): esperar a que no quede ningún pod con `deletionTimestamp` antes del smoke, y `proxy_connect_timeout 3s` en nginx (por defecto 60 s). En el run siguiente el paso esperó unos 6 s al pod viejo de `api` y el smoke pasó.

Los ~10 s de errores durante un despliegue siguen existiendo: son consecuencia de un solo Postgres con `Recreate`.

Otros rojos del 28/10, por el entorno: el runner apagado (job en cola hasta `run.cmd`) y Kubernetes de Rancher Desktop apagado (`connection refused` a `127.0.0.1:6443`).

### Persistencia de STAGING

Los mensajes 1, 2 y 3 sobrevivieron a cuatro despliegues (`b9aafef` → `f1a346b` → `efe8da2` → `1ceaa7a` → `966c5a8`); Postgres arranca con "database directory appears to contain a database; Skipping initialization".

Pendiente para la entrega: captura de `kubectl -n demo-staging get pods` con las imágenes `sha-<commit>`.

## B3: tiempos de detección

| Etapa | Qué rompí | Run en rojo | Run en verde | Minuto de detección |
|-------|-----------|-------------|--------------|---------------------|
| `sast` | `actions/checkout@v4` en `lint` (#21) | [40704482875](https://github.com/Jesusro-del/demo-cicd/actions/runs/40704482875) | [40705105624](https://github.com/Jesusro-del/demo-cicd/actions/runs/40705105624) | 0:24 |
| `lint` | `<html>` sin `lang` (#20) | [40704478535](https://github.com/Jesusro-del/demo-cicd/actions/runs/40704478535) | [40705097076](https://github.com/Jesusro-del/demo-cicd/actions/runs/40705097076) | 0:26 |
| `test-integration` | `proxy_pass` a `api:3001` (#22) | [40704490155](https://github.com/Jesusro-del/demo-cicd/actions/runs/40704490155) | [40705113679](https://github.com/Jesusro-del/demo-cicd/actions/runs/40705113679) | 1:26 |
| `security` | `FROM node:16-alpine` (#23) | [40704495856](https://github.com/Jesusro-del/demo-cicd/actions/runs/40704495856) | [40705116777](https://github.com/Jesusro-del/demo-cicd/actions/runs/40705116777) | 2:48 |

Los otros rojos reales de `deploy-staging` (shell con comillas, Secret vacío, runner apagado, Kubernetes apagado, 504 del smoke) están en la sección del B1: sirven para la defensa oral.

## B6: tiempos por job

El "antes" es el primer run completo de `main` en verde, sin contar la espera de la aprobación.

"Antes": run [40559516916](https://github.com/Jesusro-del/demo-cicd/actions/runs/40559516916), jobs 1 a 7 del intento 1 y `deploy-staging` del intento 3. Total = camino crítico de 18:23:28 a 18:27:13 más `deploy-staging`, sin la espera de la aprobación.

| Job | Antes | Después |
|-----|-------|---------|
| lint | 16 s | 22 s |
| sast | 21 s | 27 s (TruffleHog) |
| test-unit | 15 s | 11 s (en paralelo) |
| test-integration | 37 s (`compose up` ~24 s) | 54 s en paralelo (bake 13 s + up 13 s; otros runs 38–47 s) |
| package (máx. de los tres) | 36 s (db) | 24 s (sin QEMU) |
| security (máx. de los tres) | 17 s (db) | 34 s (Grype con caché; sin caché ~100 s) |
| deploy-dev | 87 s (kind ~41 s, rollout ~19 s) | 73 s (k3d 12 s, rollout 35 s) |
| deploy-staging | 17 s (pods ya listos tras el restart; un rollout normal tarda más) | 18 s (mismo commit que el run anterior: nada que actualizar) |
| **Total** | **≈ 4 min 02 s** (3 min 45 s hasta DEV + 17 s) | **3 min 34 s** (3 min 16 s hasta DEV + 18 s): **−11,6 %** |

## B4: GET /api/estadisticas

- `api/app.js`: `SELECT COUNT(*)::int AS total FROM mensajes` → `{"total": N}`. Sin el `::int`, `pg` devuelve el `bigint` como texto.
- La página muestra `· N mensajes` dentro del `<h1>` y lo actualiza al enviar un mensaje.
- Pruebas nuevas: 2 unitarias (pool falso), 1 de integración (el total sube en 1) y 1 del sitio. Unitarias 9 → 11, integración 6 → 7, sitio 6 → 7.
- En STAGING (`sha-7681151`): `/api/estadisticas` respondió `{"total":6}`.
- Se canceló el run del PR #19 que esperaba aprobación: aprobarlo habría desplegado una versión anterior al B4 encima de la nueva. Idea para el B6: `concurrency` en `deploy-staging`.

## B5: README y resumen del run

- README: badge, diagrama Mermaid y tabla de las 8 etapas (herramienta, qué revisa, qué pasa si falla, evento).
- `scripts/resumen.mjs` convierte el JSON de Vitest y de Trivy en tablas para `$GITHUB_STEP_SUMMARY`. Trivy sigue con `exit-code: "1"`: solo cambió `format: table` por `format: json`.
- Alternativa descartada: acciones de terceros como `dorny/test-reporter`, que piden `checks: write` y suman otra dependencia que fijar.

"Después": run [40726077089](https://github.com/Jesusro-del/demo-cicd/actions/runs/40726077089) (segundo run de `main` tras #27, con la caché de Grype llena). El primer run tras el merge ([40725060445](https://github.com/Jesusro-del/demo-cicd/actions/runs/40725060445)), con la caché vacía y un rollout real en STAGING, tardó 5:10. La meta del 25 % (≤ 3:01) no se alcanzó; el análisis completo está en el README.
