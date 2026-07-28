resource "google_service_account" "gke_sa" {
  account_id = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

resource "google_project_iam_member" "logging" {
  project = var.project_id
  role = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "monitoring" {
  project = var.project_id
  role = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "artifact" {
  project = var.project_id
  role = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "storage" {
  project = var.project_id
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gke_sa.email}"
}
