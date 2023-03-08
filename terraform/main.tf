
# this line is important so that backend connection is extablished in the pipeline
terraform {
  backend "azurerm" {}
}
# Configure the Microsoft Azure Provider
resource "azurerm_resource_group" "sbops-rg" {
  name     = "${var.name}-rg"
  location = var.location
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_application_insights" "sbops" {
  name                = "sbops-test-terraform-insights"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.sbops-rg.name
  application_type    = "web"
}


resource "azurerm_storage_account" "sbopssa" {
  name                     = "sbopssatf"
  resource_group_name      = azurerm_resource_group.sbops-rg.name
  location                 = azurerm_resource_group.sbops-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_function_app" "sbops" {
  name                      = "sbops-test-terraform"
  location                  = "westeurope"
  resource_group_name       = azurerm_resource_group.sbops-rg.name
  storage_account_name = azurerm_storage_account.sbopssa.name
  storage_account_access_key = azurerm_storage_account.sbopssa.primary_access_key

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.sbops.instrumentation_key
  }
}