locals {
  nacl_config = {
    for nacl_name, config in var.nacl_config : nacl_name => {
      subnet_indexes = try(config.subnet_indexes, [])
      ingress_rules  = config.ingress_rules
      egress_rules   = config.egress_rules
    }
  }

  nacl_association_map = var.create_nacl ? merge(
    [
      for nacl_name, cfg in local.nacl_config : {
        for i, subnet_index in cfg.subnet_indexes : "${nacl_name}-${i}" => {
          nacl_name = nacl_name
          index     = subnet_index
        }
      }
    ]...
  ) : {}
}

