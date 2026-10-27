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
| 1 | `pipeline/lint` | Job `lint` y `.gitattributes` (scripts con LF para el runner de Windows) | | |
| 2 | `pipeline/sast` | Job `sast` (Semgrep y Gitleaks) | | |
| 3 | `pipeline/pruebas` | Jobs `test-unit` y `test-integration` | | |
| 4 | `pipeline/package` | Jobs `package` y `security` (Trivy en `CRITICAL,HIGH`) | | |
| 5 | `pipeline/deploy-dev` | Job `deploy-dev` (kind efímero) | | |
| 6 | `pipeline/deploy-staging` | Job `deploy-staging` (runner propio, aprobación) | | |
| 7 | `pipeline/dependabot` | `.github/dependabot.yml` con `cooldown` | | |

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
