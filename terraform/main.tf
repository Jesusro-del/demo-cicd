# La plataforma como código (Reto 6 del LAB-04): la protección de main y los ambientes, que antes se
# configuraron a mano en la interfaz de GitHub.

# El id numérico del revisor: los ambientes guardan ids, no nombres de usuario.
data "github_user" "revisor" {
  username = var.revisor_staging
}

# DEV: sin revisores. deploy-dev despliega solo en cada push a main.
resource "github_repository_environment" "dev" {
  repository        = var.repositorio
  environment       = "dev"
  can_admins_bypass = true
}

# STAGING: el job deploy-staging espera la aprobación de un revisor.
# prevent_self_review = false: soy el único colaborador; si fuera true, nadie podría aprobar mis propios despliegues.
resource "github_repository_environment" "staging" {
  repository          = var.repositorio
  environment         = "staging"
  can_admins_bypass   = true
  prevent_self_review = false

  reviewers {
    users = [data.github_user.revisor.id]
  }
}

# main protegida: solo por PR, con los checks del pipeline en verde, sin force push ni borrado.
resource "github_repository_ruleset" "main" {
  name        = "main protegida"
  repository  = var.repositorio
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  # Reto 4 (GitOps): deploy-staging hace commit del tag nuevo en k8s/overlays/staging directo a main.
  # 15368 es la app GitHub Actions. Solo pasa un job con permissions: contents: write, y hoy es solo deploy-staging
  # (después de la aprobación). Los workflows de forks reciben un token de solo lectura.
  bypass_actors {
    actor_id    = 15368
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  rules {
    deletion         = true
    non_fast_forward = true

    # 0 aprobaciones: soy el único colaborador. Lo que se exige es pasar por un PR y por el pipeline.
    pull_request {
      required_approving_review_count   = 0
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = false
    }

    required_status_checks {
      strict_required_status_checks_policy = false

      # 15368 es la app de GitHub Actions: un check con el mismo nombre que venga de otra app no cuenta.
      dynamic "required_check" {
        for_each = var.checks_requeridos
        content {
          context        = required_check.value
          integration_id = 15368
        }
      }
    }
  }
}
