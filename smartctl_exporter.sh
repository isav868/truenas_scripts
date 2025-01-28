#!/bin/sh

set -e

SVC_NAME=smartctl_exporter
SVC_SRC=smartctl_exporter-0.13.0.freebsd-amd64.tar.gz
SVC_DIR=/usr/local/sbin/
SVC_PATH="$SVC_DIR/$SVC_NAME"
SVC_ETC=/usr/local/etc
SVC_ARGS="--smartctl.path=/usr/local/sbin/smartctl --web.config.file=$SVC_ETC/$SVC_NAME/web-config.yml"
SVC_FILE="$SVC_ETC/rc.d/$SVC_NAME"

# CREATE web-config AND CERTIFICATE
mkdir -p "$SVC_ETC/$SVC_NAME"

umask 0077
cat << EOF > $SVC_ETC/$SVC_NAME/web-config.yml
tls_server_config:
  cert_file: $SVC_ETC/$SVC_NAME/server.crt
  key_file: $SVC_ETC/$SVC_NAME/server.key

# !!REPLACE 'placeholder' WITH REAL VALUE IN PRODUCTION!!
basic_auth_users:
  placeholder: \$2y\$12\$qDW6YfP02gxIvMt92q.aD.31SctHNgYOkMLVso.7jAHAI33U0ctVK
EOF

openssl req -nodes -x509 -sha256 -newkey rsa:2048 -keyout $SVC_ETC/$SVC_NAME/server.key -out $SVC_ETC/$SVC_NAME/server.crt -days 3650 -subj "/C=UA/ST=UA/O=Onix/CN=smartctl-exporter" -addext "subjectAltName = DNS:smartctl-exporter"

chmod go+r $SVC_ETC/$SVC_NAME/server.crt
umask 0022

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
service $SVC_NAME stop || :

# EXTRACT SERVICE BINARY FILE
tar zxf "$SVC_SRC" -C $SVC_DIR --include "*/$SVC_NAME" --strip-components 1 --no-same-owner --no-same-permissions
chmod u=rwx,go=rx "$SVC_PATH"

service $SVC_NAME start

