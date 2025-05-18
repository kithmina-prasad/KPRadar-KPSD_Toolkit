#!/bin/bash

# KPRadar - Ethical KPSD Toolkit
# Author: Kithmina Prasad
# For educational and legal use only

# ---------- ASCII BANNER ----------
echo -e "\e[1;36m"
echo "██╗  ██╗██████╗ █████╗    █████╗ ██████╗    █████╗  █████╗ "
echo "██║ ██╔╝██╔══██╗██╔══██╗ ██╔══██╗██╔═══██╗ ██╔══██╗ ██╔══██╗"
echo "█████╔╝ ██████╔╝███████║ ███████║██║   ██║ ███████║ ██████╔╝"
echo "██╔═██╗ ██╔═══╝ ██╔══██║ ██╔══██║██║   ██║ ██╔══██║ ██╔══██╗"
echo "██║  ██╗██║     ██║  ██║ ██║  ██║╚██████╔╝ ██║  ██║ ██║  ██║"
echo "╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═════╝  ╚═╝  ╚═╝ ╚═╝  ╚═╝"
echo " 🔍 KPRadar - Ethical KPSD Toolkit v1.0 by Kithmina 🔍"
echo -e "\e[0m"

echo ""
echo "Welcome to KPRadar Toolkit — a Bash-based ethical reconnaissance suite designed for cybersecurity education and authorized testing."
echo "Please ensure you have explicit permission before running any tests. Use responsibly and legally."
echo "-------------------------------------------------------------------------------------------------------------------"

read -p "❓ Do you have permission to perform these tests? (yes/no): " has_permission
if [[ $has_permission != "yes" ]]; then
  echo "❌ Permission not granted. Exiting the toolkit."
  exit 1
fi

# ===== Setup Directories and Logging =====
mkdir -p output
LOGFILE="output/kpradar_$(date +%Y%m%d_%H%M%S).log"

# ===== Dependency Checker =====
function check_dependency() {
  local tool=$1
  if ! command -v "$tool" &> /dev/null; then
    printf "\033[33m $tool not found.\033[0m\n"
    read -p " Do you want to install $tool? (yes/no): " answer
    if [[ $answer == "yes" ]]; then
      sudo apt install -y "$tool" || sudo pacman -S "$tool" || echo "❌ Could not install $tool"
    else
      printf "\033[31m $tool is required. Exiting.\033[0m\n"
      exit 1
    fi
  fi
}

# ===== Input Sanitization =====
function sanitize_input() {
  echo "$1" | sed 's/[^a-zA-Z0-9.-]//g'
}

# ===== Output Logger =====
function log_and_display() {
  local message="$1"
  shift
  echo -e "\n\033[34m[+] $message\033[0m" | tee -a "$LOGFILE"
  "$@" 2>&1 | tee -a "$LOGFILE"
}

# ===== Feature Functions =====

function run_nmap() {
  check_dependency nmap
  read -p " Enter target IP/domain: " TARGET
  TARGET=$(sanitize_input "$TARGET")
  log_and_display "Running Nmap on $TARGET" nmap -sV "$TARGET"
}

function run_whois() {
  check_dependency whois
  read -p " Enter domain: " DOMAIN
  DOMAIN=$(sanitize_input "$DOMAIN")
  log_and_display "Whois Lookup for $DOMAIN" whois "$DOMAIN"
}

function subdomain_enum() {
  check_dependency sublist3r
  read -p " Enter domain: " DOMAIN
  DOMAIN=$(sanitize_input "$DOMAIN")
  log_and_display "Subdomain Enumeration for $DOMAIN" sublist3r -d "$DOMAIN"
}

function dns_lookup() {
  check_dependency dig
  check_dependency curl
  read -p "🌐 Enter domain name: " DOMAIN
  DOMAIN=$(sanitize_input "$DOMAIN")
  echo -e "\n--- DNS Records ---" | tee -a "$LOGFILE"
  dig A "$DOMAIN" +short | tee -a "$LOGFILE"
  dig NS "$DOMAIN" +short | tee -a "$LOGFILE"
  dig MX "$DOMAIN" +short | tee -a "$LOGFILE"
  echo -e "\n--- ASN Info ---" | tee -a "$LOGFILE"
  curl -s "https://api.hackertarget.com/aslookup/?q=$DOMAIN" | tee -a "$LOGFILE"
}

function vuln_scan() {
  check_dependency nmap
  read -p "🎯 Enter target IP/domain: " TARGET
  TARGET=$(sanitize_input "$TARGET")
  log_and_display "Running Vulnerability Scripts on $TARGET" nmap --script vuln "$TARGET"
}

# ===== Generate Report =====
function generate_report() {
  SUMMARY="output/summary.txt"
  echo "📝 Generating report summary..."

  {
    echo "======== KPRADAR REPORT ========"
    echo "Generated on: $(date)"
    echo ""
    echo "====== Summary of Findings ======"
    grep -E "^\[+\]" "$LOGFILE"
    echo ""
    echo "====== Full Log Path: $LOGFILE ======"
    echo "You can open the full log for more detailed info."
  } > "$SUMMARY"

  echo "✅ Summary report saved as: $SUMMARY"
}

function ask_exit_permission() {
  echo
  read -p "Do you want to close KPRADAR Toolkit now? (yes/no): " close_ans
  if [[ $close_ans != "yes" ]]; then
    echo " Restarting script..."
    exec "$0"
  else
    echo "👋 Bye! Stay legal."
    exit 0
  fi
}

# ===== Menu =====
clear
echo "===== KPRadar Menu ====="
echo "1) Nmap Scan"
echo "2) Whois Lookup"
echo "3) Subdomain Enumeration"
echo "4) DNS & ASN Lookup"
echo "5) Vulnerability Scan"
echo "6) Generate Summary Report"
echo "7) Exit"
echo "========================"
read -p "👉 Enter your choice (1-7): " choice

case $choice in
  1) run_nmap ;;
  2) run_whois ;;
  3) subdomain_enum ;;
  4) dns_lookup ;;
  5) vuln_scan ;;
  6) generate_report ;;
  7) echo "👋 Bye! Stay legal." && exit 0 ;;
  *) echo "❌ Invalid choice." ;;
esac

ask_exit_permission
