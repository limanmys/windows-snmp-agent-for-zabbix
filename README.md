# Zabbix-Agent-Slient-Installer
Windows Zabbix Agent Installer Sliently

Run PoweShell Administrator permissions then just run the scripts

Prerequirement
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```
Note: Reply Y for one time, A for all time

Windows Fİrewall Rule
``` powershell
New-NetFirewallRule -DisplayName "Zabbix Agent" -Direction Inbound -LocalPort 10050 -Protocol TCP -Action Allow
```

Installation
```powershel
./zabbix-agent-v1.ps1
```


To uninstall

``` powershell
c:\zabbix-agent\bin\zabbix_agentd.exe --stop --config c:\zabbix-agent\conf\zabbix_agentd.conf

c:\zabbix-agent\bin\zabbix_agentd.exe --uninstall --config c:\zabbix-agent\conf\zabbix_agentd.conf
```




**One Line Installation**

Downloads, adds firewall rule and installs Zabbix Agnet 
``` powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/dogukaneren/Zabbix-Agent-Slient-Installer/main/zabbix-agent-v1-plus.ps1" -OutFile "zabbix-agent-v1-plus.ps1"; .\zabbix-agent-v1-plus.ps1
```
