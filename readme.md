# Readme

## Running the Terraform Config

1. Ensure you are logged into AWS on your local system via Auth Keys
2. Run the command below. 

```shell
terraform apply --auto-approve  --var-file .\terraform.tfvars
```

You need a file called `terraform.tfvars` that needs to contain the following vars

```python
hosted_zone_id="XXXX"
ebs_volume_id="vol-XXXXX"
```

`hosted_zone_id` can be empty if you arent using domains[^1]. The 2nd variable `ebs_volume_id` is **REQUIRED**. This is the volume you have already configured the server on.

[^1]: See Variables file for domain variable. If you are not using domains set this to false.

