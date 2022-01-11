resource "azurerm_resource_group" "example" {
  name     = "monitoring-resources"
  location = "West Europe"
}

resource "azurerm_application_insights" "example" {
  name                = "appinsights"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_application_insights" "example2" {
  name                = "appinsights2"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

# Example: Alerting Action Cross-Resource
resource "azurerm_monitor_scheduled_query_rules_alert" "example2" {
  name                = format("%s-queryrule2", var.prefix)
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  authorized_resource_ids = [azurerm_application_insights.example2.id]
  action {
    action_group           = []
    email_subject          = "Email Header"
    custom_webhook_payload = "{}"
  }
  data_source_id = azurerm_application_insights.example.id
  description    = "Query may access data within multiple resources"
  enabled        = true
  # Count requests in multiple log resources and group into 5-minute bins by HTTP operation
  query = format(<<-QUERY
  let a=requests
    | where toint(resultCode) >= 500
    | extend fail=1; let b=app('%s').requests
    | where toint(resultCode) >= 500 | extend fail=1; a
    | join b on fail
QUERY
  , azurerm_application_insights.example2.id)
  severity    = 1
  frequency   = 5
  time_window = 30
  trigger {
    operator  = "GreaterThan"
    threshold = 3
  }
}