#!/usr/bin/env bash

#########################################
# Created by Afiniel for Yiimpool use...#
#########################################

source /etc/functions.sh
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf
source $HOME/Yiimpoolv1/yiimp_single/.wireguard.install.cnf

#Create blocks.sh

echo '#!/usr/bin/env bash
PHP_CLI='"'"''"php -d max_execution_time=60"''"'"'
DIR='""''"${STORAGE_ROOT}"''""'/yiimp/site/web/
cd ${DIR}
date
echo started in ${DIR}
while true; do
${PHP_CLI} runconsole.php cronjob/runBlocks
sleep 20
done
exec bash' | sudo -E tee $STORAGE_ROOT/yiimp/site/crons/blocks.sh >/dev/null 2>&1
sudo chmod +x $STORAGE_ROOT/yiimp/site/crons/blocks.sh

cd $HOME/Yiimpoolv1/yiimp_single