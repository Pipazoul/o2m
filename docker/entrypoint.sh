#!/bin/bash

bash create_conf_files.sh

# Start snapserver
/usr/bin/snapserver -d -s pipe:///tmp/snapfifo?name=Snapcast

# Start mopidy
/usr/bin/mopidy --config /etc/mopidy/mopidy.conf &

#python3 schema.py

python3 main.py -m flask

tail -f /dev/null
