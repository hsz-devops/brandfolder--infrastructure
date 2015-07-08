# Cluster Size
variable "counts" {
    default = {
      production_workers = 3
      feature_workers = 1
      routers = 3
      core = 5

      # Must update `var.subnet_azs` to match
      subnets = 3
    }
}

# Instance Settings
variable "instance_types" {
    default = {
      bastion = "t2.small"
      production_worker = "r3.xlarge"
      feature_worker = "r3.large"
      core = "r3.large"
      database = "db.r3.xlarge"
      redis = "cache.m3.large"
      router = "c3.large"
    }
}

variable "fleet_tags" {
  default = {
    core = "type=core,function=deis"
    production_worker = "type=worker,environment=production,function=deis"
    feature_worker = "type=worker,environment=feature,function=deis"
    bastion = "type=bastion"
    router = "type=router,function=deis"
  }
}

# AMI Table
variable "amis" {
    default = {
      coreos_633_1_0 = "ami-d2033bba" # Keep for the core machines
      coreos_717_1_0 = "ami-9f5894f4" # Latest core-os stable distribution
    }
}

# Subnets
variable "subnet_azs" {
    default = {
      subnet0 = "a"
      subnet1 = "c"
      subnet2 = "d"
    }
}