resource "aws_key_pair" "deployer_josef" {
  key_name   = "ssh_josef"
  public_key = file("${path.module}/pub-keys/ssh_josef.pub")  # You'll need to create this key
}

resource "aws_key_pair" "deployer_mat" {
  key_name   = "ssh_matmat"
  public_key = file("${path.module}/pub-keys/ssh_matmat.pub")  # You'll need to create this key
}
