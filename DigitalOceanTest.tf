resource "digitalocean_ssh_key" "default" {
  name = "Key1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzcndRtj9Ft5fAqZZ4X9IRDI+un7KRDdyvbjCfu47AFw04BfhmgGrOLUsa/vAX28gIZQiffNmJ+p61ah1I4jLlkvey0IAXshFjEBV2RLR9H1Blbl4kX+1NqONZHi/m2SN7AoLOoYXeAK0MioJ6W/dFcr1qh40vh/uro15xDDNliuoPJgPsmFxiBMEG7WQyAILRkURyijftZTNtWOQj5iwdASFW9qLJrCFoAIAwuSPYcQEkj2iBTvezlVKpLxa6ldXJCFJWUZGAyaVgWCQlyMW29ucQ/uqRFa7WzAIWhWNN+zD+BeSKWqVu3tcgSfOWXCfu0RmXPJF1+omzCrU82Gxb rsa-key-20220603"
}
resource "digitalocean_droplet" "web" {
  image  = "ubuntu-20-04-x64"
  name   = "web-1"
  region = "nyc2"
  size   = "s-1vcpu-1gb"
  ssh_keys = ["$/data/key.pub"]
}