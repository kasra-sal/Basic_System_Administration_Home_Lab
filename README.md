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

## Gathering The Required ISO Images
To gather the required ISO images, please refer to the following links:
  - Windows Server [2016](https://info.microsoft.com/ww-landing-windows-server-2016.html)/[2019](https://info.microsoft.com/ww-landing-windows-server-2019.html)
  - Windows [10](https://www.microsoft.com/en-ca/software-download/windows10ISO)/[11](https://www.microsoft.com/en-ca/software-download/windows11)
  - [Splunk Universal Forwarder] for Windows Server (https://www.splunk.com/en_us/download/universal-forwarder.html)(Create an account if you do not have one already or simply log in) 

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

## Step-By-Step Installation
### Setting up Windows Server
Setting up the Windows Server is a straight forward procedure:
 1. Create a new virtual machine
 2. Choose the ISO image you have previously downloaded
 3. If you are using Vmware, you will be prompted with easy install information; Hence fill in required information and leave the Windows product key box empty.
 4. Give it the location you want the vm to reside in
 5. Allocate sufficient disk size, RAM and cpu cores (Refer to this [article](https://learn.microsoft.com/en-us/windows-server/get-started/hardware-requirements) to find minimum requirements. 
 6. Once the template is done:
 ![3](https://user-images.githubusercontent.com/118489496/227008480-a2aabd3c-32b1-4bcf-83f9-2b54b5cd84eb.gif)
    - Click on "Edit" at the top left corner of vmware tray.
    - Click on "Virtual Network Editor"
    - Click on "Add Network" (On Windows version of vmware, you may require admin permissions)
    - Set "Network name" to vmnet 3 (This could be any number but I have set it as vmnet 3. Refer to the topology {link})
    - Select "Host-only" under "Type".
    - Once you created the network adapter, click on "vmnet3", make sure that you deselect "Use local DHCP service to distribute IP addresses to VMs.
    - Click save.
    - Go back to your virtual machine, click on "Edit Virtual Machine Settings". Under "Hardware" tab click on "add" and add a new adapter.
    - Finally set that adapter as vmnet 3.
7. Launce the virtual machine and install windows server.
  - One thing to note is that if you choose to install any version that doesn't have "Desktop experince" you will not be given a GUI.
![1](https://user-images.githubusercontent.com/118489496/227009173-eb12b163-548b-4629-a127-8af5aedea7a1.gif)

### Setting Up Network Adapters Within Windows Server
This is step is crucial so make sure your addressing is correct. We will be assigning an address to "vmnet3" adapter on windows server for when we configure RAS and NAT for our AD computers.

https://user-images.githubusercontent.com/118489496/227038073-ac232c43-c61e-462a-8303-b9a60a84ad9c.mp4

- To find the adapter options, either right click on network icon on the task bar and click "Open Network and Internet settings" or type "Network and Internet" in your settings and click on "Change Adapter Options".
- Once you have opened up your adapter options, locate the two adapters and browse through their addresses. 
- You could tell which one is your vmnet 3 and which one is your NAT adapter by looking at the ipv4 address within the status page.
- Once you found which one is internal adapter (vmnet3), right click on that adapter and choose "properties"
- double click "Internet Protocol Version 4" and enter information as follow:
  -   IP address : 172.16.0.1 (you could set your own address aslong as it doesn't overlap other addresses)
  -   Subnet mask: 255.255.255.0 (which is a /24 subnet holding up to 254 addresses available to be assigned to hosts)
  -   Leave default gateway empty
  -   Preferred DNS : 172.16.0.1
  -   Alternate DNS : 127.0.0.1
 Once you have changed the addresses, your prompt should look similar to the following picture:
 
![5](https://user-images.githubusercontent.com/118489496/227037635-2bd3686e-c6de-45da-827f-d5f1aafc5349.png)

press "OK" and close adapter options window.

The reason behind this step is to be able to make the windows server a DHCP server aswell as a NAT server so that our AD computers have to go through the server before they can reach the internet. This allows for better control over the devices as well as maintaining security by implementing more security measures that I will showcase on the upcoming projects.

### Active Directory Setup
Next step is to setup active directory. Installing Active Directory Domain Services is very simple:
#### Installing AD DS 
https://user-images.githubusercontent.com/118489496/227043489-9134658b-e620-4cb7-a57a-3b81d75142a6.mp4

1. First Click "Add Roles and Features" on your server manager.
2. On "Before You Begin" page click next
3. On installation type select "Role-based or feature-based installtion".
4. On "Server Selection" page click next. (Note if you have more Domain Controllers you may have to choose the correct one)
5. On "Server Roles" page select "Active Directory Domain Services" and click next.
6. On "Features" page click next.
7. On "AD DS" page click next.
8. On "Confirmation" page click install.
#### Promoting Server to Become a Domain Controller

Once the AD DS installtion is done, you need to promote the server to become a domain controller. 

https://user-images.githubusercontent.com/118489496/227045085-b61cc58e-94ec-4b41-a1ba-705b87b8daba.mp4

1. On "Deployment Configuration" page select "add a new forest". Enter the domain name you want inside "Root domain name" field
2. On "Domain Controller Options" page enter password for DSRM.
3. On "DNS Options" page click next.
4. On "Additional Options" page click next.
5. On "Paths" page click next.
6. On "Review Options" page click next.
7. On "Prerequisites Check" page click install.

#### Domain Admin Creation

It is good security practice to make a second tier admin that has necessary permissions to perform certain actions but restricted to a defined scope. For this reason I made a user named "John Doe" and assigned the role "Domain Admin" to it. 


https://user-images.githubusercontent.com/118489496/227644918-643886e8-2bc5-4d6e-a6fd-8f0f7a921fc4.mp4


To create a new user in your active directory, do the following:
1. Click on tools on the server manager.
2. Select active directory users and computers
3. expand the domain to be able to see OUs within the domain
4. Right click on the doman and choose New > Organizational Unit
5. Type in "Test_Users" and click ok
6. Right click on "Test_Users" OU and choose New > User
7. Type in the following information:
  - First Name: John
  - Last Name: Doe
  - Full Name John Doe
  - User logon name: J-Doe
8. Click next
9. Fill in the password field.
10. (Optional) : I decided to not force my user to change password at the next logon. This results in less flexiblity and security for the user and should be checked everytime. But for the purpose of this lab I decided to not do so.
11. Once you finished creating the user, right click on John Doe and choose properties.
12. Click on Member Of > Add ...
13. Under "Enter the object names to select type "Domain Admin" and click check names.
14. press ok.

Once you restart the server you should be able to login using John Does logon name and password.


https://user-images.githubusercontent.com/118489496/227645021-bbb03c03-c8e6-4847-8726-abb2362963a0.mp4

### Installing and Configuring RAS/NAT 

![DeepinScreenshot_select-area_20230321143326](https://user-images.githubusercontent.com/118489496/227645739-fc9b6614-2c3a-46e7-96b6-01bc9bbdabfc.png)

The intended purpose for these services is to be able to route new computer's traffic through the server. This way we would have more control over the network in return for more overhead. With that being said, I wanted to make the network so that VM "AD Jorb" (Btw I couldn't think of a better name at the time :) ) has to send its traffic through DC1 and then from DC1 the traffic gets relayed to the internet. This process will utilize NAT feature to both increase availibility of addresses on higher tier DHCP aswell as basic anonimity. It's worth noting that this anonimity doesn't protect you against potential threats, however it will only show the server's address rather than individual device addresses.


https://user-images.githubusercontent.com/118489496/227647166-5bb2f116-c3d4-461b-b2a9-5fafa259b11e.mp4


To install RAS do the following:

1. On server manager, click on "add roles and features.
2. On "Before You Begin" page click next.
3. On "Installation Type" page click next.
4. On "Server Selection" page choose your server and click next.
5. On "Server Roles" page, select "Remote Access" and click next.
6. On "Features" page click next.
7. On "Remote Access" page click next.
8. On "Role Services" select "Routing", click "add feature" and click next.
9. On "Confirmation" page click install.

To configure RAS do the following:
1. On server manager, click tools > Routing and Remote Access
2. Right click on your domain controller and click "Configure and Enable Routing and Remote Access"
3. Click Next
4. On "Configuration" page select "Network Address Translation (NAT)" and click Next.
5. On "NAT Internet Connection" select the network interface that is internet facing. To make this easier, it's the adapter that was not manually configured earlier. 
6. On "Completing the Routing and Remote Access Server Setup" Click Finish.


