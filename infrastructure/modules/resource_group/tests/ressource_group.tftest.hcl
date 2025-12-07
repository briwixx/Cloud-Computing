# Configuration du fournisseur AzureRM
provider "azurerm" {
  features {}
    subscription_id = "90304447-11f6-4097-a50d-23555344115e"  # Ton ID de souscription Azure
}

# Test pour vérifier la création du groupe de ressources
run "check_resource_group" {
  command = apply

  variables {
    resource_group_name = "Cloud-computing-project-86c14ca58087"
    location           = "Norway East"
    suffix             = "86c14ca58087"
  }

  # Vérifier que le groupe de ressources existe et que son nom est correct
  assert {
    condition     = azurerm_resource_group.rg.name == "${var.resource_group_name}-${var.suffix}"
    error_message = "Le nom du groupe de ressources est incorrect"
  }

  # Vérifier que le groupe de ressources est dans la bonne localisation
  assert {
    condition     = azurerm_resource_group.rg.location == var.location
    error_message = "La localisation du groupe de ressources est incorrecte"
  }
}