#!/bin/bash

IFLan="eth2"
IFDMZ="eth1"
IFExt="eth0"

IPDin="IP dinamica"

## 1. Borrar las reglas existentes
iptables -F
iptables -X

## 2. Estableces políticas restrictivas por defecto -> DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

## Permitir todo el tráfico loopback
# Antes de aplicar estas reglas no podemos hacer ping a la IP de loopback
# Salida -> Request
iptables -A OUTPUT -o lo -j ACCEPT
# Entrada o respuesta -> Reply
iptables -A INPUT -i lo -j ACCEPT

## 4. Permitir tráfico ICMP respondiendo por todas las interfaces
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

## 3. Acceso SSH desde LAN y direcciones IP específicas
# 3.1 Acceso desde LAN
iptables -A INPUT -p tcp --dport 22 -s $IFLan -j ACCEPT
# 3.2 Acceso desde las direcciones IP 8.8.8.8 y 4.4.4.4
iptables -A OUTPUT -p tcp --dport 22 -s 8.8.8.8,4.4.4.4 -j ACCEPT

## 5. El firewall puede iniciar conexiones SSH hacia servidores DMZ
iptables -A INPUT -p tcp --dport 22 -d $IFExt -j ACCEPT

## 6. Conectividad cliente desde el firewall a HTTP, HTTPS y DNS
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

## 7. La red DMZ tiene acceso a HTTP, HTTPS y DNS
iptables -A OUTPUT -p tcp --dport 80 -s $IFExt -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -s $IFExt -j ACCEPT

iptables -A OUTPUT -p tcp --dport 443 -s $IFExt -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -s $IFExt -j ACCEPT

iptables -I OUTPUT -p tcp --dport 53 -s $IFExt -j ACCEPT
iptables -I OUTPUT -p tcp --sport 53 -s $IFExt -j ACCEPT

## 8. Desde la red DMZ se acepta tráfico ICMP saliente de tipo 0,3,8 y 11
# Permitir todo el tráfico ICMP con orgigen en la DMZ
iptables -A FORWARD -s 172.16.0.0/24 -p icmp -j ACCEPT

iptables -A FORWARD -s 172.16.0.0/24 -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A FORWARD -s 172.16.0.0/24 -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A FORWARD -s 172.16.0.0/24 -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A FORWARD -s 172.16.0.0/24 -p icmp --icmp-type echo-request -j ACCEPT

iptables -A OUTPUT -s $IFDMZ -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A OUTPUT -s $IFDMZ -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A OUTPUT -s $IFDMZ -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -s $IFDMZ -p icmp --icmp-type echo-request -j ACCEPT

# Denegamos el resto de conexiones que no nos interesan
iptables -A FORWARD -d 172.16.0.0/24 -p icmp -j DROP

## 9. Desde la red DMZ se ofrecen los servicios:
# Web seguras -> HTTPS
iptables -I FORWARD -s $IFDMZ -p tcp --dport 443 -d 172.16.0.2 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --dport 80 -d 172.16.0.2 -j ACCEPT

iptables -I FORWARD -s $IFDMZ -p tcp --sport 443 -d 172.16.0.2 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --sport 80 -d 172.16.0.2 -j ACCEPT

# Servidor de correo SMTP, SMTPS, POP3, POP3S
iptables -I FORWARD -s $IFDMZ -p tcp --dport 25 -d 172.16.0.3 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --sport 25 -d 172.16.0.3 -j ACCEPT

iptables -I FORWARD -s $IFDMZ -p tcp --dport 465 -d 172.16.0.3 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --sport 465 -d 172.16.0.3 -j ACCEPT

iptables -I FORWARD -s $IFDMZ -p tcp --dport 587 -d 172.16.0.3 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --sport 587 -d 172.16.0.3 -j ACCEPT

iptables -I FORWARD -s $IFDMZ -p tcp --dport 565 -d 172.16.0.3 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --sport 565 -d 172.16.0.3 -j ACCEPT

iptables -I FORWARD -s $IFDMZ -p tcp --dport 110 -d 172.16.0.3 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --sport 110 -d 172.16.0.3 -j ACCEPT

iptables -I FORWARD -s $IFDMZ -p tcp --dport 995 -d 172.16.0.3 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --sport 995 -d 172.16.0.3 -j ACCEPT

iptables -I FORWARD -s $IFDMZ -p tcp --dport 220 -d 172.16.0.3 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --sport 220 -d 172.16.0.3 -j ACCEPT

iptables -I FORWARD -s $IFDMZ -p tcp --dport 2525 -d 172.16.0.3 -j ACCEPT
iptables -I FORWARD -s $IFDMZ -p tcp --sport 2525 -d 172.16.0.3 -j ACCEPT

## 10. Desde la red LAN se podrá acceder a recursos HTTP, HTTPS DNS y FTP
iptables -A INPUT -p tcp --dport 80 -s $IFLan -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -s $IFLan -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -s $IFLan -j ACCEPT
iptables -A INPUT -p tcp --dport 21 -s $IFLan -j ACCEPT

## 11. Desde la red LAN se acepta tráfico ICMP saliente de tipo 0,3,8 y 11
iptables -A OUTPUT -s $IFLan -p icmp --icmp-type destination-unreachable -j ACCEPT
iptables -A OUTPUT -s $IFLan -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A OUTPUT -s $IFLan -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -s $IFLan -p icmp --icmp-type echo-request -j ACCEPT

## DNAT
iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 80 -j DNAT --to-destination $IPDin
iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 443 -j DNAT --to-destination $IPDin

iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 53 -j DNAT --to-destination $IPDin
iptables -t nat -A PREROUTING -i $IFExt -p udp --dport 53 -j DNAT --to-destination $IPDin

iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 25 -j DNAT --to-destination $IPDin
iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 465 -j DNAT --to-destination $IPDin
iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 587 -j DNAT --to-destination $IPDin
iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 565 -j DNAT --to-destination $IPDin
iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 110 -j DNAT --to-destination $IPDin
iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 995 -j DNAT --to-destination $IPDin
iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 220 -j DNAT --to-destination $IPDin
iptables -t nat -A PREROUTING -i $IFExt -p tcp --dport 2525 -j DNAT --to-destination $IPDin

## SNAT
# DMZ
iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o $IFDMZ -j MASQUERADE
# LAN
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o $IFLAN -j MASQUERADE


exit 0
