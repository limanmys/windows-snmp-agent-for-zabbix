# Zabbix-Agent-Slient-Installer
Windows Zabbix Agnet Installer Sliently

Run PoweShell Administrator permissions then just run the scripts

Prerequirement
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```
Note: Reply Y for one time, A for all time

Installation
```powershel
./zabbix-agent-v1.ps1
```


To uninstall

``` powershell
c:\zabbix\bin\zabbix_agentd.exe --stop --config c:\zabbix\conf\zabbix_agentd.conf

c:\zabbix\bin\zabbix_agentd.exe --uninstall --config c:\zabbix\conf\zabbix_agentd.conf
```
