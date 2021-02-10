---
title: kubernetes documentation roadmap
date: 2018-12-23T23:02:13-05:00
---


# <a href="https://kubernetes.io/docs/setup/">Setup</a>

## Picking the Right Solution
  - local-machine: minikube, minishift, microk8s, 4 multi-node options
  - hosted: (lol all sound the same). familiar: gke, aws, azure, oracle
  - turnkey cloud: (20 options, like Alibaba, AWS, Azure, GCE, IBM, Oracle
  - on-prem turnkey cloud: meh
  - custom: snooze


## Downloading Kubernetes
|section|notes|
|---|---|
|Building from Source|look how easy, but don't do this unless dev'ing k8s itself
|v1.13 Release Notes|HEAVY READING

## Bootstrapping Clusters with kubeadm
_(NOTE: this whole table is N/A as we're not tryna be operators rn.)_

|section|notes|
|---|---|
|Installing kubeadm|
|Creating a single master cluster with kubeadm|
|Customizing control plane configuration with kubeadm|
|Options for Highly Available Topology|
|Creating Highly Available Clusters with kubeadm|
|Set up a High Availability etcd cluster with kubeadm|
|Configuring each kubelet in your cluster using kubeadm|
|Troubleshooting kubeadm|

## Turnkey Cloud Solutions
_(NOTE: we'll skip all but the AWS one and the GCE one for now.)_

|section|notes|
|---|---|
|Running Kubernetes on AWS EC2|you like this "guestbook" example #come-back
|Running Kubernetes on Alibaba Cloud|
|Running Kubernetes on Azure|
|Running Kubernetes on CenturyLink Cloud|
|Running Kubernetes on Google Compute Engine|
|Running Kubernetes on Multiple Clouds with Stackpoint.io|

## Custom Cloud Solutions
_(skimmed)_

|section|notes|
|---|---|
|CoreOS on AWS or GCE|
|Installing Kubernetes On-premises/Cloud Providers with Kubespray|
|Installing Kubernetes on AWS with kops|

## On-Premises VMs
_(skimmed each page. no idea what anything meant.)_

|section|notes|
|---|---|
|Cloudstack|
|Kubernetes on DC/OS|
|oVirt|

## Kubernetes Version and Version Skew Support Policy

  - _(out of scope to us for now)_

## Building Large Clusters

  - _(N/A to us)_

## Running in Multiple Zones

  - _(skip)_

## CRI installation

  - _(I don't think I need to know what this is yet.)_

## Creating a Custom Cluster from Scratch

  - _(HEAVY READING. skip for now as likely N/A)_

## Installing Kubernetes with Digital Rebar Provision (DRP) via KRIB

  - _(skip)_

## PKI Certificates and Requirements

  - _(skip)_

## Running Kubernetes Locally via Minikube

  - alternative container runtimes (really?)
  - thing about "which speeds up local experiments"
  - \#TYPO: says "`docker-env command`" should be "`docker-env` command"
  - summary: #come-back we want to understand `#use-local-images-by-re-using-the-docker-daemon`

## Validate Node Setup

  - skimmed. #come-back to this later


# <a href="https://kubernetes.io/docs/concepts/">Concepts</a>

## Overview
|section|notes|
|---|---|
|What is Kubernetes?|
|Kubernetes Components|
|The Kubernetes API|

## Overview - Working with Kubernetes Objects
|section|notes|
|---|---|
|Understanding Kubernetes Objects|
|Names|
|Namespaces|
|Labels and Selectors|
|Annotations|
|Field Selectors|
|Recommended Labels|

## Overview - Object Management Using kubectl
|section|notes|
|---|---|
|Kubernetes Object Management|
|Managing Kubernetes Objects Using Imperative Commands|
|Imperative Management of Kubernetes Objects Using Configuration Files|
|Declarative Management of Kubernetes Objects Using Configuration Files|

## Kubernetes Architecture
|section|notes|
|---|---|
|Nodes|
|Master-Node communication|
|Concepts Underlying the Cloud Controller Manager|

## Containers
|section|notes|
|---|---|
|Images|
|Container Environment Variables|
|Runtime Class|
|Container Lifecycle Hooks|

## Workloads

## Workloads - Pods
|section|notes|
|---|---|
|Pod Overview|
|Pods|
|Pod Lifecycle|
|Init Containers|
|Pod Preset|
|Disruptions|

## Workloads - Controllers
|section|notes|
|---|---|
|ReplicaSet|
|ReplicationController|
|Deployments|
|StatefulSets|
|DaemonSet|
|Garbage Collection|
|TTL Controller for Finished Resources|
|Jobs - Run to Completion|
|CronJob|

## Services, Load Balancing, and Networking
|section|notes|
|---|---|
|Services|
|DNS for Services and Pods|
|Connecting Applications with Services|
|Ingress|
|Network Policies|
|Adding entries to Pod /etc/hosts with HostAliases|

## Storage
|section|notes|
|---|---|
|Volumes|
|Persistent Volumes|
|Volume Snapshots|
|Storage Classes|
|Volume Snapshot Classes|
|Dynamic Volume Provisioning|
|Node-specific Volume Limits|

## Configuration
|section|notes|
|---|---|
|Configuration Best Practices|
|Managing Compute Resources for Containers|
|Assigning Pods to Nodes|
|Taints and Tolerations|
|Secrets|
|Organizing Cluster Access Using kubeconfig Files|
|Pod Priority and Preemption|
|Scheduler Performance Tuning|

## Policies
|section|notes|
|---|---|
|Resource Quotas|
|Pod Security Policies|

## Cluster Administration
|section|notes|
|---|---|
|Cluster Administration Overview|
|Certificates|
|Cloud Providers|
|Managing Resources|
|Cluster Networking|
|Logging Architecture|
|Configuring kubelet Garbage Collection|
|Federation|
|Proxies in Kubernetes|
|Controller manager metrics|
|Installing Addons|

## Extending Kubernetes
|section|notes|
|---|---|
|Extending your Kubernetes Cluster|

## Extending Kubernetes - Extending the Kubernetes API
|section|notes|
|---|---|
|Extending the Kubernetes API with the aggregation layer|
|Custom Resources|

## Extending Kubernetes - Compute, Storage, and Networking Extensions
|section|notes|
|---|---|
|Network Plugins|
|Device Plugins|
|Service Catalog|


# <a href="https://kubernetes.io/docs/tasks/">Tasks</a>

## Install Tools
|section|notes|
|---|---|
|Install and Set Up kubectl|
|Install Minikube|

## Configure Pods and Containers
|section|notes|
|---|---|
|Assign Memory Resources to Containers and Pods|
|Assign CPU Resources to Containers and Pods|
|Configure Quality of Service for Pods|
|Assign Extended Resources to a Container|
|Configure a Pod to Use a Volume for Storage|
|Configure a Pod to Use a PersistentVolume for Storage|
|Configure a Pod to Use a Projected Volume for Storage|
|Configure a Security Context for a Pod or Container|
|Configure Service Accounts for Pods|
|Pull an Image from a Private Registry|
|Configure Liveness and Readiness Probes|
|Assign Pods to Nodes|
|Configure Pod Initialization|
|Attach Handlers to Container Lifecycle Events|
|Configure a Pod to Use a ConfigMap|
|Share Process Namespace between Containers in a Pod|
|Translate a Docker Compose File to Kubernetes Resources|

## Administer a Cluster

## Administer a Cluster - Administration with kubeadm
|section|notes|
|---|---|
|Certificate Management with kubeadm|
|Upgrading kubeadm HA clusters from v1.11 to v1.12|
|Upgrading kubeadm HA clusters from v1.12 to v1.13|
|Upgrading kubeadm clusters from v1.10 to v1.11|
|Upgrading kubeadm clusters from v1.11 to v1.12|
|Upgrading kubeadm clusters from v1.12 to v1.13|

## Administer a Cluster - Manage Memory, CPU, and API Resources
|section|notes|
|---|---|
|Configure Default Memory Requests and Limits for a Namespace|
|Configure Default CPU Requests and Limits for a Namespace|
|Configure Minimum and Maximum Memory Constraints for a Namespace|
|Configure Minimum and Maximum CPU Constraints for a Namespace|
|Configure Memory and CPU Quotas for a Namespace|
|Configure a Pod Quota for a Namespace|

## Administer a Cluster - Install a Network Policy Provider
|section|notes|
|---|---|
|Use Calico for NetworkPolicy|
|Use Cilium for NetworkPolicy|
|Use Kube-router for NetworkPolicy|
|Romana for NetworkPolicy|
|Weave Net for NetworkPolicy|
|Access Clusters Using the Kubernetes API|
|Access Services Running on Clusters|
|Advertise Extended Resources for a Node|
|Autoscale the DNS Service in a Cluster|
|Change the Reclaim Policy of a PersistentVolume|
|Change the default StorageClass|
|Cluster Management|
|Configure Multiple Schedulers|
|Configure Out Of Resource Handling|
|Configure Quotas for API Objects|
|Control CPU Management Policies on the Node|
|Customizing DNS Service|
|Debugging DNS Resolution|
|Declare Network Policy|
|Developing Cloud Controller Manager|
|Encrypting Secret Data at Rest|
|Guaranteed Scheduling For Critical Add-On Pods|
|IP Masquerade Agent User Guide|
|Kubernetes Cloud Controller Manager|
|Limit Storage Consumption|
|Namespaces Walkthrough|
|Operating etcd clusters for Kubernetes|
|Reconfigure a Node's Kubelet in a Live Cluster|
|Reserve Compute Resources for System Daemons|
|Safely Drain a Node while Respecting Application SLOs|
|Securing a Cluster|
|Set Kubelet parameters via a config file|
|Set up High-Availability Kubernetes Masters|
|Share a Cluster with Namespaces|
|Static Pods|
|Storage Object in Use Protection|
|Using CoreDNS for Service Discovery|
|Using a KMS provider for data encryption|
|Using sysctls in a Kubernetes Cluster|

## Inject Data Into Applications
|section|notes|
|---|---|
|Define a Command and Arguments for a Container|
|Define Environment Variables for a Container|
|Expose Pod Information to Containers Through Environment Variables|
|Expose Pod Information to Containers Through Files|
|Distribute Credentials Securely Using Secrets|
|Inject Information into Pods Using a PodPreset|

## Run Applications
|section|notes|
|---|---|
|Run a Stateless Application Using a Deployment|
|Run a Single-Instance Stateful Application|
|Run a Replicated Stateful Application|
|Update API Objects in Place Using kubectl patch|
|Scale a StatefulSet|
|Delete a StatefulSet|
|Force Delete StatefulSet Pods|
|Perform Rolling Update Using a Replication Controller|
|Horizontal Pod Autoscaler|
|Horizontal Pod Autoscaler Walkthrough|
|Specifying a Disruption Budget for your Application|

## Run Jobs
|section|notes|
|---|---|
|Running Automated Tasks with a CronJob|
|Parallel Processing using Expansions|
|Coarse Parallel Processing Using a Work Queue|
|Fine Parallel Processing Using a Work Queue|

## Access Applications in a Cluster
|section|notes|
|---|---|
|Web UI (Dashboard)|
|Accessing Clusters|
|Configure Access to Multiple Clusters|
|Use Port Forwarding to Access Applications in a Cluster|
|Use a Service to Access an Application in a Cluster|
|Connect a Front End to a Back End Using a Service|
|Create an External Load Balancer|
|Configure Your Cloud Provider's Firewalls|
|List All Container Images Running in a Cluster|
|Communicate Between Containers in the Same Pod Using a Shared Volume|
|Configure DNS for a Cluster|

## Monitor, Log, and Debug
|section|notes|
|---|---|
|Application Introspection and Debugging|
|Auditing|
|Core metrics pipeline|
|Debug Init Containers|
|Debug Pods and ReplicationControllers|
|Debug Services|
|Debug a StatefulSet|
|Debugging Kubernetes nodes with crictl|
|Determine the Reason for Pod Failure|
|Developing and debugging services locally|
|Events in Stackdriver|
|Get a Shell to a Running Container|
|Logging Using Elasticsearch and Kibana|
|Logging Using Stackdriver|
|Monitor Node Health|
|Tools for Monitoring Resources|
|Troubleshoot Applications|
|Troubleshoot Clusters|
|Troubleshooting|

## Extend Kubernetes

## Extend Kubernetes - Use Custom Resources
|section|notes|
|---|---|
|Extend the Kubernetes API with CustomResourceDefinitions|
|Versions of CustomResourceDefinitions|
|Configure the Aggregation Layer|
|Setup an Extension API Server|
|Use an HTTP Proxy to Access the Kubernetes API|

## TLS
|section|notes|
|---|---|
|Certificate Rotation|
|Manage TLS Certificates in a Cluster|

## Federation - Run an App on Multiple Clusters
|section|notes|
|---|---|
|Cross-cluster Service Discovery using Federated Services|
|Set up Cluster Federation with Kubefed|
|Set up CoreDNS as DNS provider for Cluster Federation|
|Set up placement policies in Federation|

## Manage Cluster Daemons
|section|notes|
|---|---|
|Perform a Rollback on a DaemonSet|
|Perform a Rolling Update on a DaemonSet|

## Install Service Catalog
|section|notes|
|---|---|
|Install Service Catalog using Helm|
|Install Service Catalog using SC|

## Federation - Run an App on Multiple Clusters
|section|notes|
|---|---|
|Federated Cluster|
|Federated ConfigMap|
|Federated DaemonSet|
|Federated Deployment|
|Federated Events|
|Federated Horizontal Pod Autoscalers (HPA)|
|Federated Ingress|
|Federated Jobs|
|Federated Namespaces|
|Federated ReplicaSets|
|Federated Secrets|

## Extend kubectl with plugins

## Manage HugePages

## Schedule GPUs


# <a href="https://kubernetes.io/docs/tutorials/">Tutorials</a>

## Hello Minikube

## Learn Kubernetes Basics
|section|notes|
|---|---|
|Learn Kubernetes Basics|

## Learn Kubernetes Basics - Create a Cluster
|section|notes|
|---|---|
|Using Minikube to Create a Cluster|
|Interactive Tutorial - Creating a Cluster|

## Learn Kubernetes Basics - Deploy an App
|section|notes|
|---|---|
|Using kubectl to Create a Deployment|
|Interactive Tutorial - Deploying an App|

## Learn Kubernetes Basics - Explore Your App
|section|notes|
|---|---|
|Viewing Pods and Nodes|
|Interactive Tutorial - Exploring Your App|

## Learn Kubernetes Basics - Expose Your App Publicly
|section|notes|
|---|---|
|Using a Service to Expose Your App|
|Interactive Tutorial - Exposing Your App|

## Learn Kubernetes Basics - Scale Your App
|section|notes|
|---|---|
|Running Multiple Instances of Your App|
|Interactive Tutorial - Scaling Your App|

## Learn Kubernetes Basics - Update Your App
|section|notes|
|---|---|
|Performing a Rolling Update|
|Interactive Tutorial - Updating Your App|

## Online Training Courses
|section|notes|
|---|---|
|Overview of Kubernetes Online Training|

## Configuration
|section|notes|
|---|---|
|Configuring Redis using a ConfigMap|

## Stateless Applications
|section|notes|
|---|---|
|Exposing an External IP Address to Access an Application in a Cluster|
|Example: Deploying PHP Guestbook application with Redis|

## Stateful Applications
|section|notes|
|---|---|
|StatefulSet Basics|
|Example: Deploying WordPress and MySQL with Persistent Volumes|
|Example: Deploying Cassandra with Stateful Sets|
|Running ZooKeeper, A Distributed System Coordinator|

## Clusters
|section|notes|
|---|---|
|AppArmor|

## Services
|section|notes|
|---|---|
|Using Source IP|




## (document-meta)

  - #born.
