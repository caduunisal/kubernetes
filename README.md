# kubernetes
Kubernetes Deployments


1. Pré-requisitos
Certifique-se de que você tem os seguintes componentes instalados em sua máquina virtualizada:
Docker

Kubernetes (kubectl, kubeadm, kubelet)

Minikube (opcional, se for testar localmente)

Helm (para gerenciamento de pacotes no Kubernetes)


Se ainda não tiver o Kubernetes instalado, você pode configurá-lo usando kubeadm:

# Instale o kubeadm, kubectl e kubelet
sudo apt update && sudo apt install -y kubeadm kubectl kubelet

# Inicialize o cluster Kubernetes (caso não tenha um)
sudo kubeadm init --pod-network-cidr=192.168.1.0/24

# Configure o usuário para acessar o cluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Instale um CNI (por exemplo, Calico para rede de containers)
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml


2. Criar o Deployment no Kubernetes
Agora, vamos criar um Deployment para gerenciar os dois servidores Nginx.
Crie um arquivo chamado nginx-deployment.yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
	app: nginx
spec:
  replicas: 2
  selector:
	matchLabels:
  	app: nginx
  template:
	metadata:
  	labels:
    	app: nginx
	spec:
  	containers:
  	- name: nginx
    	image: nginx:latest
    	ports:
    	- containerPort: 80


Agora, aplique esse Deployment ao cluster:

kubectl apply -f nginx-deployment.yaml


3. Criar um Service para Balanceamento de Carga
Para garantir a redundância entre os servidores, vamos criar um Service do tipo LoadBalancer (ou NodePort se estiver em um ambiente sem provedor de nuvem).
Crie um arquivo chamado nginx-service.yaml:

apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
	app: nginx
  ports:
	- protocol: TCP
  	port: 80
  	targetPort: 80
  type: NodePort


Agora, aplique esse serviço:
kubectl apply -f nginx-service.yaml

Verifique a porta aberta para acesso ao serviço:
kubectl get svc nginx-service


Se estiver usando Minikube, execute:
minikube service nginx-service


4. Testar e Validar a Redundância
   
Verifique se os pods do Nginx estão rodando:
kubectl get pods -o wide


Verifique se os serviços estão disponíveis:
kubectl get svc


Agora, você pode acessar o serviço via curl ou diretamente no navegador usando o IP do nó e a porta do NodePort.
curl http://<NODE-IP>:<PORT>


5. (Opcional) Adicionar um Ingress Controller
Para um controle mais avançado de tráfego, podemos adicionar um Ingress Controller, como o Nginx Ingress.
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml


Depois, criar uma regra de Ingress:

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
	nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: my-nginx.local
	http:
  	paths:
  	- path: /
    	pathType: Prefix
    	backend:
      	service:
        	name: nginx-service
        	port:
          	number: 80


Aplicar e testar:

kubectl apply -f nginx-ingress.yaml
curl -H "Host: my-nginx.local" http://<NODE-IP>


Resumo dos Componentes Utilizados

Kubernetes Cluster – Gerencia os containers.

Docker – Plataforma de containers.

Nginx Deployment – Criação de 2 instâncias do Nginx para redundância.

Kubernetes Service – Balanceamento de carga para distribuir o tráfego.

Ingress Controller (opcional) – Para controle avançado de rotas HTTP.


Isso garante que seu ambiente tenha alta disponibilidade e balanceamento de carga.


