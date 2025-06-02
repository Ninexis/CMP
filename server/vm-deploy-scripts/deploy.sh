#!/bin/bash

#Pour que si jamais il y a une erreur le script s'arrête
set -e



### VARIABLES ####

#---- Récupération du numéro des VM dans OpenStack, du script d'installation du back et création des noms de VM ----

COUNTER_FILE=".deploy_counter"

# Initialise le compteur si non existant
if [ ! -f "$COUNTER_FILE" ]; then
  echo 1 > "$COUNTER_FILE"
fi

# Récupère la valeur actuelle du compteur
COUNT=$(cat "$COUNTER_FILE")

# Récupère le script cloud-init.sh
USER_DATA=$(base64 -w 0 cloud-init.sh)

#Crée les noms uniques
VM_NAME_1="vm-backend-master-${COUNT}"
VM_NAME_2="vm-backend-slave-${COUNT}"

#----------------------- Récupération du port pour le port-forwarding dans les scripts Ansible ----------------------

# Étape 1 : Lire et incrémenter le port actuel
PORT_FILE="current_port.txt"
START_PORT=8080

if [[ ! -f $PORT_FILE ]]; then
  echo $START_PORT > $PORT_FILE
fi

CURRENT_PORT=$(cat $PORT_FILE)
PORT=$((CURRENT_PORT + 1))

#---------------------------------------------------------------------------------------------------------------------




### SCRIPTS ###

#--------- Lancement des scripts Terraform pour le déploiement des VM dans OpenStack et l'installation du back -------

echo "==> Initialisation de Terraform"
terraform -chdir=../terraform-scripts init

echo "==> Déploiement dans l'environnement 1 avec le nom $VM_NAME_1"
terraform -chdir=../terraform-scripts apply -var-file=env1.tfvars -var="vm_name=${VM_NAME_1}" -var="user_data=${USER_DATA}" -auto-approve
VM1_INTERNAL_IP=$(terraform -chdir=../terraform-scripts output -raw floating_ip_address)
echo "✅ VM $VM_NAME_1 déployée et prêtes. IP Interne : $VM1_INTERNAL_IP"

echo "==> Déploiement dans l'environnement 2 avec le nom $VM_NAME_2"
terraform -chdir=../terraform-scripts apply -var-file=env2.tfvars -var="vm_name=${VM_NAME_2}" -var="user_data=${USER_DATA}" -auto-approve
VM2_INTERNAL_IP=$(terraform -chdir=../terraform-scripts output -raw floating_ip_address)
echo "✅ VM $VM_NAME_2 déployée et prêtes. IP Interne : $VM2_INTERNAL_IP"

# Incrémente le compteur si tout s'est bien passé
NEXT_COUNT=$((COUNT + 1))
echo "$NEXT_COUNT" > "$COUNTER_FILE"

echo "✅ Backend redondant déployé : $VM_NAME_1 et $VM_NAME_2 sont deployées et prêtes."

#------------------------------ Lancement des scripts Ansible pour le Port-forwarding ---------------------------------

echo "Démarrage des scripts Ansible pour le Port-forwarding ..."

cat > port_forwarding/vars/openstack-host-1.yml <<EOF
backend_vm_ip: $VM1_INTERNAL_IP
external_port: "$PORT"
EOF

cat > port_forwarding/vars/openstack-host-2.yml <<EOF
backend_vm_ip: $VM2_INTERNAL_IP
external_port: "$PORT"
EOF

cd port_forwarding/

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini port_forward.yml

cd ..

#Sauvegarder le port actuel
echo $PORT > $PORT_FILE

#----------------------------------------------------------------------------------------------------------------------


printf "\n\n✅ Backend redondant déployé et disponible sur \n\n(master) 34.159.53.80:$PORT \n(slave) 34.88.21.66:$PORT \n\n(attendre ~2 min pour pouvoir curl)\n\n"
