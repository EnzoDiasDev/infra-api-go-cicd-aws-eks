# METADATA
# title: Porta do PostgreSQL aberta para a internet
# description: |
#   Um security group libera a porta 5432 (PostgreSQL) para 0.0.0.0/0 ou ::/0.
#   As checagens padrão do Trivy não cobrem essa porta, então esta checagem
#   própria impede que o banco volte a ficar exposto.
# scope: package
# custom:
#   id: API-GO-0001
#   avd_id: API-GO-0001
#   provider: aws
#   service: ec2
#   severity: CRITICAL
#   short_code: no-public-postgres
#   recommended_action: Libere a 5432 só para o security group da aplicação ou para o CIDR da VPC.
#   input:
#     selector:
#       - type: cloud
#         subtypes:
#           - service: ec2
#             provider: aws
package user.aws.ec2.no_public_postgres

import rego.v1

porta_postgres := 5432

internet := {"0.0.0.0/0", "::/0"}

# Regra com protocolo "-1" vale para todas as portas.
cobre_a_porta(regra) if regra.protocol.value == "-1"

cobre_a_porta(regra) if {
	regra.fromport.value <= porta_postgres
	regra.toport.value >= porta_postgres
}

deny contains res if {
	some grupo in input.aws.ec2.securitygroups
	some regra in grupo.ingressrules
	cobre_a_porta(regra)
	some bloco in regra.cidrs
	bloco.value in internet
	res := result.new(sprintf("A porta %d (PostgreSQL) está aberta para %s.", [porta_postgres, bloco.value]), bloco)
}
