# Monitoring 

To set up monitoring with Prometheus, Loki, and Grafana without using Helm and by using the manual binary method, you need to follow these steps:

## Step 1: Install Prometheus

Download Prometheus:
- Download the latest Prometheus release from the Prometheus releases page. This step has already be done with ansible in phase 1.

Configure Prometheus:
- cd to prometheus-2.41.0.linux-amd64
- Create a prometheus.yml configuration file.
    ```
    global:
      scrape_interval: 15s # How often to scrape targets by default
    
   # scrape_configs:
      - job_name: 'your_job_name' # Name of the scrape job
        static_configs:
          - targets: ['localhost:9090'] # Targets to scrape metrics from (Prometheus itself)
    ```
Run Prometheus:
- Start Prometheus with the custom configuration file.
    ```
     nohup sudo ./prometheus &> prometheus.log &
    ```
- Runs the Prometheus server as a background process.
- Redirects all output and errors to prometheus.log.
- Ensures the process continues running even if you log out of the session.

## Step 2: Install Loki

Download Loki and promtail:
- Download the latest Loki and promtail release from the Loki releases page.This step has already be done with ansible in phase 1. We need promtail as log shipper to collect logs from specfic targets.

Download Promtail:
Download the latest Promtail release from the Loki releases page.
    ```
    wget https://github.com/grafana/loki/releases/download/v2.7.1/promtail-linux-amd64.zip
    unzip promtail-linux-amd64.zip
    chmod a+x promtail-linux-amd64
    ```
Configure Promtail:
- cd to loki_promtail dir
- Create a promtail-config.yaml file to specify how and where Promtail collects logs and where to send them.
      
     ```
    server:
      http_listen_port: 9080
      grpc_listen_port: 0
    
    positions:
      filename: /tmp/positions.yaml
    
    clients:
      - url: http://localhost:3100/loki/api/v1/push # Loki server endpoint
    
    scrape_configs:
      - job_name: system
        static_configs:
          - targets:
              - localhost
            labels:
              job: varlogs
              __path__: /var/log/*.log # Path to log files to collect
    
      - job_name: my_app_logs
        static_configs:
          - targets:
              - localhost
            labels:
              job: my_app
              __path__: /path/to/my/app/logs/*.log # Path to application log files to collect
    ```
- Run Promtail with the custom configuration file.
    ```
    sudo ./promtail-linux-amd64 -config.file=promtail-config.yaml
    ```

Configure Loki:
- cd to loki_promtail dir
- Create a loki-config.yaml configuration file.
    ```
    auth_enabled: false # Disable authentication for the Loki server
    
    server:
      http_listen_port: 3100 # Port where Loki will listen for incoming requests
    
    ingester:
      lifecycler:
        ring:
          kvstore:
            store: inmemory # Store the ring information in-memory
          replication_factor: 1  # Number of times data is replicated
      chunk_idle_period: 5m # How long to wait before closing an idle chunk
      chunk_retain_period: 30s
      max_transfer_retries: 0
    
    schema_config:
      configs:
        - from: 2020-10-24
          store: boltdb-shipper
          object_store: filesystem
          schema: v11
          index:
            prefix: index_
            period: 168h
    
    storage_config:
      boltdb_shipper:
        active_index_directory: /tmp/loki/boltdb-shipper-active
        cache_location: /tmp/loki/boltdb-shipper-cache
        shared_store: filesystem
      filesystem:
        directory: /tmp/loki/chunks
    
    chunk_store_config:
      max_look_back_period: 0s
    
    table_manager:
      retention_deletes_enabled: false
      retention_period: 0s
    ```

Run Loki:
- Start Loki with the custom configuration file.
    ```
     nohup sudo ./loki-linux-amd64 -config.file=loki-local-config.yaml &> prometheus.log &
    ```

**Note** : While Loki itself doesn't scrape logs, you can add targets to your Promtail configuration to specify which logs to collect and send to Loki. The scrape_configs section in promtail-config.yaml allows you to define multiple log sources.

## Step 3: Install Grafana

Install Grafana:
- Install the grafana.This step has already be done with ansible in phase 1.

Configure Grafana:
- Grafana uses a default configuration file located at ```/etc/grafana/grafana```. ini . You can override settings by creating a custom grafana.ini file or by setting environment variables.

Run Grafana:
Start Grafana with the custom configuration file.
    ```
       sudo systemctl start grafana-server
    ```


## Step 4: Configure Grafana to use Prometheus and Loki as Data Sources

Add Prometheus Data Source:
- Open Grafana in your web browser (http://server_ip:8080)
- Go to Configuration -> Data Sources -> Add data source.
- Select Prometheus and set the URL to http://prometheus_server_ip:9090.
- Save & test the data source.

Add Loki Data Source:
- Go to Configuration -> Data Sources -> Add data source.
- Select Loki and set the URL to http://loki_server_ip:3100.
- Save & test the data source.

## Step 5: Create Dashboards in Grafana

Create Prometheus Dashboards:
- Go to Create -> Dashboard.
- Add a new panel and select Prometheus as the data source.
- Enter your desired Prometheus query to visualize metrics.

Create Loki Dashboards:
- Go to Create -> Dashboard.
- Add a new panel and select Loki as the data source.
- Enter your desired Loki query to visualize logs.


## Final Summary
- Install Prometheus: Download, configure (prometheus.yml), and run.
- Install Loki: Download, configure (loki-config.yaml), and run.
- Install Grafana: Download, configure (grafana.ini if needed), and run.
- Configure Grafana: Add Prometheus and Loki as data sources.
- Create Dashboards: Use Prometheus and Loki data sources to create dashboards in Grafana.

By following these steps, you can manually set up Prometheus, Loki, and Grafana for monitoring your infrastructure.
