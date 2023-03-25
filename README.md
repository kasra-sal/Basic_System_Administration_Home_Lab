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

- [Basic_System_Administration_Home_Lab](#basic-system-administration-home-lab)
  * [What Should I take Away From This Project?](#what-should-i-take-away-from-this-project-)
  * [Network Topology](#network-topology)
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
    + [Promoting Server to Become a Domain Controller](#promoting-server-to-become-a-domain-controller)
  * [Domain Admin Creation](#domain-admin-creation)
  * [Installing and Configuring RAS/NAT](#installing-and-configuring-ras-nat)
    + [Installing RAS/NAT](#to-install-ras-do-the-following-)
    + [Configuring RAS/NAT](#to-configure-ras-do-the-following-)
  * [Installing and Configuring DHCP](#installing-and-configuring-dhcp)
    + [Installing DHCP](#to-install-dhcp-do-the-following-)
    + [Configuring DHCP](#to-configure-dhcp-do-the-following-)
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

## Setting Up Network Adapters Within Windows Server
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

## Active Directory Setup
Next step is to setup active directory. Installing Active Directory Domain Services is very simple:
### Installing AD DS 

https://user-images.githubusercontent.com/118489496/227043489-9134658b-e620-4cb7-a57a-3b81d75142a6.mp4

1. First Click "Add Roles and Features" on your server manager.
2. On "Before You Begin" page click next
3. On installation type select "Role-based or feature-based installtion".
4. On "Server Selection" page click next. (Note if you have more Domain Controllers you may have to choose the correct one)
5. On "Server Roles" page select "Active Directory Domain Services" and click next.
6. On "Features" page click next.
7. On "AD DS" page click next.
8. On "Confirmation" page click install.
### Promoting Server to Become a Domain Controller

Once the AD DS installtion is done, you need to promote the server to become a domain controller. 

https://user-images.githubusercontent.com/118489496/227045085-b61cc58e-94ec-4b41-a1ba-705b87b8daba.mp4

1. On "Deployment Configuration" page select "add a new forest". Enter the domain name you want inside "Root domain name" field
2. On "Domain Controller Options" page enter password for DSRM.
3. On "DNS Options" page click next.
4. On "Additional Options" page click next.
5. On "Paths" page click next.
6. On "Review Options" page click next.
7. On "Prerequisites Check" page click install.

## Domain Admin Creation

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

## Installing and Configuring RAS/NAT 

![DeepinScreenshot_select-area_20230321143326](https://user-images.githubusercontent.com/118489496/227645739-fc9b6614-2c3a-46e7-96b6-01bc9bbdabfc.png)

The intended purpose for these services is to be able to route new computer's traffic through the server. This way we would have more control over the network at the cost of more overhead. With that being said, I wanted to make the network so that VM "AD Jorb" (Btw I couldn't think of a better name at the time :) ) has to send its traffic through DC1 and then from DC1 the traffic gets relayed to the internet using NAT.

https://user-images.githubusercontent.com/118489496/227647166-5bb2f116-c3d4-461b-b2a9-5fafa259b11e.mp4

### To install RAS do the following:

1. On server manager, click on "add roles and features.
2. On "Before You Begin" page click next.
3. On "Installation Type" page click next.
4. On "Server Selection" page choose your server and click next.
5. On "Server Roles" page, select "Remote Access" and click next.
6. On "Features" page click next.
7. On "Remote Access" page click next.
8. On "Role Services" select "Routing", click "add feature" and click next.
9. On "Confirmation" page click install.

### To configure RAS do the following:

1. On server manager, click tools > Routing and Remote Access
2. Right click on your domain controller and click "Configure and Enable Routing and Remote Access"
3. Click Next
4. On "Configuration" page select "Network Address Translation (NAT)" and click Next.
5. On "NAT Internet Connection" select the network interface that is internet facing. To make this easier, it's the adapter that was not manually configured earlier. 
6. On "Completing the Routing and Remote Access Server Setup" Click Finish.

## Installing and Configuring DHCP

To make the process as dynamic as possible, I decided to install DHCP on my domain controller. This way any new device that connects to the vmnet3 network, will be able to obtain an ip address from the DHCP server in this case being DC1. for the sake of simplicity, I avoided making exclusions or making it too complicated however you could exclude certain address ranges on your DHCP scope. 

https://user-images.githubusercontent.com/118489496/227656290-f807c845-ec84-4d03-a6b9-5d8d32d551b7.mp4

### To Install DHCP do the following:

1. On server manager, click on "add roles and features.
2. On "Before You Begin" page click next.
3. On "Installation Type" page click next.
4. On "Server Selection" page choose your server and click next.
5. On "Server Roles" page, select "DHCP" and click next.
6. On "Features" page click next.
7. On "DHCP Server" page click next.
8. On "Confirmation" page click install.

### To configure DHCP do the following:

1. On server manager, click tools > DHCP
2. Expand your domain.
3. Right click on IPv4 > New Scope ...
4. Click Next
5. Enter the name you want to give this scope. i.e "Internal_Network_Scope"
6. Enter the IP range you want the DHCP server to distribute.
7. Under subnet mask, make sure you input the correct number. To simplify this procedure, think about how many hosts you want to have and use the formula (2^n)-2 to get the correct amount of hosts. Once you find this number, subtract it from 32 and that will be your subnet mask. As an example:
  - Hosts needed = 254
  - 2^8 = 256, 256 - 2 = 254. 32 - 8 = /24 => 255.255.255.0 
8. On "Add Exclusions and Delay, you could add your own exclusions, however for this lab I decided to not include any.
9. On "Lease Duration" select an appropriate duration. Think about it these scenario:
  - Scenario 1: A cafeteria has a public wifi. Customers would walk in to the cafeteria and connect to the wifi receiving their addresses from the DHCP server. At the end of the night they leave and might not come back the next day. This causes issues with new customers as DHCP server allocates the address to the specific device and is reserving it until lease duration expires, however there are more customers walking the next day and yet all of the addresses are reserved for those customers who may never come back. In this case a shorter lease duration is more appropriate.
  - Scenario 2: A small business has setup their electronics and have 30 - 80 devices. These devices are stationary and do not leave the premise. So the IP addresses assigned are being used whenever someone uses these devices. In this scenario it's more appropriate to make lease duration longer.
 - For the sake of simplicity, I have set DHCP lease duration to 3 days.
10. On "Configure DHCP Options" page click Next.
11. On "Router (Default Gateway)" page enter the address of the router or device that you want the network to be routed to. In this case DC1's address (172.16.0.1)
12. On "Domain Nmae and DNS Servers" ake sure your DC1's address is at the top and click next.
13. Feel free to ignore WINS Servers or remove any addresses there. I will not be using WINS server for this project.
14. On "Activate Scope" click Next.

Now our new VMs should be able to obtain IP address from DC1'S DHCP server and gain access to the internet.

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

Although this step could've been done with a pxe image, I decided to keep it simple and use a normal Windows 10 ISO. One thing to note is that make sure that this VM does not have access to the internet. This allows us to bypass the "sign in with a microsoft account step" and allows the installtion to be smoother.

Another thing to note is that not all versions of windows can join an AD domain. Only the following versions are appropriate for our lab.

https://user-images.githubusercontent.com/118489496/227679249-b6be490e-879a-467b-a31b-d72f2bc771d0.mp4

https://user-images.githubusercontent.com/118489496/227679251-e26f6a5f-eea4-4f59-bbda-4474dbafdbf3.mp4

## Joining New Windows VM to the domain

https://user-images.githubusercontent.com/118489496/227680122-d9abe1af-d862-44f7-8e4a-abfa6ee6e603.mp4

Once the Windows VM is done installing, we need to join it to the domain we created previously. To do this do the following steps:
1. In search bar type "about your pc".
2. On the right panel click on "Rename this PC (advanced)".
3. Beside "to rename this computer or change its domain or workgroup" click change.
4. Change "Computer name" and then select "Domain" under "Member of".
5. Type in your domain name.
6. Click OK.
7. Enter a user's information to join the domain. In this example I used one of the users that I created using the script.
8. Restart your computer and login with your username.

https://user-images.githubusercontent.com/118489496/227680136-f0663630-4c0a-49c5-9bd6-def4c2f10ed4.mp4

To view the new computer joining the domain you could go to Tools > Active Directory users and computers > Computers

https://user-images.githubusercontent.com/118489496/227680249-8747cf13-7d94-41dd-8f05-13cf688db402.mp4

## Basic Installtion Finished

Now that we have everything setup, we should have the following functioning:
1. A functioning Windows Servr that has the following features installed and functional:
  - Active Directory Domain Services
  - Remote Access Services (RAS) / NAT
  - DHCP
2. Users created in the "Test_Users" OU 
3. Newly domain joined Windows VM visible under "Computers"
4. VM has network access using vmnet3 adapter.


With that being said all that's left is to install Splunk Universal Forwarder on the vm using group policy. 
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
computer vs user
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

To have a more enforced policy, we will take advantage of policy hierarchy. To do this we will make a policy at the highest level, set general password policies and then enforce it down to lower level policies.

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




