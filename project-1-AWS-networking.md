---
icon: network-wired
description: >-
  Project to build two VPCs connected via a peering connection with static
  routes, using Terraform.
---

# Project 1 - AWS Networking

The goal of this project is to establish two AWS VPCs with a static route between them across a peering connection.&#x20;

The project will be successful if EC2 instances located in each VPC are able to ping one another across the static route.&#x20;

The purpose of the project is to practice using Terraform to create IAC environments, as well as practicing configuring networking features in AWS.&#x20;

Below you will see the network diagram for the end state of the project. The connection to the internet at large is purely for SSH connections in to the EC2 instances, as the goal of the project will be for the EC2 instances to ping each other via private IP addresses.&#x20;

<figure><img src=".gitbook/assets/AWS TEST VPC1-VPC2 Connection.drawio.png" alt=""><figcaption><p>Fig 1. Network diagram of proposed project.</p></figcaption></figure>

Below is the Terraform code for the implementation of this project. This code is not optimized with variables. Variables will be applied on a future project.&#x20;

{% @github-files/github-code-block url="https://github.com/gus-young/AWS-Projects/blob/19bc57374cfd8987c8b2f1deb4c7db41988c9c55/project_1.tf" %}
