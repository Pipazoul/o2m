FROM ubuntu:20.04 as builder

# interactive mode
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install Rust gstreamer
RUN apt update
RUN apt install -y curl
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup toolchain install nightly
RUN rustup default nightly
RUN apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gcc pkg-config git
RUN git clone --depth 1 https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs
WORKDIR /app/gst-plugins-rs
RUN cargo build --package gst-plugin-spotify -Z sparse-registry  --release 

FROM ubuntu:20.04

# interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update 

# Insstall dependencies
RUN apt install -y wget 

# Install Python
RUN apt install -y  python3 python3-pip git

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
COPY ./docker/create_conf_files.sh ./create_conf_files.sh
RUN chmod +x ./entrypoint.sh
RUN chmod +x ./create_conf_files.sh

# Install Python dependencies with caching
RUN --mount=type=cache,target=/root/.cache \
    pip3 install -r requirements.txt

# Install Rust gstreamer
COPY --from=builder /app/gst-plugins-rs/target/release/libgstspotify.so /app/target/release/libgstspotify.so
RUN install -m 644 /app/target/release/libgstspotify.so /usr/lib/x86_64-linux-gnu/gstreamer-1.0/

# Install snapcraft
RUN apt install -y libavahi-client3 libavahi-common3 libsoxr0
RUN wget "https://github.com/badaix/snapcast/releases/download/v0.27.0/snapserver_0.27.0-1_amd64.deb"  # May change in case of new release.
RUN  dpkg -i snapserver_0.27.0-1_amd64.deb
RUN  apt -f install # To fix dependencies
#vi /etc/snapserver.conf

RUN rm snapserver_0.27.0-1_amd64.deb



ENTRYPOINT ["./entrypoint.sh"]