#!/usr/bin/env bash
apt update
apt install -y openssl

#rm -rf $(dirname $0)/ssl
mkdir -p $(dirname $0)/ssl
cd $(dirname $0)/ssl

#1 Generate CA KEY
if [ ! -e "lan-chain-ca.key" ]; then
    openssl genrsa -out lan-chain-ca.key 2048
fi

#2 Generate CA CSR
if [ ! -e "lan-chain-ca.csr" ]; then
    openssl req -new -subj "/C=CN/ST=SC/L=CD/O=LAN/OU=LAN/CN=LANChainCA" -key lan-chain-ca.key -out lan-chain-ca.csr
fi

#3 Self signed CA
if [ ! -e "lan-chain-ca.crt" ]; then
    if [ ! -e "lan-chain-ca.ext" ]; then
cat > lan-chain-ca.ext <<EOF
[v3_ca]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
EOF
    fi
    openssl x509 -req -days 36500 -sha256 -extfile lan-chain-ca.ext -extensions v3_ca -in lan-chain-ca.csr -signkey lan-chain-ca.key -out lan-chain-ca.crt
fi

#4 Generate Middle Certificates Key
if [ ! -e "lan-chain-sign.key" ]; then
openssl genrsa -out lan-chain-sign.key 4096
fi

#5 Generate Middle Certificates Sign Request
if [ ! -e "lan-chain-sign.csr" ]; then
openssl req -new -subj "/C=CN/ST=SC/L=CD/O=LAN/OU=LAN/CN=LANSIGN" -key lan-chain-sign.key -out lan-chain-sign.csr
fi

#6 Use CA Sign Middle Certificates
if [ ! -e "lan-chain-sign.crt" ]; then
    if [ ! -e "lan-chain-sign.ext" ]; then
cat > lan-chain-sign.ext <<EOF
[v3_intermediate_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF
    fi
    openssl x509 -req -extfile lan-chain-sign.ext -extensions v3_intermediate_ca -days 36500 -sha256 -CA lan-chain-ca.crt -CAkey lan-chain-ca.key -CAcreateserial -CAserial serial -in lan-chain-sign.csr -out lan-chain-sign.crt
fi

#7 verify middle certificates
openssl verify -CAfile lan-chain-ca.crt lan-chain-sign.crt

#8 Generate Server Key
ServerCN="192.168.13.8"
if [ "$1" ]; then
    ServerCN=$1
fi
echo CN: $ServerCN

if [ ! -e "$ServerCN.key" ]; then
    openssl genrsa -out $ServerCN.key 2048
fi

#9 Generate Server Certificates Sign Request
if [ ! -e "$ServerCN.csr" ]; then
    openssl req -new -subj "/C=CN/ST=SC/L=CD/O=LAN/OU=LAN/CN=$ServerCN" -key $ServerCN.key -out $ServerCN.csr
fi

#10 Generate Server pem
if [ ! -e "$ServerCN.crt" ]; then
    if [ ! -e "$ServerCN.ext" ]; then
cat > $ServerCN.ext <<EOF
[v3_server]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage=digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName=@alt_names
[alt_names]
IP.1 = $ServerCN
EOF
    fi
    openssl x509 -req -extfile $ServerCN.ext -extensions v3_server -days 36500 -sha256 -CA lan-chain-sign.crt -CAkey lan-chain-sign.key -CAserial serial -in $ServerCN.csr -out $ServerCN.crt
    #openssl x509 -sha256 -req -extfile $ServerCN.ext -extensions v3_server -days 3650 -in $ServerCN.csr -CA lan-chain-sign.crt -CAkey lan-chain-sign.key -CAcreateserial -out $ServerCN-serial.crt
fi

#11 Make Final Chain Server Cert
cat lan-chain-sign.crt lan-chain-ca.crt > verify-v-full-chain.crt
openssl verify -CAfile verify-v-full-chain.crt $ServerCN.crt
cat $ServerCN.crt lan-chain-sign.crt lan-chain-ca.crt > $ServerCN-full-chain.crt
