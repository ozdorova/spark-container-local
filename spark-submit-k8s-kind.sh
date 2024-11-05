#!bin/bash
# Используется docker образ их официальной сборки spark и k8s на kind
# создается докер образ и отправляется в kind, после чего указвается мастер на k8s и сабмитится скрипт.
# python cкрипт передается через конфиг мап и созданием pod template 
# (пример в k8s-utils/spark-k8s-pod-template.yaml)
#
#
# kind create cluster
#
# ./bin/docker-image-tool.sh -t spark-k8s -p kubernetes/dockerfiles/spark/bindings/python/Dockerfile build
#
# kind load docker-image spark-py:spark-k8s
# 
# kubectl create serviceaccount spark
#
# kubectl create clusterrolebinding spark-role --clusterrole=edit --serviceaccount=default:spark --namespace=default
#
# пока скрипт передается через конфиг мап, потому что докер не видит local (файлы хоста)

# создается конфигмап с скриптов, после чего с помощью template передается в pod
kubectl create configmap spark-app --from-file=main.py=/Users/mbold1911/Documents/PROG/Pyth/pet_projects/spark_k8s_test/apps/main.py


spark-submit \
    --master k8s://127.0.0.1:62819 \
    --deploy-mode cluster \
    --name spark-k8s-test \
    --conf spark.executor.instances=2 \
    --conf spark.kubernetes.container.image=spark-py:spark-k8s \
    --conf spark.kubernetes.container.image.pullPolicy=IfNotPresent \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.kubernetes.driver.podTemplateFile=k8s-utils/spark-k8s-pod-template.yaml \
    --conf spark.kubernetes.executor.podTemplateFile=k8s-utils/spark-k8s-pod-template.yaml \
    local:///opt/spark/apps/main.py \
    100 

#
#
# kubectl port-forward <driver-pod-name> 4040:4040

