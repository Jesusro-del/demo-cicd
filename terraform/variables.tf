variable "dueno" {
  description = "Usuario u organización dueña del repositorio"
  type        = string
  default     = "Jesusro-del"
}

variable "repositorio" {
  description = "Nombre del repositorio"
  type        = string
  default     = "demo-cicd"
}

variable "revisor_staging" {
  description = "Usuario de GitHub que aprueba los despliegues a STAGING"
  type        = string
  default     = "Jesusro-del"
}

# Los checks que main exige para mezclar: los nombres visibles de los jobs. package y security son matrices,
# así que cada imagen es un check aparte. Si un job cambia de nombre, hay que cambiarlo aquí (pasó en el B2).
variable "checks_requeridos" {
  description = "Nombres de los jobs que tienen que estar en verde para mezclar a main"
  type        = list(string)
  default = [
    "1. Lint (ESLint, HTMLHint, Hadolint)",
    "2. SAST (Semgrep) y secretos (TruffleHog)",
    "3. Pruebas unitarias y del sitio",
    "4. Pruebas de integración (Compose)",
    "5. Empaquetar y publicar (web)",
    "5. Empaquetar y publicar (api)",
    "5. Empaquetar y publicar (db)",
    "6. Escaneo de imagen (web)",
    "6. Escaneo de imagen (api)",
    "6. Escaneo de imagen (db)",
  ]
}
