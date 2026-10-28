# La plataforma como código (Reto 6 del LAB-04)

La protección de `main` y los ambientes `dev` y `staging` los configuré primero a mano, con la interfaz de GitHub y con `gh api`. Aquí están descritos con Terraform, para que se puedan reproducir y revisar en un PR como cualquier otro cambio.

| Recurso | Qué es |
|---------|--------|
| `github_repository_ruleset.main` | `main protegida`: solo por PR, con los 10 checks del pipeline en verde, sin force push ni borrado |
| `github_repository_environment.dev` | Ambiente `dev`, sin revisores |
| `github_repository_environment.staging` | Ambiente `staging`, con revisor requerido y sin *prevent self-review* |

## Uso

Terraform 1.17.0 y el provider `integrations/github` 6.13.0, los dos con versión fija. El token sale de tu sesión de `gh`, solo para ese comando; nunca va en el código ni en un archivo:

```bash
terraform -chdir=terraform init
GITHUB_TOKEN="$(gh auth token)" terraform -chdir=terraform plan
```

Como todo ya existía, `imports.tf` le dice a Terraform que lo adopte en vez de crearlo. El primer `plan` contra el repositorio real dio:

```
Plan: 3 to import, 0 to add, 0 to change, 0 to destroy.
```

Cero cambios: el código describe exactamente lo que hay en GitHub. Un `terraform apply` solo guardaría los tres recursos en el estado, sin tocar nada en GitHub; después, cada `plan` diría `No changes`.

## Dónde vive el estado

Hoy, **local** (`terraform.tfstate`, en `.gitignore`). El estado es la memoria de Terraform sobre qué recursos administra, y puede guardar datos sensibles: no se versiona.

| Opción | A favor | En contra |
|--------|---------|-----------|
| **Local** (elegida) | Cero infraestructura extra; alcanza para una sola persona | Si se pierde el archivo, hay que volver a importar; no se puede compartir ni bloquear |
| Terraform Cloud (gratis hasta 500 recursos) | Estado compartido, con bloqueo e historial; puede correr el `plan` en cada PR | Una cuenta y un token más que administrar |
| Bucket (S3, GCS) con bloqueo | Estándar en equipos | Hay que crear y asegurar el bucket, y eso también debería estar en código |

Para un repositorio de una persona, local alcanza. En un equipo, el estado tendría que estar en un backend remoto con bloqueo, para que dos `apply` no se pisen.
