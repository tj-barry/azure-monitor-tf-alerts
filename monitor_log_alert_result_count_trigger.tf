resource "azurerm_resource_group" "arg" {
  name     = "coreservices"
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

# Example: Alerting Action with result count trigger
resource "azurerm_monitor_scheduled_query_rules_alert" "example" {
  name                = format("%s-queryrule", var.prefix)
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  action {
    action_group           = []
    email_subject          = "Email Header"
    custom_webhook_payload = "{}"
  }
  data_source_id = azurerm_application_insights.example.id
  description    = "Alert when total results cross threshold"
  enabled        = true
  # Count all requests with server error result code grouped into 5-minute bins
  query       = <<-QUERY
  requests
    | where tolong(resultCode) >= 500
    | summarize count() by bin(timestamp, 5m)
  QUERY
  severity    = 1
  frequency   = 5
  time_window = 30
  trigger {
    operator  = "GreaterThan"
    threshold = 3
  }
}