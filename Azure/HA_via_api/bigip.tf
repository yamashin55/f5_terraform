# BIG-IP Cluster

# Create Route Table
resource "azurerm_route_table" "udr" {
  name                          = "udr"
  location                      = data.azurerm_resource_group.main.location
  resource_group_name           = data.azurerm_resource_group.main.name
  disable_bgp_route_propagation = false

  route {
    name                   = "route1"
    address_prefix         = var.managed_route
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.vm02-ext-nic.private_ip_address
  }

  tags = {
    f5_cloud_failover_label = var.f5_cloud_failover_label
    f5_self_ips             = "${azurerm_network_interface.vm01-ext-nic.private_ip_address},${azurerm_network_interface.vm02-ext-nic.private_ip_address}"
  }
}

# Create Public IPs
resource "azurerm_public_ip" "vm01mgmtpip" {
  name                = "${var.prefix}-vm01-mgmt-pip"
  location            = data.azurerm_resource_group.main.location
  sku                 = "Standard"
  availability_zone   = 1
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    Name        = "${var.environment}-vm01-mgmt-public-ip"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

resource "azurerm_public_ip" "vm01selfpip" {
  name                = "${var.prefix}-vm01-self-pip"
  location            = data.azurerm_resource_group.main.location
  sku                 = "Standard"
  availability_zone   = 1
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    Name        = "${var.environment}-vm01-self-public-ip"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

resource "azurerm_public_ip" "vm02mgmtpip" {
  name                = "${var.prefix}-vm02-mgmt-pip"
  location            = data.azurerm_resource_group.main.location
  sku                 = "Standard"
  availability_zone   = 2
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    Name        = "${var.environment}-vm02-mgmt-public-ip"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

resource "azurerm_public_ip" "vm02selfpip" {
  name                = "${var.prefix}-vm02-self-pip"
  location            = data.azurerm_resource_group.main.location
  sku                 = "Standard"
  availability_zone   = 2
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    Name        = "${var.environment}-vm02-self-public-ip"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

resource "azurerm_public_ip" "pubvippip" {
  name                = "${var.prefix}-pubvip-pip"
  location            = data.azurerm_resource_group.main.location
  sku                 = "Standard"
  availability_zone   = 1
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    Name        = "${var.environment}-pubvip-public-ip"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

# Create NIC for Management 
resource "azurerm_network_interface" "vm01-mgmt-nic" {
  name                = "${var.prefix}-vm01-mgmt"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5vm01mgmt
    public_ip_address_id          = azurerm_public_ip.vm01mgmtpip.id
  }

  tags = {
    Name        = "${var.environment}-vm01-mgmt"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

resource "azurerm_network_interface" "vm02-mgmt-nic" {
  name                = "${var.prefix}-vm02-mgmt"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.mgmt.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5vm02mgmt
    public_ip_address_id          = azurerm_public_ip.vm02mgmtpip.id
  }

  tags = {
    Name        = "${var.environment}-vm02-mgmt"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

# Create NIC for External
resource "azurerm_network_interface" "vm01-ext-nic" {
  name                 = "${var.prefix}-vm01-ext"
  location             = data.azurerm_resource_group.main.location
  resource_group_name  = data.azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5vm01ext
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.vm01selfpip.id
  }

  tags = {
    Name                      = "${var.environment}-vm01-ext"
    environment               = var.environment
    owner                     = var.owner
    group                     = var.group
    costcenter                = var.costcenter
    application               = var.application
    f5_cloud_failover_label   = var.f5_cloud_failover_label
    f5_cloud_failover_nic_map = var.f5_cloud_failover_nic_map
  }
}

resource "azurerm_network_interface" "vm02-ext-nic" {
  name                 = "${var.prefix}-vm02-ext"
  location             = data.azurerm_resource_group.main.location
  resource_group_name  = data.azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5vm02ext
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.vm02selfpip.id
  }

  ip_configuration {
    name                          = "secondary1"
    subnet_id                     = data.azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5privatevip
  }

  ip_configuration {
    name                          = "secondary2"
    subnet_id                     = data.azurerm_subnet.external.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.f5publicvip
    public_ip_address_id          = azurerm_public_ip.pubvippip.id
  }

  tags = {
    Name                      = "${var.environment}-vm02-ext"
    environment               = var.environment
    owner                     = var.owner
    group                     = var.group
    costcenter                = var.costcenter
    application               = var.application
    f5_cloud_failover_label   = var.f5_cloud_failover_label
    f5_cloud_failover_nic_map = var.f5_cloud_failover_nic_map
  }
}

# Create NIC for Internal
resource "azurerm_network_interface" "vm01-int-nic" {
  name                 = "${var.prefix}-vm01-int"
  location             = data.azurerm_resource_group.main.location
  resource_group_name  = data.azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = data.azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Name        = "${var.environment}-vm01-int"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

resource "azurerm_network_interface" "vm02-int-nic" {
  name                 = "${var.prefix}-vm02-int"
  location             = data.azurerm_resource_group.main.location
  resource_group_name  = data.azurerm_resource_group.main.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

  ip_configuration {
    name                          = "secondary"
    subnet_id                     = data.azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Name        = "${var.environment}-vm02-int"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}


# Setup Onboarding scripts
locals {
  f5_onboard1 = templatefile("${path.module}/f5_onboard.tmpl", {
    INIT_URL                = var.INIT_URL
    DO_URL                  = var.DO_URL
    AS3_URL                 = var.AS3_URL
    TS_URL                  = var.TS_URL
    CFE_URL                 = var.CFE_URL
    FAST_URL                = var.FAST_URL
    DO_VER                  = split("/", var.DO_URL)[7]
    AS3_VER                 = split("/", var.AS3_URL)[7]
    TS_VER                  = split("/", var.TS_URL)[7]
    CFE_VER                 = split("/", var.CFE_URL)[7]
    FAST_VER                = split("/", var.FAST_URL)[7]
    f5_username             = var.uname
    f5_password             = var.upassword
    ssh_keypair             = var.ssh_key
    law_id                  = azurerm_log_analytics_workspace.law.workspace_id
    law_primkey             = azurerm_log_analytics_workspace.law.primary_shared_key
    f5_cloud_failover_label = var.f5_cloud_failover_label
    local_selfip            = var.f5vm01ext
    remote_selfip           = var.f5vm02ext
    mgmt_gw                 = var.mgmt_gw
    gateway                 = var.ext_gw
    regKey                  = var.license1
    local_host              = var.host1_name
    host1                   = var.host1_name
    host2                   = var.host2_name
    managed_route           = var.managed_route
    bigIqLicenseType        = var.bigIqLicenseType
    bigIqHost               = var.bigIqHost
    bigIqPassword           = var.bigIqPassword
    bigIqUsername           = var.bigIqUsername
    bigIqLicensePool        = var.bigIqLicensePool
    bigIqSkuKeyword1        = var.bigIqSkuKeyword1
    bigIqSkuKeyword2        = var.bigIqSkuKeyword2
    bigIqUnitOfMeasure      = var.bigIqUnitOfMeasure
    bigIqHypervisor         = var.bigIqHypervisor
  })
  f5_onboard2 = templatefile("${path.module}/f5_onboard.tmpl", {
    INIT_URL                = var.INIT_URL
    DO_URL                  = var.DO_URL
    AS3_URL                 = var.AS3_URL
    TS_URL                  = var.TS_URL
    CFE_URL                 = var.CFE_URL
    FAST_URL                = var.FAST_URL
    DO_VER                  = split("/", var.DO_URL)[7]
    AS3_VER                 = split("/", var.AS3_URL)[7]
    TS_VER                  = split("/", var.TS_URL)[7]
    CFE_VER                 = split("/", var.CFE_URL)[7]
    FAST_VER                = split("/", var.FAST_URL)[7]
    f5_username             = var.uname
    f5_password             = var.upassword
    ssh_keypair             = var.ssh_key
    law_id                  = azurerm_log_analytics_workspace.law.workspace_id
    law_primkey             = azurerm_log_analytics_workspace.law.primary_shared_key
    f5_cloud_failover_label = var.f5_cloud_failover_label
    local_selfip            = var.f5vm02ext
    remote_selfip           = var.f5vm01ext
    dns_server              = var.dns_server
    ntp_server              = var.ntp_server
    timezone                = var.timezone
    mgmt_gw                 = var.mgmt_gw
    gateway                 = var.ext_gw
    regKey                  = var.license2
    local_host              = var.host2_name
    host1                   = var.host1_name
    host2                   = var.host2_name
    managed_route           = var.managed_route
    bigIqLicenseType        = var.bigIqLicenseType
    bigIqHost               = var.bigIqHost
    bigIqPassword           = var.bigIqPassword
    bigIqUsername           = var.bigIqUsername
    bigIqLicensePool        = var.bigIqLicensePool
    bigIqSkuKeyword1        = var.bigIqSkuKeyword1
    bigIqSkuKeyword2        = var.bigIqSkuKeyword2
    bigIqUnitOfMeasure      = var.bigIqUnitOfMeasure
    bigIqHypervisor         = var.bigIqHypervisor
  })
}


data "template_file" "vm01_do_json" {
  template = file("${path.module}/do.json")

  vars = {
    regKey         = var.license1
    host1          = var.host1_name
    host2          = var.host2_name
    local_host     = var.host1_name
    local_selfip   = var.f5vm01ext
    remote_selfip  = var.f5vm02ext
    gateway        = var.ext_gw
    dns_server     = var.dns_server
    ntp_server     = var.ntp_server
    timezone       = var.timezone
    admin_user     = var.uname
    admin_password = var.upassword
  }
}

data "template_file" "vm02_do_json" {
  template = file("${path.module}/do.json")

  vars = {
    regKey         = var.license2
    host1          = var.host1_name
    host2          = var.host2_name
    local_host     = var.host2_name
    local_selfip   = var.f5vm02ext
    remote_selfip  = var.f5vm01ext
    gateway        = var.ext_gw
    dns_server     = var.dns_server
    ntp_server     = var.ntp_server
    timezone       = var.timezone
    admin_user     = var.uname
    admin_password = var.upassword
  }
}

data "template_file" "as3_json" {
  template = file("${path.module}/as3.json")

  vars = {
    rg_name         = data.azurerm_resource_group.main.name
    subscription_id = var.sp_subscription_id
    tenant_id       = var.sp_tenant_id
    client_id       = var.sp_client_id
    client_secret   = var.sp_client_secret
    backendvm_ip    = var.backend01ext
    publicvip       = var.f5publicvip
    privatevip      = var.f5privatevip
  }
}

data "template_file" "ts_json" {
  template = file("${path.module}/ts.json")

  vars = {
    region      = var.location
    law_id      = azurerm_log_analytics_workspace.law.workspace_id
    law_primkey = azurerm_log_analytics_workspace.law.primary_shared_key
  }
}

data "template_file" "failover_json" {
  template = file("${path.module}/failover.json")

  vars = {
    f5_cloud_failover_label = var.f5_cloud_failover_label
    managed_route           = var.managed_route
    local_selfip            = var.f5vm02ext
    remote_selfip           = var.f5vm01ext
  }
}

# Create F5 BIG-IP VMs
resource "azurerm_linux_virtual_machine" "f5vm01" {
  name                            = "${var.prefix}-f5vm01"
  location                        = data.azurerm_resource_group.main.location
  resource_group_name             = data.azurerm_resource_group.main.name
  zone                            = 1
  network_interface_ids           = [azurerm_network_interface.vm01-mgmt-nic.id, azurerm_network_interface.vm01-ext-nic.id, azurerm_network_interface.vm01-int-nic.id]
  size                            = var.instance_type
  admin_username                  = var.uname
  admin_password                  = var.upassword
  disable_password_authentication = false
  computer_name                   = "${var.prefix}vm01"
  custom_data                     = base64encode(local.f5_onboard1)

  admin_ssh_key {
    username   = var.uname
    public_key = var.ssh_key
  }

  os_disk {
    name                 = "${var.prefix}vm01-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "f5-networks"
    offer     = var.product
    sku       = var.image_name
    version   = var.bigip_version
  }

  plan {
    name      = var.image_name
    publisher = "f5-networks"
    product   = var.product
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.main.primary_blob_endpoint
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Name        = "${var.environment}-f5vm01"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

resource "azurerm_linux_virtual_machine" "f5vm02" {
  name                            = "${var.prefix}-f5vm02"
  location                        = data.azurerm_resource_group.main.location
  resource_group_name             = data.azurerm_resource_group.main.name
  zone                            = 2
  network_interface_ids           = [azurerm_network_interface.vm02-mgmt-nic.id, azurerm_network_interface.vm02-ext-nic.id, azurerm_network_interface.vm02-int-nic.id]
  size                            = var.instance_type
  admin_username                  = var.uname
  admin_password                  = var.upassword
  disable_password_authentication = false
  computer_name                   = "${var.prefix}vm02"
  custom_data                     = base64encode(local.f5_onboard2)

  os_disk {
    name                 = "${var.prefix}vm02-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "f5-networks"
    offer     = var.product
    sku       = var.image_name
    version   = var.bigip_version
  }

  plan {
    name      = var.image_name
    publisher = "f5-networks"
    product   = var.product
  }

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.main.primary_blob_endpoint
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Name        = "${var.environment}-f5vm02"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

# Configure VMs to use a system-assigned managed identity
resource "azurerm_role_assignment" "f5vm01ra" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = lookup(azurerm_linux_virtual_machine.f5vm01.identity[0], "principal_id")
}

resource "azurerm_role_assignment" "f5vm02ra" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = lookup(azurerm_linux_virtual_machine.f5vm02.identity[0], "principal_id")
}

# Run Startup Script
resource "azurerm_virtual_machine_extension" "f5vm01-run-startup-cmd" {
  name                 = "${var.environment}-f5vm01-run-startup-cmd"
  virtual_machine_id   = azurerm_linux_virtual_machine.f5vm01.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash /var/lib/waagent/CustomData; exit 0;"
    }
  SETTINGS

  tags = {
    Name        = "${var.environment}-f5vm01-startup-cmd"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}

resource "azurerm_virtual_machine_extension" "f5vm02-run-startup-cmd" {
  name                 = "${var.environment}-f5vm02-run-startup-cmd"
  virtual_machine_id   = azurerm_linux_virtual_machine.f5vm02.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "bash /var/lib/waagent/CustomData; exit 0;"
    }
  SETTINGS

  tags = {
    Name        = "${var.environment}-f5vm02-startup-cmd"
    environment = var.environment
    owner       = var.owner
    group       = var.group
    costcenter  = var.costcenter
    application = var.application
  }
}
