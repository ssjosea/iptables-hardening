#!/bin/bash

# Jose A. Estrella Tijeras

IPExt="80.1.1.2"
IPLan="172.16.0.1"
IFExt="eth0"
IFLan="eth1"

iptables -F
iptables -Z

## --- PARTE 1 ---
# Enrutar como firewall
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# Denegar todas las conexiones (entrada, salida y paso)
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

## Permitir todo el tráfico loopback
# Antes de aplicar estas reglas no podemos hacer ping a la IP de loopback
# Salida -> Request
iptables -A OUTPUT -o lo -j ACCEPT
# Entrada o respuesta -> Reply
iptables -A INPUT -i lo -j ACCEPT

# Permitir conexiones SSH -> Puerto 22
iptables -A OUTPUT -o $IFExt -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -i $IFExt -p tcp --sport 22 -j ACCEPT

# Permitir SOLO el tráfico ICMP saliente
iptables -A OUTPUT -o $IFExt -p icmp -j ACCEPT

# Permitir tráfico saliente DNS, HTTP y HTTPS
# --- DNS --- Van primero porque si no no funcionan el resto de conexiones y reglas
iptables -I OUTPUT -p udp -o $IFExt --dport 53 -j ACCEPT # Puerto 53 -> DNS entrada / protocólo UDP
iptables -I INPUT -p udp -i $IFExt --sport 53 -j ACCEPT # Puerto 53 -> DNS salida / protocólo TCP

iptables -I OUTPUT -p tcp -o $IFExt --dport 53 -j ACCEPT # Puerto 53 -> DNS entrada / protocólo UDP
iptables -I INPUT -p tcp -i $IFExt --sport 53 -j ACCEPT # Puerto 53 -> DNS salida / protocólo TCP
# --------------------------------- HTTP -----------------------------------
iptables -A OUTPUT -p tcp -o $IFExt --dport 80 -j ACCEPT # Puerto 80 -> HTTP entrada
iptables -A INPUT -p tcp -i $IFExt --sport 80 -j ACCEPT # Puerto 80 -> HTTP salida
# -------------------------------- HTTPS -----------------------------------
iptables -A OUTPUT -p tcp -o $IFExt --dport 443 -j ACCEPT # Puerto 443 -> HTTPS entrada
iptables -A INPUT -p tcp -i $IFExt --dport 443 -j ACCEPT # Puerto 443 -> HTTPS salida

# Permitir tráfico ICMP (ping) desde la máquina Windows
iptables -I INPUT -p icmp -s 10.0.4.7 -j ACCEPT

# Servir direcciones IP a los equipos con DHCP
iptables -A INPUT -i $IFExt -p udp --dport 67:68 -j ACCEPT # 67 - Puerto servidor
iptables -A OUTPUT -o $IFExt -p udp --sport 67:68 -j ACCEPT # 68 - Puerto cliente

# Permitir el trafico ICMP saliente y su respuesta
iptables -A  INPUT -p icmp --icmp-type echo-request -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir tráfico de redirección tanto por protocólo UDP como TCP
iptables -A FORWARD -i $IFLan -o $IFExt -s $IPLan -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i $IFExt -o $IFLan -s $IPLan -p udp --sport 53 -j ACCEPT

iptables -A FORWARD -i $IFLan -o $IFExt -s $IPLan -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -i $IFLan -o $IFExt -s $IPLan -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -i $IFLan -o $IFExt -s $IPLan -p tcp --dport 443 -j ACCEPT

iptables -A FORWARD -i $IFExt -o $IFLan -s $IPLan -p tcp --sport 53 -j ACCEPT
iptables -A FORWARD -i $IFExt -o $IFLan -s $IPLan -p tcp --sport 80 -j ACCEPT
iptables -A FORWARD -i $IFExt -o $IFLan -s $IPLan -p tcp --sport 443 -j ACCEPT

# Forwarding para ICMP
iptables -I FORWARD -i $IFLan -o $IFExt -s $IPLan -p icmp -j ACCEPT
iptables -I FORWARD -i $IFExt -o $IFLan -s $IPLan -p icmp -j ACCEPT

exit 0

