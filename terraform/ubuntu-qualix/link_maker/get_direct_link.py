#!/usr/bin/env python3
"""
Builds a direct QualiX URL with all connection params embedded in the fragment.
No server-side token exchange — each browser click re-authenticates fresh and
registers the connection on-demand, so the link never expires.

Requires /disableValidateLink on the QualiX server (disables the 60-second
qtoken time window). If that file is absent, the link only works for ~60s
after apply; use get_token.py (direct_link = false) instead.

Input  (stdin): JSON with qualix_ip, hostname, protocol, port, username, access_key
Output (stdout): JSON with link
"""

import base64
import json
import sys
import time
import urllib.parse
import uuid

data = json.load(sys.stdin)

qualix_ip  = data["qualix_ip"]
hostname   = data["hostname"]
protocol   = data["protocol"]
port       = data["port"]
username   = data["username"]
access_key = data["access_key"]

# Fresh qtoken — timestamp validated by QualiX on each click (or skipped if
# /disableValidateLink exists on the server)
guid   = uuid.uuid4().hex
raw    = f"{guid},{int(time.time()) * 10000000}"
b64    = base64.b64encode(raw.encode()).decode()
qtoken = b64.replace("+", "-").replace("/", "_").replace("=", "~")

# "qualix" param tells QualiX to use the 5-char connection ID format,
# matching what QxController puts in the client URL
qid = (protocol + guid)[:5]

# urllib.parse.urlencode properly encodes the raw PEM key (\n → %0A etc.)
# so QualiX receives the decoded PEM and sets it directly as private-key
params = urllib.parse.urlencode({
    "qtoken":     qtoken,
    "hostname":   hostname,
    "protocol":   protocol,
    "port":       port,
    "username":   username,
    "access-key": access_key,
    "qualix":     qualix_ip,
})

print(json.dumps({"link": f"https://{qualix_ip}/remote/#/client/{qid}/?{params}"}))
