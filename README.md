# Linux Hardening Auditor

![Linux Security Audit](https://github.com/pixelopscloud/linux-hardening/actions/workflows/security-audit.yml/badge.svg)

A lightweight Bash-based security auditing tool for Linux servers.

**Linux Hardening Auditor** checks common Linux security configurations and reports potential security issues using `PASS`, `WARN`, and `FAIL` results.

The project also includes **GitHub Actions automation** that connects to an AWS EC2 Linux server over SSH, runs the security audit remotely, and uploads the generated audit report as a GitHub Actions artifact.

---

## 🚀 Features

* Bash-based Linux security auditing
* 18 security and hardening checks
* `PASS`, `WARN`, and `FAIL` reporting
* Audit-only design — does not modify system configuration
* Remote EC2 auditing through SSH
* Automated execution with GitHub Actions
* Audit report uploaded as a workflow artifact
* Designed for Ubuntu/Linux servers

---

## 🔍 Security Checks

The auditor currently checks:

1. SSH Root Login
2. SSH Password Authentication
3. UFW Firewall
4. ASLR — Address Space Layout Randomization
5. Kernel `dmesg` Restriction
6. `/etc/shadow` Permissions
7. Password Policy
8. Listening TCP Ports
9. Automatic Security Updates
10. Sudo Privileges
11. Sudo `NOPASSWD` Configuration
12. User Account Login Shells
13. Failed systemd Services
14. SSH Configuration
15. IP Forwarding
16. Kernel Security Parameters
17. World-Writable Files
18. Critical File Ownership

---

## 📊 Result Levels

| Result | Meaning                                                    |
| ------ | ---------------------------------------------------------- |
| `PASS` | Security configuration meets the check                     |
| `WARN` | Configuration requires review or depends on system context |
| `FAIL` | Potential security issue detected                          |
| `INFO` | Information reported for review                            |

> Some checks are intentionally reported as `WARN` because their secure configuration depends on the server's role and environment.

---

## 🏗️ Architecture

```text
Developer
   │
   │ git push
   ▼
GitHub Repository
   │
   ▼
GitHub Actions
   │
   │ SSH
   ▼
AWS EC2 Ubuntu Server
   │
   ▼
hardening-audit.sh
   │
   ▼
Security Audit
   │
   ├── PASS
   ├── WARN
   └── FAIL
   │
   ▼
audit-report.txt
   │
   ▼
GitHub Actions Artifact
```

---

## ⚙️ Requirements

* Linux server
* Bash
* `sudo`
* `systemctl`
* `sysctl`
* OpenSSH
* Git

For the automated workflow:

* AWS EC2 Linux server
* GitHub repository
* SSH private key
* GitHub Actions secrets

---

## 🖥️ Run Locally

Clone the repository:

```bash
git clone https://github.com/pixelopscloud/linux-hardening.git
cd linux-hardening
```

Make the script executable:

```bash
chmod +x hardening-audit.sh
```

Run the audit:

```bash
./hardening-audit.sh
```

---

## 📄 Save an Audit Report

To save the audit output to a file:

```bash
mkdir -p reports
./hardening-audit.sh | tee reports/audit-report.txt
```

The generated report contains the complete security audit results.

---

## 🤖 GitHub Actions Automation

The project includes a GitHub Actions workflow:

```text
.github/
└── workflows/
    └── security-audit.yml
```

The workflow automatically runs when changes are pushed to the `main` branch.

### Workflow

```text
GitHub Push
     │
     ▼
GitHub Actions Runner
     │
     │ SSH
     ▼
AWS EC2
     │
     ▼
git pull
     │
     ▼
hardening-audit.sh
     │
     ▼
Audit Results
     │
     ▼
audit-report.txt
     │
     ▼
GitHub Actions Artifact
```

---

## 🔐 GitHub Actions Secrets

The workflow uses the following repository secrets:

```text
EC2_HOST
EC2_USER
EC2_SSH_KEY
```

These secrets are used to securely connect GitHub Actions to the EC2 server.

> The SSH private key is stored as a GitHub Actions secret and is not included in the repository.

---

## 📦 Audit Report Artifact

After a successful workflow run, GitHub Actions uploads:

```text
linux-hardening-audit
```

The artifact contains:

```text
audit-report.txt
```

This allows the security audit results to be downloaded and reviewed from the GitHub Actions workflow.

---

## 🧪 Example Audit Result

```text
==================================================
           Linux Hardening Audit
==================================================

Hostname : ip-172-31-30-19
OS       : Ubuntu 24.04.4 LTS

--------------------------------------------------
1. SSH Root Login
--------------------------------------------------
[FAIL] SSH root login setting: without-password

--------------------------------------------------
2. SSH Password Authentication
--------------------------------------------------
[PASS] SSH password authentication is disabled

--------------------------------------------------
3. UFW Firewall
--------------------------------------------------
[FAIL] UFW firewall is inactive

...

==================================================
                 AUDIT SUMMARY
==================================================

PASS : 9
WARN : 5
FAIL : 2

==================================================
[RESULT] Security issues require review.
==================================================
```

The exact results can vary depending on the server configuration.

---

## 🛡️ Safety

This project is designed as an **audit-only security tool**.

It:

* Does not modify SSH configuration
* Does not enable or disable firewalls
* Does not change password policies
* Does not modify kernel parameters
* Does not create or remove users
* Does not automatically fix security findings

The purpose is to **identify and report** configurations that may require security review.

---

## 📁 Project Structure

```text
linux-hardening/
│
├── hardening-audit.sh
├── README.md
├── reports/
│   └── sample-report.txt
│
└── .github/
    └── workflows/
        └── security-audit.yml
```

---

## 🎯 Project Goals

This project demonstrates practical experience with:

* Linux security
* Linux system administration
* Bash scripting
* Security auditing
* AWS EC2
* SSH
* Git & GitHub
* GitHub Actions
* CI/CD automation
* DevSecOps concepts

---

## 🔮 Future Improvements

Possible future enhancements include:

* Additional Linux hardening checks
* HTML security reports
* JSON output for automation
* Security score calculation
* Email/Slack notifications
* Multi-server auditing
* Integration with security dashboards

---

## 👨‍💻 Author

**Muhammad Ali**

DevOps Engineer | Linux | AWS | Docker | Kubernetes | CI/CD | DevSecOps

---

## 📜 License

This project is available for educational and portfolio purposes.

