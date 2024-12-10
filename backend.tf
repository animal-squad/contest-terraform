terraform {
  cloud {
    organization = "animal-squad"

    workspaces {
      name = "contest"
    }
  }
}
