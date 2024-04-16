/* Update Kubeconfig */
resource "local_file" "update_kubeconfig_sh" {
  content  = <<-EOT
CLUSTER_NAME=${module.eks.cluster_id}
aws eks update-kubeconfig --region ap-northeast-2 --name $CLUSTER_NAME --alias $CLUSTER_NAME
    EOT
  filename = "sh/00.update-kubeconfig.sh"
}

/* ADD ALB-controller */
resource "local_file" "aws_load_balancer_controller_sh" {
  content  = <<-EOT
# Deploy alb_cotroller
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.4.1/cert-manager.yaml

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=${module.eks.cluster_id} -n kube-system --set serviceAccount.create=true --set nodeSelector.role=builders
    EOT
  filename = "sh/01.aws_load_balancer_controller.sh"
}

/* ADD Cluster-Autoscaler */
resource "local_file" "cluster_autoscaler_sh" {
  content  = <<-EOT
# Metric Server Install
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# connecting ServiceAccount to IAM Role
eksctl create iamserviceaccount \
--cluster=${module.eks.cluster_id} \
--namespace=kube-system \
--name=cluster-autoscaler \
--attach-role-arn=${module.cluster_autoscaler_irsa_role.iam_role_arn} \
--override-existing-serviceaccounts \
--region=${var.region} \
--approve

# Deploy Cluster Autoscaler
curl -o cluster-autoscaler-autodiscover.yaml https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
sed -i s/'<YOUR CLUSTER NAME>'/${module.eks.cluster_id}/g cluster-autoscaler-autodiscover.yaml
kubectl apply -f cluster-autoscaler-autodiscover.yaml
kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=${module.cluster_autoscaler_irsa_role.iam_role_arn}
kubectl patch deployment cluster-autoscaler \
-n kube-system \
-p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl patch deployments -n kube-system cluster-autoscaler -p '{"spec": {"template": {"spec": {"nodeSelector": {"role": "builders"}}}}}'
    EOT
  filename = "sh/02.cluster_autoscaler.sh"
}