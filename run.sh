#!/bin/bash

load_oc_db() {
  local namespace="$1"
  echo "Namespace: $namespace"
  local db="$2"
  echo "Database: $db"

  # Get the pod name
  pod_name=$(oc -n $namespace get pods --selector=$OC_LABEL -o name)
  echo "Pod name: $pod_name"

  # Remove the 'pod/' prefix from the pod name
  prefix="pod/"
  pod_name=${pod_name#"$prefix"}

  date=$(TZ=US/Pacific date +%Y-%m-%d)
  src="${pod_name}://backups/daily/${date}/postgresql-${OC_ENV}-${db}_${date}_01-00-00.sql.gz"
  echo "Source path: $src"

  db_file="${db}.sql.gz"

  # ocp backup container stores monthly backups in a different location
  oc -n $namespace cp $src $db_file
  if [ -e $db_file ]
  then
      echo "downloaded successfully from daily backups"
  else
    src="${pod_name}://backups/monthly/${date}/postgresql-${OC_ENV}-${db}_${date}_01-00-00.sql.gz"
    oc -n $namespace cp $src $db_file
    echo "downloaded successfully from monthly backups"
  fi

  # Upload the database dump to Google Cloud Storage
  gsutil cp $db_file "gs://${DB_BUCKET}/${db}/"

  # Delete and recreate the database
  gcloud --quiet sql databases delete $DB_NAME --instance=$GCP_SQL_INSTANCE
  gcloud sql databases create $DB_NAME --instance=$GCP_SQL_INSTANCE

  # Grant permissions to the database user
  cat <<EOF > user.sql
GRANT USAGE, CREATE ON SCHEMA public TO "$DB_USER";
GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$DB_USER";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO "$DB_USER";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO "$DB_USER";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO "$DB_USER";
EOF

  gsutil cp user.sql "gs://${DB_BUCKET}/${db}/"

  # import user grants
  gcloud --quiet sql import sql $GCP_SQL_INSTANCE "gs://${DB_BUCKET}/${db}/user.sql" --database=$DB_NAME --user=postgres
  gcloud sql operations list --instance=$GCP_SQL_INSTANCE --filter='NOT status:done' --format='value(name)' | xargs -r gcloud sql operations wait --timeout=unlimited

  # import the database dump
  gcloud --quiet sql import sql $GCP_SQL_INSTANCE "gs://${DB_BUCKET}/${db}/${db_file}" --database=$DB_NAME --user=$DB_USER
  gcloud sql operations list --instance=$GCP_SQL_INSTANCE --filter='NOT status:done' --format='value(name)' | xargs -r gcloud sql operations wait --timeout=unlimited

  #mask
  gcloud --quiet sql import sql $GCP_SQL_INSTANCE "gs://${DB_BUCKET}/mask/lear.sql" --database=$DB_NAME --user=$DB_USER
  gcloud sql operations list --instance=$GCP_SQL_INSTANCE --filter='NOT status:done' --format='value(name)' | xargs -r gcloud sql operations wait --timeout=unlimited
}

# Change to the working directory
cd /opt/app-root

if [ "$LOAD_DATA_FROM_OCP" == true ]; then
  # Log in to OpenShift
  oc login --server=$OC_SERVER --token=$OC_TOKEN
  # Load the database
  load_oc_db $OC_NAMESPACE $DB_NAME
fi

if [ "$CREATE_BACKUP" == true ]; then
  # generate mask backup for use later
  gcloud sql export sql $GCP_SQL_INSTANCE "gs://${DB_BUCKET}/backups" --database=$DB_NAME
  gcloud sql operations list --instance=$GCP_SQL_INSTANCE --filter='NOT status:done' --format='value(name)' | xargs -r gcloud sql operations wait --timeout=unlimited
fi
