import sys
import uuid
import requests


def make_post_request(url, data, headers):
    response = requests.post(url, json=data, headers=headers)
    return response.status_code, response.json()

def launch_env(token, space, blueprint_name, region, duration):
    url = f"https://preview.qualilabs.net/api/spaces/{space}/environments"

    payload = {
        "environment_name": f"processing cluster {region} {str(uuid.uuid4())}",
        "blueprint_name": blueprint_name,
        "owner_email": "johnathan.v@quali.com", # change to the correct owner
        "source": {
            "repository_name": "bps"
        },
        "inputs": {
            "agent": "demo-prod", # change to the correct agent
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
    if len(sys.argv) != 8:
        print("Usage: python3 main.py <token> <region1> <region2> <region3> <region4> <space> <duration>")
        print("Example: python3 main.py 2 ML dev")
        sys.exit(1)

    token = sys.argv[1]
    region1 = sys.argv[2]
    region2 = sys.argv[3]
    region3 = sys.argv[4]
    region4 = sys.argv[5]
    space = sys.argv[6]
    duration = sys.argv[7]

    region_to_bp = {
        'eu-west-1': 'hello-world-terragrunt',
        'eu-west-2': 'hello-world-terragrunt',
        'us-east-1': 'hello-world-terragrunt',
        'us-east-2': 'hello-world-terragrunt'
    }

    blueprints = []
    blueprints.append((region1, region_to_bp[region1]))
    if region2 != 'pass':
        blueprints.append((region2, region_to_bp[region2]))
    if region3 != 'pass':
        blueprints.append((region3, region_to_bp[region3]))
    if region4 != 'pass':
        blueprints.append((region4, region_to_bp[region4]))

    for region, blueprint_name in blueprints:
        status_code, response_data = launch_env(token, space, blueprint_name, region, duration)
        if status_code != 202:
            exit(1)
        env_id = response_data.get('id')
        print(f'env id: {env_id}')


    # number_of_requests = 1 if region2 == "pass" else 2
    # for _ in range(number_of_requests):
    #     status_code, response_data = make_post_request(url, payload, headers)
    #     print(
    #         f"Status Code: {status_code}, Response: {response_data}, Headers: {headers}")


if __name__ == "__main__":
    main()