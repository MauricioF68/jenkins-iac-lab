
-----

# Laboratorio de Infraestructura como Código con Jenkins

Implementación de un entorno de integración continua (CI) basado en Jenkins, configurado íntegramente mediante principios de **Infraestructura como Código (IaC)**.

El objetivo principal es eliminar la configuración manual ("ClickOps") garantizando la reproducibilidad, portabilidad y mantenibilidad del entorno. El sistema implementa una arquitectura distribuida utilizando **Docker-in-Docker (DinD)** para la gestión de agentes efímeros.

## Arquitectura del Proyecto

El entorno se orquesta mediante Docker Compose y consta de dos servicios principales que se comunican a través de una red interna dedicada:

1.  **Jenkins Controller (Master):** Instancia principal personalizada basada en la imagen `jenkins/jenkins:lts-jdk17`.
      * Gestión automatizada de plugins mediante CLI.
      * Configuración del sistema definida en YAML (JCasC).
      * Número de ejecutores en el maestro establecido a 0 para forzar el uso de agentes distribuidos.
2.  **Docker Daemon (Cloud Node):** Contenedor `dind` (Docker-in-Docker) que actúa como proveedor de nube.
      * Expone el socket de Docker vía TCP (puerto 2375).
      * Permite el aprovisionamiento dinámico de agentes de construcción bajo demanda.


## Requisitos Previos

  * **Docker Engine** (Versión 20.10+)
  * **Docker Compose** (Versión 1.29+ o Plugin Compose V2)
  * Git

## Instalación y Despliegue

Siga los siguientes pasos para desplegar el entorno desde cero:

1.  **Clonar el repositorio:**

    ```bash
    git clone <URL_DEL_REPOSITORIO>
    cd jenkins-iac-lab
    ```

2.  **Iniciar los servicios:**
    Se recomienda utilizar el indicador de forzar recreación para asegurar la lectura de las configuraciones más recientes.

    ```bash
    docker-compose up -d --build --force-recreate
    ```

3.  **Verificar el estado:**
    Asegúrese de que ambos contenedores (`jenkins_server` y `dind`) se encuentran en estado `Up`.

    ```bash
    docker-compose ps
    ```

## Acceso y Credenciales

Una vez que los servicios estén activos, la interfaz web estará disponible en:

  * **URL:** `http://localhost:8080`
  * **Usuario:** `admin`
  * **Contraseña:** `admin`

*Nota: La configuración de seguridad y credenciales se inyecta automáticamente a través del archivo `configs/jenkins.yaml`.*

## Detalles de Configuración Técnica

### 1\. Gestión de Plugins (Open/Closed Principle)

La instalación de plugins se maneja mediante el script `install-plugins.sh` y el archivo `plugins.txt`. Esto respeta el principio de "Abierto para extensión, cerrado para modificación", permitiendo añadir nuevos plugins al archivo de texto sin necesidad de alterar la lógica del script de instalación o el Dockerfile.

### 2\. Jenkins Configuration as Code (JCasC)

El sistema no requiere configuración manual post-despliegue. El archivo `jenkins.yaml` define:

  * **Security Realm:** Usuarios y permisos básicos.
  * **Clouds:** Configuración del proveedor Docker apuntando al host `tcp://dind:2375`.
  * **Templates:** Definición de los agentes (etiqueta `docker-agent`) que se instanciarán para ejecutar los Pipelines.

### 3\. Redes

Se utiliza una red tipo `bridge` definida en `docker-compose.yml` para permitir la resolución de nombres DNS entre el controlador de Jenkins y el daemon de Docker, evitando el uso de direcciones IP estáticas o configuraciones dependientes del host.

## Verificación de Funcionamiento

Para validar la correcta configuración de la nube y los agentes, se puede ejecutar el siguiente Pipeline de prueba:

```groovy
pipeline {
    agent { label 'docker-agent' } 
    
    stages {
        stage('Validación de Entorno') {
            steps {
                echo 'El agente Docker se ha aprovisionado correctamente.'
                sh 'cat /etc/os-release'
                sh 'java -version'
            }
        }
    }
}
```

## Solución de Problemas

  * **Error de conexión a Dind:** Si Jenkins no puede conectar con la nube Docker, verifique que no existan otros contenedores utilizando el puerto 8080 o conflictos de red. Ejecute `docker stop $(docker ps -q)` para limpiar el entorno y reinicie el despliegue.
  * **Persistencia:** Si realiza cambios en `jenkins.yaml`, es necesario recrear el contenedor para aplicar los cambios (`docker-compose up -d --force-recreate`).

-----
