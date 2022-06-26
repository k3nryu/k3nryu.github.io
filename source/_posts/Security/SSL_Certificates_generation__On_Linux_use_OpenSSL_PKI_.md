---
title: SSL Certificates generation (On Linux use OpenSSL PKI)
date: 2021/10/28 21:17:38
categories:
  - Security
toc: true
#sidebar: none
---

[toc]

# Introduction

![1449efa5e5facdd61663427a98e3a3a7.png](/resources/1fa2a2eab1bc40278d446a4d051bf8e7.png)

# Definitons
- PKI: Public Key Infrastructure
Security architecture where trust is conveyed through the signature of a trusted CA.
- CA: Certificate Authority
Entity issuing certificates and CRLs.
- TLS: 传输层安全协议 Transport Layer Security的缩写
- SSL: 安全套接字层 Secure Socket Layer的缩写
- KEY: 通常指私钥Private key。
- CSR: 证书签名请求Certificate Signing Request的缩写，可以简单理解成公钥，生成证书时要把这个提交给权威的证书颁发机构。
- CRT: 证书Certificate的缩写
- CRL: 证书吊销列表 Certificate Revocation Lists的缩写。

- X.509: 是一种证书格式。
对X.509证书来说，认证者总是CA或由CA指定的人，一份X.509证书是一些标准字段的集合，这些字段包含有关用户或设备及其相应公钥的信息。
X.509的证书文件，一般以.crt结尾，根据该文件的内容编码格式，可以分为以下二种格式：

t- PEM (Privacy Enhanced Mail)文本格式,以"---BEGIN---"开头, "---END---"结尾,内容是BASE64编码。Apache和Nginx服务器偏向于使用这种编码格式.

t- DER (Distinguished Encoding Rules)二进制格式,不可读.Java和Windows服务器偏向于使用这种编码格式

OpenSSL 相当于SSL的一个实现，如果把SSL规范看成OO中的接口，那么OpenSSL则认为是接口的实现。接口规范本身是安全没问题的，但是具体实现可能会有不完善的地方，比如之前的"心脏出血"漏洞，就是OpenSSL中的一个bug.




# Prerequisites

- You have set up OpenSSL on your machine.
- You have established a process to sign trusted certificates. If you want to have the certificates signed by a certification authority, you have either established your own certification authority or you use an external certification authority. Alternatively, you can sign the generated certificate yourself.

# Procedure

## 0. Edit OpenSSL `conf` file

```
cd /etc/pki/tls/
cp openssl.cnf_org ca.conf
vim ca.conf

[ ca ]
default_ca = CA_default #56行、何も変わらなかった

[ CA_default ]
...
x509_extensions = usr_cert #76行、何も変わらなかった
...

[ req ] #123行から
default_bits = 2048
# 125 default_md = sha256 #この行をコメントアウト
default_keyfile = privkey.pem
distinguished_name = req_distinguished_name
attributes = req_attributes
x509_extensions = v3_ca
req_extensions = v3_req #130この行を追記

...

[ usr_cert ]
191 basicConstraints=CA:FALSE #コメントイン
192 #basicConstraints=CA:TRUE #コメントアウト

nsComment = "OpenSSL Generated Certificate" #212行、何も変わらなかった

subjectKeyIdentifier = hash
authorityKeyIdentifier=keyid,issuer:always #217行、最後の`:always`を追記
subjectAltName = @alt_names #218行追記

[ v3_req ]
basicConstraints = CA:FALSE #244行、何も変わらなかった
keyUsage = nonRepudiation, digitalSignature, keyEncipherment #245行、何も変わらなかった
subjectAltName = @alt_names #246行、追記

[alt_names] #このセクションは元々存在せず追記するもの
DNS.1 = example.com
DNS.2 = *.example.com
IP.1 = 192.168.0.1
IP.2 = 192.168.0.2

```

CSRを作る際
```
[req] req_extensions = v3_req
↓
[v3_req] subjectAltName = @alt_names
↓
[alt_names]
DNS.1 = サーバのドメイン名
IP.1 = サーバのIPアドレス
```
といった流れで参照します。この設定ファイルを -config で指定して CSR を作ると、CSR に X509v3 Subject Alternative Name:エントリが入ります。

## 1. Generate Private Key & CSR

```
openssl req -new -newkey rsa:2048 -nodes -sha256 \
-subj "/C=JP/ST=Saitama/L=Toda/O=Core Micro Systems, Inc./CN=cmsinc.co.jp/emailAddress=cjl@kensho.toda" \
-config server.conf \
-keyout server.key \
-out server.csr
```

View CSR details
```
openssl req -noout -text -in /etc/pki/tls/server.csr
```


## 2. Signing

- Submit the CSR to the certification authority.
- Alternatively, sign the certificate yourself.

```
openssl ca -batch \
-keyfile /etc/pki/CA/private/cakey.pem \
-days 365 \
-config ca.conf \
-in server.csr \
-out server.crt
```
View Certificate's details
```
openssl x509 -text -noout -in server.crt
```

# Other

## File Convert

### 1. Certificate

```
openssl x509 -in kvm-bmc.crt -out kvm-bmc.pem
```

### 2. Key

Public key or Private key
```
openssl rsa -in kvm-bmc.key -out kvm-bmc-private.pem
```




## CAで発行したサーバ証明書を失効にする方法

```
openssl ca -revoke /etc/pki/CA/newcerts/xxx.pem #replacing the serial number
```


## Trouble Shooting

# Reference
>
>1. [OpenSSL Essentials: Working with SSL Certificates, Private Keys and CSRs
](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs)
>2. [Chrome58で、HTTPSの自己証明書がNET::ERR_CERT_COMMON_NAME_INVALID になる場合の対応
](https://tech.torico-corp.com/blog/chrome58-https-ssl-cert-san-error/)
>3. [OpenSSL PKI Tutorial ](https://pki-tutorial.readthedocs.io/en/latest/#)
>4. [OpenSSL Certificate Manager](https://www.golinuxcloud.com/tutorial-pki-certificates-authority-ocsp/)
