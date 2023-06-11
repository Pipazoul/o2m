FROM debian:buster-slim

# Install dependencies
RUN apt update 

# Insstall dependencies
RUN apt install -y wget 

# Install Python
RUN apt install -y python3.7 python3.7-dev python3-pip build-essential libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev liblircclient-dev lirc

# Mopidy
RUN mkdir -p /etc/apt/keyrings
RUN wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg \
    https://apt.mopidy.com/mopidy.gpg
RUN  wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/bullseye.list
RUN apt-get update
RUN apt-get -y install mopidy python-spotify libspotify-dev
RUN  apt-get install -y swig libpcsclite-dev libcairo2-dev


WORKDIR /app

COPY ./assets /app/assets
COPY ./samples /app/samples
COPY ./sandbox /app/sandbox
COPY ./src /app/src
COPY main.py /app/main.py
COPY schema.py /app/schema.py
COPY requirements.txt /app/requirements.txt
COPY ./docker/entrypoint.sh ./entrypoint.sh

RUN chmod +x ./entrypoint.sh

# Install Python dependencies with caching
RUN --mount=type=cache,target=/root/.cache \
    pip3 install -r requirements.txt

RUN systemctl enable mopidy

# Finalise modpidy configuration
RUN  cp samples/mopidy.conf /etc/mopidy/mopidy.conf
RUN  chmod 777 /etc/mopidy/mopidy.conf
#RUN  vi /etc/mopidy/mopidy.conf #and configure as needed
RUN  mopidyctl local scan

#Tags db initialisation
RUN  cp samples/o2m.db o2m.db #and modify as needed
RUN  cp samples/o2m.conf /etc/mopidy/o2m.conf
RUN  chmod 777 /etc/mopidy/o2m.conf


#autorun o2m
RUN  cp samples/o2m.service /lib/systemd/system/o2m.service
RUN  chmod 644 /lib/systemd/system/o2m.service
#RUN  vi lib/systemd/system/o2m.service #and configure if needed
RUN  systemctl enable o2m.service




ENTRYPOINT ["./entrypoint.sh"]