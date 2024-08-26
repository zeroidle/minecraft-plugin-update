#!/bin/bash
#
# /etc/crontab
# 0 9 * * * [USER] /opt/minecraft/update.sh"
#
curl_path="/usr/bin/curl"
minecraft_dir="/opt/minecraft"
plugin_dir="$minecraft_dir/data/plugins"
geyser_remote="https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
geyser_name="Geyser-Spigot.jar"
floodgate_remote="https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"
floodgate_name="floodgate-spigot.jar"
is_necessary_update=false

geyser_remote_bytes=`$curl_path -L --silent --head --compressed $geyser_remote | grep content-length|awk 'NR==2 {printf "%d\n", $2}'`
floodgate_remote_bytes=`$curl_path -L --silent --head --compressed $floodgate_remote |grep content-length|awk 'NR==2 {printf "%d\n", $2}'`
geyser_local_bytes=`ls -al $plugin_dir/$geyser_name | awk '{print $5}'`
floodgate_local_bytes=`ls -al $plugin_dir/$floodgate_name | awk '{print $5}'`

echo "	$geyser_name	$floodgate_name"
echo "local :	$geyser_local_bytes	$floodgate_local_bytes"
echo "remote:	$geyser_remote_bytes	$floodgate_remote_bytes"

if [ $geyser_local_bytes != $geyser_remote_bytes ] || [ $floodgate_local_bytes != $floodgate_remote_bytes ]; then
	echo "Update prepare"
	is_necessary_update=true
fi

if [ $is_necessary_update != false ]; then
	echo "Update required - $is_necessary_update"

	cd $plugin_dir
	echo "Oh My God"
	$curl_path --silent -L -o $geyser_name $geyser_remote
	$curl_path --silent -L -o $floodgate_name $floodgate_remote

	cd $minecraft_dir
	docker-compose down
	sleep 3;
	sh ./init.sh
	docker-compose up -d
else
	echo "Update not necessary"
fi
