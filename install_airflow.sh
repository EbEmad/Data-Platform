# Check if kind cluster already exists before creating it
if ! kind get clusters | grep -q "^kind$"; then
  kind create cluster --image kindest/node:v1.29.4
else
  echo "Kind cluster 'kind' already exists, skipping creation."
fi


# Add airflow to my Helm repo
helm repo add apache-airflow https://airflow.apache.org
helm repo update

# Download the specific chart version to avoid download timeout during Helm installation
CHART_FILE="chart/airflow-1.16.0.tgz"
if [ ! -f "$CHART_FILE" ]; then
    echo "Downloading Airflow Helm chart version 1.16.0..."
    curl -L --retry 3 --retry-delay 5 --connect-timeout 30 -o "$CHART_FILE" \
        "https://archive.apache.org/dist/airflow/helm-chart/1.16.0/airflow-1.16.0.tgz"
else
    echo "Airflow Helm chart version 1.16.0 already downloaded."
fi

helm show values "$CHART_FILE" > chart/values-example.yaml

# Export values for Airflow docker image
export IMAGE_NAME=my-dags
export IMAGE_TAG=$(date +%Y%m%d%H%M%S)
export NAMESPACE=airflow
export RELEASE_NAME=airflow


# Build the image and load it into kind
docker build --pull --tag $IMAGE_NAME:$IMAGE_TAG -f cicd/Dockerfile .
kind load docker-image $IMAGE_NAME:$IMAGE_TAG


# Create a namespace if it does not already exist
kubectl get namespace $NAMESPACE &>/dev/null || kubectl create namespace $NAMESPACE


#Apply kubernetes secrets
# kubectl apply -f k8s/secrets/git-secrets.yaml

# Install or upgrade Airflow using Helm (pinning to stable chart 1.16.0 which uses Airflow 2.10.5)
helm upgrade --install $RELEASE_NAME "$CHART_FILE" \
    --namespace $NAMESPACE -f chart/values-override.yaml \
    --set-string images.airflow.tag="$IMAGE_TAG" \
    --debug

# Port forward the Webserver
kubectl port-forward svc/$RELEASE_NAME-webserver 8080:8080 --namespace $NAMESPACE