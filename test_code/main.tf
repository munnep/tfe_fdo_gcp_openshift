terraform {
  cloud {
    hostname = "tfe31.aws.munnep.com"
    organization = "test"

    workspaces {
      name = "test"
    }
  }
}

resource "null_resource" "name" {
}