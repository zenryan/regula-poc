
# This repository is used to test Regula Functionality


## Reference
https://docs.regulaforensics.com/develop/doc-reader-sdk/web-service/administration/server/

## Pre-requisite
Docker
Copy regula.license into the root folder

## Installation and Setup the docker server


To start the Docker container, invoke:
```
sudo docker-compose up -d
```



# How to enable Mobile Upload
- You need to enable server side verification, can allow set the transaction / session logs in S3, Google Cloud Storage, of Container or Folder for more info look at the documentation

https://docs.regulaforensics.com/develop/doc-reader-sdk/web-service/administration/server-side-verification/#self-hosted-databases

With the configuration below you will see the session data in the following folder
/app/docreader-transactions/year=2025/month=11/day=27/hour=6/minute=47

```
  sessionApi:
    enabled: true
    transactions:
      location:
        folder: "docreader-transactions"
        prefix: "session-api"
```

- Also requires webServer to store records in the database. 

To do this, we need to specify datbase location in the config.yaml
```
  database:
    connectionString: "postgresql://postgres:development_password@postgres:5432/reguladb"
```

Then, set up postgres sql server in the  docker-compose.yml

```
postgres:
    image: postgres:14-alpine
    container_name: postgres14
    restart: unless-stopped
    networks:
      - docreader-network
    environment:
      # Required: Set your database credentials
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: development_password
      POSTGRES_DB: reguladb
      
      # Optional: Additional configuration
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8"
      PGDATA: /var/lib/postgresql/data/pgdata
    
    command: >
      postgres -c shared_preload_libraries=pgcrypto
    
    ports:
      - "5432:5432"
    
    volumes:
      # Persist database data
      - postgres_data:/var/lib/postgresql/data
      
      # Optional: Custom initialization scripts
      # Place .sql or .sh files in ./init-scripts/ to run on first startup
      - ./init-scripts:/docker-entrypoint-initdb.d
      
      # Optional: Custom postgresql.conf
      # - ./postgresql.conf:/etc/postgresql/postgresql.conf

volumes:
  postgres_data:
    driver: local
```


Next you need to create 01-init-pgcrypto.sql inside the init-scripts folder for enableing the pgcrypto extension

```
-- Enable pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Verify installation
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';
```

## Runtime stats

When running with 10 workers below is the memory and cpu usage
```
CONTAINER ID   NAME         CPU %     MEM USAGE / LIMIT     MEM %     
ba659468421c   postgres14   0.01%     34.43MiB / 7.656GiB   0.44%     
215a1bff7e65   docreader    1.83%     3.885GiB / 7.656GiB   50.75%    
```

Below is the stats when running with 1 workers
```
CONTAINER ID   NAME         CPU %     MEM USAGE / LIMIT     MEM %  
ba659468421c   postgres14   0.08%     18.96MiB / 7.656GiB   0.24%  
215a1bff7e65   docreader    0.18%     463.1MiB / 7.656GiB   5.91%  
```
