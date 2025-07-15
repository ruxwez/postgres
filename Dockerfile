# Usar la imagen base oficial de PostgreSQL 17
FROM postgres:17

# Instalar las extensiones necesarias y herramientas de compilación
RUN apt-get update && apt-get install -y \
    postgresql-contrib \
    postgresql-17-postgis-3 \
    postgresql-17-postgis-3-scripts \
    git \
    build-essential \
    postgresql-server-dev-17 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar pgvector desde el código fuente
RUN git clone --branch v0.7.4 https://github.com/pgvector/pgvector.git /tmp/pgvector \
    && cd /tmp/pgvector \
    && make clean \
    && make OPTFLAGS="" \
    && make install \
    && cd / \
    && rm -rf /tmp/pgvector

# Limpiar paquetes de compilación para reducir el tamaño de la imagen
RUN apt-get update && apt-get remove -y \
    git \
    build-essential \
    postgresql-server-dev-17 \
    && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar el script de inicialización opcional
COPY init.sql /docker-entrypoint-initdb.d/

# Exponer el puerto por defecto de PostgreSQL
EXPOSE 5432
