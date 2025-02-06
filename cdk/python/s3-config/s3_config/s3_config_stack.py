from aws_cdk import (
    # Duration,
    Stack,
    aws_s3 as s3,
)
from constructs import Construct

class S3ConfigStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, bucket_name, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        s3.Bucket(
            self, 
            id="bucket", 
            bucket_name=bucket_name
            )
