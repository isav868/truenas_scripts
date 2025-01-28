# truenas_scripts

Custom scripts for TrueNAS.

On TrueNAS Core go to Tasks -> Init/Shutdown Scripts -> Add:

Type: COMMAND:
```
cd /root/custom_scripts && ( git stash ; git pull https://github.com/isav868/truenas_scripts.git && sh ./smartctl_exporter.sh ) || ( git clone https://github.com/isav868/truenas_scripts.git /root/custom_scripts && cd /root/custom_scripts && sh ./smartctl_exporter.sh )

```
When: POSTINIT.

