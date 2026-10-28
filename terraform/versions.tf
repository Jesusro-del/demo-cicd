# Versiones fijas, como todo en este repositorio: Terraform y el provider de GitHub.
# .terraform.lock.hcl (versionado) fija además los hashes del provider.
terraform {
  required_version = "= 1.17.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "= 6.13.0"
    }
  }
}

# El token NO va aquí: el provider lo lee de la variable de entorno GITHUB_TOKEN.
#   GITHUB_TOKEN="$(gh auth token)" terraform plan
provider "github" {
  owner = var.dueno
}
