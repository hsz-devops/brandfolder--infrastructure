# Brandfolder Infrastructure

## Introduction

As [Brandfolder](https://brandfolder.com) grew, it saw the need to move away from Heroku and onto a more stable, secure, scalable, and affordable infrastructure. 

One of our core values at Brandfolder speaks to elegance, so we felt as though our technology needed to reflect that as much as our product does. As an end user of Brandfolder, its simplicity makes your job easier. This is only possible due to Brandfolder's ability to rapidly iterate and ship code in order to refine the best experience. This same simplicity is what is required in order to make Brandfolder's developers easy enough to keep a fast pace. We are excited to say that our infrastructure has done just that. It has delivered a easily configurable and almost no touch maintenance that allows developers to remain working at an incredible pace. 

We love what we have done and think that other companies can benefit from the work we have done. In addition, we feel as though being transparent with our clients will give them the peace of mind that we have built a platform that is secure, stable, and scalable to a factor that meets or exceeds their expectations. Therefore, Brandfolder's infrastructure in its entirety is **open source**.

## Attributions

The elegance of Brandfolder's infrastructure could not have been possible without these amazing tools.

| Powered By Deis (PaaS) | Managed With Terraform (IaC) | Provided By AWS (IaaS) |
|:-------------:|:-------------:|:-----:|
| [![Deis](https://brandfolder.com/brandfolder-infrastructure/assets/yf0vtwt0)](http://deis.io) | [![Terraform](https://brandfolder.com/brandfolder-infrastructure/assets/ak6pnrtw)](https://terraform.io) | [![AWS](https://brandfolder.com/brandfolder-infrastructure/assets/a70ln6en)](https://aws.amazon.com)

## Server Locations

![Map](https://brandfolder.com/brandfolder-infrastructure/attachments/h75claxg/brandfolder-infrastructure-infra-locations-map-image.png?dl=true)

### Origin
Brandfolder's Origin is deployed in the AWS East Region, located in Virginia, USA. Any action that requires a "write" action must be done on the origin, therefore all write traffic must be routed to the origin in Virginia.

### Asset Edge
Assets are served from the asset edge upon subsequent requests from users closest to each edge location. Therefore, the first request for each asset in each location will take longer than subsequent requests for that asset.

## Infrastructure Diagram

View the [infrastructure diagram](diagram.asci).

## The Tech Stack

Brandfolders infrastructure is built on a number of technologies that will be good to understand before developing/forking the configuration.

* [Deis](https://deis.io) - Deis is an Open Source Platform-as-a-Service that makes deployment and configuration of applications quick and easy for the development team.
* [Amazon AWS](https://aws.amazon.com) - Amazon AWS is an Infrastructure-as-a-Service that allows Brandfolder to easily provision hardware on demand. Ultimately, the infrastructure would not be possible without the hardware to run it on.
* [Terraform](https://terraform.io) - In this project you will see almost nothing by `.tf` files. These files are code that define our infrastructure. Terraform takes the pain out of managing infrastructure and allows for teams to spend more time on developing applications.
* [Docker](https://docker.com) - Docker is at the root of everything at Brandfolder it is used all the way up from development to production. Docker ultimately allows for our applications and services to run into isolated containers.
* [Core OS](https://coreos.com) - CoreOS is the operation system that runs Brandfolder's Servers. Core OS was designed to run and manage docker containers in a clusterd environment. Some of the other benefits of the OS also allow for very low touch management and administration.
* [etcd](https://github.com/coreos/etcd) - etcd, a component of Core OS maintains the configuration for everything in the cluster. It is a consistent, highly available, fault tolerant data store.
* [fleet](https://github.com/coreos/fleet) - fleet, a component of Core OS is a cluster-wide scheduling system that allows us to run services and applications anywhere according to a central set of rules and tags set within etcd. 
* [flannel](https://github.com/coreos/flannel) - flannel, a component of Core OS, is the networking mesh that allows all the containers in the cluster to speak to each other without having to allocate ports on the primary docker hosts.
* [SkyDNS](https://github.com/skynetservices/skydns) - SkyDNS is a DNS system built on top of etcd for the purpose of services discovery. As services and applications in the cluster move from server to server, SkyDNS provides a single hostname in which to access them.

## Security Model

### Cluster Access

#### SSH Access

SSH Access to the cluster is only provided via a [Bastion Host](https://en.wikipedia.org/wiki/Bastion_host). The bastion host only exposes port 22 for SSH an requires a public-key belonging to the "bastion" team in github. Once within the bastion host, users have full access to rest of the cluster.

The "bastion-master" key, that provides root access to the bastion machine is under lock and key and only accessible by the CTO of Brandfolder.

#### Security Patches

See [System Updates](#system-updates)

## Clustering

There are 3 primary components of Brandfolder. Each of which is designed to scale (or not to scale) indepedently. All components are deployed to 3 [availability zones](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html) to ensure fault-tolerance.

### The Core

The core is comprised of exactly and always 5 [Core OS](https://coreos.com/) machines. The core runs the PaaS controller, the App Builder and the App Registry as Services. The core is the MOST STABLE piece of the platform. It's primary function is to keep consensus of at least 3 machines in order provide [etcd](https://github.com/coreos/etcd) as a key-value store for cluster wide configuration.

### The Workers

Workers are auto scaling components that host running applications. They can scale up or down on demand and be cycled without damaging cluster availability. When applications are online they publish the workers IP and the containers listening port to etcd in order for the routers to consume.

### The Routers

Routers send incoming traffic to the correct workers or core components. They read configuration from etcd and route the incoming traffic to the proper container within the core.

## System Updates

All of the machines automatically update to the stable channel of [Core OS](https://coreos.com/). This is a core feature of the operating system and offers Brandfolder no-touch up-to-date patches for security and new features.

## Networking

Networking within the cluster is done via 2 primary channels.

### Host-to-Host networking

Hosts must communicate with each other in order for services such as etcd, flannel and SkyDNS to communicate properly. In addition to core services, due to a limitation of Deis, the application containers communicate with the routers via host networking instead of container networking.

### Container-to-Container Networking

When containers have to access core services such as databases or cache servers, they communicate over the [flannel](https://github.com/coreos/flannel) container overlay network. This network does not communicate with the host network and encapsulates traffic between containers in a secure manner.

## Auto Scaling

Certain utilization events on the routers and workers trigger actions to scale up the machines until the utilization has subsided and the servers scale down.

## Developing on Brandfolder's Infrastructure

**Prerequisites:**

* Install Terraform
* Sign up for [Atlas](https://atlas.hashicorp.com/) and get invited to the Brandfolder organization.
* Find your Atlas API access key, you will need it next.
* Run the following command:
  `terraform remote config -backend-config="access_token={{Atlas Access Key}}" -backend-config="name=brandfolder/infrastructure"`
* (Optional) Set your environment variables to include
  ```
  export AWS_ACCESS_KEY_ID={{Your AWS Access Key}}
  export AWS_SECRET_ACCESS_KEY={{Your AWS Secret Access Key}}
  ```

**Usage:**

1. Make the changes in project.
1. View Planned Changes
  `make plan`
1. Commit the Changes
  `git add -a`
  `git commit -m "commit message`
1. Apply the Changes
  `make apply`
