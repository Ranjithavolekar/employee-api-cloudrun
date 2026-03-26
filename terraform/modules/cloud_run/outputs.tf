output "service_url" {
  description = "the url for the cloud run"
  value = google_cloud_run_v2_service.employee_api.uri
}