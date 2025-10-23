CRUD Profesor - Flask + Docker

Arquitectura
- 2 contenedores:
  - mysql_db: Base de datos MySQL 8.0
  - flask_app: Aplicación web Flask

Despliegue en AWS

1. Subir código a GitHub
git init
git add .
git commit -m "Aplicación CRUD Profesor con Flask y Docker"
git remote add origin https://github.com/TU-USUARIO/TU-REPO.git
git push -u origin main

2. Conectar a instancia AWS
ssh -i tu-llave.pem ubuntu@TU-IP-AWS

3. Instalar dependencias en AWS
sudo apt update
sudo apt install -y git docker.io docker-compose
sudo usermod -aG docker ubuntu
newgrp docker

4. Clonar repositorio y ejecutar
git clone https://github.com/TU-USUARIO/TU-REPO.git
cd TU-REPO
docker-compose up -d

5. Verificar contenedores
docker ps

6. Configurar Security Group en AWS
EC2 - Security Groups - Inbound Rules
Agregar: Custom TCP, Puerto 5000, Source: 0.0.0.0/0

7. Acceder a la aplicación
http://TU-IP-AWS:5000

Comandos útiles

Ver logs:
docker-compose logs -f

Detener contenedores:
docker-compose down

Reiniciar:
docker-compose restart

Ver contenedores:
docker ps
