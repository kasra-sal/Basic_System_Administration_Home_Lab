# Basic_System_Administration_Home_Lab

Microsoft's Active Directory offers centralized management of user accounts, computer systems, and other resources within Windows-based networks. The focus of this project is on setting up Active Directory on a Windows Server virtual machine, configuring organizational units, automating user addition, installing applications on each PC using group policies, and connecting the managed PCs and accounts to a previously established Splunk server on my Splunk server repository through the use of Splunk Universal Forwarder.

The key takeaway from this project is the implementation of basic policies and automated processes to minimize the potential for human error when configuring these services. This project outlines a step-by-step procedure for configuring and utilizing basic system administration configurations, best practices, and a fundamental approach to Active Directory services.

There are several important points to note about this project:

1. It serves as a "bone structure" for future projects, but it is also sufficient to provide a general idea of how a small business would operate using basic AD.
2. The project includes a basic demonstration of tools such as AD DS, GPOs, RAS, and DHCP. However, these are presented in a way that allows for easy scalability and customization to fit your specific needs.
3. While a basic script to add users is provided, the CSVDE tool can also be used for automation if the provided PowerShell script is not suitable.
4. Numerous settings and policies are redacted, as they fall outside the scope of this project. Future projects will cover these configurations.

Moving on from the introductory text, the following sections will provide instructions on configuring this homelab.


## Network Topology

To have a better idea of what I've done in this project, I have made a basic topology of devices, network configurations and general view of how the entire network would look after implementing this project. 

![DeepinScreenshot_select-area_20230321162454](https://user-images.githubusercontent.com/118489496/226732350-c9bce8b7-6a25-407d-b445-6df55625e2ba.png)

# Table of Content
- [Basic_System_Administration_Home_Lab](#basic-system-administration-home-lab)
  * [Network Topology](#network-topology)
- [Table of Content](#table-of-content)
- [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Gathering The Required ISO Images](#gathering-the-required-iso-images)
  * [Github Installation](#github-installation)
  * [Cloning This Repository](#cloning-this-repository)
- [Step-By-Step Installation](#step-by-step-installation)
  * [Setting up Windows Server](#setting-up-windows-server)
  * [Setting Up Network Adapters Within Windows Server](#setting-up-network-adapters-within-windows-server)
  * [Active Directory Setup](#active-directory-setup)
    + [Installing AD DS](#installing-ad-ds)
  * [Domain Admin Creation](#domain-admin-creation)
  * [Installing and Configuring RAS/NAT](#installing-and-configuring-ras-nat)
    + [Installing RAS](#installing-ras)
    + [Configuring RAS](#configuring-ras)
  * [Installing and Configuring DHCP](#installing-and-configuring-dhcp)
    + [Installing DHCP](#installing-dhcp)
    + [Configuring DHCP](#configuring-dhcp)
  * [Populating Active Directory Users using Powershell](#populating-active-directory-users-using-powershell)
  * [Installing AD Windows Operating System](#installing-ad-windows-operating-system)
  * [Joining New Windows VM to the domain](#joining-new-windows-vm-to-the-domain)
  * [Basic Installtion Finished](#basic-installtion-finished)
- [Installing Applications through Group Policy](#installing-applications-through-group-policy)
  * [Making a Shared Folder](#making-a-shared-folder)
  * [Configuring a new GPO](#configuring-a-new-gpo)
  * [Installing Splunk Universal Forwarder](#installing-splunk-universal-forwarder)
  * [Peform Basic Account Security](#peform-basic-account-security)





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

# Step-By-Step Installation
## Setting up Windows Server
Setting up the Windows Server is a straightforward process that involves the following steps:

1. Create a new virtual machine.
2. Select the ISO image that you previously downloaded.
3. If you are using VMware, you will be prompted with easy installation information. Fill in the required information and leave the Windows product key box empty.
4. Choose the location where you want the VM to reside.
5. Allocate sufficient disk size, RAM, and CPU cores. Refer to this article (https://learn.microsoft.com/en-us/windows-server/get-started/hardware-requirements) to determine the minimum requirements.
6. Once the template is complete, follow these steps to configure the virtual network editor:
 - Click on __Edit__ at the top left corner of the VMware tray.
 - Click on __Virtual Network Editor__.
 - Click on __Add Network__ (On the Windows version of VMware, you may require admin permissions).
 - Set the __Network name__ to vmnet 3 (This could be any number, but I have set it as vmnet 3. Refer to the topology link).
 - Select __Host-only__ under __Type__.
 - Once you have created the network adapter, click on __vmnet3__ and make sure that you deselect __Use local DHCP service to distribute IP addresses to VMs__.
 - Click on __Save__.
 - Go back to your virtual machine, click on __Edit Virtual Machine Settings__, and under the __Hardware__ tab, click on __Add__ and add a new adapter.
 - Finally, set that adapter as vmnet 3.
7. Launch the virtual machine and install Windows Server.

Note that if you choose to install any version that doesn't have "Desktop Experience", you will not be given a GUI.

![1](https://user-images.githubusercontent.com/118489496/227009173-eb12b163-548b-4629-a127-8af5aedea7a1.gif)

## Setting Up Network Adapters Within Windows Server
This step is crucial, so it is essential to ensure that the addressing is correct. The goal is to assign an address to the __vmnet3__ adapter on Windows Server to configure RAS and NAT for our AD computers.

https://user-images.githubusercontent.com/118489496/227038073-ac232c43-c61e-462a-8303-b9a60a84ad9c.mp4

Here's how you can do it:

- To find the adapter options, either right-click on the network icon on the taskbar and click __Open Network and Internet settings__ or type __Network and Internet__ in your settings and click on __Change Adapter Options.__
- Once you have opened up your adapter options, locate the two adapters and browse through their addresses. You can tell which one is your vmnet3 and which one is your NAT adapter by looking at the IPv4 address within the status page.
- Once you have found which one is the internal adapter (vmnet3), right-click on that adapter and choose __Properties.__
- Double-click __Internet Protocol Version 4__ and enter the following information:
    - __IP address__: 172.16.0.1 (you can set your own address as long as it doesn't overlap with other addresses)
    - __Subnet mask__: 255.255.255.0 (which is a /24 subnet holding up to 254 addresses available to be assigned to hosts)
    - Leave __default gateway__ empty
    - __Preferred DNS__: 172.16.0.1
    - __Alternate DNS__: 127.0.0.1

Once you have changed the addresses, your prompt should look similar to the picture shown below:

![5](https://user-images.githubusercontent.com/118489496/227037635-2bd3686e-c6de-45da-827f-d5f1aafc5349.png)

Press __OK__ and close the adapter options window.

The reason behind this step is to make the Windows Server a DHCP server and NAT server so that our AD computers have to go through the server before they can reach the internet. This allows for better control over the devices as well as maintaining security by implementing more security measures that I will showcase in the upcoming projects.

## Active Directory Setup
Next step is to setup active directory. Installing Active Directory Domain Services is very simple:
### Installing AD DS 

https://user-images.githubusercontent.com/118489496/227043489-9134658b-e620-4cb7-a57a-3b81d75142a6.mp4

To set up an Active Directory Domain Services on your Windows Server, follow these steps:

1. Begin by opening your Server Manager and clicking on __Add Roles and Features__.
2. On the __Before You Begin__ page, click __Next__.
3. Select __Role-based or feature-based installation__ as the installation type.
4. On the __Server Selection__ page, click __Next__. Note that if you have multiple domain controllers, you may need to choose the correct one.
5. On the __Server Roles__ page, select __Active Directory Domain Services__ and click __Next__.
6. On the __Features__ page, click __Next__.
7. On the __AD DS__ page, click __Next__.
8. On the __Confirmation__ page, click __Install__.

Once the installation of AD DS is complete, you will need to promote the server to become a domain controller by following these steps:

https://user-images.githubusercontent.com/118489496/227045085-b61cc58e-94ec-4b41-a1ba-705b87b8daba.mp4

1. On the __Deployment Configuration__ page, select __Add a new forest__ and enter the desired domain name in the __Root domain name__ field.
2. On the __Domain Controller Options__ page, enter a password for DSRM.
3. On the __DNS Options__ page, click __Next__.
4. On the __Additional Options__ page, click __Next__.
5. On the __Paths__ page, click __Next__.
6. On the __Review Options__ page, click __Next__.
7. On the __Prerequisites Check__ page, click __Install__.

## Domain Admin Creation

It's important to implement good security practices to ensure the safety and integrity of your system. One such practice is creating a second tier admin with necessary permissions to perform certain actions but restricted to a defined scope. For this reason, I created a user named __John Doe__ and assigned the role of __Domain Admin__ to it.

https://user-images.githubusercontent.com/118489496/227644918-643886e8-2bc5-4d6e-a6fd-8f0f7a921fc4.mp4

To create a new user in your active directory, follow these steps:

1. Click on __Tools__ on the server manager.
2. Select __Active Directory Users and Computers__.
3. Expand the domain to be able to see OUs within the domain.
4. Right-click on the domain and choose __New__ > __Organizational Unit__.
5. Type in __Test_Users__ and click __OK__.
6. Right-click on the __Test_Users__ OU and choose __New__ > __User__.
7. Type in the following information:
    - __First Name__: John
    - __Last Name__: Doe
    - __Full Name__: John Doe
    - __User Logon Name__: J-Doe
8. Click __Next__.
9. Fill in the password field.
10. (Optional): You may choose to force the user to change their password at the next logon. While this can reduce the risk of unauthorized access, it can also result in less flexibility and security for the user. Make sure to weigh the pros and cons and decide accordingly.
11. Once you have finished creating the user, right-click on John Doe and choose __Properties__.
12. Click on __Member Of__ > __Add ...__.
13. Under __Enter the object names to select__, type __Domain Admin__ and click __Check Names__.
14. Press __OK__.

It's important to note that regular password changes are also a good security practice. While forcing the user to change their password at the next logon can be less flexible, it can help reduce the risk of unauthorized access. Make sure to weigh the pros and cons and decide accordingly.

https://user-images.githubusercontent.com/118489496/227645021-bbb03c03-c8e6-4847-8726-abb2362963a0.mp4

Once you have completed these steps and restarted the server, you should be able to log in using John Doe's logon name and password.

## Installing and Configuring RAS/NAT 

![DeepinScreenshot_select-area_20230321143326](https://user-images.githubusercontent.com/118489496/227645739-fc9b6614-2c3a-46e7-96b6-01bc9bbdabfc.png)

The primary goal of implementing these services is to have greater control over the network, albeit at the cost of additional overhead. Specifically, we want to route new computer traffic through the server. In this context, I have configured the network such that the traffic originating from the VM "AD Jorb" (admittedly not the most imaginative name!) must go through DC1 before being relayed to the internet using NAT.

https://user-images.githubusercontent.com/118489496/227647166-5bb2f116-c3d4-461b-b2a9-5fafa259b11e.mp4

## Installing RAS
### To install RAS, follow these steps:

1. Open Server Manager and click on __Add Roles and Features__.
2. On the __Before You Begin__ page, click Next.
3. On the __Installation Type__ page, click Next.
4. On the __Server Selection__ page, select your server and click Next.
5. On the __Server Roles__ page, select __Remote Access__ and click Next.
6. On the __Features__ page, click Next.
7. On the __Remote Access__ page, click Next.
8. Under __Role Services__, select __Routing__. Then click __Add Feature__ and click Next.
9. On the __Confirmation__ page, click Install.

## Configuring RAS

### To configure RAS, follow these steps:

1. Open Server Manager and click on __Tools__ > __Routing and Remote Access__.
2. Right-click on your domain controller and select __Configure and Enable Routing and Remote Access__.
3. Click Next.
4. On the __Configuration__ page, select __Network Address Translation (NAT)__ and click Next.
5. Under __NAT Internet Connection__, select the network interface that is internet-facing. This should be the adapter that was not manually configured earlier.
6. On the __Completing the Routing and Remote Access Server Setup__ page, click Finish.

## Installing and Configuring DHCP
To make the process as flexible as possible, DHCP is installed on the domain controller (DC1). This ensures that any new device that connects to the vmnet3 network is able to obtain an IP address from the DHCP server. To simplify the process, exclusions are avoided, but it is possible to exclude certain address ranges on your DHCP scope.

## Installing DHCP

### To install DHCP, follow these steps:

1. On Server Manager, click on __Add Roles and Features.__
2. On the __Before You Begin__ page, click next.
3. On the __Installation Type__ page, click next.
4. On the __Server Selection__ page, choose your server and click next.
5. On the __Server Roles__ page, select __DHCP__ and click next.
6. On the __Features__ page, click next.
7. On the __DHCP Server__ page, click next.
8. On the __Confirmation__ page, click install.

## Configuring DHCP 

### To configure DHCP, follow these steps:

1. On Server Manager, click __Tools__ > __DHCP__.
2. Expand your domain.
3. Right-click on IPv4 > __New Scope...__.
4. Click __Next__.
5. Enter the name you want to give this scope, for example, __Internal_Network_Scope__.
6. Enter the IP range you want the DHCP server to distribute.
7. Under subnet mask, input the correct number. To simplify this procedure, think about how many hosts you want to have and use the formula (2^n)-2 to get the correct amount of hosts. Once you find this number, subtract it from 32 and that will be your subnet mask. For example:
    - Hosts needed = 254
    - 2^8 = 256, 256 - 2 = 254. 32 - 8 = /24 => 255.255.255.0
8. Under __Add Exclusions and Delay__, you could add your own exclusions, however, for this lab, we will not include any.
9. Under __Lease Duration__, select an appropriate duration based on your scenario:
    - Scenario 1: A cafeteria has a public wifi. Customers would walk in to the cafeteria and connect to the wifi receiving their addresses from the DHCP server. At the end of the night they leave and might not come back the next day. This causes issues with new customers as DHCP server allocates the address to the specific device and is reserving it until the lease duration expires. In this case, a shorter lease duration is more appropriate.
    - Scenario 2: A small business has set up their electronics and has 30 - 80 devices. These devices are stationary and do not leave the premises. So the IP addresses assigned are being used whenever someone uses these devices. In this scenario, it's more appropriate to make the lease duration longer.
    - For the sake of simplicity, we have set the DHCP lease duration to 3 days.

10. On the __Configure DHCP Options__ page, click __Next__.
11. On the __Router (Default Gateway)__ page, enter the address of the router or device that you want the network to be routed to. In this case, DC1's address (172.16.0.1).
12. On the __Domain Name and DNS Servers__ page, make sure DC1's address is at the top and click __Next__.
13. Feel free to ignore WINS Servers or remove any addresses there. We will not be using a WINS server for this project.
14. On the __Activate Scope__ page, click __Next__.

Now, new VMs should be able to obtain an IP address from DC1's DHCP server

## Populating Active Directory Users using Powershell

Next step is to simulate an basic work environment. To do this I decided to make a basic powershell script that would automatically add users to a specific OU from a text document containting full names. It's worth noting that this could also be done through using CSVDE tool. 

https://user-images.githubusercontent.com/118489496/227679156-feba7ce2-9df6-410b-9ad9-d37e20e7b4e0.mp4

With that being said please refer to the code provided inside the repo.
This script requires a text document that contains full names based on the following :
```
firstname lastname
John Doe
James Pappas
```

Once you have populated the text document, you could change $path variable to better fit your domain name and OU. 
```
i.e. $path = "OU=Ou_name, DC=your_domain, DC=your_domain_root" $path = "OU=Finance,DC=Financialworld,DC=com"
```
Once you have set that up the script will convrt initial code as SecureString.
```
$pass = ConvertTo-SecureString -String $password -AsPlainText -Force
```
Next it will iterate and split each line into two. Once the split has been processed, it will store first index of the list to $first variable and second index to $last variable 
```
$first = $line.split(" ")[0].ToLower()
$last = $line.split(" ")[1].ToLower()
```
Then it will create a Sam Account Name by joining first name and last name using "."
```
$username = "$first.$last"
```
Lastly it will create the new user. Note that there is a "ChangePasswordAtLogon" parameter used to provide flexibility and security for users.
```
New-AdUser -AccountPassword $pass -GivenName $first -Surname $last -Name $line -SamAccountName $username -UserPrincipalName $username -Enabled $True -Path $path -ChangePasswordAtLogon $true```
```
## Installing AD Windows Operating System

To keep things simple, I used a normal Windows 10 ISO instead of a pxe image for a certain step. It's important to ensure that the VM used for this step doesn't have internet access to avoid any issues during installation, such as having to sign in with a Microsoft account.

Another thing to note is that not all versions of Windows can join an AD domain. For our lab, only certain versions are appropriate.
https://user-images.githubusercontent.com/118489496/227679249-b6be490e-879a-467b-a31b-d72f2bc771d0.mp4

https://user-images.githubusercontent.com/118489496/227679251-e26f6a5f-eea4-4f59-bbda-4474dbafdbf3.mp4

## Joining New Windows VM to the domain

https://user-images.githubusercontent.com/118489496/227680122-d9abe1af-d862-44f7-8e4a-abfa6ee6e603.mp4

Once the Windows VM is done installing, it needs to be joined to the domain that was previously created. Follow these steps:

1. Type __about your pc__ in the search bar.
2. Click on __Rename this PC (advanced)__ in the right panel.
3. Click __Change__ next to __To rename this computer or change its domain or workgroup__.
4. Change the __Computer name__ and select __Domain__ under __Member of__.
5. Enter the domain name.
6. Click __OK__.
7. Enter a user's information to join the domain. In this example, one of the users created using the script was used.
8. Restart the computer and login with the username.

https://user-images.githubusercontent.com/118489496/227680136-f0663630-4c0a-49c5-9bd6-def4c2f10ed4.mp4

To view the new computer joining the domain, go to Tools > Active Directory users and computers > Computers.

https://user-images.githubusercontent.com/118489496/227680249-8747cf13-7d94-41dd-8f05-13cf688db402.mp4

## Basic Installtion Finished

Now that everything is set up, the following should be functioning:
1. A functioning Windows Server with Active Directory Domain Services, Remote Access Services (RAS)/NAT, and DHCP installed and functional.
2. Users created in the __Test_Users__ OU.
3. Newly domain-joined Windows VM visible under __Computers__.
4. VM has network access using the vmnet3 adapter.


With that being said, all that's left is to install Splunk Universal Forwarder on the vm using group policy. 
Note that if you haven't setup a splunk server, please do so or refer to my [Ubuntu Splunk Server](https://github.com/kasra-sal/Splunk-Environment-Setup) repo for more guide.

# Installing Applications through Group Policy

The reason behind this step is to simulate how an administrator would install programs on AD computers automatically without having to configure each pc with required program. 

Here we will install google chrome and splunk universal forwarder on domain pcs through gpo. Something to keep in mind is that I have moved the vm we created earlier to a new organizational unit as demonstrated in the video. So for the sake of proper flow make sure you follow the same order and settings.


before we begin, we need to create a shared folder on our DC and make sure the permissions are setup so that domain computers can "Read" files. Furthermore we need to ensure that when installing Splunk Universal Forwarder through gpo, we need to use "orca" which comes with [Windows SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/). One orca is installed you should update Splunk Universal Forwarder and then install it using GPO. 


https://user-images.githubusercontent.com/118489496/227703879-f7acbb61-ed3a-4a33-95ce-43e4dea6c0a8.mp4


Follow the steps below to configure shared folders and install programs using GPO:

## Making a Shared Folder
Making a shared folder is easy. For the sake of simplicity we will keep the shared folder on the same storage as the server.

1. Go to your C drive.
2. Create a new folder named "Shared_Folder".
3. Right click on this folder and go to properties.
4. Click on "Sharing" tab.
5. Click on Advanced Sharing.
6. Select "Share this folder" (Note: addig $ at the end of share name will make it hidden, yet discoverable if full path is specifed)
7. Click on Permissions > Add.
8. Under "Enter the object names to select" type "Domain Computers".
9. Remove "Everyone" to limit access to this folder. Click Apply.
10. Once you close the advanced share tab, click on share and repeat step 7-9.
11. Save the network path present under "Sharing" tab.
12. Move the programs you want to install to this folder. In the case of this project, move google chrome and Splunk Universal Forwarder's msi installer.

## Configuring a new GPO
It's worth noting that certain policies may require creating policies based on users, such as making specific software available to certain departments that don't share computers. In such cases, configuring software installation under users would be more appropriate. However, in this tutorial, I chose to configure these settings based on the computer.

1. On Server Manager, click tools > Group Policy Management
2. Right click "Test_User_Computers" or your new OU for DOmain computers and select "New GPO"
3. Type a name for this GPO. In this case PC_SOFTWARE_INIT
4. Right click on the newly created GPO and choose "Edit"
5. Expand Computer Configuration > Policies > Software Settings.
6. Right click on the white space and choose New > Package
7. Enter the address you copied from shared folder into the address bar
8. Select your program. In this case google chrome.
9. You are done.

Now all you have to do is to login to the AD Computer created previously "AD Jorb", open up command prompt as administrator and type 
```
gpupdate /force
```
## Installing Splunk Universal Forwarder
Installing Splunk Universal Forwarder is a bit different. Since the installtion requires acceptance of license and certain entries such as username, password and deployment server, we need to configure this using [orca](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/). 

1. Open orca
2. Click File > Open and choose the Splunk Universal Forwarder's installation file.
3. IMPORTANT: right after you finish step 2, click Transform > New Transform.
4. Scroll down on the left panel and select "Property"
5. Scroll down untill you see "AGREETOLICENSE" and change the value to "Yes"
6. Right click anywhere, select Add Row.
7. Enter "SPLUNKADMIN" as property and enter your username as value. In this case "TEST1".
8. Repeat steps 6 and 7 for the following information:
  - SPLUNKPASSWORD : your_password(In this case TESTpass123!)
  - DEPLOYMENTSERVER: Address_of_splunk_server:8089 (In this case 172.16.65.132:8089)
9. Click Transform > Generate Transform
10. Save it under the shared folder
11. Go back to the Group Policy Management window, right click on the white space and choose New > Package
12. select Splunk Universal Forwarder's installtion file
13. Under "select deployment method" select Advanced
14. Switch over to "Modifications" and click Add
15. Select the newly created MST file using orca.
16. Press OK

And you are done. Head over to the VM, open up cmd and type
```
gpupdate /force
```
https://user-images.githubusercontent.com/118489496/227703931-0dd0a5c4-1714-431c-86dd-5ed81d730608.mp4

## Peform Basic Account Security

In order to establish a more strictly enforced policy, we will utilize policy hierarchy. To achieve this, we will create a policy at the highest level, define general password policies, and then implement it down to lower level policies.

https://user-images.githubusercontent.com/118489496/227737268-a82b4ccc-3b1f-4c02-97ae-9dd4f01007db.mp4

Follow the steps given below to enforce policies from higher tier:
1. Click on Tools > Group Policy Management
2. Expand Domains > homelab.com (or your domain name)
3. Right click on your domain and click "Create a GPO in this domain and link it here"
4. Give it a name (In this case "Default_Admin_Stuff")
5. Right click on the newly created GPO and choose "Edit"
6. Expand Computer Configuration > Policies > Windows Settings > Security Settings > Password Policy
7. Edit each policy with the given value:
  - Enforced Password History : True
  - Maximum Password Age : 30 days
    - This is important because in the event that a malicious actor gains access to the system without the system recognizing it, they will have access to this account for a long period of time. Another benefit of this option is that if a user uses the same credentials for other services and it gets leaked, on the long run it will not affect the current company directly.
  - Minimum Password Age : 15 days 
    - This ensures that once the user changed their password, they cannot change it again within 15 days.
  - Minimum Password Length : 10 
    - Having this option enabled is benefitial as shorter passwords are easier to crack.
    - Another important thing to note is that passwords containing personal belongings or pet names should be avoided as this will increase the crackability of an account using a brute force attack or targetted attacks
  - Password Must Meet Password Complexity Requirements
    - This option allows administrators to enforce password policies that deny passwords that do not have the required criterias.
    - Usually these requirements include atleast one uppercase letter, one lowercase letter, numbers and special characters


https://user-images.githubusercontent.com/118489496/227737281-7544acf3-bcd1-4d86-b8f7-95525461fb7e.mp4


Once you are done enforce these roles so that lower GPOs do take these changes:
1. On Group Policy Management window, Right click on "Default_Admin_Stuff"
2. Click "Enforced"

Now the higher tier policy should take precedence.




