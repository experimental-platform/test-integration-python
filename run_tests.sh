#!/usr/bin/env bash

# enable fail detection...
set -e

echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
HOSTIP=$(vagrant ssh-config | awk '/HostName/ {print $2}')

cat /.ssh/id_rsa.pub | vagrant ssh -c "docker exec -i dokku sshcommand acl-add dokku root"

git clone https://github.com/guaq/heroku-in-a-bottle.git python-example
cd python-example

# http://progrium.viewdocs.io/dokku/checks-examples.md
echo -e "WAIT=10\nATTEMPTS=20\n/ Hello" > CHECKS
git config user.email "engineering@protonet.info"
git config user.name "Protonet Integration Test"
git add CHECKS
git commit -a -m "Bootle needs some time, so we're taking it sloooow."

git remote add protonet ssh://dokku@${HOSTIP}:8022/python-app
# destroy in case it's already deployed
ssh -t -p 8022 dokku@${HOSTIP} apps:destroy python-app force || true
# ssh -t -p 8022 dokku@${HOSTIP} trace on
git push protonet master

wget http://${HOSTIP}/python-app
