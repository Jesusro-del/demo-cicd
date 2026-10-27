# Progreso del LAB-04

Fecha límite: 30/10/2026 23:59. Repositorio: https://github.com/Jesusro-del/demo-cicd

## Estado por ítem

| Ítem | Estado | PR | Run |
|------|--------|----|-----|
| B1 Pipeline de la guía | 🟡 Falta Dependabot y ruleset | #1–#7 | [main ✅ STAGING](https://github.com/Jesusro-del/demo-cicd/actions/runs/40559516916) |
| B2 Dos herramientas cambiadas | ⬜ Pendiente | | |
| B3 Cuatro etapas rotas | ⬜ Pendiente | | |
| B4 Endpoint de estadísticas | ⬜ Pendiente | | |
| B5 README, badge y resumen | ⬜ Pendiente | | |
| B6 Pipeline 25 % más rápido | ⬜ Pendiente | | |

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
| 7 | `pipeline/dependabot` | `.github/dependabot.yml` con `cooldown` | | |

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
Pendiente: Dependabot con un PR suyo mezclado, ruleset de `main`, captura de los pods, comprobar que los mensajes sobreviven a un nuevo despliegue.

## B3: tiempos de detección

| Etapa | Qué rompí | Run en rojo | Run en verde | Minuto de detección |
|-------|-----------|-------------|--------------|---------------------|

## B6: tiempos por job

El "antes" es el primer run completo de `main` en verde, sin contar la espera de la aprobación.

"Antes": run [40559516916](https://github.com/Jesusro-del/demo-cicd/actions/runs/40559516916), jobs 1 a 7 del intento 1 y `deploy-staging` del intento 3. Total = camino crítico de 18:23:28 a 18:27:13 más `deploy-staging`, sin la espera de la aprobación.

| Job | Antes | Después |
|-----|-------|---------|
| lint | 16 s | |
| sast | 21 s | |
| test-unit | 15 s | |
| test-integration | 37 s (`compose up` ~24 s) | |
| package (máx. de los tres) | 36 s (db) | |
| security (máx. de los tres) | 17 s (db) | |
| deploy-dev | 87 s (kind ~41 s, rollout ~19 s) | |
| deploy-staging | 17 s (pods ya listos tras el restart; un rollout normal tarda más) | |
| **Total** | **≈ 4 min 02 s** (3 min 45 s hasta DEV + 17 s) | |
