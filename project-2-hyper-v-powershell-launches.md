---
icon: server
description: Scripted Launching, Committing, and Teardown of Hyper-V based VM Labs.
---

# Project 2 - Hyper-V PowerShell Launches

The goal of this project is to create scripted processes that can launch VM based labs from a Hyper-V environment. While working at an MSP, I was constantly trying to figure out how to train new hires on actual issues, without having to constantly break my work laptop. I could only uninstall printer drivers, or rotate my screen, so many times before it became tiresome. &#x20;

My home lab is Hyper-V based (thanks Broadcom), which was the primary reason I chose Hyper-V as the hypervisor for this project. Additionally, PowerShell, and the vast catalogue of Hyper-V commands that exist within PowerShell, made this quite a simple task.&#x20;

This lab utilizes a JSON file for the most relevant variables, namely pathing for VHDX files.&#x20;

The parameters of the VM are indicated as variables at the top of the lab\_launch.ps1 file, rather than within the JSON file. PowerShell continued to throw an error for the MemoryStartupBytes value when I tried to pull it in from the JSON file. After an hour of troubleshooting I decided this was not the hill I wanted to die on. The parameters for the VM will change much less often than the disk path, in my opinion, so it did not seem worth the effort at this time.&#x20;

The basic logic of the system is this:&#x20;

1. Create a VM that you would like to use as the base of your lab.&#x20;
   1. The VHDX of this lab will function as the "Parent" disk.&#x20;
   2. Connect to this VM and set everything to the state you would like when a trainee or student begins the scenario. (Run updates, create users, add files, break drivers, whatever you want to do!)&#x20;
   3. Shutdown the VM and set the parent VHDX file to **read-only**!&#x20;
2. When the "lab\_launch.ps1" script is run, it will create a differencing disk from the parent disk. This differencing disk will function as the disk for the VM while it is running. What's super cool about this is, once the lab is shut down, the differencing disk can be deleted. The script always creates a new differencing disk from the parent on each launch, so the lab will ALWAYS start in the state you intend.&#x20;
3. The save\_changes.ps1 script allows you to make updates to the original state of the lab. Say you decide down the road that you want the student to start in a different spot, or you have to run some security updates on the VM, the save\_changes.ps1 merges the differencing disk with the parent disk. Be careful what changes you merge, because you will have to start over if you merge the wrong thing.&#x20;

Looking specifically at lab\_launch.ps1

This pulls the variables from the JSON file:&#x20;

````powershell
```powershell
$data = Get-Content -Path ".\lab_variables.json" -Raw | ConvertFrom-Json
```
````

This sets the parameters for the VM that is created by Hyper-V

````powershell
```powershell
#VM Variables
$vm_name = $data.vm_name
$switch_name = "Intel(R) Ethernet 10G 4P X540/I350 rNDC - Virtual Switch"
$memory_size = 8GB
$cpu_size = 4
$vm_gen = 2
```
````

To ensure the launch doesn't throw errors, this checks for vhdx files or VMs that might have the same name from a previous launch. If it finds them, it delets them:&#x20;

````powershell
```powershell
#Step 0. Ensure previous lab was cleaned up properly
if (Get-VM $vm_name -ErrorAction SilentlyContinue) {
    Remove-VM $vm_name -Force
}

if (Test-Path $diff_path) {
    Remove-Item $diff_path
}

```
````

This creates the fresh differencing disk, based off the parent disk:&#x20;

````powershell
```powershell
#Step 1. Create the new Diff Disk
New-VHD -ParentPath $parent_disk -Path $diff_path -differencing
```
````

This creates the VM for use in the lab, using the variables from the above block. I have Secure Boot disabled, because this was built using UbuntuServer:

````powershell
```powershell
#Step 2. Create the VM using the Diff Disk
New-VM -Name $vm_name -MemoryStartupBytes $memory_size -VHDPath $diff_path -Generation $vm_gen -SwitchName $switch_name 
Set-VMProcessor -VMName $vm_name -Count: $cpu_size
Set-VMFirmware -VMName $vm_name -EnableSecureBoot Off
```
````

&#x20;The next two steps launch the VM and then connect to the VM via a console window:&#x20;

````powershell
```powershell
#Step 3. Launch the VM
Start-VM -Name $vm_name

#Step 4. Connect to the VM
VMConnect localhost $vm_name
```
````

The save\_changes.ps1 pulls variables from the JSON file as well:&#x20;

````powershell
```powershell
#Get Variables from JSON file
$data = Get-Content -Path ".\lab_variables.json" -Raw | ConvertFrom-Json

Merge-VHD -Path $data.diff_path -DestinationPath $data.parent_disk
```
````

Here is the JSON file that I use for this:&#x20;

````json
```json
{
    "vm_name" : "Ubuntu Lab",
    "parent_disk" : "V:\\Virtual Disks\\Ubuntu Lab\\Parent.vhdx",
    "diff_path" : "V:\\Virtual Disks\\Ubuntu Lab\\Production.vhdx"
}
```
````



{% @github-files/github-code-block url="https://github.com/gus-young/HyperV_Lab_Launcher" %}
