# clone-private-repo

Script para clonar repositorios privados de GitHub de forma segura e interactiva utilizando un Personal Access Token (PAT).

## 🚀 Uso Rápido

Para descargar y ejecutar el script directamente en un servidor "limpio" (sin configuración previa), utiliza el siguiente comando:

```bash
git clone https://github.com/juanlanuza/clone-private-repo.git && cd clone-private-repo && bash clone_private_repo.sh
```

## 📝 ¿Qué hace este script?

Este proyecto facilita la clonación de repositorios privados en servidores de despliegue o entornos temporales.

1.  **Configuración Interactiva**: Te guía para crear un archivo `.env` con tus credenciales de GitHub (Usuario y Token) y los datos del repositorio objetivo.
2.  **Clonación Automatizada**: Utiliza las credenciales para clonar el repositorio privado vía HTTPS.
3.  **Scripts Post-Clonación**: Si el repositorio clonado contiene una carpeta `scripts/` con archivos `.sh`, el script te permitirá seleccionar y ejecutarlos automáticamente.
4.  **Limpieza de Seguridad**: Ofrece la opción de eliminar el archivo `.env` con las credenciales al finalizar para no dejar rastros sensibles.

## 🔧 Requisitos

- `git`
- `bash`
- Un **GitHub Personal Access Token** (Classic o Fine-grained) con permisos para leer el repositorio (`repo` o `Contents: Read`).
