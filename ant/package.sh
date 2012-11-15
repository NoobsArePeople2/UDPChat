#! /bin/bash

export PATH=~/Dev/Flex/4.6.0_AIR_3.5/bin:$PATH

adt -package -keystore ../cert/cert.p12 -storetype pkcs12 -storepass password -target bundle UDPChat.app UDPChat-app.xml UDPChat.swf