#!/bin/bash

PossibleOptions()
{
    echo "a - see network card model, chanel speed, duplex, link, MAC"
    echo "b - see IPv4 configuration"
    echo "c - configure IPv4 interface"
    echo "d - exit" 
}

Start()
{
    read -p "Chose option " option
    echo $option
}

ConfigureIP()
{
    interface=`lshw -class network | grep "name" | awk '{print $3}'`
    echo "$interface is active interface"
    echo "a - configure automatically"
    echo "b - configure manually"
    echo "c - quit"

    read -p "Chose option " option
    case $option in
    a)
        dhcclient -v -r $interface
        dhcclient -v $interface
        ;;
    
    b)
        ip="10.100.0.2"
        mask="255.255.255.0"
        gate="10.100.0.1"
        dns="8.8.8.8"
        
        ip address add $ip/$mask dev $interface
        ip route delete default dev $interface
        ip route add default via $gate dev $interface
        echo "namespace ${dns}" | tee /etc/resolv.conf
        ;;

    c)  
        PossibleOptions
        OptionSwitch $(Start)
        ;;
    
    *)
        echo "Unknown command"
        ;;

    esac
    echo
    ConfigureIP
}

OptionSwitch()
{
    option=$1
    case $option in
    a)
        interface=`lshw -class network | grep "name" | awk '{print $3}'`
        card=`lshw -class network | grep "product"`
        speed=`ethtool $interface | grep "Speed"`
        duplex=`ethtool $interface | grep "Duplex"`
        link=`ethtool $interface | grep "Link"`
        mac=`lshw -class network | grep "serial"`

        echo 
        echo "Results:"
        echo $interface
        echo $card
        echo $speed
        echo $duplex
        echo $link
        echo $mac
        ;;

    b)
        interface=`lshw -class network | grep "name" | awk '{print $3}'`
        mask=`ip -detail address show dev $interface | grep "inet " | awk '{print $2}'`
        gate=`ip -human route show dev $interface`
        dns=`cat /etc/resolv.conf`

        echo 
        echo "Results:"
        echo $mask
        echo $gate
        echo $dns
        ;;

    c)
        ConfigureIP
        ;;
    
    d)
        exit
        ;;
    
    *)
        echo "Unknown command"
        ;;
    esac

    echo
    PossibleOptions
    OptionSwitch $(Start)
}

echo "Lab 1. Task 1"
PossibleOptions
OptionSwitch ($Start)
