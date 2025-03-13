apiVersion: batch/v1
kind: Job
metadata:
  name: phraseanet-mysql-create-dbs
  namespace: phraseanet
spec:
  template:
    spec:
      containers:
      - name: mysql-client
        image: mysql:latest
        command:
        - /bin/sh
        - -c
        - |
          mysql -h ${rds_db_host} -u root -p$(MYSQL_ROOT_PASSWORD) -e "CREATE DATABASE IF NOT EXISTS ab_master; CREATE DATABASE IF NOT EXISTS db_databox1;"
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: ${rds_db_root_password}
      restartPolicy: Never
  backoffLimit: 10