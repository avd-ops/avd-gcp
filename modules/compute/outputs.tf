output "instance_group_name" {
  value = google_compute_region_instance_group_manager.session_hosts.name
}

output "instance_template_id" {
  value = google_compute_instance_template.session_host.id
}
