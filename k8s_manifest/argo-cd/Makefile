upgrade-eks:
	helm upgrade -i argocd \
		-n argocd \
		--create-namespace \
		-f values-eks.yaml \
		.

delete:
	helm delete -n argocd argocd

template-eks:
	helm template -n argocd -f values-eks.yaml argocd .