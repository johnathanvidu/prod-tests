#!/usr/bin/env python3
"""
Posts connection parameters to a QualiX /remote/api/tokens endpoint and
returns the auth token. Called by Terraform's external data source.

Input  (stdin): JSON object with keys matching the query map in main.tf
Output (stdout): JSON object {"auth_token": "..."}
"""

import json
import ssl
import sys
import urllib.parse
import urllib.request

data = json.load(sys.stdin)

qualix_ip = data["qualix_ip"]

body = urllib.parse.urlencode({
    "qtoken":     data["qtoken"],
    "hostname":   data["hostname"],
    "protocol":   data["protocol"],
    "port":       data["port"],
    "username":   data["username"],
    "access-key": data["access_key"],  # raw PEM — urllib handles URL-encoding
    "qualix":     qualix_ip,           # signals QualiX to use 5-char connection IDs
}).encode("utf-8")

req = urllib.request.Request(
    f"https://{qualix_ip}/remote/api/tokens",
    data=body,
    headers={"Content-Type": "application/x-www-form-urlencoded"},
)

# QualiX commonly uses self-signed certs
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

with urllib.request.urlopen(req, context=ctx) as resp:
    result = json.loads(resp.read())

print(json.dumps({"auth_token": result["authToken"]}))
