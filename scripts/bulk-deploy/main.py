import requests
import sys
import uuid


def make_post_request(url, data, headers):
    response = requests.post(url, json=data, headers=headers)
    return response.status_code, response.json()


def main():
    if len(sys.argv) != 6:
        print("Usage: python3 main.py <token> <region1> <region2> <space> <application>")
        print("Example: python3 main.py 2 ML dev")
        sys.exit(1)

    token = sys.argv[1]
    region1 = sys.argv[2]
    region2 = sys.argv[3]
    space = sys.argv[4]
    application = sys.argv[5]

    if application == "prod":
        blueprint_name = "hello-world-terragrunt" 
    elif application == "qa":
        blueprint_name = "hello-world-terragrunt"
    elif application == "dev":
        blueprint_name = "hello-world-terragrunt"
    else:
        print("Unknown application type. Please use 'prod', 'qa', or 'dev'.")
        sys.exit(1)

    url = f"https://portal.qtorque.io/api/spaces/{space}/environments"

    payload = {
        "environment_name": f"processing cluster {str(uuid.uuid4())}",
        # "blueprint_name": blueprint_name,
        "owner_email": "david.b@quali.com",
        "source": {
            "blueprint_name": blueprint_name,
            "repository_name": "bps",
        },
        "inputs": {
            "agent": "demo-prod",
            "1st-region": "us-east-1",
            "2nd-region": "us-east-1"
        },
        "labels": [
            {
                "key": "region",
                "value": "us-east-1"
            }
        ],
        # "collaborators": {
        #     "collaborators_emails": ["string"],
        #     "all_space_members": True
        # },
        "automation": True,
        # "scheduled_end_time": "2019-08-24T14:15:22Z",
        "duration": "PT1H"
    }
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": f"Bearer {token}"
    }

    status_code, response_data = make_post_request(url, payload, headers)
    print(
        f"Status Code: {status_code}, Response: {response_data}, Headers: {headers}")

    # number_of_requests = 1 if region2 == "pass" else 2
    # for _ in range(number_of_requests):
    #     status_code, response_data = make_post_request(url, payload, headers)
    #     print(
    #         f"Status Code: {status_code}, Response: {response_data}, Headers: {headers}")


if __name__ == "__main__":
    main()