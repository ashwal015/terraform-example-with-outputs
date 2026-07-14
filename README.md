# 🌍 Terraform + GitHub Actions: Automated EC2 Deployment

A full CI/CD pipeline that provisions an AWS EC2 instance with Terraform, installs NGINX, and deploys a static website — all triggered automatically by a `git push`, with a separate manual workflow to tear everything down.

---

## 📌 What This Project Does

```
Push to GitHub
      │
      ▼
GitHub Actions triggers
      │
      ▼
Terraform provisions:
  • Security Group (opens ports 22 & 80)
  • EC2 instance (t2.micro, Ubuntu)
      │
      ▼
Workflow reads Terraform outputs (public IP)
      │
      ▼
SSH into the instance
      │
      ▼
Install NGINX  →  Deploy index.html
      │
      ▼
Website is live at http://<public-ip>
```

A separate **manually-triggered workflow** (`workflow_dispatch`) runs `terraform destroy` to clean up all resources on demand.

---

## 🗂️ Project Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform.yml       # CI/CD pipeline: apply+deploy, and destroy
├── main.tf                      # Provider, Security Group, EC2 instance
├── variables.tf                 # Instance type, count, AMI as variables
├── outputs.tf                   # Public/private IP outputs
├── index.html                   # Website content deployed via SSH
├── .gitignore                   # Excludes .pem keys and Terraform state files
└── README.md
```

---

## ⚙️ Infrastructure Overview (`main.tf`)

| Resource | Purpose |
|---|---|
| `aws_security_group.web_sg` | Opens inbound **port 22** (SSH) and **port 80** (HTTP); allows all outbound traffic |
| `aws_instance.first_instance` | EC2 instance, attached to `web_sg`, using an existing key pair for SSH access |

Remote state is stored in an **S3 backend**, so the Terraform state persists across GitHub Actions runs (each run uses a fresh, temporary runner with no local disk memory):

```hcl
terraform {
  backend "s3" {
    bucket = "<your-s3-bucket-name>"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
```

---

## 🔧 Variables (`variables.tf`)

| Variable | Default | Purpose |
|---|---|---|
| `aws_instance_type` | `t2.micro` | Free Tier eligible instance size |
| `instance_count` | `1` | Number of EC2 instances to create |

---

## 📤 Outputs (`outputs.tf`)

| Output | Description |
|---|---|
| `public_ips` | Public IP address(es) of the created instance(s) |
| `private_ips` | Private IP address(es) of the created instance(s) |

---

## ⚙️ Setup Instructions

### 1. Create an S3 bucket for Terraform state
Bucket names must be **globally unique** and **lowercase**:
```bash
aws s3api create-bucket --bucket <your-unique-bucket-name> --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1
```
Update the `bucket` value in `main.tf`'s `backend "s3"` block to match.

### 2. Create an EC2 key pair (if you don't already have one)
```bash
aws ec2 create-key-pair --key-name <your-key-name> --region eu-central-1 --query "KeyMaterial" --output text | Out-File -FilePath <your-key-name>.pem -Encoding ascii
```
Update `key_name` in `main.tf` to match.

### 3. Add GitHub repository secrets
Go to **Settings → Secrets and variables → Actions → New repository secret**:

| Secret name | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | Your IAM user's access key |
| `AWS_SECRET_ACCESS_KEY` | Your IAM user's secret key |
| `SSH_PRIVATE_KEY` | Full contents of your `.pem` private key file |

> ⚠️ Make sure `SSH_PRIVATE_KEY` is added under **Repository secrets**, not Environment secrets — otherwise the workflow won't be able to read it.

### 4. Push to trigger deployment
```bash
git add .
git commit -m "deploy"
git push
```

### 5. View the live site
Once the workflow completes, check the **Actions tab** for the `public_ips` output, then visit:
```
http://<public-ip>
```

---

## 🔥 Tearing Everything Down

To avoid ongoing AWS charges, destroy all resources when done:

**Via GitHub Actions (recommended):**
1. Go to **Actions tab → Terraform Workflow**
2. Click **"Run workflow"** (uses `workflow_dispatch`, runs the destroy job only)

**Or locally:**
```bash
terraform destroy
```

---

## 🛠️ Tech Stack

- **Terraform** — Infrastructure as Code
- **AWS EC2** — compute resource
- **AWS S3** — remote Terraform state backend
- **GitHub Actions** — CI/CD automation
- **NGINX** — serves the static website
- **SSH/SCP** — securely connects to and deploys files onto the instance

---

## 📝 Notes & Lessons Learned

- The SSH private key is written using `printf '%s\n'` (not `echo`) to reliably preserve multi-line key formatting inside the workflow.
- The EC2 instance **must** reference the Terraform-managed security group (`vpc_security_group_ids`) — otherwise it falls back to the account's `default` security group, which blocks SSH/HTTP entirely.
- AWS Free Tier covers 750 hours/month of `t2.micro` usage combined across all running instances — keep `instance_count = 1` to stay safely within the free tier.
- Apply and Destroy are split into separate jobs within the same workflow file, gated by `github.event_name`, so a normal `push` only ever deploys — destruction requires an explicit manual trigger.

---

## 📄 License

This project is for learning/demo purposes.
