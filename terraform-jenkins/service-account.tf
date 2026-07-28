resource "google_service_account" "jenkins_sa" {
  account_id = var.jenkins_service_account
  display_name = "Jenkins Service Account"
}
