# Example Packer AMI image preparation with Ansible provisioner
Ansible roles are in `ansible-roles` directory.
Any new role should be also referenced in the `packer/{ami_name}/packer.yml` file.

## How To

1. Edit `packer/vars.json` file and update

  - *region* - region where image will be built
  - *instance_type* - instance size for the builder instance, the bigger the faster it builds
  - *owners* - If using official AWS base image, leave to "099720109477"
  - *stage* - Stage to attach to instance name and tags
  - *subnet_id* -  Packer needs to spin up instance in public network so that it can SSH to it, so here specify default VPC public subnet

2. Export `AWS_PROFILE` with your account creds
3. Navigate to desired ami directory
```bash
cd packer/example-ami
```
4. Build image

```bash
make build
```

or run full command:

```bash
packer build -var-file="../vars.json" ./build.json.pkr.hcl 2>&1 | tee build.log
```

If success, you will get new AMI id in the output:

```
==> amazon-ebs.example_ami: Stopping the source instance...
    amazon-ebs.example_ami: Stopping instance
==> amazon-ebs.example_ami: Waiting for the instance to stop...
==> amazon-ebs.example_ami: Creating AMI example-ami-prod-ubuntu22-21-Jan-25-08-29-44 from instance i-0361b4e2fb98b505d
    amazon-ebs.example_ami: AMI: ami-0455f1ca406c15e33
==> amazon-ebs.example_ami: Waiting for AMI to become ready...
```
