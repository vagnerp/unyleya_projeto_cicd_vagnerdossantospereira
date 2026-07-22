terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Grupo de recursos - "pasta" que agrupa tudo no Azure
resource "azurerm_resource_group" "rg" {
  name     = "rg-unyleya-devops"
  location = "australiacentral"
#  location = "Brazil South"
}

# Plano do App Service (define o "tamanho" da máquina/preço)
resource "azurerm_service_plan" "plan" {
  name                = "plan-unyleya-devops"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"   # camada básica, mais barata
}

# App Service configurado para rodar container (imagem do Docker Hub)
resource "azurerm_linux_web_app" "app" {
  name                = "app-unyleya-vagnerdossantospereira"   # precisa ser ÚNICO no Azure inteiro
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = false

    application_stack {
      docker_image_name   = "vagnerp/mobead:latest"
      docker_registry_url = "https://index.docker.io"
    }
  }
}

output "app_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}