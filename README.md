# Simple Upload Tool for S3

Usage:
```
#!/bin/sh

export AWS_ACCESS_KEY_ID='supersecret'
export AWS_SECRET_ACCESS_KEY='supersecret'
export S3_ENDPOINT='https://hostname:port'
export S3_BUCKET_NAME='bucketname'

shotgun --host 0.0.0.0 --port 8080 s3uploader.rb
```
