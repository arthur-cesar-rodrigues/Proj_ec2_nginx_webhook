#!/bin/bash

# Atualizando os pacotes do Ubuntu
sudo apt-get update -y && sudo apt-get upgrade -y

# Instalando o Nginx
sudo apt-get install nginx -y

# Criando o arquivo HTML (a página do NGINX)
sudo cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Projeto Linux/AWS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light text-dark">
    
    <header class="bg-dark text-white text-center py-4">
        <h1 class="mb-0 fs-4">Projeto Linux/AWS</h1>
    </header>
    
    <div class="container mt-5">
        <section>
            <main class="mb-3 p-4 border bg-white">
                <h2 class="text-dark fs-4">Instâncias Amazon AWS EC2</h2>
                    <p >Uma instância EC2 é como se fosse uma Virtual Machine (VM) dentro da Amazon AWS, ou seja, é seu servidor na nuvem para rodar sua aplicação/serviço/sistema. Essa instância para funcionar precisa ao menos de: um nome, uma AMI (sistema operacional do servidor), configuração de rede (VPC e security group configurados), e um volumes EBS e seu tipo (é o recurso de armazenamento da Amazon AWS para as instâncias EC2).</p>

                    <h2 class="text-dark fs-4">NGINX</h2>
                    <p >O NGINX é um software que fornece recursos para os servidores web, sendo eles: carregar páginas web ("subir seu site na internet"), balanceador de carga e proxy reverso. No caso desse projeto, o NGINX foi usado pra subir uma página HTML simples (essa que você está lendo), para acessar página é necessário digitar o IP público desse servidor.</p>

                    <h2 class="text-dark fs-4">Webhooks Discord</h2>
                    <p >É uma maneira simples de enviar mensagens e notificações personalizadas para seu servidor. Neste projeto foi criado um Shell Script que envia uma mensagem (do formato JSON) usando o webhook do discord de acordo com o funcionamento do NGINX.</p>
            </main>
        </section>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
EOF

# Reiniciando o Nginx para aplicar as mudanças
sudo systemctl restart nginx

# Ativando o NGINX para iniciar junto do boot do servidor
sudo systemctl enable nginx

# Criando o script de monitoramento do NGINX
sudo cat <<EOF > /usr/bin/monitoramento.sh
#!/bin/bash

sudo curl -s localhost > /var/log/conexao.log

webhook="https://discord.com/api/webhooks/1343433089837170709/l0P39edxofzxcOqt9nzCK_NgEGMIXhdUbLuwMmtmyVd9sf3pWNqkCgfiYwueNBvagM_o"
data=\$(sudo date +%d/%m/%Y" - "%H:%M:%S)

if sudo grep -q "<!DOC" /var/log/conexao.log 
then
	msg="\$data - Requisição HTTP feita no site NGINX :white_check_mark:"
	echo \$msg >> /var/log/monitoramento.log
else
	msg="\$data - Falha de conexão do servidor NGINX na porta 80, o servidor será  reniciado :warning: :warning: :warning:"
	echo \$msg >> /var/log/monitoramento.log
	sudo systemctl restart nginx.service
fi

sudo curl -H "Content-Type: application/json" -X POST -d  "{\"content\":\"\$msg\"}" "\$webhook"
EOF

# Concedendo permissão de execução do script monitoramento.sh para todos os usuários
sudo chmod a+x /usr/bin/monitoramento.sh

# Criando um serviço que vai executar o script monitoramento.sh automaticamente (a cada 40 segundos)
sudo cat <<EOF > /etc/systemd/system/monitoramento.service
[Unit]
Description=Servico de monitoramento de disponibilidade da página NGINX.
After=network.target

[Service]
Restart=always
RestartSec=40
ExecStart=/usr/bin/monitoramento.sh

[Install]
WantedBy=multi-user.target
EOF

# Reniciando o Systemd (para que o serviço monitoramento.service funcione)
sudo systemctl daemon-reload

# Ativando o monitoramento.service para iniciar junto do boot do servidor
sudo systemctl enable monitoramento.service

# Iniciando o monitoramento.service
sudo systemctl start monitoramento.service
