\# Tag 11 – Monitoring mit Node Exporter, Prometheus und Grafana



\## Ziel



Die TechStyle-EC2-Instanzen sollen automatisch von Prometheus erkannt und mit \*\*Node Exporter\*\* überwacht werden.



Die System-Metriken werden anschließend in \*\*Grafana\*\* visualisiert.



\## Architektur



```text

TechStyle EC2

&#x20;   │

&#x20;   │ Node Exporter :9100

&#x20;   ▼

Prometheus

&#x20;   │

&#x20;   │ AWS EC2 Service Discovery

&#x20;   │ ec2\_sd\_configs

&#x20;   ▼

Grafana

&#x20;   │

&#x20;   ├── CPU Usage

&#x20;   ├── Memory Usage

&#x20;   └── Disk Usage

```



\---



\## 1. Node Exporter



Auf dem TechStyle-Webserver wurde \*\*Node Exporter\*\* installiert.



Installation:



```bash

sudo apt update

sudo apt install -y prometheus-node-exporter

```



Service aktivieren und starten:



```bash

sudo systemctl enable --now prometheus-node-exporter

```



Status prüfen:



```bash

sudo systemctl status prometheus-node-exporter --no-pager

```



Der Service läuft auf Port:



```text

9100

```



Die Metriken können lokal getestet werden:



```bash

curl http://localhost:9100/metrics

```



Wenn Node Exporter funktioniert, werden verschiedene System-Metriken ausgegeben, zum Beispiel:



```text

node\_cpu\_seconds\_total

node\_memory\_MemAvailable\_bytes

node\_filesystem\_avail\_bytes

```



\---



\## 2. AWS Security Group



Damit Prometheus den Node Exporter erreichen kann, muss TCP-Port `9100` auf der TechStyle-EC2 erreichbar sein.



Die Terraform-Konfiguration der TechStyle-Infrastruktur wurde deshalb um Port `9100` erweitert.



Beispiel:



```hcl

ingress {

&#x20; description = "Prometheus Node Exporter"

&#x20; from\_port   = 9100

&#x20; to\_port     = 9100

&#x20; protocol    = "tcp"

&#x20; cidr\_blocks = \["0.0.0.0/0"]

}

```



Für eine produktive Umgebung sollte der Zugriff stärker eingeschränkt werden, zum Beispiel auf das Monitoring-Netzwerk bzw. die entsprechende Security Group.



\---



\## 3. AWS IAM Role für Prometheus



Prometheus benötigt Zugriff auf die AWS EC2 API, damit die EC2-Instanzen automatisch gefunden werden können.



Auf der Monitoring-EC2 wurde deshalb das AWS Instance Profile



```text

LabInstanceProfile

```



zugewiesen.



Dieses verwendet im AWS Learner Lab die:



```text

LabRole

```



Dadurch kann Prometheus die AWS EC2 API verwenden, ohne AWS Access Keys direkt in der Prometheus- oder Docker-Konfiguration zu speichern.



\---



\## 4. AWS EC2 Service Discovery



Prometheus verwendet `ec2\_sd\_configs`, um laufende EC2-Instanzen automatisch über die AWS API zu erkennen.



Die verwendete Konfiguration:



```yaml

global:

&#x20; scrape\_interval: 15s

&#x20; evaluation\_interval: 15s



scrape\_configs:



&#x20; - job\_name: "prometheus"

&#x20;   static\_configs:

&#x20;     - targets: \["localhost:9090"]



&#x20; - job\_name: "cadvisor"

&#x20;   static\_configs:

&#x20;     - targets: \["cadvisor:8080"]



&#x20; - job\_name: "techstyle-node"

&#x20;   metrics\_path: "/metrics"

&#x20;   scheme: "http"



&#x20;   ec2\_sd\_configs:

&#x20;     - region: "us-east-1"

&#x20;       port: 9100

&#x20;       filters:

&#x20;         - name: instance-state-name

&#x20;           values: \["running"]



&#x20;   relabel\_configs:



&#x20;     # Nur TechStyle EC2-Instanzen verwenden

&#x20;     - source\_labels: \[\_\_meta\_ec2\_tag\_Name]

&#x20;       regex: "techstyle-pa4-gha-.\*-ec2"

&#x20;       action: keep



&#x20;     # Nur Instanzen mit Public IP verwenden

&#x20;     - source\_labels: \[\_\_meta\_ec2\_public\_ip]

&#x20;       regex: (.+)

&#x20;       action: keep



&#x20;     # Public IP als Scrape-Adresse verwenden

&#x20;     - source\_labels: \[\_\_meta\_ec2\_public\_ip]

&#x20;       target\_label: \_\_address\_\_

&#x20;       replacement: '${1}:9100'



&#x20;     # EC2 Name als Instance Label

&#x20;     - source\_labels: \[\_\_meta\_ec2\_tag\_Name]

&#x20;       target\_label: instance



&#x20;     # EC2 Instance ID

&#x20;     - source\_labels: \[\_\_meta\_ec2\_instance\_id]

&#x20;       target\_label: instance\_id



&#x20;     # Availability Zone

&#x20;     - source\_labels: \[\_\_meta\_ec2\_availability\_zone]

&#x20;       target\_label: availability\_zone



&#x20;     # Instance Type

&#x20;     - source\_labels: \[\_\_meta\_ec2\_instance\_type]

&#x20;       target\_label: instance\_type



&#x20;     # Private IP als zusätzliches Label

&#x20;     - source\_labels: \[\_\_meta\_ec2\_private\_ip]

&#x20;       target\_label: private\_ip

```



\---



\## 5. Warum wird die Public IP verwendet?



Prometheus hat die TechStyle-Instanzen zunächst korrekt über AWS erkannt.



Als Scrape-Adresse wurde jedoch automatisch die private IP verwendet:



```text

10.40.1.54:9100

```



Die Monitoring-VM befindet sich jedoch in einem anderen AWS-Netzwerk.



Ein Verbindungstest von der Monitoring-VM:



```bash

curl -v --connect-timeout 5 http://10.40.1.54:9100/metrics

```



führte deshalb zu:



```text

Connection timed out

```



Es bestand keine entsprechende private Netzwerkverbindung zwischen den beiden VPCs.



Deshalb wird mit `relabel\_configs` die öffentliche IP der EC2-Instanz als Prometheus-Scrape-Adresse gesetzt:



```yaml

\- source\_labels: \[\_\_meta\_ec2\_public\_ip]

&#x20; target\_label: \_\_address\_\_

&#x20; replacement: '${1}:9100'

```



Prometheus verwendet dadurch:



```text

Public-IP:9100

```



anstatt:



```text

Private-IP:9100

```



Danach konnte Prometheus den Node Exporter erfolgreich erreichen.



\---



\## 6. Prometheus Target prüfen



Die automatisch erkannten Targets können unter folgendem Pfad geprüft werden:



```text

http://<PROMETHEUS-IP>:9090/targets

```



Prometheus erkennt die TechStyle-Instanzen automatisch über AWS.



Die konfigurierte Instanz



```text

techstyle-pa4-gha-12-ec2

```



wird als:



```text

UP

```



angezeigt.



Eine ältere Instanz



```text

techstyle-pa4-gha-11-ec2

```



wird ebenfalls durch die EC2 Service Discovery gefunden.



Auf dieser Instanz wurde jedoch kein Node Exporter eingerichtet. Deshalb wird dieses Target als:



```text

DOWN

```



angezeigt.



Das zeigt gleichzeitig, dass die dynamische EC2 Service Discovery funktioniert.



\---



\## 7. Grafana Dashboard



In Grafana wurde ein Dashboard mit dem Namen



```text

TechStyle System Monitoring

```



erstellt.



Als Data Source wird \*\*Prometheus\*\* verwendet.



Das Dashboard enthält Metriken für:



\- CPU-Auslastung

\- RAM-Auslastung

\- Disk-Auslastung



\---



\## 8. CPU Usage



Für die CPU-Auslastung wird folgende PromQL-Abfrage verwendet:



```promql

100 - (

&#x20; avg by (instance) (

&#x20;   rate(

&#x20;     node\_cpu\_seconds\_total{

&#x20;       mode="idle",

&#x20;       job="techstyle-node"

&#x20;     }\[5m]

&#x20;   )

&#x20; ) \* 100

)

```



Grafana-Einstellungen:



```text

Title: CPU Usage

Visualization: Time series

Unit: Percent (0-100)

```



\---



\## 9. Memory Usage



Für die RAM-Auslastung wird folgende PromQL-Abfrage verwendet:



```promql

100 \* (

&#x20; 1 - (

&#x20;   node\_memory\_MemAvailable\_bytes{

&#x20;     job="techstyle-node"

&#x20;   }

&#x20;   /

&#x20;   node\_memory\_MemTotal\_bytes{

&#x20;     job="techstyle-node"

&#x20;   }

&#x20; )

)

```



Grafana-Einstellungen:



```text

Title: Memory Usage

Visualization: Time series

Unit: Percent (0-100)

```



\---



\## 10. Disk Usage



Für die Disk-Auslastung wird folgende PromQL-Abfrage verwendet:



```promql

100 \* (

&#x20; 1 -

&#x20; (

&#x20;   node\_filesystem\_avail\_bytes{

&#x20;     job="techstyle-node",

&#x20;     mountpoint="/",

&#x20;     fstype!="rootfs"

&#x20;   }

&#x20;   /

&#x20;   node\_filesystem\_size\_bytes{

&#x20;     job="techstyle-node",

&#x20;     mountpoint="/",

&#x20;     fstype!="rootfs"

&#x20;   }

&#x20; )

)

```



Grafana-Einstellungen:



```text

Title: Disk Usage

Visualization: Gauge

Unit: Percent (0-100)

Min: 0

Max: 100

```



\---



\## 11. Ergebnis



Die Anforderungen des Projektauftrags Tag 11 wurden umgesetzt:



\- \[x] Node Exporter auf dem TechStyle-Webserver eingerichtet

\- \[x] Node Exporter läuft auf Port `9100`

\- \[x] Security Group für Port `9100` erweitert

\- \[x] AWS `LabInstanceProfile` / `LabRole` für Prometheus verwendet

\- \[x] Dynamische `scrape\_config` mit `ec2\_sd\_configs` eingerichtet

\- \[x] TechStyle-EC2-Instanzen werden automatisch über AWS erkannt

\- \[x] Public IP wird automatisch als Scrape-Adresse verwendet

\- \[x] Prometheus fragt Node Exporter erfolgreich ab

\- \[x] TechStyle Target wird in Prometheus als `UP` angezeigt

\- \[x] Grafana-Dashboard mit CPU-, RAM- und Disk-Metriken erstellt

