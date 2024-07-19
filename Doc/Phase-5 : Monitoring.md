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
      scrape_interval: 15s
    
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
    ```
Run Prometheus:
- Start Prometheus with the custom configuration file.
    ```
     nohup sudo ./prometheus &> prometheus.log &
    ```
    
## Step 2: Install Loki

Download Loki:
- Download the latest Loki release from the Loki releases page.This step has already be done with ansible in phase 1.

  
Configure Loki:
- cd to loki_promtail dir
- Create a loki-config.yaml configuration file.
    ```
    auth_enabled: false
    
    server:
      http_listen_port: 3100
    
    ingester:
      lifecycler:
        ring:
          kvstore:
            store: inmemory
          replication_factor: 1
      chunk_idle_period: 5m
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
- Open Grafana in your web browser (http://localhost:3000) and log in (default user: admin, password: admin).
- Go to Configuration -> Data Sources -> Add data source.
- Select Prometheus and set the URL to http://localhost:9090.
- Save & test the data source.

Add Loki Data Source:
- Go to Configuration -> Data Sources -> Add data source.
- Select Loki and set the URL to http://localhost:3100.
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
