#!/bin/bash

# ============================================================
# Linux Hardening Auditor
# Purpose: Check common Linux security configurations
# Author: Arish
# ============================================================

# -------------------------
# Audit Counters
# -------------------------
PASS=0
FAIL=0
WARN=0

# -------------------------
# Header
# -------------------------
echo "=================================================="
echo "           Linux Hardening Audit"
echo "=================================================="
echo
echo "Hostname : $(hostname)"
echo "User     : $(whoami)"
echo "OS       : $(. /etc/os-release && echo "$PRETTY_NAME")"
echo "Date     : $(date)"
echo


# ============================================================
# 1. SSH ROOT LOGIN
# ============================================================

echo "--------------------------------------------------"
echo "1. SSH Root Login"
echo "--------------------------------------------------"

ROOT_LOGIN=$(sudo sshd -T 2>/dev/null | awk '/^permitrootlogin / {print $2}')

if [ "$ROOT_LOGIN" = "no" ]; then
    echo "[PASS] SSH root login is disabled"
    ((PASS++))
else
    echo "[FAIL] SSH root login setting: $ROOT_LOGIN"
    ((FAIL++))
fi

echo


# ============================================================
# 2. SSH PASSWORD AUTHENTICATION
# ============================================================

echo "--------------------------------------------------"
echo "2. SSH Password Authentication"
echo "--------------------------------------------------"

PASSWORD_AUTH=$(sudo sshd -T 2>/dev/null | awk '/^passwordauthentication / {print $2}')

if [ "$PASSWORD_AUTH" = "no" ]; then
    echo "[PASS] SSH password authentication is disabled"
    ((PASS++))
else
    echo "[FAIL] SSH password authentication: $PASSWORD_AUTH"
    ((FAIL++))
fi

echo


# ============================================================
# 3. UFW FIREWALL
# ============================================================

echo "--------------------------------------------------"
echo "3. UFW Firewall"
echo "--------------------------------------------------"

if sudo ufw status 2>/dev/null | grep -q "Status: active"; then
    echo "[PASS] UFW firewall is active"
    ((PASS++))
else
    echo "[FAIL] UFW firewall is inactive"
    ((FAIL++))
fi

echo


# ============================================================
# 4. ASLR
# ============================================================

echo "--------------------------------------------------"
echo "4. ASLR - Address Space Layout Randomization"
echo "--------------------------------------------------"

ASLR=$(sysctl -n kernel.randomize_va_space 2>/dev/null)

if [ "$ASLR" = "2" ]; then
    echo "[PASS] ASLR is fully enabled"
    ((PASS++))
else
    echo "[FAIL] ASLR value: $ASLR"
    ((FAIL++))
fi

echo


# ============================================================
# 5. KERNEL DMESG RESTRICTION
# ============================================================

echo "--------------------------------------------------"
echo "5. Kernel dmesg Restriction"
echo "--------------------------------------------------"

DMESG=$(sysctl -n kernel.dmesg_restrict 2>/dev/null)

if [ "$DMESG" = "1" ]; then
    echo "[PASS] Kernel dmesg access is restricted"
    ((PASS++))
else
    echo "[FAIL] Kernel dmesg access is unrestricted"
    ((FAIL++))
fi

echo


# ============================================================
# 6. /etc/shadow PERMISSIONS
# ============================================================

echo "--------------------------------------------------"
echo "6. /etc/shadow Permissions"
echo "--------------------------------------------------"

SHADOW_PERM=$(stat -c "%a" /etc/shadow 2>/dev/null)

if [ "$SHADOW_PERM" = "600" ] || [ "$SHADOW_PERM" = "640" ]; then
    echo "[PASS] /etc/shadow permissions are secure: $SHADOW_PERM"
    ((PASS++))
else
    echo "[FAIL] /etc/shadow permissions: $SHADOW_PERM"
    ((FAIL++))
fi

echo


# ============================================================
# 7. PASSWORD POLICY
# ============================================================

echo "--------------------------------------------------"
echo "7. Password Policy"
echo "--------------------------------------------------"

MAX_DAYS=$(sudo chage -l "$USER" 2>/dev/null |
    awk -F: '/Maximum number of days/ {
        gsub(/ /,"",$2);
        print $2
    }')

if [ -n "$MAX_DAYS" ] && [ "$MAX_DAYS" -le 90 ]; then
    echo "[PASS] Password maximum age: $MAX_DAYS days"
    ((PASS++))
else
    echo "[WARN] Password maximum age: ${MAX_DAYS:-unknown} days"
    ((WARN++))
fi

echo


# ============================================================
# 8. LISTENING TCP PORTS
# ============================================================

echo "--------------------------------------------------"
echo "8. Listening TCP Ports"
echo "--------------------------------------------------"

sudo ss -lntp 2>/dev/null |
    awk 'NR>1 {print "       " $4}'

echo
echo "[INFO] Listening ports are reported for review."

echo


# ============================================================
# 9. AUTOMATIC SECURITY UPDATES
# ============================================================

echo "--------------------------------------------------"
echo "9. Automatic Security Updates"
echo "--------------------------------------------------"

UPDATES=$(systemctl is-enabled unattended-upgrades 2>/dev/null)

if [ "$UPDATES" = "enabled" ]; then
    echo "[PASS] Automatic security updates are enabled"
    ((PASS++))
else
    echo "[FAIL] Automatic security updates are disabled"
    ((FAIL++))
fi

echo

# ============================================================
# 10. SUDO PRIVILEGES
# ============================================================

echo "--------------------------------------------------"
echo "10. Sudo Privileges"
echo "--------------------------------------------------"

SUDO_USERS=$(getent group sudo | awk -F: '{print $4}')

if [ -n "$SUDO_USERS" ]; then
    echo "[INFO] Users with sudo privileges:"
    echo "$SUDO_USERS" | tr ',' '\n' | sed 's/^/       /'
else
    echo "[INFO] No users found in sudo group"
fi

# ============================================================
# 11. SUDO NOPASSWD CONFIGURATION
# ============================================================

echo "--------------------------------------------------"
echo "11. Sudo NOPASSWD Configuration"
echo "--------------------------------------------------"

NOPASSWD=$(sudo grep -R "NOPASSWD" /etc/sudoers /etc/sudoers.d/ 2>/dev/null)

if [ -n "$NOPASSWD" ]; then
    echo "[WARN] NOPASSWD sudo configuration found:"
    echo "$NOPASSWD" | sed 's/^/       /'
    ((WARN++))
else
    echo "[PASS] No NOPASSWD sudo configuration found"
    ((PASS++))
fi

echo

# ============================================================
# 12. USER ACCOUNT LOGIN SHELLS
# ============================================================

echo "--------------------------------------------------"
echo "12. User Account Login Shells"
echo "--------------------------------------------------"

LOGIN_USERS=$(awk -F: '$3 >= 1000 && $3 < 65534 && $7 != "/bin/false" && $7 != "/usr/sbin/nologin" {print $1 ":" $7}' /etc/passwd)

if [ -n "$LOGIN_USERS" ]; then
    echo "[INFO] Users with login-capable shells:"
    echo "$LOGIN_USERS" | sed 's/^/       /'
else
    echo "[PASS] No unnecessary login-capable users found"
    ((PASS++))
fi

echo

# ============================================================
# 13. FAILED SYSTEMD SERVICES
# ============================================================

echo "--------------------------------------------------"
echo "13. Failed Systemd Services"
echo "--------------------------------------------------"

FAILED_SERVICES=$(systemctl --failed --no-legend)

if [ -z "$FAILED_SERVICES" ]; then
    echo "[PASS] No failed systemd services found"
    ((PASS++))
else
    echo "[FAIL] Failed systemd services found:"
    echo "$FAILED_SERVICES" | sed 's/^/       /'
    ((FAIL++))
fi

echo

# ============================================================
# 14. SSH CONFIGURATION
# ============================================================

echo "--------------------------------------------------"
echo "14. SSH Configuration"
echo "--------------------------------------------------"

SSH_PROTOCOL=$(sudo sshd -T 2>/dev/null | awk '/^protocol / {print $2}')
X11_FORWARDING=$(sudo sshd -T 2>/dev/null | awk '/^x11forwarding / {print $2}')

if [ "$X11_FORWARDING" = "no" ]; then
    echo "[PASS] SSH X11 forwarding is disabled"
    ((PASS++))
else
    echo "[WARN] SSH X11 forwarding: $X11_FORWARDING"
    ((WARN++))
fi

echo "[INFO] SSH protocol setting: ${SSH_PROTOCOL:-default}"

echo


# ============================================================
# 15. IP FORWARDING
# ============================================================

echo "--------------------------------------------------"
echo "15. IP Forwarding"
echo "--------------------------------------------------"

IP_FORWARD=$(sysctl -n net.ipv4.ip_forward 2>/dev/null)

if [ "$IP_FORWARD" = "0" ]; then
    echo "[PASS] IPv4 packet forwarding is disabled"
    ((PASS++))
else
    echo "[WARN] IPv4 packet forwarding is enabled"
    ((WARN++))
fi

echo


# ============================================================
# 16. KERNEL SECURITY PARAMETERS
# ============================================================

echo "--------------------------------------------------"
echo "16. Kernel Security Parameters"
echo "--------------------------------------------------"

RP_FILTER=$(sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null)
ICMP_REDIRECTS=$(sysctl -n net.ipv4.conf.all.accept_redirects 2>/dev/null)

if [ "$RP_FILTER" = "1" ]; then
    echo "[PASS] Reverse path filtering is enabled"
    ((PASS++))
else
    echo "[WARN] Reverse path filtering: $RP_FILTER"
    ((WARN++))
fi

if [ "$ICMP_REDIRECTS" = "0" ]; then
    echo "[PASS] ICMP redirects are disabled"
    ((PASS++))
else
    echo "[WARN] ICMP redirects are enabled"
    ((WARN++))
fi

echo


# ============================================================
# 17. WORLD-WRITABLE FILES
# ============================================================

echo "--------------------------------------------------"
echo "17. World-Writable Files"
echo "--------------------------------------------------"

WORLD_WRITABLE=$(sudo find /etc /usr/bin /usr/sbin -type f -perm -0002 2>/dev/null)

if [ -z "$WORLD_WRITABLE" ]; then
    echo "[PASS] No world-writable files found in critical directories"
    ((PASS++))
else
    echo "[WARN] World-writable files found:"
    echo "$WORLD_WRITABLE" | head -20 | sed 's/^/       /'
    ((WARN++))
fi

echo


# ============================================================
# 18. CRITICAL FILE OWNERSHIP
# ============================================================

echo "--------------------------------------------------"
echo "18. Critical File Ownership"
echo "--------------------------------------------------"

OWNERSHIP_OK=true

for FILE in /etc/passwd /etc/shadow /etc/group /etc/gshadow; do

    OWNER=$(stat -c "%U" "$FILE" 2>/dev/null)

    if [ "$OWNER" != "root" ]; then
        echo "[FAIL] $FILE is owned by: $OWNER"
        OWNERSHIP_OK=false
    fi

done

if [ "$OWNERSHIP_OK" = true ]; then
    echo "[PASS] Critical account files are owned by root"
    ((PASS++))
else
    ((FAIL++))
fi

echo

echo

# ============================================================
# FINAL SUMMARY
# ============================================================

echo "=================================================="
echo "                 AUDIT SUMMARY"
echo "=================================================="

echo "PASS : $PASS"
echo "WARN : $WARN"
echo "FAIL : $FAIL"

echo "=================================================="

if [ "$FAIL" -eq 0 ]; then
    echo "[RESULT] No critical audit failures detected."
else
    echo "[RESULT] Security issues require review."
fi

echo "=================================================="
