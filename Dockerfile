FROM debian:stretch

MAINTAINER PeGa! <dev@pega.sh>

COPY openmediavault.list /
# We need to make sure rrdcached uses /data for it's data
COPY defaults/rrdcached /etc/default

# Add our startup script last because we don't want changes
# to it to require a full container rebuild
COPY omv-startup /usr/sbin/omv-startup

RUN 	export DEBIAN_FRONTEND=noninteractive && \
	echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections && \
	sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests wget && \
	wget --no-check-certificate -O "/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.asc" https://packages.openmediavault.org/public/archive.key && \
	mv /openmediavault.list /etc/apt/sources.list.d/ && \
	apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests \
		openmediavault-keyring \
		postfix \
		locales \
		openmediavault

RUN chmod +x /usr/sbin/omv-startup

EXPOSE 8080 8443

VOLUME /data

ENTRYPOINT /usr/sbin/omv-startup
