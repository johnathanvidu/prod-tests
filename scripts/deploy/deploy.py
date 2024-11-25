import sys
import uuid
import requests

from datetime import datetime


def make_post_request(url, data, headers):
    response = requests.post(url, json=data, headers=headers)
    return response.status_code, response.json()

def launch_env(token, space, blueprint_name, duration):
    url = f"https://portal.qtorque.io/api/spaces/{space}/environments"

    payload = {
        "environment_name": f"env {datetime.now().isoformat()}",
        "blueprint_name": blueprint_name,
        "owner_email": "johnathan.v@quali.com",
        "source": {
            "repository_name": "bps"
        },
        "inputs": {
            "agent": "vido-vido-prod",
        },
        "labels": [
            {
                "key": "attach-processing"
            },
            {
              "key": "detach-processing"
            }
        ],
        "automation": True,
        "duration": f"PT{duration}H"
    }
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": f"Bearer {token}"
    }
    return make_post_request(url, payload, headers)

def main():
    if len(sys.argv) != 6:
        print("Usage: python3 main.py <token> <space> <duration>")
        sys.exit(1)

    token = sys.argv[1]
    space = sys.argv[2]
    duration = sys.argv[3]
    status_code, response_data = launch_env(token, space, 'output-hello-world.yaml', duration)
    if status_code != 202:
      exit(1)

if __name__ == "__main__":
    main()
