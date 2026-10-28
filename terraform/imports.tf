# Todo esto ya existía, creado a mano o con gh durante el B1. Con estos bloques import (Terraform >= 1.5),
# el primer plan adopta lo que hay en GitHub en vez de intentar crearlo de nuevo. Si el código describe bien
# la configuración real, plan muestra 3 recursos para importar y 0 para cambiar.
import {
  to = github_repository_environment.dev
  id = "${var.repositorio}:dev"
}

import {
  to = github_repository_environment.staging
  id = "${var.repositorio}:staging"
}

# 25984021 es el id del ruleset (gh api repos/<dueño>/<repo>/rulesets).
import {
  to = github_repository_ruleset.main
  id = "${var.repositorio}:25984021"
}
