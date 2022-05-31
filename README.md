## AWS Cloudflare Security Group Updater 

This is a docker image and helm chart to retrieve Cloudflare's IP address list and
update an AWS Security Group and S3 Policies.

It was originally written by John McCracken (johnmccuk@gmail.com), 
updated by Ryan Gibbons (rtgibbons) and Endrigo Antonini (antonini).
Forked by @hubbleprocol

### Setup

The Lambda uses the Python 3.10 runtime and requires the following
environment variables:

* `SECURITY_GROUP_IDS_LIST` - a list of security group IDs to update
* `SECURITY_GROUP_ID` - If list is undefined, a group ID for the specified security group
* `PORTS_LIST` - comma-separated list of ports e.g. `80,443`.
* `S3_CLOUDFLARE_SID` - Sid that stores all the CloudFlare configurataion. That Sid is stored on the Stament policy.
* `S3_BUCKET_IDS_LIST` - a list of S3 buckets IDs to update
* `S3_BUCKET_ID` - if list is undefined, a ID for the specified S3 bucket.
* `UPDATE_IPV6` - if set to 0, will not update IPv6 ranges in security groups nor S3 bucket policies.

You need to allow the program to execute those actions (example on the file `allow-lambda-ingress-role`:

* ec2:AuthorizeSecurityGroupIngress
* ec2:RevokeSecurityGroupIngress
* ec2:DescribeSecurityGroup
* s3:GetBucketPolicyStatus
* s3:PutBucketPolicy
* s3:GetBucketPolicy


##### To update Security Groups

You need to define at least `SECURITY_GROUP_ID` or `SECURITY_GROUP_IDS_LIST`.
The parameter `PORTS_LIST` is also used to update an AWS Security Group.

```shell
aws ec2 create-security-group --name cloudflare-access --group-name cloudflare-access --description "http(s) access from Cloudflare IPs only" --vpc-id VPC-ID-GOES-HERE

SECURITY_GROUP_ID=sg-... python src/updater/main.py
```

##### To update S3 Policy

You need to define the parameter `S3_CLOUDFLARE_SID` and at least one of the
following parameters `S3_BUCKET_IDS_LIST` or `S3_BUCKET_ID`.

#### Run docker image

```shell
docker run \
-e SECURITY_GROUP_ID="sg-1234..." \
-e AWS_DEFAULT_REGION="eu-west-1" \
-e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
-e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  hubbleprotocol/cloudflare-security-group-updater:latest
```

### Development

#### Build docker image

```shell
docker build . -t hubbleprotocol/cloudflare-security-group-updater
```

#### Build helm chart
```shell
cd helm

helm package ./
```

##### values.yaml
```yaml
cronjob-base-chart:
  cloudflare-security-group-updater:
    jobs:
    - name: update-cloudflare-ingress-security-groups
      schedule: "*/5 * * * *"
      envVars:
        - name: SECURITY_GROUP_ID
          value: "sg-123..."
        - name: AWS_DEFAULT_REGION
          value: "eu-west-1"
        - name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              name: cloudflare-security-group-updater-secret
              key: AWS_ACCESS_KEY_ID
        - name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              name: cloudflare-security-group-updater-secret
              key: AWS_ACCESS_KEY_ID
  secrets:
    AWS_ACCESS_KEY_ID:
    AWS_SECRET_ACCESS_KEY:
```

### Contributors

* John McCracken ([@johnmccuk](https://www.github.com/johnmccuk))
* Ryan Gibbons ([@rtgibbons](https://www.github.com/rtgibbons)) 
* Ben Steinberg ([@bensteinberg](https://www.github.com/bensteinberg))
* Endrigo Antonini ([@antonini](https://www.github.com/antonini))
* Hubble developers ([@hubbleprotocol](https://www.github.com/hubbleprotocol))