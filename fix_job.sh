#!/bin/bash

vm_name=$1

job_name="v2v-helper-$vm_name"



sudo kubectl get job -n migration-system $job_name -o json \
| jq 'del(
    .metadata.uid,
    .metadata.resourceVersion,
    .metadata.creationTimestamp,
    .metadata.generation,
    .metadata.annotations,
    .metadata.labels,
    .metadata.ownerReferences,
    .spec.selector,
    .spec.manualSelector,
    .spec.template.metadata.annotations,
    .spec.template.metadata.creationTimestamp,
    .spec.template.metadata.labels["controller-uid"],
    .spec.template.metadata.labels["batch.kubernetes.io/controller-uid"],
    .spec.template.metadata.labels["batch.kubernetes.io/job-name"],
    .status
  )
  | .spec.template.spec.containers[0].resources.limits.memory = "6Gi"
  | .spec.template.spec.containers[0].resources.limits["ephemeral-storage"] = "5Gi"
  | .spec.template.spec.containers[0].resources.limits.cpu = "4"' \
| tee $job_name.job.json 
sudo kubectl delete job -n migration-system $job_name --ignore-not-found 
sudo kubectl apply -f $job_name.job.json

