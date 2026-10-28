# Argo CD para STAGING (Reto 4 del LAB-04)

STAGING es GitOps: lo que corre en `demo-staging` es lo que dice `k8s/overlays/staging` en `main`. Argo CD vive dentro del clúster y **jala** los cambios desde Git; el pipeline ya no **empuja** al clúster.

```
deploy-staging (con aprobación) ── commit del tag en el overlay ──> main
                                                                     │  Argo CD revisa cada 60 s
                                                                     ▼
                                                   Argo CD sincroniza demo-staging
                                                                     │
verify-staging (runner propio) ── espera las imágenes nuevas y corre el smoke
```

## Instalación (una sola vez, en Rancher Desktop)

```bash
kubectl create namespace argocd
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.5/manifests/install.yaml
# Argo CD revisa Git cada ~3 min por defecto. GitHub no puede avisarle por webhook (está en mi laptop), así que 60 s:
kubectl -n argocd patch configmap argocd-cm --type merge -p '{"data":{"timeout.reconciliation":"60s"}}'
kubectl -n argocd rollout restart statefulset/argocd-application-controller deploy/argocd-repo-server
# La Application, recién cuando k8s/overlays/staging en main ya tenga el bloque images:
kubectl apply -n argocd -f k8s/argocd/staging.yaml
```

`--server-side`: los CRD de Argo CD son más grandes que el límite de la anotación que usa `kubectl apply` del lado del cliente.

## La interfaz

```bash
kubectl -n argocd port-forward svc/argocd-server 8443:443
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Usuario `admin`, en https://localhost:8443 (certificado autofirmado). La contraseña inicial solo vive en el clúster.

## Qué no administra Argo CD

El Secret `db-credenciales` se creó a mano y no está en Git. Argo CD no lo borra, porque `prune` solo afecta a lo que Argo CD creó a partir de Git.
