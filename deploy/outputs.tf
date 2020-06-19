output "url" {
    value = "http://${aws_lb.bpdts_tech_test.dns_name}"
}