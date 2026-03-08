import os
import json
import urllib.request
from datetime import datetime, timezone
import boto3

s3 = boto3.client("s3")

def lambda_handler(event, context):

    api_key = os.environ["API_KEY"]
    bucket = os.environ["S3_BUCKET"]
    prefix = os.environ.get("S3_PREFIX", "").strip("/")

    symbols = ["BTC", "ETH"]

    symbol_param = "+".join(symbols)
    url = f"https://api.freecryptoapi.com/v1/getData?symbol={symbol_param}"

    req = urllib.request.Request(
        url,
        headers={
            "Authorization": f"Bearer {api_key}",
            "User-Agent": "my-training-lambda/1.0"
        }
    )

    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())

    now = datetime.now(timezone.utc)
    timestamp = now.strftime("%Y%m%dT%H%M%SZ")

    for item in data["symbols"]:
        symbol = item["symbol"]

        # 🔥 AQUI está a definição da "pasta"
        key = f"{prefix}/{symbol}/{timestamp}.json" if prefix else f"{symbol}/{timestamp}.json"

        s3.put_object(
            Bucket=bucket,
            Key=key,
            Body=json.dumps(item).encode("utf-8"),
            ContentType="application/json"
        )

    return {
        "statusCode": 200,
        "body": "Arquivos gravados com sucesso"
    }