# Basic_System_Administration_Home_Lab

Microsoft's Active Directory provides a powerful tool for centralized management of user accounts, computer systems and such resources in a Windows-based network environment. This project will focus on setting up Active Directory on a Windows Server virtual machine, configuring organizational units, automating user addition, using group policies to install applications on each PC, and connecting the managed PCs and accounts to Splunk server previously made {link} using Splunk Forwarder.

## Why Use Active Directory?
Active Directory is a very powerful tool. It allows administrators to create and manage accounts, groups, devices and such while providing granular or fine grained control over access management, user permissions and policies across the network surface. This enables administrators to streamline their IT processes, reduce administrative overheads and better secure their networks. Hence Active Directory is an essential tool for any administrators or enterprises looking to elastically scale or optimize their network and system management processes while maintaining and imporving their overall security. 

## What Should I take Away From This Project?
One of the most important things about this project is setting basic policies and automating processes to reduce the likelyhood of human error while configuring these services. I have provided a step-by-step procedure on how to configure and utilize basic system administration configurations, best practices and basic approach to Active Directory services.

There are a couple things worth mentioning about this project:

1. This project is intended to be a "bone structure" for future projects that I am working on.
2. There will be a basic demonstration of tools such as AD DS, GPOs, RAS and DHCP however they are done in a way that if you want to scale it up or configure it to your own needs, you could simply follow the steps and reconfigure or edit the script for auto addition of users.
3. I have provided a basic script to add users, however you could also use CSVDE tool to automate aswell if you are not comfortable with the basic powershell script I have provided.
4. A lot of settings and policies are redacted as they are outside of the scope of this project. I will be making more projects that will require such configs.

Enough with the dry text, Following sections should get us started before we move on to configuring this homelab.


## Network Topology

To have a better idea of what I've done in this project, I have made a basic topology of devices, network configurations and general view of how the entire network would look after implementing this project. 

![DeepinScreenshot_select-area_20230321162454](https://user-images.githubusercontent.com/118489496/226732350-c9bce8b7-6a25-407d-b445-6df55625e2ba.png)

## 

