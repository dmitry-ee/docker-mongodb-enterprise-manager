#!make

# could be obtained from https://www.mongodb.com/download-center/ops-manager/releases, "Red Hat + CentOS 6, 7" section
OPS_MANAGER_VERSION=4.0.2.50187.20180905T1454Z-1

build:
	docker build .
