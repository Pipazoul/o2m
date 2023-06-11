#!/bin/bash

echo "Starting o2m service"

systemctl start o2m.service

echo "Starting mopidy service"

/usr/bin/mopidy --config /etc/mopidy/mopidy.conf &

python3 schema.py

python3 main.py