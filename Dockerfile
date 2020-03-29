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
	sed -i 's/main/main contrib non-free/g' /etc/apt-get/sources.list && \
	apt-get update && \
	apt-get install -y wget && \
	wget -O "/etc/apt-get/trusted.gpg.d/openmediavault-archive-keyring.asc" https://packages.openmediavault.org/public/archive.key && \
	mv /openmediavault.list /etc/apt-get/sources.list.d/ && \
	apt-get update && \
	apt-get install -y \
		openmediavault-keyring \
		postfix \
		locales \
		openmediavault

RUN chmod +x /usr/sbin/omv-startup

EXPOSE 8080 8443

VOLUME /data

ENTRYPOINT /usr/sbin/omv-startup
