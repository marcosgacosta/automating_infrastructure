# Intro
Este proyecto forma parte de la certificación DevOps de MundosE, y la consigna del mismo es _utilizar GitHub Actions para desplegar un Apache
en una EC2 utilizando Terraform._
El objetivo de este Proyecto Integrador es integrar las siguientes tecnologías en un proyecto:
1. GitHub Actions
2. Apache
3. Amazon Web Services
    - DynamoDB
    - EC2
    - S3
5. Terraform

El objetivo es didáctico por lo que el enfoque es limitado y un caso de uso real podría incorporar tecnologías y métodos más avanzados.


#Primer Paso: Crear los archivos de Terraform

DynamoDB y S3 serán utilizados para conservar los archivos Terraform State lo cual permite la colaboración de múltiples usuarios sobre la misma infraestructura. Pero eso será implementado más adelante. Primero generaremos el archivo que va a crear la instancia EC2 y los requerimientos de red necesarios para que funcione.

El siguiente diagrama muestra lo que sería el resultado de correr el Terraform File (main.tf):

![Diagrama mostrando el resultado de _main.tf_.](/assets/diagrams/MainTFDiagram.png)




