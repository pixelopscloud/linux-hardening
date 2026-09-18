# Linux Hardening Auditor

A lightweight Bash-based security auditing tool for Linux servers.

This project checks common Linux security configurations and reports potential security issues using `PASS`, `WARN`, and `FAIL` results.

> **Audit-only:** This tool does not modify or fix system configurations.

---

## Features

The auditor checks 18 security areas:

1. SSH Root Login
2. SSH Password Authentication
3. UFW Firewall Status
4. ASLR
5. Kernel dmesg Restriction
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

## Result Levels

| Result | Meaning |
|---|---|
| PASS | Security check meets the expected condition |
| WARN | Configuration requires review |
| FAIL | Security issue detected |
| INFO | Information reported for manual review |

---

## Requirements

- Linux system
- Bash
- `sudo` privileges
- `systemd`
- Common Linux utilities such as:
  - `awk`
  - `grep`
  - `stat`
  - `ss`
  - `sysctl`

Tested on:

```text
Ubuntu 24.04 LTS
# linux-hardening
