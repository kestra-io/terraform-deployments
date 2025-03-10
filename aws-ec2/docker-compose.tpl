services:
  kestra:
    image: kestra/kestra:latest
    entrypoint: /bin/bash
    environment:
      KESTRA_CONFIGURATION: |
        datasources:
          postgres:
            url: jdbc:postgresql://${db_host}:${db_port}/kestra
            driverClassName: org.postgresql.Driver
            username: ${db_username}
            password: ${db_password}
        kestra:
          repository:
            type: postgres
          storage:
            type: s3
            s3:
              accessKey: "${aws_access_key}"
              secretKey: "${aws_secret_key}"
              region: "${aws_region}"
              bucket: "${aws_bucket}"
          queue:
            type: postgres
          server:
            basic-auth:
              enabled: true
              username: "${kestra_user}"
              password: "${kestra_password}"
          tasks:
            scripts:
              docker:
                volume-enabled: true
            tmp-dir:
              path: /tmp/kestra-wd/tmp
          url: http://localhost:8080/
          variables:
            env-vars-prefix: ""
    user: "root"
    command:
      - -c
      - /app/kestra server standalone --worker-thread=128
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /tmp/kestra-wd:/tmp/kestra-wd
    ports:
      - "8080:8080"
      - "8081:8081"

