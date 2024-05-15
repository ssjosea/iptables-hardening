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
