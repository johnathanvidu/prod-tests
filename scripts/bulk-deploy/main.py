import sys
import uuid
import requests


def make_post_request(url, data, headers):
    response = requests.post(url, json=data, headers=headers)
    return response.status_code, response.json()

def launch_env(token, space, blueprint_name, region, duration):
    url = f"https://portal.qtorque.io/api/spaces/{space}/environments"

    payload = {
        "environment_name": f"processing cluster {region} {str(uuid.uuid4())}",
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
                "key": "region",
                "value": f"{region}"
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
        print("Usage: python3 main.py <token> <region1> <region2> <space> <duration>")
        sys.exit(1)

    token = sys.argv[1]
    region1 = sys.argv[2]
    region2 = sys.argv[3]
    space = sys.argv[4]
    duration = sys.argv[5]

    region_to_bp = {  # change those to the right blueprint names
        'eu-west-1': 'hello-world-terragrunt', 
        'us-east-1': 'hello-pre-scripts',
    }

    blueprints = []
    blueprints.append((region1, region_to_bp[region1]))
    if region2 != 'pass':
        blueprints.append((region2, region_to_bp[region2]))

    for region, blueprint_name in blueprints:
        status_code, response_data = launch_env(token, space, blueprint_name, region, duration)
        if status_code != 202:
            exit(1)
        env_id = response_data.get('id')
        env_var_name = region.replace('-', '_')
        print(f'export {env_var_name}=https://portal.qtorque.io/{space}/environments/{env_id}')


if __name__ == "__main__":
    main()