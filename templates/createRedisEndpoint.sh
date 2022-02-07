aws dms create-endpoint \
           --endpoint-identifier targetRedisEndpoint \
           --endpoint-type target \
           --engine-name redis \
           --redis-settings file://redis-settings.json
