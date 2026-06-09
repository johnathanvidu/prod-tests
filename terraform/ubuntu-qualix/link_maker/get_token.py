#!/usr/bin/env python3
"""
Generates a fresh QualiX qtoken, POSTs to /remote/api/tokens, and returns
the auth token and connection ID. Called by Terraform's external data source.

Input  (stdin): JSON with qualix_ip, hostname, protocol, port, username, access_key
Output (stdout): JSON with auth_token and qid
"""

import base64
import json
import ssl
import sys
import time
import urllib.parse
import urllib.request
import uuid

data = json.load(sys.stdin)

qualix_ip  = data["qualix_ip"]
hostname   = data["hostname"]
protocol   = data["protocol"]
port       = data["port"]
username   = data["username"]
access_key = data["access_key"]

# Generate a fresh qtoken at execution time — no Terraform timestamp needed
guid   = uuid.uuid4().hex
raw    = f"{guid},{int(time.time()) * 10000000}"
b64    = base64.b64encode(raw.encode()).decode()
qtoken = b64.replace("+", "-").replace("/", "_").replace("=", "~")

# 5-char connection ID — mirrors QxController's qid calculation
qid = (protocol + guid)[:5]

body = urllib.parse.urlencode({
    "qtoken":     qtoken,
    "hostname":   hostname,
    "protocol":   protocol,
    "port":       port,
    "username":   username,
    "access-key": access_key,  # raw PEM — urllib handles URL-encoding
    "qualix":     qualix_ip,
}).encode("utf-8")

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode    = ssl.CERT_NONE

req = urllib.request.Request(
    f"https://{qualix_ip}/remote/api/tokens",
    data=body,
    headers={"Content-Type": "application/x-www-form-urlencoded"},
)

with urllib.request.urlopen(req, context=ctx) as resp:
    result = json.loads(resp.read())

print(json.dumps({
    "auth_token": result["authToken"],
    "qid":        qid,
}))
