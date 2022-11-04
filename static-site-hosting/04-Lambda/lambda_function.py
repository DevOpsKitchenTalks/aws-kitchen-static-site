import pathlib
import base64


def get_file(path):
    data = None
    try:
        with open(f"dist/{path}", "rb") as f:
            data = f.read()
    except OSError:
        print("no file found")
    return (pathlib.Path(path).suffix.replace(".", ""), data)


def lambda_handler(event, context):
    path = event["rawPath"]
    # Final response core
    response = {"statusCode": 200, "headers": {"Content-Type": "text/html"}}
    # Try to get file
    extension, body = get_file(path)
    if not body:
        if not path.endswith("index.html"):
            return {"statusCode": 301, "headers": {"Location": "index.html"}}

    if extension == "jpg":
        response["body"] = base64.b64encode(body).decode("utf-8")
        response["headers"]["Content-Type"] = "image/jpg"
        response["isBase64Encoded"] = True
    else:
        response["body"] = body
        response["headers"]["Content-Type"] = f"text/{extension}"
    return response
