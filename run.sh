#!/usr/bin/env bash
echo -e "nameserver 127.0.0.11\nnameserver 8.8.8.8\nnameserver 223.5.5.5\n" > /etc/resolv.conf

if [ -f /dashboard/data/config.yaml ]; then
	echo "配置文件存在，跳过配置"
else
	echo "配置文件不存在，初始化默认配置"
	cp /dashboard/config.yaml /dashboard/data/config.yaml
fi

# Restore the database if it does not already exist.
# if [ -f /data/db ]; then
# 	echo "Database already exists, skipping restore"
# else
# 	echo "No database found, restoring from replica if exists"
# 	litestream restore -v -if-replica-exists -o /data/db "${REPLICA_URL}"
# fi

# # Run litestream with your app as the subprocess.
# exec litestream replicate -exec "/usr/local/bin/myapp -dsn /data/db"

check_dependencies() {
  DEPS_CHECK=("wget" "unzip")
  DEPS_INSTALL=(" wget" " unzip")
  for ((i=0;i<${#DEPS_CHECK[@]};i++)); do [[ ! $(type -p ${DEPS_CHECK[i]}) ]] && DEPS+=${DEPS_INSTALL[i]}; done
  [ -n "$DEPS" ] && { apt-get update >/dev/null 2>&1; apt-get install -y $DEPS >/dev/null 2>&1; }
}

generate_nezha() {
  cat > nezha.sh << EOF
#!/usr/bin/env bash
NEZHA_SERVER=${NEZHA_HOST}
NEZHA_PORT=${NEZHA_PORT}
NEZHA_KEY=${NEZHA_TOKEN}
check_run() {
  [[ \$(pgrep -laf nezha-agent) ]] && echo "It's running!" && exit
}
check_variable() {
  [[ -z "\${NEZHA_SERVER}" || -z "\${NEZHA_PORT}" || -z "\${NEZHA_KEY}" ]] && exit
}
download_agent() {
  if [ ! -e nezha-agent ]; then
    URL=\$(wget -qO- -4 "https://api.github.com/repos/naiba/nezha/releases/latest" | grep -o "https.*linux_amd64.zip")
    wget -t 2 -T 10 -N \${URL}
    unzip -qod ./ nezha-agent_linux_amd64.zip && rm -f nezha-agent_linux_amd64.zip
  fi
}
run() {
  [[ ! \$PROCESS =~ nezha-agent && -e nezha-agent ]] && ./nezha-agent -s \${NEZHA_SERVER}:\${NEZHA_PORT} -p \${NEZHA_KEY} 2>&1 &
}
check_run
check_variable
download_agent
run
EOF
}

check_dependencies
generate_nezha
[ -e nezha.sh ] && bash nezha.sh 2>&1 &
/dashboard/app
