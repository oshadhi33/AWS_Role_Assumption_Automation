#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="us-east-1"            # Change the region as per the requirment 
SESSION_NAME="session"      
DURATION_SECONDS=3600

CONFIG_FILE="$HOME/.aws-secure-config"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing config file at $CONFIG_FILE"
  exit 1
fi

# ── Load static credentials and MFA serial ──────────────────────────────────────
source "$CONFIG_FILE"

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" || -z "${MFA_SERIAL:-}" ]]; then
  echo "One or more required values are missing from $CONFIG_FILE"
  exit 1
fi

# ── Prompt for role selection ───────────────────────────────────────────────────
echo "Select a role to assume:"
echo "1) dev"
echo "2) privdev"
echo "3) devops"
read -rp "Enter choice [1-3]: " choice

case "$choice" in
  1) ROLE_KEY="dev";    ROLE_ARN="arn:aws:iam::AWS Account ID:role/Dev_role" ;;          # Replace with your actual AWS account ID
  2) ROLE_KEY="privdev"; ROLE_ARN="arn:aws:iam::AWS Account ID:role/PrivDev_role" ;;
  3) ROLE_KEY="devops"; ROLE_ARN="arn:aws:iam::AWS Account ID:role/Devops_role" ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

ASSUMED_PROFILE="assumed-$ROLE_KEY"

read -rp "Enter current MFA token code: " MFA_TOKEN_CODE

# ── Check jq ─────────────────────────────────────────────────────────────────────
if ! command -v jq &> /dev/null; then
  echo "'jq' is not installed. Please install it and try again."
  exit 1
fi

# ── Call sts:AssumeRole ─────────────────────────────────────────────────────────
echo "Assuming role '$ROLE_KEY'..."

CREDS_JSON=$( \
  AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  aws sts assume-role \
    --role-arn "$ROLE_ARN" \
    --role-session-name "$SESSION_NAME" \
    --duration-seconds "$DURATION_SECONDS" \
    --serial-number "$MFA_SERIAL" \
    --token-code "$MFA_TOKEN_CODE" \
    --output json \
)

# ── Extract credentials and set profile ─────────────────────────────────────────
ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' <<<"$CREDS_JSON")
SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' <<<"$CREDS_JSON")
SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' <<<"$CREDS_JSON")

aws configure set region "$AWS_REGION"                        --profile "$ASSUMED_PROFILE"
aws configure set aws_access_key_id "$ACCESS_KEY_ID"          --profile "$ASSUMED_PROFILE"
aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY"  --profile "$ASSUMED_PROFILE"
aws configure set aws_session_token "$SESSION_TOKEN"          --profile "$ASSUMED_PROFILE"

echo
echo "Role '$ROLE_KEY' assumed successfully!"
echo "Use with: assumed -c $ASSUMED_PROFILE"
echo "Credentials expire in $((DURATION_SECONDS / 60)) minutes."
