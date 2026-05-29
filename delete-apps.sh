#!/bin/bash

kubectl get applications -n argocd -o name | xargs kubectl delete -n argocd