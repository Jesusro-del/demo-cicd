# Progreso del LAB-04

Fecha límite: 30/10/2026 23:59. Repositorio: https://github.com/Jesusro-del/demo-cicd

## Estado por ítem

| Ítem | Estado | PR | Run |
|------|--------|----|-----|
| B1 Pipeline de la guía | 🟡 En curso | | |
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
| 6 | `pipeline/deploy-staging` | Job `deploy-staging` (runner propio, aprobación) | | |
| 7 | `pipeline/dependabot` | `.github/dependabot.yml` con `cooldown` | | |

### Trivy en CRITICAL,HIGH: de 83 HIGH a 0

| Imagen | HIGH al inicio | Origen | Decisión |
|--------|:--------------:|--------|----------|
| web | 47 | Alpine 3.23 de `nginx-unprivileged:1.29-alpine`, rama sin mantenimiento desde mayo | Base `1.30-alpine3.24` (47 → 3) y `apk upgrade --no-cache` para brotli y curl (3 → 0) |
| api | 11 | 1 en `body-parser` (vía express) y 10 en el `npm` de `node:22-alpine` | `body-parser` 1.20.9 en el lockfile; `npm` y `npx` borrados de la imagen final |
| db | 25 | Librería estándar de Go 1.24.6 dentro del binario `gosu` | `.trivyignore` con los 25 CVE, justificados (código no alcanzable) y con `exp:2027-01-31` |

Configuración manual pendiente: paquetes públicos, environment `staging` con revisor, ruleset de `main`, runner registrado, namespace y Secret de `demo-staging`.

## B3: tiempos de detección

| Etapa | Qué rompí | Run en rojo | Run en verde | Minuto de detección |
|-------|-----------|-------------|--------------|---------------------|

## B6: tiempos por job

El "antes" es el primer run completo de `main` en verde, sin contar la espera de la aprobación.

| Job | Antes | Después |
|-----|-------|---------|
| lint | | |
| sast | | |
| test-unit | | |
| test-integration | | |
| package (máx. de los tres) | | |
| security (máx. de los tres) | | |
| deploy-dev | | |
| deploy-staging | | |
| **Total** | | |
