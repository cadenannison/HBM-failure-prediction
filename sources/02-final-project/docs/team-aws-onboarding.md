# PANIC team AWS onboarding

Complete these steps after the platform owner confirms your IAM user is ready and privately sends you a temporary password. You do not need to create a personal AWS account or enter payment information.

## 1. Sign in

Open the [team AWS sign-in page](https://278634873542.signin.aws.amazon.com/console/) and use your assigned username and temporary password.

| Person | Username |
|---|---|
| RJ | `panic-rj` |
| Caden | `panic-caden` |
| Joe | `panic-joe` |

If AWS asks for an account ID, enter **`278634873542`**. Use **IAM user** sign-in. If your browser is already signed into another AWS identity, use a private/incognito window for setup.

## 2. Change your temporary password

AWS should prompt you to change your password on your first sign-in.

1. Enter your temporary password if requested.
2. Choose a new, unique password that meets the displayed requirements.
3. Confirm the new password and submit the change.
4. Save your password privately in your password manager.

If you cannot sign in or complete the required password change, contact the platform owner.

## 3. Open your security credentials

1. Select your username/account menu in the upper-right corner of the AWS console.
2. Choose **Security credentials** or **My security credentials**.
3. Find **Multi-factor authentication (MFA)** and select **Assign MFA device**.

Use your own security credentials page. You do not need access to the account's full IAM Users list.

## 4. Enroll an authenticator app

1. Enter your device name exactly as shown below.
2. Choose **Authenticator app**, then **Next**.
3. Open an authenticator app on your phone and add an account by scanning the QR code displayed by AWS. Select **Show QR code** if necessary.
4. Enter the current six-digit code from the app into **MFA code 1**.
5. Wait for the code to change, then enter the new code into **MFA code 2**. These must be two consecutive codes, not the same code twice.
6. Select **Add MFA** promptly and confirm the device appears as assigned.

| Person | MFA device name |
|---|---|
| RJ | `panic-rj-phone` |
| Caden | `panic-caden-phone` |
| Joe | `panic-joe-phone` |

These names match the permissions configured for your user. Keep your MFA app entry; you will need it for later sign-ins.

## 5. Sign out and sign back in with MFA

1. Sign out of AWS.
2. Return to the [team sign-in page](https://278634873542.signin.aws.amazon.com/console/).
3. Sign in with your username and new password.
4. When prompted, enter the current code from your authenticator app.

Signing back in is required so your session includes MFA authentication before switching roles.

## 6. Switch into your project role

While signed in with MFA, open your assigned link and select **Switch Role**.

| Person | Role | Switch Role link |
|---|---|---|
| RJ | `panic-lead-ml` | [PANIC Lead and ML](https://signin.aws.amazon.com/switchrole?account=278634873542&roleName=panic-lead-ml&displayName=PANIC-ML) |
| Caden | `panic-mlops` | [PANIC MLOps](https://signin.aws.amazon.com/switchrole?account=278634873542&roleName=panic-mlops&displayName=PANIC-MLOps) |
| Joe | `panic-app` | [PANIC App](https://signin.aws.amazon.com/switchrole?account=278634873542&roleName=panic-app&displayName=PANIC-App) |

Confirm that the account menu now shows your project role and that you are working in account **`278634873542`**. Use Region **US East (N. Virginia), `us-east-1`** for project services.

Your IAM user handles sign-in and your own credentials. Your assigned role provides the project permissions. For future sessions, sign in with MFA and switch into your role before starting project work. If the role session expires, switch into it again; if necessary, sign in again with MFA.

## If something does not work

- **User not found or temporary password rejected:** Confirm with the platform owner that your user and console password are ready.
- **MFA codes rejected:** Enable automatic date/time on your phone and retry with two fresh consecutive codes.
- **Access denied when switching roles:** Sign out completely, sign back in with MFA, and use your own role link. Contact the platform owner if it still fails.
- **Access denied in a project service:** Confirm your project role is active. Send the platform owner the task you were attempting and the error message, including the action and resource if shown.
- **Lost phone/MFA device or forgotten password:** Contact the platform owner for recovery.

Keep passwords, MFA codes, QR codes, and setup keys private. Do not post them in team chat, issues, screenshots, or the repository. You do not need to create access keys for these console setup steps; CLI/Terraform setup can be handled separately when needed.

## AWS references

- [MFA enrollment instructions](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html)
- [Switching to an IAM role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html)
