#!/bin/bash
echo "screen$(xdpyinfo | grep dim | sed -E -e s:"\s{2,}":" ":g)"
# you need option 'E' to use extended regex so that characters such as '\s' will be valid
