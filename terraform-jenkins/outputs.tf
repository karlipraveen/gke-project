output "Jenkins_Public_IP" {
  value = google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip
}

output "Jenkins_URL" {
  value = "http://${google_compute_instance.jenkins.network_interface[0].access_config[0].nat_ip}:8080"
}

output "Service_Account" {
  value = google_service_account.jenkins_sa.email
}
