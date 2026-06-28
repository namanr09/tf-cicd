
import os

def handler(event, context):
    print("ingest invoked:", event)
    print("target bucket:", os.environ.get("BUCKET_NAME"))
    return {"statusCode": 200, "body": "ok"}
