data "google_project" "current" {
  project_id = var.project_id
}

locals {
  jenkins_service_account = "${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}
