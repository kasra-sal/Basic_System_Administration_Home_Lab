# Basic_System_Administration_Home_Lab

Microsoft's Active Directory provides a powerful tool for centralized management of user accounts, computer systems and such resources in a Windows-based network environment. This project will focus on setting up Active Directory on a Windows Server virtual machine, configuring organizational units, automating user addition, using group policies to install applications on each PC, and connecting the managed PCs and accounts to Splunk server previously made on my [splunk server repo](https://github.com/kasra-sal/Splunk-Environment-Setup.git) using Splunk Universal Forwarder.

## What Should I take Away From This Project?
One of the most important things about this project is setting basic policies and automating processes to reduce the likelyhood of human error while configuring these services. I have provided a step-by-step procedure on how to configure and utilize basic system administration configurations, best practices and basic approach to Active Directory services.

There are a couple things worth mentioning about this project:

1. This project is intended to be a "bone structure" for future projects that I am working on. However it is sufficient enough to create a general idea of how a small business would function using basic AD.
2. There will be a basic demonstration of tools such as AD DS, GPOs, RAS and DHCP however they are done in a way that if you want to scale it up or configure it to your own needs, you could simply follow the steps and reconfigure or edit the script for bette customization of content.
3. I have provided a basic script to add users, however you could also use CSVDE tool to automate aswell if you are not comfortable with the basic powershell script I have provided.
4. A lot of settings and policies are redacted as they are outside of the scope of this project. I will be making more projects that will require such configs.

Enough with the dry text, Following sections should get us started before we move on to configuring this homelab.


## Network Topology

To have a better idea of what I've done in this project, I have made a basic topology of devices, network configurations and general view of how the entire network would look after implementing this project. 

![DeepinScreenshot_select-area_20230321162454](https://user-images.githubusercontent.com/118489496/226732350-c9bce8b7-6a25-407d-b445-6df55625e2ba.png)

# Getting Started

## Prerequisites
- Vmware Workstation or VirtualBox (This project utilizes Vmware)
- Git
- Windows Server 2016/2019 ISO image
- Windows 10/11 ISO image
- Splunk Universal Forwarder Image for Windows server 2016/2019 ISO image
- Splunk Server (Refer to my other [repo](https://github.com/kasra-sal/Splunk-Environment-Setup.git)) 


## Github Installation
Download the github installer from [Github](https://desktop.github.com/) follow the installation steps to install github on your windows server.

Alternatively if you would like to clone the script on a ubuntu sftp server and move the script to the windows server you could use the following commands:
```
git --version 
```
If the output shows git with a version, then skip Git installation section as you already have git installed

If git was not installed, do the following
```
sudo apt-get update; sudo apt-get install git -y
```
## Cloning This Repository
Use the following command to clone this repository
```
git clone https://github.com/kasra-sal/Basic_System_Administration_Home_Lab.git
```

## Gathering The Required ISO Images
To gather the required ISO images, please refer to the following links:
  - Windows Server [2016](https://info.microsoft.com/ww-landing-windows-server-2016.html)/[2019](https://info.microsoft.com/ww-landing-windows-server-2019.html)
  - Windows [10](https://www.microsoft.com/en-ca/software-download/windows10ISO)/[11](https://www.microsoft.com/en-ca/software-download/windows11)
  - [Splunk Universal Forwarder for Windows Server](https://www.splunk.com/en_us/download/universal-forwarder.html)(Create an account if you do not have one already or simply log in) 
