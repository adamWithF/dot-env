docker-ip() {
  # docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@"
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

db-devel-backup() {
  local FILE=${1:-"backup.sql"}
  local CONTAINER=wordpress_db
  local DATABASE=wordpress
  local USER=wordpress
  local PASSWORD=wordpress
  local PREFIX=wp_

  echo "Database back up started..."

  docker exec $CONTAINER /usr/bin/mysqldump --opt -Q -u $USER --password=$PASSWORD $DATABASE ${PREFIX}options ${PREFIX}posts ${PREFIX}postmeta ${PREFIX}terms ${PREFIX}term_taxonomy ${PREFIX}term_relationships ${PREFIX}termmeta > $FILE

  echo "Database backing up finished."
}

db-devel-restore() {
  local FILE=${1:-"backup.sql"}
  local CONTAINER=wordpress_db
  local DATABASE=wordpress
  local USER=wordpress
  local PASSWORD=wordpress

  if [[ -e $FILE  ]]; then
    echo "Restoring database..."
    cat $FILE | docker exec -i $CONTAINER /usr/bin/mysql -u $USER --password=$PASSWORD $DATABASE
    echo "Database restored."
  else
    echo "File $FILE doesn't exists."
  fi
}

is_darwin() {
  [[ $(uname -s) == 'Darwin' ]] && result=true || result=false
  echo $result
}

is_linux() {
  [[ $(uname -s) == 'Linux' ]] && result=true || result=false
  echo $result
}

checkport() {
  if [[ -z $1 ]]; then
    echo "No port specified!"
    return 1
  fi

  netstat -ltnp | grep -w ':$1'
  # lsof -nP -iTCP:$1 | grep LISTEN
}