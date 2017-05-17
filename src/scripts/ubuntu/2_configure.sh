#!/bin/bash

# Expected input
EXTERNAL_FQDN=${EXTERNAL_FQDN}
SECRET_KEY=${SECRET_KEY}
ADMIN_PASSWORD=${ADMIN_PASSWORD}
DOMAIN=${DOMAIN:-localhost}
ROOT_URL=${ROOT_URL:-localhost}

DATABASE_USER=${DATABASE_USER:-grafana}
DATABASE_PASSWORD=${DATABASE_PASSWORD}
DATABASE_ADDRESS=${DATABASE_ADDRESS:-127.0.0.1}
DATABASE_PORT=${DATABASE_PORT:-3306}
DATABASE_NAME=${DATABASE_NAME:-grafana}

MEMCACHED_ADDRESSES=${MEMCACHED_ADDRESSES}
MEMCACHED_PORT=${MEMCACHED_PORT:-11211}


# Prepare memcached connection string
LENGTH=$(echo ${MEMCACHED_ADDRESSES} | /usr/bin/jq 'length')
LAST_INDEX=$((LENGTH-1))

MEMCACHED_CONN=''
for I in `seq 0 $LAST_INDEX`; do
  ADDR=$(echo $MEMCACHED_ADDRESSES | /usr/bin/jq -r ".[$I]" )
  MEMCACHED_CONN="${MEMCACHED_CONN};$ADDR:$MEMCACHED_PORT"
done

MEMCACHED_CONN=$( echo $MEMCACHED_CONN | sed 's/^;//' )


# Write configuration
mkdir -p /var/lib/grafana/dashboards

cat <<EOF > /etc/grafana/grafana.ini
app_mode = production
instance_name = ${HOSTNAME}

[paths]
data = /var/lib/grafana
logs = /var/log/grafana
plugins = /var/lib/grafana/plugins

[server]
protocol = http
http_addr = 0.0.0.0
http_port = 3000
domain = ${EXTERNAL_FQDN}
enforce_domain = false
root_url = ${ROOT_URL}
enable_gzip = false

[database]
type = mysql
ssl_mode = false
url = mysql://$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_ADDRESS:$DATABASE_PORT/$DATABASE_NAME

[session]
provider = memcache
provider_config = $MEMCACHED_CONN
cookie_name = grafana_sess
cookie_secure = false
session_life_time = 86400

[analytics]
reporting_enabled = false
check_for_updates = false

[security]
admin_user = admin
admin_password = $ADMIN_PASSWORD
secret_key = $SECRET_KEY
disable_gravatar = true

[snapshots]
external_enabled = false

[users]
allow_sign_up = false
allow_org_create = false
auto_assign_org = false
auto_assign_org_role = Viewer
default_theme = dark

[auth]
disable_login_form = false

[auth.anonymous]
enabled = true
org_name = admin@localhost
org_role = Admin

[auth.basic]
enabled = false

[emails]
welcome_email_on_sign_up = false

[log]
mode = console file
level = info

[log.console]
level =
format = console

[log.file]
level =
format = text
log_rotate = true

max_lines = 1000000
max_size_shift = 28
daily_rotate = true
max_days = 7

[log.syslog]
level =
format = text

[dashboards.json]
enabled = true
path = /var/lib/grafana/dashboards

[alerting]
enabled = true
execute_alerts = true

[metrics]
enabled           = false
interval_seconds  = 10
EOF
