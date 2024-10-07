echo -e "Discord-VPN-DDoS-Attack-Alerts Software codificado por GonsanZ"
echo
echo "Si necesita ayuda para configurar o agregar el mensaje de notificación id: sebaxhino en Discord para obtener ayuda."
echo
echo -e "033[97mPackets/s \033[36m{}\n\033[97mBytes/s \033[36m{}\n\033[97mKbp/s \033[36m{}\n\033[97mGbp/s \033[36m{}\n\033[97mMbp/s \033[36m{}"
interface=eth0
dumpdir=/root/dumps
url='WEBHOOK HERE' ## Cambie esto a la URL de su webhook
while /bin/true; do
  old_b=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $1 }'`
  
  old_ps=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $2 }'`
  sleep 1
  new_b=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $1 }'`

  new_ps=`grep $interface: /proc/net/dev | cut -d :  -f2 | awk '{ print $2 }'`
  ##Defining Packets/s
  pps=$(( $new_ps - $old_ps ))
  ##Defining Bytes/s
  byte=$(( $new_b - $old_b ))

  gigs=$(( $byte/1024 ** 3 ))
  mbps=$(( $byte/1024 ** 2 ))
  kbps=$(( $byte/1024 ** 1 ))

  echo -ne "\r$pps packets/s\033[0K"
  tcpdump -n -s0 -c 1500 -w $dumpdir/capture.`date +"%Y%m%d-%H%M%S"`.pcap
  echo "`date` Detección de paquetes de ataque."
  sleep 1
  if [ $pps -gt 10000 ]; then ## Attack alert will display after incoming traffic reach 30000 PPS
    echo " Attack Detected Monitoring Incoming Traffic"
    curl -H "Content-Type: application/json" -X POST -d '{
      "embeds": [{
      	"inline": false,
        "title": "Ataque detectado en",
        "username": "Alertas de ataque",
        "color": 15158332,
         "thumbnail": {
          "url": "https://imgur.com/a/cZAa3Pu"
        },
         "footer": {
            "text": "Nuestro sistema está intentando mitigar el ataque y se ha activado el volcado automático de paquetes.",
            "icon_url": "https://cdn.countryflags.com/thumbs/united-states-of-america/flag-800.png"
          },
    
        "description": "Detección de un ataque ",
         "fields": [
      {
        "name": "**Proveedor de servidor**",
        "value": "OVH LLC",
        "inline": false
      },
      {
        "name": "**Dirección IP**",
        "value": "x.x.x.x",
        "inline": false
      },
      {
        "name": "**Paquetes entrantes**",
        "value": " '$pps' Pps ",
        "inline": false
      }
    ]
      }]
    }' $url
    echo "Paused for."
    sleep 120  && pkill -HUP -f /usr/sbin/tcpdump  ## La alerta "Ataque ya no detectado" se mostrará en 220 segundos.
    ## echo "Paquetes de ataques de tráfico eliminados"
    echo -ne "\r$mbps megabytes/s\033[97"
    curl -H "Content-Type: application/json" -X POST -d '{
      "embeds": [{
      	"inline": false,
        "title": "Ataque detenido",
        "username": "  Alertas de ataque",
        "color": 3066993,
         "thumbnail": {
          "url": "https://imgur.com/a/1YNwLCo.gif"
        },
         "footer": {
            "text": "Nuestro sistema ha mitigado el ataque y se ha desactivado el volcado automático de paquetes.",
            "icon_url": "https://cdn.countryflags.com/thumbs/united-states-of-america/flag-800.png"
          },    
          
        "description": "Fin del ataque",
         "fields": [
      {
        "name": "**Proveedor de servidor**",
        "value": "OVH LLC",
        "inline": false
      },
      {
        "name": "**Dirección IP**",
        "value": "x.x.x.x",
        "inline": false
      },
      {
        "name": "**Paquetes**",
        "value": "'$mbps' Mbps ",
        "inline": false
      }
    ]
      }]
    }' $url
  fi
done
