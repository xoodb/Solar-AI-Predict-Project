upgrade-monitoring:
	helm upgrade -i prometheus-grafana \
		-n monitoring \
		--create-namespace \
		-f values-monitoring.yaml \
		.

delete:
	helm delete -n monitoring prometheus-grafana