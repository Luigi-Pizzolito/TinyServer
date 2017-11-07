#!/bin/sh

#  RunServer.sh
#  TinyServer
#
#  Created by Luigi Pizzolito on 7/11/2017.
#  Copyright © 2017 Luigi Pizzolito. All rights reserved.
#
# 1 is port number
# 2 is root address
# 3 is java server address

echo Starting server on $(ipconfig getifaddr en0):"${1}" with root at "${2}"
java -jar "${3}" "${2}" "${1}"
