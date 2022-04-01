# Terraform & AWS Demo

## AWS Credentials

To run this project you will need admin credentials to an AWS account.

Log in to the AWS account, head to the IAM section and do the following

- Create a new user and attach the `AdministratorAccess` policy
- Create security credentials for said user

Now you'll need to do one of the following to get terraform to use the credentials.

NOTE: for more information on how to authenticate terraform with AWS, refer to
[AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Option 1: use aws-vault (secure, preferred)

This is the most secure way to use aws credentials locally, and is what I recommend everyone
use.

[aws-vault](https://github.com/99designs/aws-vault) is a little wrapper that
stores your permanent AWS credentials (the ones you've created from the IAM
console) in your OS's keychain (supports macOS, windows & linux) and it creates
temporary credentials every time you execute the profile. This means your AWS
credentials are never in plaintext anywhere in your computer.

To install on mac:

```
brew install aws-vault
```

Then add a new profile, which will prompt you for your AWS credentials.

```
aws-vault add myprofile
```

Now that you're done setting up `aws-vault`, let's configure Makefile to use
that. Copy `staging/.make.env.example` to `staging/.make.env` and uncomment and
adjust the `TF` var as following:

```
TF=aws-vault exec myprofile -- terraform
```

That's it, this will tell `aws-vault` to get temporary credentials for your
profile and pass them along to `terraform` as environment variables.


### Option 2: store credentials in  `~/.aws/credentials` (insecure)

Create or edit the file at `~/.aws/credentials` and enter your AWS credentials
as follows

```
[default]
aws_access_key_id=<your-key-id>
aws_secret_access_key=<your-key-secret>
```

### Option 3: store credentials in the terraform config (insecure)

This is the quickest way to get the terraform files working, but also the
less secure, as you'll be editing the `.tf` file directly and there's a chance
you might accidentally commit this to the repository. There's ways around this using
variables to specity the keys, but you should really be using `aws-vault` locally.

Edit `staging/terraform.tf` and update the `aws` provider config to include your security keys:

```terraform
provider "aws" {
  region = "ap-southeast-2"
  access_key = ""
  secret_key = ""
}
```

## Running the terraform module

From the `staging` directory, run the folowing to initialise terraform, which
will install the required providers as per `staging/versions.tf`

```
make init
```

Now, you can just use the `make` command to run terraform. I've provided tasks that somewhat
match the terraform counterpart. Just runing `make` with no arguments will list all the avialable
tasks and their purpose.

- `make plan` will show you what terraform will do on AWS.
- `make apply` will apply the changes.
- `make destroy` will destroy the infrastructure that was created by terraform.

