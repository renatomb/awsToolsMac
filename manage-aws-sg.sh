#!/bin/bash

# SCRIPT DE GERENCIAMENTO DE SECURITY GROUPS AWS
# Objetivo: Gerenciar as regras do security group via linha de comando
# Baseado nas instrucoes do cli disponiveis em: http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-sg.html
# Autor: Renato Monteiro Batista
# Versao 1.0

export SGID=sg-99999999
export GNAME="GroupName: meugrupo"
export LASTGROUP=sg-99999999
wget http://www.rmbinformatica.com/ip/txt/ -O aws-update.var -o wget.log
source aws-update.var
rm -f aws-update.var wget.log
#export KG=true
while true; do
   clear
   echo "Gerenciamento de security group AWS"
   echo "v1.0 (C) Renato Monteiro Batista"
   echo "==================================="
   echo "Gerenciando: $SGID"
   if [[ $SGID = "sg-99999999" ]]; then
      echo "GRUPO: meugrupo"
   else
      GNAME=`aws ec2 describe-security-groups --group-ids $SGID | grep GroupName`
      echo $GNAME
      LASTGROUP=SGID
   fi
   echo "Seu IP publico: $MYIP"
   echo "==================================="
   echo "1) Liberar acesso completo para meu ip"
   echo "2) Listar regras atuais do grupo"
   echo "3) Liberar acesso para outro ip"
   echo "4) Criar novo security group"
   echo "5) Remover security group"
   echo "6) Gerenciar outro grupo"
   echo "7) Listar todos os grupos"
   echo "8) Remover permissao para endereco IP"
   echo "X) Sair"
   read -p "Escolha sua opcao: " op
   case $op in
        [1]* ) aws ec2 authorize-security-group-ingress --group-id $SGID --protocol -1 --cidr $MYIP/32; read -p "Pressione enter para continuar...";;
        [2]* ) aws ec2 describe-security-groups --group-ids $SGID; read -p "Pressione enter para continuar...";;
        [3]* ) read -p "Bloco CIDR: " BLCIDR; read -p "Informe o protocolo (tcp, udp, icmp, ou -1 para todos): " PROTOCOLO;
               if [[ $PROTOCOLO = "icmp" ]]; then
                  aws ec2 authorize-security-group-ingress --group-id $SGID --protocol icmp --cidr $BLCIDR; 
               else
                  read -p "Informe a porta $PROTOCOLO: " PROTOPORT
                  aws ec2 authorize-security-group-ingress --group-id $SGID --protocol $PROTOCOLO --port $PROTOPORT --cidr $BLCIDR;
               fi
             read -p "Pressione ENTER para continuar..."
             ;;
        [4]* ) read -p "Informe o nome do grupo: " GPNAME; read -p "Informe a descricao do grupo: " GPDESC; echo "Criando..."; aws ec2 create-security-group --group-name $GPNAME --description "$GPDESC";read -p "Comando executado, pressione enter tecla para continuar...";;
        [5]* ) aws ec2 delete-security-group --group-id $SGID; read -p "Comando executado, pressione ENTER para continuar"; aws ec2 describe-security-groups; read -p "Informe a ID do grupo a administrar " SGID;;
        [6]* ) read -p "Informe a ID do grupo (ex.: $SGID) " SGID;;
        [7]* ) aws ec2 describe-security-groups; read -p "Comando executado, pressione ENTER para continuar...";;
        [7]* ) aws ec2 describe-security-groups; read -p "Comando executado, pressione ENTER para continuar...";;
        [8]* ) read -p "Bloco cidr: " RMCIDR; aws ec2 revoke-security-group-ingress --group-id $SGID --protocol -1 --cidr $RMCIDR;; 
        [Xx]* ) echo "Encerrando...";exit;;
        * ) echo "Opcao invalida!";;
   esac
#   done
done
