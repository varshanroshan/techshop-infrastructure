# TechShop Infrastructure Project

**Projet de Synthèse - EFREI M1-CSAI - Cloud Computing**

Ce dépôt contient l'infrastructure complète pour déployer l'application e-commerce microservices "TechShop". Le projet couvre la conteneurisation (Docker), l'orchestration (Kubernetes), l'Infrastructure as Code (Terraform) et le CI/CD (GitHub Actions).

## Table des Matières
1. [Architecture](#architecture)
2. [Déploiement Local (Docker Compose)](#déploiement-local)
3. [Déploiement Kubernetes](#déploiement-kubernetes)
4. [Infrastructure as Code (Terraform)](#infrastructure-as-code-terraform)
5. [CI/CD (GitHub Actions)](#cicd)
6. [Observabilité & Sécurité](#observabilité--sécurité)

---

## Architecture

L'application TechShop est composée des microservices suivants :
* **API Gateway** (Node.js/Express) : Point d'entrée pour le routage (Port 3000)
* **User Service** (Python/FastAPI) : Gestion des utilisateurs couplée à une base de données PostgreSQL (Port 8001)
* **Product Service** (Java/Spring Boot) : Catalogue de produits (Port 8002)
* **Order Service** (Go) : Gestion des commandes (Port 8003)

### Services d'Infrastructure
* **PostgreSQL** : Base de données principale gérant l'état pour les services (User Service)
* **Redis** : Cache en mémoire
* **RabbitMQ** : File de messages asynchrone

*Toutes les images applicatives (`api-gateway`, `user-service`, `product-service`, `order-service`) sont construites avec des **multi-stage builds** Docker pour garantir des images légères et optimisées.*

---

## Déploiement Local

Pour un environnement de développement local rapide, vous pouvez utiliser Docker Compose.

```bash
git clone https://github.com/varshanroshan/techshop-infrastructure.git
cd techshop-infrastructure

# Lancer tous les services
docker compose -f docker/docker-compose.yml up -d
```

---

## Déploiement Kubernetes

L'orchestration de production est gérée avec Kubernetes. Les manifests se trouvent dans `kubernetes/base`.

### Prérequis
* Un cluster Kubernetes actif (Minikube, KinD, Docker Desktop ou Cloud Kubernetes Engine).
* `kubectl` configuré pour pointer vers votre cluster.

### Déploiement
1. Créez un namespace pour le projet et déployez les composants d'infrastructure de base (Postgres, Secrets, ConfigMaps) :
   ```bash
   kubectl create namespace techshop
   cd kubernetes/base
   
   kubectl apply -f postgres-secret.yaml
   kubectl apply -f postgres.yaml
   kubectl apply -f redis.yaml
   kubectl apply -f rabbitmq.yaml
   kubectl apply -f api-gateway-configmap.yaml
   ```

2. Déployez les services applicatifs de la plateforme :
   ```bash
   kubectl apply -f user-service.yaml
   kubectl apply -f product-service.yaml
   kubectl apply -f order-service.yaml
   kubectl apply -f api-gateway.yaml
   ```

3. Exposez l'application via un Ingress Controller (par exemple, Nginx Ingress) :
   ```bash
   kubectl apply -f ingress.yaml
   ```
   *Note : L'Ingress est configuré pour supporter le **HTTPS (TLS)** via le secret `techshop-tls-secret`. N'oubliez pas d'ajouter une résolution DNS locale dans votre fichier `/etc/hosts`:* `127.0.0.1 techshop.local`

4. Appliquez les stratégies de sécurité (Network Policies) et l'AutoScaling (HPA) :
   ```bash
   kubectl apply -f networkpolicy-postgres.yaml
   kubectl apply -f networkpolicy-user-service.yaml
   kubectl apply -f hpa-product-service.yaml
   ```

---

## Infrastructure as Code (Terraform)

L'infrastructure Cloud (AWS) est gérée avec Terraform pour créer un Cluster Elastic Kubernetes Service (EKS). 
L'état est distant et collaboratif via le backend d'état **(Amazon S3 + DynamoDB)**, garantissant la sécurité des déploiements.
Le code Terraform est modulaire et divisé en environnements distincts **(dev, prod)**.

```bash
cd terraform

# Initialisation des plugins AWS et Modules locaux
terraform init

# Validation du code
terraform validate

# Planification et provisionnement (Nécessite des identifiants AWS configurés)
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"
```
> Le cluster provisionné par défaut s'appelle `techshop-cluster` et inclut la configuration VPC (Public/Private Subnets, NAT Gateways).

---

## CI/CD

L'intégration et le déploiement continus sont gérés par **GitHub Actions**.
Le pipeline (`.github/workflows/ci.yml`) réalise automatiquement les tâches suivantes sur chaque push vers la branche `main` :

1. **Build** : Construction des images Docker avec Docker Compose.
2. **Scanner de Vulnérabilités** : Analyse des images avec Trivy pour identifier les failles critiques.
3. **Déploiement Simulatif** : Affichages des étapes pour appliquer les manifests `kubectl` dans le cas d'un pipeline complet.

---

## Observabilité & Sécurité

### Sécurité
* **Secrets** : Les mots de passe (comme ceux de PostgreSQL) sont stockés sous forme de `Secrets` Opaque dans Kubernetes.
* **Network Policies** : Limitation du trafic entrant vers les bases de données afin d'éviter les accès non autorisés.
* **Image Pull Policy** : Stratégie stricte de récupération des images en versionnant par tag explicite (`1.0`).

### Liveness et Readiness
Des `LivenessProbes` et `ReadinessProbes` HTTP sont implémentées pour les services applicatifs pour vérifier leur santé opérationnelle. Par exemple, le `api-gateway` et le `user-service`.

### Auto-Scaling (HPA)
Des **Horizontal Pod Autoscalers (HPA)** surveillent la charge CPU et allouent dynamiquement entre 1 et 5 pods au `product-service` pour gérer les montées de charge.

### Observabilité (Monitoring et Logging)
La stack complète d'observabilité de base a été mise en place avec le **Kube-Prometheus-Stack** (Prometheus, Grafana) pour les métriques et **Loki-Stack** (Loki, Promtail) pour les logs centralisés.
Un script automatisé Helm a été fourni pour installer la stack complète :
```bash
bash monitoring/setup.sh
```
Une fois déployé, vous pouvez accéder aux Dashboards Grafana sur la machine locale via :
`kubectl port-forward svc/prometheus-grafana 8080:80 -n monitoring`
