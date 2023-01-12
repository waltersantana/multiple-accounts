# MULTIPLE ACCOUNTS
This implementation include multiple-account concepts, core and SDLC organizations and ec2 fargate



| Created by      | Creation Date | Modified by      | Modification Date |
| ----------------| ------------- | ---------------- | ----------------- |
| Walter Santana  |  16/12/2022   | Walter Santana   | 16/12/2022        |

---
<br>

## REQUIREMENTS
1. A IAM USER with Administrator Access permission on the root account
2. A Administrator role on each environment account to trust on the root account with AdministratorAccess attached policy

**Example**

```

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::[rooAccountNumber]:root"
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
```


3. Create the Terraform Workspaces on the root folder 
   
**Example**
```
cd /path/to/Environments/Projects

terraform workspace new dev
terraform workspace new qua
terraform workspace new stg
terraform workspace new prd

terraform workpace list

```

**Verification**
```
% terraform workspace list
  default
  dev
  qua
  stg
* prd

```

## RUN TERRAFORM

```
$ terraform workspace select qua

$ ENV=qua make plan
$ ENV=qua make apply
$ ENV=qua make destroy

```

   


