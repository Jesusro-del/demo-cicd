# Argo CD para STAGING (Reto 4 del LAB-04)

STAGING es GitOps: lo que corre en `demo-staging` es lo que dice `k8s/overlays/staging` en la rama **`gitops/staging`**. Argo CD vive dentro del clúster y **jala** los cambios desde Git; el pipeline ya no **empuja** al clúster.

```
deploy-staging (con aprobación) ── commit de main + tag nuevo ──> rama gitops/staging
                                                                     │  Argo CD revisa cada 60 s
                                                                     ▼
                                                   Argo CD sincroniza demo-staging
                                                                     │
verify-staging (runner propio) ── espera las imágenes nuevas y corre el smoke
```

## Por qué una rama aparte y no `main`

`main` está protegida: solo se escribe por PR con los checks en verde. Lo natural era exceptuar a la app GitHub Actions en el ruleset, pero GitHub lo rechaza en un repositorio de cuenta personal (*Actor GitHub Actions integration must be part of the ruleset source or owner organization*; solo funciona en organizaciones). Las otras salidas eran peores: una deploy key con escritura guardada como Secret (una credencial de larga duración) o un PR automático (los PR creados con `GITHUB_TOKEN` no disparan el pipeline, así que sus checks nunca corren).

`gitops/staging` es siempre "un commit de `main` más el tag de imagen de ese commit", y `deploy-staging` la reemplaza en cada despliegue (`--force`). Así, manifiestos e imágenes de STAGING salen del mismo commit. La historia de qué se desplegó y quién lo aprobó queda en los runs y en Argo CD.

## Instalación (una sola vez, en Rancher Desktop)

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.5/manifests/install.yaml
# Argo CD revisa Git cada ~3 min por defecto. GitHub no puede avisarle por webhook (está en mi laptop), así que 60 s:
kubectl -n argocd patch configmap argocd-cm --type merge -p '{"data":{"timeout.reconciliation":"60s"}}'
kubectl -n argocd rollout restart statefulset/argocd-application-controller deploy/argocd-repo-server
# La Application, recién cuando exista la rama gitops/staging con el bloque images (si no, Argo CD no tiene qué mirar):
kubectl apply -n argocd -f k8s/argocd/staging.yaml
```

`--server-side`: los CRD de Argo CD son más grandes que el límite de la anotación que usa `kubectl apply` del lado del cliente.

## La interfaz

```bash
kubectl -n argocd port-forward svc/argocd-server 8443:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Usuario `admin`, en https://localhost:8443 (certificado autofirmado). La contraseña inicial solo vive en el clúster.

## Observabilidad (Reto 3)

Prometheus y Grafana viven en el namespace `observabilidad`. Los administra una segunda `Application`, que sigue la carpeta `observabilidad/` en `main`. Antes de crearla hay que hacer el Secret de Grafana, que no está en Git (en Git Bash, porque PowerShell no tiene `openssl`):

```bash
kubectl create namespace observabilidad
kubectl -n observabilidad create secret generic grafana-admin \
  --from-literal=usuario=admin --from-literal=contrasena="$(openssl rand -base64 18)"
kubectl apply -n argocd -f k8s/argocd/observabilidad.yaml
```

Para entrar:

```bash
kubectl -n observabilidad port-forward svc/grafana 3001:3000      # http://localhost:3001
kubectl -n observabilidad port-forward svc/prometheus 9090:9090   # http://localhost:9090/alerts
kubectl -n observabilidad get secret grafana-admin -o jsonpath='{.data.contrasena}' | base64 -d
```

## Qué no administra Argo CD

Los Secrets `db-credenciales` (en `demo-staging`) y `grafana-admin` (en `observabilidad`) se crearon a mano y no están en Git. Argo CD no lo borra, porque `prune` solo afecta a lo que Argo CD creó a partir de Git.
