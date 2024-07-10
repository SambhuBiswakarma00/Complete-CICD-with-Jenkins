sudo mkdir loki_promtail
cd loki_promtail

sudo wget https://github.com/grafana/loki/releases/download/v3.1.0/loki-linux-amd64.zip
sudo wget https://github.com/grafana/loki/releases/download/v3.1.0/promtail-linux-amd64.zip

sudo unzip loki-linux-amd64.zip
sudo unzip promtail-linux-amd64.zip 


wget https://raw.githubusercontent.com/grafana/loki/v3.1.0/cmd/loki/loki-local-config.yaml
wget https://raw.githubusercontent.com/grafana/loki/v3.1.0/clients/cmd/promtail/promtail-local-config.yaml

nohup sudo ./loki-linux-amd64 -config.file=loki-local-config.yaml &> prometheus.log &