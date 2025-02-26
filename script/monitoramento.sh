#!/bin/bash

sudo curl -s localhost > /var/log/conexao.log

webhook="(insira aqui a url do seu webhook)"
data=$(sudo date +%d/%m/%Y" - "%H:%M:%S)

if sudo grep -q "<!DOC" /var/log/conexao.log 
then
	msg="$data - Requisição HTTP feita no site NGINX :white_check_mark:"
	echo $msg >> /var/log/monitoramento.log
else
	msg="$data - Falha de conexão do servidor NGINX na porta 80, o servidor será  reniciado :warning: :warning: :warning:"
	echo $msg >> /var/log/monitoramento.log
	sudo systemctl restart nginx.service
fi

sudo curl -H "Content-Type: application/json" -X POST -d  "{\"content\":\"$msg\"}" "$webhook"