# Бакет для хранения состояний Terraform (имя должно быть уникальным среди всех)
resource "yandex_storage_bucket" "terraform-states-olga-bucket" {
  access_key = yandex_iam_service_account_static_access_key.bucket-sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.bucket-sa-static-key.secret_key
  bucket     = "terraform-states-olga-bucket"
  folder_id  = local.folder_id
  acl        = "private"
  depends_on = [yandex_iam_service_account.bucket-sa, yandex_resourcemanager_folder_iam_member.bucket-sa-editor] # при destroy может сначала удалить bucket-sa-editor, а только потом бакет => при ошибке уже не будет работать
}