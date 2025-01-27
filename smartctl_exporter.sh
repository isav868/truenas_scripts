#!/bin/sh

SVC_NAME=smartctl_exporter
SVC_SRC=smartctl_exporter-0.13.0.freebsd-amd64.tar.gz
SVC_DIR=/usr/local/sbin/
SVC_PATH="$SVC_DIR/$SVC_NAME"
SVC_ARGS="--smartctl.path=/usr/local/sbin/smartctl"
SVC_FILE="/usr/local/etc/rc.d/$SVC_NAME"

# CREATE SERVICE RC FILE
cat << EOF > $SVC_FILE
#!/bin/sh

. /etc/rc.subr

name=$SVC_NAME
rcvar=${SVC_NAME}_enable

load_rc_config $SVC_NAME

: \${${SVC_NAME}_enable:=no}

pidfile="/var/run/${SVC_NAME}-daemon.pid"
procname=$SVC_PATH
procuser=root
procargs="$SVC_ARGS"
command=/usr/sbin/daemon
command_args="-cf -p \${pidfile} -u \$procuser \${procname} \$procargs"

run_rc_command "\$1"
EOF

chmod +x $SVC_FILE

# ENABLE SERVICE
sysrc ${SVC_NAME}_enable=yes

# STOP SERVICE BEFORE BINARY FILE MODIFICATION
service $SVC_NAME stop

# EXTRACT SERVICE BINARY FILE
tar zxf "$SVC_SRC" -C $SVC_DIR --include "*/$SVC_NAME" --strip-components 1 --no-same-owner --no-same-permissions
rm -f "$SVC_SRC"
chmod u=rwx,go=rx "$SVC_PATH"

service $SVC_NAME start

