import aws_cdk as core
import aws_cdk.assertions as assertions

from s3.s3_stack import S3Stack

# example tests. To run these tests, uncomment this file along with the example
# resource in s3/s3_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = S3Stack(app, "s3")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
