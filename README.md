# AWS Role Assumption Automation with Granted

This project simplifies assuming AWS IAM roles from your terminal using [Granted](https://granted.dev/) and a shell-based profile wizard. It securely fetches and configures temporary credentials using MFA, improving your cloud workflow speed and security.

---

## Why Use This?

Working with AWS IAM roles via the AWS Console can be repetitive, error-prone, and slow. This script lets you:

- Assume roles directly from your terminal
- Switch roles instantly with `assume`
- Use MFA-protected static credentials securely
- Avoid manually copying session tokens or editing config files

---

## What’s Included

- A shell-based wizard to assume predefined IAM roles
- MFA prompt and temporary credentials setup
- Automatic profile creation using `aws configure`
- Support for multiple roles (dev, privdev, devops)
- Usage of [`Granted`](https://granted.dev/) to activate the session

---

## Installation

### macOS (via Homebrew)

```bash
brew tap common-fate/granted
brew install granted
```

### Windows
1. Download the ZIP from Granted
2. Extract it and copy assume and granted to a folder in your system PATH (e.g., C:\Program Files\granted)

---

## Setup
### 1. Create ~/.aws-secure-config
Add your long-term static credentials and MFA serial:

``` bash
AWS_ACCESS_KEY_ID=AKIAxxxxxxxxxxxxxxxx
AWS_SECRET_ACCESS_KEY=wJalrxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
MFA_SERIAL=arn:aws:iam::123456789012:mfa/your-device
```

### 2. Use the Wizard Script
Make it executable:
``` bash
chmod +x aws_profile_wizard.sh
```
Run it:
``` bash
./aws_profile_wizard.sh
```
The script will:

- Prompt you to select a role (dev / privdev / devops)
- Prompt for MFA token
- Assume the selected IAM role
- Create an AWS CLI profile named assumed-<role>
- Print instructions to activate the session with assume -c assumed-role

---

## Example
``` bash
$ ./aws_profile_wizard.sh

Select a role to assume:
1) dev
2) privdev
3) devops
Enter choice [1-3]: 1
Enter current MFA token code: 123456

Role 'dev' assumed successfully!
   Use with: assume -c assumed-dev
   Credentials expire in 60 minutes.
```
Then activate it:
``` bash
assume -c assumed-dev
```
Your shell will now use temporary credentials tied to the assumed role.

---

## Role Support

The script includes the following roles (edit as needed):

| Option  | IAM Role                                    |
| ------- | ------------------------------------------- |
| dev     | `arn:aws:iam::ACCOUNT_ID:role/Dev_role`     |
| privdev | `arn:aws:iam::ACCOUNT_ID:role/PrivDev_role` |
| devops  | `arn:aws:iam::ACCOUNT_ID:role/Devops_role`  |

---

## Project Structure
``` bash
aws-role-assume/
├── aws_profile_wizard.sh     # Main wizard script
└── aws-secure-config         # Contains your static credentials and MFA serial
```

---

## Prerequisites

- AWS CLI installed and configured
- jq installed (used for parsing JSON)
- Granted (assume) installed and on your PATH
- AWS IAM user with permission to sts:AssumeRole

---

## Troubleshooting

| Issue                      | Solution                                                          |
| -------------------------- | ----------------------------------------------------------------- |
| `jq not found`             | Install it using `brew install jq` or your OS package manager     |
| `Invalid MFA`              | Ensure the MFA device ARN is correct and the token is not expired |
| `assume command not found` | Confirm that Granted is installed and in your PATH                |


---

## License

This project is open-source and available for personal and professional use. Feel free to modify it to fit your organization’s role structure.

