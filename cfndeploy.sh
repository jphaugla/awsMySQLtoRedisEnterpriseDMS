CAP1=CAPABILITY_NAMED_IAM
CAP2=CAPABILITY_AUTO_EXPAND
CAP3=CAPABILITY_IAM
aws cloudformation deploy --template-file ./packaged-template.out --stack-name ${PROJECT_NAME} --capabilities $CAP1 $CAP2 $CAP3 --parameter-overrides ProjectName=$PROJECT_NAME S3BucketName=${S3_BUCKET} RedisDatabasePort=${REDISPORT} ClusterName=${CLUSTERNAME} HostedZoneName=${HOSTEDZONENAME} HostedZoneId=${HOSTEDZONEID} ClusterUserName=${CLUSTERUSERNAME} ClusterPassword=${CLUSTERPASSWORD} ClusterURL=${CLUSTERURL} LocalIp=${LOCAL_IP} S3Bucket=${S3_BUCKET} KeyName=${KEY_PAIR} EC2ServerInstanceType=${EC2_INSTANCE_TYPE} NumberInstances=${NUMBER_INSTANCES} LabType=${LAB_TYPE}
