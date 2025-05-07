#### TO DO List

1 - Incorporar modulo para crear VPN site-to-site
    a - pendiente revisar outputs
    b - prueba con transit gateway
    c - asociacion de rutas
2 - Creacion de modulo para VPC peering 
3 - Analizar incorporacion de recursos para direct connect https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dx_connection 
4 - Revisar dependencias a la hora de crear/asociar rutas a la tabla de rutas (en el caso de tgw primero se debe crear la vpc/tgw y vpc-atachmetn y posterior a esto la creacion de la asociasion de rutas)
5 - Mejorar uso de variables de destination para route asociation
6 - Prueba de crear en el modulo de TGW un atachment sin estar invitado al RAM
7 - Generar logica para tomar control de la tabla de rutas default, NACL defaulty SG default
8 - Pruebas de IPv6 en los distintos recursos