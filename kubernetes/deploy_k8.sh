export KUBECONFIG=${pwd}/config/config.yaml
kubectl get nodes

kubectl apply -f generated/vrtuoso/templates/cluster-setup/mandatory.yaml;
kubectl apply -f generated/vrtuoso/templates/cluster-setup/cloud-generic.yaml;
kubectl apply -f generated/vrtuoso/templates/cluster-setup/do_nginx-ingress-controller.yaml;

kubectl delete -f generated/vrtuoso/templates/migrations;
kubectl apply -f generated/vrtuoso/templates/migrations;
kubectl apply -f generated/vrtuoso/templates/secrets;
kubectl apply -f generated/vrtuoso/templates/deployments;
kubectl apply -f generated/vrtuoso/templates/svcs;
kubectl apply -f generated/vrtuoso/templates/ingress/ingress.yaml;
