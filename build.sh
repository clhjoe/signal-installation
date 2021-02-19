#!/bin/bash
# ====variables====

SIGNAL_FOLDER=Signal-Server
SIGNAL_CONFIG_TEMPLATE=signal_server_config_temp.conf
SIGNAL_CONFIG=$SIGNAL_FOLDER/service/config/config.yml

APPLICATION_CONNECTOR=19002
ADMIN_CONNECTOR=8081
AUTH_TOKEN_SECRET=`head -c 16 /dev/urandom | hexdump -ve '1/1 "%.2x"'`
CACHE_SERVER=redis:\\/\\/127.0.0.1:46379
SQS_URL=http:\\/\\/localhost:44566\\/000000000000\\/signal-queue.fifo
CDS_URL=http:\\/\\/127.0.0.1:9090
S3_BUCKET=signal
ZK_SECRET=x
ZK_PUBLIC=y
DELIVERY_CERT=x
DELIVERY_PRIVATE_KEY=y
POSTGRE_USERNAME=postgres
POSTGRE_PWD=postgres
POSTGRE_HOST=jdbc:postgresql:\\/\\/127.0.0.1:45432\\/signal

#====generate GCP_SIGNKEY====
openssl genrsa -out private_key_rsa_4096_pkcs1.pem 4096
openssl pkcs8 -topk8 -in private_key_rsa_4096_pkcs1.pem -inform pem -out private_key_rsa_4096_pkcs8-exported.pem -outform pem -nocrypt
GCP_SIGNKEY=`awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}'  private_key_rsa_4096_pkcs8-exported.pem`
GCP_SIGNKEY=${GCP_SIGNKEY//\//\\\/}

[ ! -d "$SIGNAL_FOLDER" ] && git clone https://github.com/signalapp/Signal-Server/


#====compile====
mvn clean install -DskipTests

#====create zkconfig
cerString=`java -jar $SIGNAL_FOLDER/service/target/TextSecureServer-3.21.jar zkparams`
counter=0
for key in $cerString
do
    if [[ $counter -eq 1 ]]; then
        ZK_PUBLIC=${key//\//\\\/}
    elif [[ $counter -eq 3 ]]; then
        ZK_SECRET=${key//\//\\\/}
    fi
     counter=$((counter+1)) 
done

#====create UnidentifiedDelivery pair====
cerString=`java -jar $SIGNAL_FOLDER/service/target/TextSecureServer-3.21.jar certificate -ca`
counter=0
for key in $cerString
do
    if [[ $counter -eq 6 ]]; then
        privateKey=$key
    fi
    counter=$((counter+1)) 
done
cerString=`java -jar $SIGNAL_FOLDER/service/target/TextSecureServer-3.21.jar certificate --id 0 --key $privateKey`
counter=0
for key in $cerString
do
    if [[ $counter -eq 1 ]]; then
        DELIVERY_CERT=${key//\//\\\/}
    elif [[ $counter -eq 4 ]]; then
        DELIVERY_PRIVATE_KEY=${key//\//\\\/}
    fi
    counter=$((counter+1)) 
done

# ====update Config====
cp $SIGNAL_CONFIG_TEMPLATE $SIGNAL_CONFIG
sed -i "s/{{APPLICATION_CONNECTOR}}/$APPLICATION_CONNECTOR/g" $SIGNAL_CONFIG
sed -i "s/{{ADMIN_CONNECTOR}}/$ADMIN_CONNECTOR/g" $SIGNAL_CONFIG
sed -i "s/{{AUTH_TOKEN_SECRET}}/$AUTH_TOKEN_SECRET/g" $SIGNAL_CONFIG
sed -i "s/{{CACHE_SERVER}}/$CACHE_SERVER/g" $SIGNAL_CONFIG
sed -i "s/{{SQS_URL}}/$SQS_URL/g" $SIGNAL_CONFIG
sed -i "s/{{CDS_URL}}/$CDS_URL/g" $SIGNAL_CONFIG
sed -i "s/{{S3_BUCKET}}/$S3_BUCKET/g" $SIGNAL_CONFIG
sed -i "s/{{ZK_SECRET}}/$ZK_SECRET/g" $SIGNAL_CONFIG
sed -i "s/{{ZK_PUBLIC}}/$ZK_PUBLIC/g" $SIGNAL_CONFIG
sed -i "s/{{DELIVERY_CERT}}/$DELIVERY_CERT/g" $SIGNAL_CONFIG
sed -i "s/{{DELIVERY_PRIVATE_KEY}}/$DELIVERY_PRIVATE_KEY/g" $SIGNAL_CONFIG
sed -i "s/{{POSTGRE_USERNAME}}/$POSTGRE_USERNAME/g" $SIGNAL_CONFIG
sed -i "s/{{POSTGRE_PWD}}/$POSTGRE_PWD/g" $SIGNAL_CONFIG
sed -i "s/{{POSTGRE_HOST}}/$POSTGRE_HOST/g" $SIGNAL_CONFIG
#sed -i "s/{{GCP_SIGNKEY}}/$GCP_SIGNKEY/g" $SIGNAL_CONFIG

#====migrate db====
java -jar $SIGNAL_FOLDER/service/target/TextSecureServer-3.21.jar abusedb migrate $SIGNAL_CONFIG
java -jar $SIGNAL_FOLDER/service/target/TextSecureServer-3.21.jar accountdb migrate $SIGNAL_CONFIG
java -jar $SIGNAL_FOLDER/service/target/TextSecureServer-3.21.jar messagedb migrate $SIGNAL_CONFIG
