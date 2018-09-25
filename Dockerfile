FROM 		debian:jessie

ENV 		MONGO_ENTERPRISE_MANAGER_USER=mongodb-mms

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN		groupadd -g 1998 -r ${MONGO_ENTERPRISE_MANAGER_USER} && useradd  -u 1998 -r -g ${MONGO_ENTERPRISE_MANAGER_USER} ${MONGO_ENTERPRISE_MANAGER_USER}

RUN 		set -x \
		&& apt-get update \
		&& apt-get install -y --no-install-recommends \
			ca-certificates wget bash openssl \
		&& rm -rf /var/lib/apt/lists/*

# MONGO_ENTERPRISE_MANAGER_BUILD could be obtained from https://www.mongodb.com/download-center/ops-manager/releases
# "Red Hat + CentOS 6, 7"
# Correct url will look like: https://downloads.mongodb.com/on-prem-mms/deb/mongodb-mms_4.0.2.50187.20180905T1427Z-1_x86_64.deb
# NOTE: that freakin deb is about 700m

ENV 		MONGO_ENTERPRISE_MANAGER_MAJOR		4.0
ENV 		MONGO_ENTERPRISE_MANAGER_VERSION	4.0.2
ENV 		MONGO_ENTERPRISE_MANAGER_BUILD		4.0.2.50187.20180905T1427Z-1
ENV 		MONGO_ENTERPRISE_MANAGER_CONF_DIR=/opt/mongodb/mms/conf
ENV 		MONGO_ENTERPRISE_MANAGER_CONF_ORIG_DIR=/opt/mongodb/mms/conf-orig
ENV 		MONGO_ENTERPRISE_MANAGER_CERT_DIR=/etc/mongodb-mms
ENV 		MONGO_ENTERPRISE_MANAGER_LOG_DIR=/opt/mongodb/mms/logs
# #

RUN 		cd /tmp \
		&& wget https://downloads.mongodb.com/on-prem-mms/deb/mongodb-mms_${MONGO_ENTERPRISE_MANAGER_BUILD}_x86_64.deb \
			--no-check-certificate \
		-O mongodb-mms-package.deb \
		&& dpkg -i mongodb-mms-package.deb \
		&& apt-get purge -y --auto-remove ca-certificates wget \
		&& rm -rf /opt/mongodb/mms/agent/* \
		&& rm mongodb-mms-package.deb

RUN 		mkdir -p \
			${MONGO_ENTERPRISE_MANAGER_CONF_DIR} \
			${MONGO_ENTERPRISE_MANAGER_CERT_DIR} \
			${MONGO_ENTERPRISE_MANAGER_LOG_DIR} \
		&& chown -R ${MONGO_ENTERPRISE_MANAGER_USER}:${MONGO_ENTERPRISE_MANAGER_USER} \
			${MONGO_ENTERPRISE_MANAGER_CONF_DIR} \
			${MONGO_ENTERPRISE_MANAGER_CERT_DIR} \
			${MONGO_ENTERPRISE_MANAGER_LOG_DIR} \
		&& cp -r ${MONGO_ENTERPRISE_MANAGER_CONF_DIR} ${MONGO_ENTERPRISE_MANAGER_CONF_ORIG_DIR}

VOLUME		${MONGO_ENTERPRISE_MANAGER_CONF_DIR} ${MONGO_ENTERPRISE_MANAGER_CERT_DIR} ${MONGO_ENTERPRISE_MANAGER_LOG_DIR}

LABEL 		description="MongoDB Enterprise OpsManager (non-official) image with fixed uid for user(1998)"
LABEL 		maintainer="Dmitry Evdokimov # devdokimoff@gmail.com / devdokimov@alfabank.ru #"

# DEFAULT ENV VARS EXPOSED TO CONTAINER
# default email address? why not rambler?
ENV 		MONGO_ENTERPRISE_MANAGER_DB_URI=mongodb://localhost:27017
ENV 		MONGO_ENTERPRISE_MANAGER_ADMIN_EMAIL=noreply@rambler.ru
ENV 		MONGO_ENTERPRISE_MANAGER_BOOTSTRAP_MAIN_PORT=7070
ENV 		MONGO_ENTERPRISE_MANAGER_BOOTSTRAP_BACKUP_PORT=7071
ENV 		MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XSS=328k
ENV 		MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XMX=4352m
ENV 		MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XMS=4352m
ENV 		MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_NEW_SIZE=600m
ENV 		MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XMN=1500m
ENV 		MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_RESERVED_CODE_CACHE=128m

COPY 		docker-entrypoint.sh 		/entrypoint.sh

ENTRYPOINT 	[ "/entrypoint.sh" ]
ENV   		 PATH=/opt/mongodb/mms/bin/:$PATH

EXPOSE		7070 7071

CMD 		[ "mongodb-mms" ]
