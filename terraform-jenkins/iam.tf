resource "google_project_iam_member" "artifact_registry" {
  project = var.project_id
  role = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.jenkins_sa.email}"
}

resource "google_project_iam_member" "gke_admin" {
  project = var.project_id
  role = "roles/container.admin"
  member = "serviceAccount:${google_service_account.jenkins_sa.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.jenkins_sa.email}"
}

resource "google_project_iam_member" "logging" {
  project = var.project_id
  role = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.jenkins_sa.email}"
}

resource "google_project_iam_member" "monitoring" {
  project = var.project_id
  role = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.jenkins_sa.email}"
}
