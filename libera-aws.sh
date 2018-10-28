#!/bin/bash

# SCRIPT DE LIBERACAO AUTOMATICA DO MEU IP NO AWS SECURITY GROUP
# Objetivo: Liberar acesso ao servidor a partir da minha conexao a internet atual. 
# Baseado nas instrucoes do cli disponiveis em: http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-sg.html
# Autor: Renato Monteiro Batista
# Versao 1.0 - 27 Nov 2014.

# Parâmetros de configuração (alterar para os ids do security group padrão e vpn)
export SGID=sg-99999999
export SGVPN=sg-99999999

echo "=====CONFIGURACAO ATUAL DO SECURITY GROUP====="
read -p "====> Qual grupo deseja listar? Padrao ou VPN? (p/v) " -n 1;echo
if [[ $REPLY =~ ^[Pp]$ ]]; then
   aws ec2 describe-security-groups --group-ids $SGID
fi
if [[ $REPLY =~ ^[Vv]$ ]]; then
   aws ec2 describe-security-groups --group-ids $SGVPN
fi   
wget http://www.rmbinformatica.com/ip/txt/ -O aws-update.var -o wget.log
source aws-update.var
read -p "====> Deseja incluir $MYIP na lista de liberacoes do sg? (y/n) " -n 1;echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
   aws ec2 authorize-security-group-ingress --group-id $SGID --protocol -1 --cidr $MYIP/32
else
   read -p "====> Deseja liberar apenas acesso vpn e ping? (y/n) " -n 1;echo
   if [[ $REPLY =~ ^[Yy]$ ]]; then
      aws ec2 authorize-security-group-ingress --group-id $SGVPN --ip-permissions "{\"FromPort\":-1,\"ToPort\":-1,\"IpProtocol\":\"icmp\",\"IpRanges\":[{\"CidrIp\": \"$MYIP/32\"}]}"  
      aws ec2 authorize-security-group-ingress --group-id $SGVPN --ip-permissions "{\"FromPort\":1723,\"ToPort\":1723,\"IpProtocol\":\"tcp\",\"IpRanges\":[{\"CidrIp\": \"$MYIP/32\"}]}"  
      aws ec2 authorize-security-group-ingress --group-id $SGVPN --ip-permissions "{\"FromPort\":-1,\"ToPort\":-1,\"IpProtocol\":\"47\",\"IpRanges\":[{\"CidrIp\": \"$MYIP/32\"}]}"  

   fi
fi
rm -f aws-update.var wget.log
