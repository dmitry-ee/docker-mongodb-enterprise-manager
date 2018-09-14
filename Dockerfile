FROM debian:jessie

ARG MONGO_ENTERPRISE_MANAGER_USER			mongoopsmanager

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN 				groupadd -g 1999 -r $MONGO_ENTERPRISE_MANAGER_USER && useradd  -u 1999 -r -g $MONGO_ENTERPRISE_MANAGER_USER $MONGO_ENTERPRISE_MANAGER_USER

RUN 				apt-get update \
							&& apt-get install -y --no-install-recommends \
								numactl \
							&& rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
ENV 				GOSU_VERSION 1.7
RUN 				set -x \
							&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget bash && rm -rf /var/lib/apt/lists/* \
							&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
							&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
							&& export GNUPGHOME="$(mktemp -d)" \
							&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
							&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
							&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
							&& chmod +x /usr/local/bin/gosu \
							&& gosu nobody true

# Could be obtained from https://www.mongodb.com/download-center/ops-manager/releases
# "Red Hat + CentOS 6, 7"
# Url will look like: https://downloads.mongodb.com/on-prem-mms/deb/mongodb-mms_4.0.2.50187.20180905T1427Z-1_x86_64.deb
# NOTE: that freakin image is about 700m

ENV MONGO_ENTERPRISE_MANAGER_MAJOR		4.0
ENV MONGO_ENTERPRISE_MANAGER_VERSION	4.0.2
ENV MONGO_ENTERPRISE_MANAGER_BUILD		4.0.2.50187.20180905T1427Z-1
# #

RUN 				cd /tmp \
							&& wget https://downloads.mongodb.com/on-prem-mms/deb/mongodb-mms_${MONGO_ENTERPRISE_MANAGER_BUILD}_x86_64.deb \
								--no-check-certificate \
								-O mongodb-mms-package.deb \
							&& dpkg -i mongodb-mms-package.deb
							#&& apt-get purge -y --auto-remove ca-certificates wget

RUN 				mkdir -p /etc/ops-manager/ \
							&& chown -R $MONGO_ENTERPRISE_MANAGER_USER:$MONGO_ENTERPRISE_MANAGER_USER /etc/ops-manager/

VOLUME			/etc/ops-manager/

LABEL 			description="MongoDB Enterprise OpsManager (non-official) image with fixed uid for user(1999)"

COPY 				docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT 	["/entrypoint.sh"]

EXPOSE 			8080

ENTRYPOINT 	[ "bash" ]
