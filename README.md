# Guía Completa de Configuración de iptables

## Introducción

`iptables` es una herramienta esencial para la gestión de cortafuegos en sistemas Linux. Este script unificado muestra cómo ver las reglas actuales, bloquear todo el tráfico entrante, permitir conexiones SSH, bloquear una IP específica, permitir tráfico HTTP/HTTPS, y guardar/restaurar la configuración.

## Script ejemplo de iptables

```sh
#!/bin/bash

# Mostrar las reglas actuales de iptables
echo "Mostrando las reglas actuales de iptables:"
sudo iptables -L -v

# Bloquear todo el tráfico entrante excepto el tráfico en la interfaz loopback (lo)
echo "Bloqueando todo el tráfico entrante excepto loopback y conexiones establecidas:"
sudo iptables -P INPUT DROP
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir conexiones SSH entrantes en el puerto 22
echo "Permitiendo tráfico SSH entrante en el puerto 22:"
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Bloquear tráfico entrante desde una dirección IP específica
BLOCK_IP="192.168.1.100"
echo "Bloqueando todo el tráfico desde la IP: $BLOCK_IP"
sudo iptables -A INPUT -s $BLOCK_IP -j DROP

# Permitir tráfico HTTP (puerto 80) y HTTPS (puerto 443)
echo "Permitiendo tráfico HTTP y HTTPS:"
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Guardar las reglas actuales de iptables
echo "Guardando la configuración actual de iptables:"
sudo iptables-save > /etc/iptables/rules.v4

# Mostrar las reglas actuales después de la configuración
echo "Mostrando las reglas actuales después de la configuración:"
sudo iptables -L -v

# Nota: Para restaurar la configuración en el inicio, se debe asegurar que el paquete iptables-persistent esté instalado y configurado correctamente.
# sudo apt-get install iptables-persistent
# sudo netfilter-persistent save
# sudo netfilter-persistent reload

echo "Configuración de iptables completada."

# Explicación de los Scripts de iptables

Este documento explica dos scripts diferentes de configuración de `iptables`. Cada uno de ellos configura reglas de cortafuegos (firewall) para diferentes interfaces de red y objetivos específicos.

## Script 1: `ej1-iptables.sh`

### Introducción

El script `ej1-iptables.sh` está diseñado para configurar un cortafuegos utilizando `iptables`. Incluye reglas para enrutar tráfico, permitir conexiones SSH, y gestionar tráfico ICMP, DNS, HTTP y HTTPS.

### Detalles del Script

1. **Limpieza de Reglas Existentes:**
   - Se eliminan todas las reglas existentes en todas las cadenas (`iptables -F`).
   - Se reinician los contadores de bytes y paquetes en todas las cadenas (`iptables -Z`).

2. **Enrutamiento como Firewall:**
   - Se enmascaran las direcciones IP para el tráfico que sale por la interfaz `eth1` (`iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE`).

3. **Políticas por Defecto:**
   - Se establece que todas las conexiones entrantes (`INPUT`), salientes (`OUTPUT`) y de reenvío (`FORWARD`) se deniegan por defecto (`DROP`).

4. **Permitir Tráfico Loopback:**
   - Se permite el tráfico entrante y saliente en la interfaz loopback (`lo`).

5. **Permitir Conexiones SSH:**
   - Se permiten conexiones SSH salientes y entrantes en la interfaz externa (`IFExt`), utilizando el puerto 22.

6. **Permitir ICMP Saliente:**
   - Se permite todo el tráfico ICMP saliente en la interfaz externa (`IFExt`).

7. **Permitir Tráfico DNS, HTTP y HTTPS:**
   - Se permite el tráfico DNS (puerto 53), HTTP (puerto 80) y HTTPS (puerto 443) tanto entrante como saliente en la interfaz externa (`IFExt`).

8. **Permitir ICMP desde una Máquina Específica:**
   - Se permite el tráfico ICMP desde la IP `10.0.4.7`.

9. **Servir DHCP:**
   - Se permite el tráfico DHCP para la asignación de direcciones IP.

10. **Permitir Redirección de Tráfico:**
    - Se permiten las redirecciones de tráfico UDP y TCP para DNS, HTTP y HTTPS entre las interfaces LAN (`IFLan`) y externa (`IFExt`).

11. **Permitir Forwarding para ICMP:**
    - Se permite el reenvío de tráfico ICMP entre las interfaces LAN y externa.

## Script 2: `ej2-iptables.sh`

### Introducción

El script `ej2-iptables.sh` configura un cortafuegos con `iptables` para gestionar varias interfaces de red, incluyendo una interfaz LAN, DMZ y externa. Configura reglas para SSH, ICMP, HTTP, HTTPS y otros servicios.

### Detalles del Script

1. **Limpieza de Reglas Existentes:**
   - Se eliminan todas las reglas existentes en todas las cadenas (`iptables -F` y `iptables -X`).

2. **Políticas por Defecto:**
   - Se establece que todas las conexiones entrantes (`INPUT`), salientes (`OUTPUT`) y de reenvío (`FORWARD`) se deniegan por defecto (`DROP`).

3. **Permitir Tráfico Loopback:**
   - Se permite el tráfico entrante y saliente en la interfaz loopback (`lo`).

4. **Permitir Tráfico ICMP:**
   - Se permite todo el tráfico ICMP en todas las interfaces.

5. **Acceso SSH:**
   - Se permite el acceso SSH desde la LAN (`IFLan`) y desde direcciones IP específicas (8.8.8.8 y 4.4.4.4).
   - El firewall puede iniciar conexiones SSH hacia servidores DMZ.

6. **Conectividad Cliente desde el Firewall:**
   - Se permite tráfico saliente a HTTP (puerto 80), HTTPS (puerto 443) y DNS (puerto 53).

7. **Acceso desde la Red DMZ:**
   - La red DMZ (`IFExt`) tiene acceso a HTTP, HTTPS y DNS.
   - Se permite tráfico ICMP saliente de tipo 0 (echo-reply), 3 (destination-unreachable), 8 (echo-request) y 11 (time-exceeded) desde la DMZ.

8. **Servicios Ofrecidos desde la DMZ:**
   - Se configuran reglas para permitir servicios web seguros (HTTP y HTTPS) y servicios de correo (SMTP, SMTPS, POP3, POP3S) desde la DMZ a direcciones específicas.

9. **Acceso desde la Red LAN:**
   - La red LAN (`IFLan`) puede acceder a recursos HTTP, HTTPS, DNS y FTP.

10. **Permitir Tráfico ICMP Saliente desde la LAN:**
    - Se permite tráfico ICMP saliente de tipo 0, 3, 8 y 11 desde la LAN.

11. **Configuración DNAT y SNAT:**
    - Se configuran reglas de DNAT para redirigir el tráfico entrante en puertos específicos a una dirección IP dinámica (`IPDin`).
    - Se configuran reglas de SNAT para enmascarar el tráfico saliente tanto de la DMZ como de la LAN.

Estos scripts proporcionan una configuración robusta de cortafuegos, asegurando que solo el tráfico permitido pueda fluir entre las diferentes interfaces de red y servicios.
