# Start 
```
docker compose up -d
```

# Logs
```
docker compose logs ca -f
```

# Exec
```
docker compose exec ca bash
```

# Simple PKI

## Setup Directories
```
mkdir -p ca/root-ca/private ca/root-ca/db crl certs
chmod 700 ca/root-ca/private
```

## Setup root CA DBs
```
cp /dev/null ca/root-ca/db/root-ca.db
cp /dev/null ca/root-ca/db/root-ca.db.attr
echo 01 > ca/root-ca/db/root-ca.crt.srl
echo 01 > ca/root-ca/db/root-ca.crl.srl
```

## Create a private key and CSR
```
openssl req -new \
    -config /etc/pki/root-ca.conf \
    -out ca/root-ca.csr \
    -keyout ca/root-ca/private/root-ca.key
```
Enter the phassphrase and record it.

## (Optional) Details of the pri key
```
openssl rsa -in ca/root-ca/private/root-ca.key -text -noout
```

## (Optional) Extract public key from csr
```
openssl req -in ca/root-ca.csr -noout -pubkey | openssl pkey -pubin -noout -text
```

## (Optional) Extract public key from private key
```
openssl rsa -in ca/root-ca/private/root-ca.key -pubout
```

## Sign and create the root CA certificate
```
openssl ca -selfsign \
    -config /etc/pki/root-ca.conf \
    -in ca/root-ca.csr \
    -out ca/root-ca.crt \
    -extensions root_ca_ext
```

## Create intermediate CA
```
mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
chmod 700 ca/signing-ca/private
```

## Setup intermediate CA DBs
```
cp /dev/null ca/signing-ca/db/signing-ca.db
cp /dev/null ca/signing-ca/db/signing-ca.db.attr
echo 01 > ca/signing-ca/db/signing-ca.crt.srl
echo 01 > ca/signing-ca/db/signing-ca.crl.srl
```

## Create intermediate key and CSR
```
openssl req -new \
    -config /etc/pki/signing-ca.conf \
    -out ca/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key
```
Enter the phassphrase and record it.

## Sign and create the intermediate CA certificate
```
openssl ca \
    -config /etc/pki/root-ca.conf \
    -in ca/signing-ca.csr \
    -out ca/signing-ca.crt \
    -extensions signing_ca_ext
```

## Create website key and csr
```
SAN=DNS:www.finmid.internal \
openssl req -new \
    -config /etc/pki/server.conf \
    -out certs/finmid.internal.csr \
    -keyout certs/finmid.internal.key
```

## View server CSR
```
openssl req \
    -in certs/finmid.internal.csr \
    -noout \
    -text
```

## Sign and create the website certificate
```
openssl ca \
    -config /etc/pki/signing-ca.conf \
    -in certs/finmid.internal.csr \
    -out certs/finmid.internal.crt \
    -extensions server_ext
```

## View server certificate
```
openssl x509 \
    -in certs/finmid.internal.crt \
    -noout \
    -text
```

# Cleanup
```
docker compose stop
docker compose rm -s -f
```
