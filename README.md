# MongoDB Enterprise Ops Manager image

User statical uid and guid for ops-manager:

    uid: 1999
    guid: 1999

## Build

```bash
git checkout 3.0.6
./gradlew build
```

docker default tag will resolve by `git describe --tags` command

Or with image prefix customization:

```bash
./gradlew build -PimagePrefix=mydockerepo.company.ru
```

imagePrefix default value: `docker.moscow.alfaintra.net`

## Push to registry

```
./gradlew push
```

## Used in

## Env Arguments
### App
MONGO_ENTERPRISE_MANAGER_DB_URI
MONGO_ENTERPRISE_MANAGER_ADMIN_EMAIL
MONGO_ENTERPRISE_MANAGER_BOOTSTRAP_MAIN_URL
MONGO_ENTERPRISE_MANAGER_BOOTSTRAP_BACKUP_URL
### Java Opts
MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XSS
MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XMX
MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XMS
MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_NEW_SIZE
MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_XMN
MONGO_ENTERPRISE_MANAGER_JAVA_OPTS_RESERVED_CODE_CACHE
