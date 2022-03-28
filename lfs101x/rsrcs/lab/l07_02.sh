#!/bin/bash
echo "for location of 'ip': $( which ip )"
echo "for everything related to 'ip':$(whereis ip | sed -e s:"ip\:":"":g)"