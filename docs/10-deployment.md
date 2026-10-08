AMI source: ami-0d27e0fb3bac4d724
Release ID: "v1.0.0"

Root volume: vol-06eb605fb196666dc
Encryption: "SSEAlgorithm": "AES256"
Delete on termination: True
IMDSv2: Enabled 

Runtime instance profile:"Id": "AIPA6IXLKRHE4MVWCYDQZ"
Security group: GroupId   |  sg-0576413c6db1e17ab           |
|  GroupName |  terraform-status-lab-dev-core  |
Inbound rules:[]  None

Bootstrap behavior: Installs nginx on boot of ec2 and enables it to keep Active till the instance is alive. 
Nginx port: 8080
Health endpoint:curl -i http://127.0.0.1:18080/health
Health response:HTTP/1.1 200 OK
SSM evidence: Working sessions and logs checked , starting a session with ssm.
Artifact download evidence: Able to access S3 and download the artiacts/status.txt

Direct internet :8080 test: Fail
Second terraform plan: No changes

User-data change behavior: Change... no recreate,destroy or replace 
