########################################################################################
# IMPORTANT: This is NOT a substitute for documentation. Make sure that you understand #
# the configuration parameters you use in your configuration file.                     #
########################################################################################

##########################
# Topology Configuration #
##########################
# You can use IPs for the below as well, but hostnames are preferable.
ENDPOINT = 'Enter Loadbalancer or Hostname of Endpoint Here'
MASTER_MYSQL_SERVER_HOST = 'Enter Master MySQL Server Hostname Here'
SLAVE_MYSQL_SERVER_HOST = 'Enter Slave MySQL Server Hostname Here'
APP_SERVER_1 = 'Enter App/Proxy Server 1 Hostname Here'
APP_SERVER_2 = 'Enter App/Proxy Server 2 Hostname Here'
WORKER_SERVER = 'Enter Worker Server Hostname Here'
INFLUXDB_SERVER = 'Enter InfluxDB Server Hostname Here'
MEMCACHED_PORT = "11211"

####################
 # External Routing #
####################
enable_all false

proto = 'https'  # Set up the SSL settings and this to 'https' to use HTTPS

routing[:endpoint_scheme] = proto
routing[:endpoint_host] = ENDPOINT

routing[:graphics_scheme] = proto
routing[:graphics_host] = ENDPOINT

routing[:plotter_scheme] = proto
routing[:plotter_host] = ENDPOINT
routing[:plotter_port] = if proto == 'http' then 80 else 443 end

####################
# Internal Routing #
####################

## In the event of a failover event, change this to SLAVE_MYSQL_SERVER_HOST
app[:mysql_scalr_host] = MASTER_MYSQL_SERVER_HOST
app[:mysql_scalr_port] = 3306

## In the event of a failover event, change this to SLAVE_MYSQL_SERVER_HOST
app[:mysql_analytics_host] = MASTER_MYSQL_SERVER_HOST
app[:mysql_analytics_port] = 3306

# Memcached Servers
app[:memcached_servers] = [APP_SERVER_1 + ':' + MEMCACHED_PORT, APP_SERVER_2 + ':' + MEMCACHED_PORT]

# Look for the app and graphics locally as well
proxy[:app_upstreams] = ['127.0.0.1:6000']
proxy[:graphics_upstreams] = ['0.0.0.0:6100']
proxy[:plotter_upstreams]  = ['0.0.0.0:6200']

# Bind the proxy publicly
proxy[:bind_host] = '0.0.0.0'

# But bind locally, since it'll go through the proxy
web[:app_bind_host] = '127.0.0.1'
web[:app_bind_port] = 6000

web[:graphics_bind_host] = '0.0.0.0'
web[:graphics_bind_port] = 6100

service[:plotter_bind_host] = '0.0.0.0'
service[:plotter_bind_port] = 6200

# Bind MySQL publicly, because it'll need to be accessed by the app & worker
mysql[:bind_host] = '0.0.0.0'
mysql[:bind_port] = 3306

memcached[:bind_host] = '0.0.0.0'
memcached[:bind_port] = 11211

# Scalr Web/AMQP Host
app[:influxdb_host] = INFLUXDB_SERVER
influxdb[:http_bind_host] = '0.0.0.0'

app[:rabbitmq_host] = WORKER_SERVER
rabbitmq[:bind_host] = '0.0.0.0'
rabbitmq[:mgmt_bind_host] = '0.0.0.0'
proxy[:rabbitmq_upstreams] = [WORKER_SERVER]
