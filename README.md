# Metabase Implementation

![Metabase Product Screenshot](docs/images/metabase-product-screenshot.svg)

### What is Metabase?
Metabase is a completely open source BI tool, this platform offers graphs, dashboards and other organizations using question-based data manipulation

### Get Start
The project was implemented in a containerized manner in the AWS cloud.
Using the Ohio region, the application is located in 3 different AZ's to guarantee high availability of the environment, so that container management is objective and efficient, we use ECS (Elastic Container Service) as an orchestrator.

### AWS ECS Fargate
O serviço do ECS está implementado como Fargate eliminando quaisquer gestão de instancias e seus SO (Sistema Operacional), o serviço possui seu próprio grupo de segurança bem como sua role permitindo o acesso aos demais serviços da AWS. Para garantir escalabilidade, foi implementado um serviço de Application LoadBalancer que recebe o tréfego na porta 443 (HTTPS) e encaminhando para o(s) container(s) de forma balanceada

### LOGS
O serviço possui a saída de logs integrada com o cloudwatch logs, foi escolhido este serviço devido ao seu menor gerenciamento por ser totalmente serverless

