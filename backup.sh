#!/usr/bin/env bash

PWD=$(pwd)

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[1;33m'
blue='\033[0;34m'
nc='\033[0m'

log() {

    local currentTime
    currentTime=$(date "+%Y-%m-%d %H:%M:%S")

    local type="$1"
    shift
    local msg="$*"

    case "$type" in
        "INFO") printf "%s - %b[INFO]%b %s\n" "$currentTime" "$blue" "$nc" "$msg" ;;
        "SUCCESS") printf "%s - %b[SUCCESS]%b %s\n" "$currentTime" "$green" "$nc" "$msg" ;;
        "WARNING") printf "%s - %b[WARNING]%b %s\n" "$currentTime" "$yellow" "$nc" "$msg" ;;
        "ERROR") printf "%s - %b[ERROR]%b %s\n" "$currentTime" "$red" "$nc" "$msg" ;;
        *) printf "%s - [LOG] %s\n" "$currentTime" "$msg" ;;
    esac
}

run() {
  $@ || {
    log ERROR "Error while executing $@"
    exit 1
  }
}

lrun() {
  log INFO "Executing: $@"
  run $@
}


requirements() {
  run git --version > /dev/null;
  log INFO "Git instance: $(which git)"

  run curl --version > /dev/null;
  log INFO "Curl instance: $(which curl)"

  run ping -c 1 google.com > /dev/null
  log INFO "Basic internet acess detected"

  if [ "$(whoami)" == "root" ]; then
    log WARNING "Script is executed by root !!!"
  fi
}

out() {
  if [[ ! -v OUT_DIR ]]; then
    OUT_DIR="$PWD/out"
    log INFO "Could find OUT_DIR env. Script will default to '$OUT_DIR'"
  else
    log INFO "Found '$OUT_DIR' variable"
  fi

  GCC_OUT="$OUT_DIR/gcc"
  LLVM_OUT="$OUT_DIR/clang"
  RFC_OUT="$OUT_DIR/rfc"
  WIKIMEDIA_OUT="$OUT_DIR/wikimedia"
  LINUX_OUT="$OUT_DIR/linux"

  lrun mkdir -p         \
    "$GCC_OUT"          \
    "$RFC_OUT"          \
    "$LLVM_OUT"         \
    "$WIKIMEDIA_OUT"    \
    "$LINUX_OUT"
}

gclone() {
  # To maintain a balance between download time and file size,
  # we only download the history of the last ten commits.
  # In the event that an error occurs in the main branch,
  # this approach gives us the chance to restore a working version.
  lrun git clone --depth=10 "$1" $2
}

gupdate() {
  cd "$1"
  lrun git fetch origin
  lrun git reset --hard @{u}
  lrun git clean -fd
  cd "$PWD"
}

gbackup() {
  if [ ! -d "$2" ]; then
    gclone "$1" "$2"
  else
    gupdate "$2"
  fi
}

cdownload() {
  lrun curl -fsSL "$1" -o "$2"
}

cupdate() {
  lrun curl -fsSL -z "$2" "$1" -o "$2"
}

cbackup() {
  local url="$1"
  local dest="$2"

  if [ ! -f "$dest" ]; then
    cdownload "$url" "$dest"
  else
    cupdate "$url" "$dest"
  fi
}

gcc_backup() {
  gbackup "https://github.com/gcc-mirror/gcc.git" "$GCC_OUT/source"
  lrun sync

  log SUCCESS "Gcc backup success"
}

llvm_backup() {
  gbackup "https://github.com/llvm/llvm-project.git" "$LLVM_OUT/source"
  lrun sync

  log SUCCESS "LLVM backup success"
}

linux_backup() {
  gbackup "https://github.com/torvalds/linux.git" "$LINUX_OUT/source"
  lrun sync

  log SUCCESS "Linux backup success"
}

wikimedia_backup() {
  gbackup "https://github.com/wikimedia/mediawiki.git" "$WIKIMEDIA_OUT/source"
  lrun sync

  log SUCCESS "Wikimedia backup success"
}

rfc_backup() {
  local rfcs=(
    "rfc768"   # UDP - User Datagram Protocol
    "rfc791"   # IP - Internet Protocol (IPv4)
    "rfc792"   # ICMP - Internet Control Message Protocol
    "rfc793"   # TCP - Transmission Control Protocol
    "rfc821"   # SMTP - Simple Mail Transfer Protocol (original)
    "rfc822"   # Standard for ARPA Internet Text Messages
    "rfc826"   # ARP - Address Resolution Protocol
    "rfc854"   # Telnet Protocol Specification
    "rfc959"   # FTP - File Transfer Protocol
    "rfc1034"  # Domain Names - Concepts and Facilities (DNS)
    "rfc1035"  # Domain Names - Implementation and Specification (DNS)
    "rfc1122"  # Requirements for Internet Hosts - Communication Layers
    "rfc1123"  # Requirements for Internet Hosts - Application and Support
    "rfc1149"  # IP over Avian Carriers (IPoAC)
    "rfc1157"  # SNMP - Simple Network Management Protocol
    "rfc1321"  # The MD5 Message-Digest Algorithm
    "rfc1459"  # IRC - Internet Relay Chat Protocol
    "rfc1518"  # CIDR - An Architecture for IP Address Allocation
    "rfc1519"  # CIDR - Classless Inter-Domain Routing
    "rfc1631"  # The IP Network Address Translator (NAT)
    "rfc1661"  # PPP - The Point-to-Point Protocol
    "rfc1738"  # Uniform Resource Locators (URL)
    "rfc1812"  # Requirements for IP Version 4 Routers
    "rfc1918"  # Address Allocation for Private Internets
    "rfc1939"  # POP3 - Post Office Protocol - Version 3
    "rfc1945"  # HTTP/1.0 - Hypertext Transfer Protocol
    "rfc1950"  # ZLIB Compressed Data Format Specification
    "rfc1951"  # DEFLATE Compressed Data Format Specification
    "rfc1952"  # GZIP file format specification
    "rfc2045"  # MIME Part One: Format of Internet Message Bodies
    "rfc2046"  # MIME Part Two: Media Types
    "rfc2119"  # Key words for use in RFCs (MUST, SHOULD, MAY)
    "rfc2131"  # DHCP - Dynamic Host Configuration Protocol
    "rfc2181"  # Clarifications to the DNS Specification
    "rfc2246"  # The TLS Protocol Version 1.0
    "rfc2324"  # HTCPCP - Hyper Text Coffee Pot Control Protocol
    "rfc2328"  # OSPF Version 2
    "rfc2460"  # IPv6 Specification (original)
    "rfc2518"  # WebDAV - HTTP Extensions for Distributed Authoring
    "rfc2549"  # IP over Avian Carriers with Quality of Service
    "rfc2616"  # HTTP/1.1 (classic specification)
    "rfc2663"  # IP Network Address Translator (NAT) Terminology
    "rfc2782"  # DNS SRV RR - A DNS RR for specifying the location of services
    "rfc2821"  # SMTP - Simple Mail Transfer Protocol
    "rfc2822"  # Internet Message Format
    "rfc3022"  # Traditional IP Network Address Translator (Traditional NAT)
    "rfc3164"  # The BSD Syslog Protocol
    "rfc3174"  # US Secure Hash Algorithm 1 (SHA1)
    "rfc3261"  # SIP - Session Initiation Protocol
    "rfc3339"  # Date and Time on the Internet: Timestamps
    "rfc3411"  # Architecture for Describing SNMP Management Frameworks (SNMPv3)
    "rfc3501"  # IMAP4rev1 - Internet Message Access Protocol
    "rfc3550"  # RTP - A Transport Protocol for Real-Time Applications
    "rfc3629"  # UTF-8, a transformation format of ISO 10646
    "rfc3986"  # URI - Uniform Resource Identifier: Generic Syntax
    "rfc4122"  # UUID - A Universally Unique IDentifier URN Namespace
    "rfc4180"  # Common Format and MIME Type for CSV Files
    "rfc4251"  # The Secure Shell (SSH) Protocol Architecture
    "rfc4252"  # The Secure Shell (SSH) Authentication Protocol
    "rfc4253"  # The Secure Shell (SSH) Transport Layer Protocol
    "rfc4254"  # The Secure Shell (SSH) Connection Protocol
    "rfc4271"  # BGP-4 - A Border Gateway Protocol 4
    "rfc4291"  # IP Version 6 Addressing Architecture
    "rfc4301"  # Security Architecture for the Internet Protocol (IPsec)
    "rfc4443"  # ICMPv6 - Internet Control Message Protocol for IPv6
    "rfc4648"  # The Base16, Base32, and Base64 Data Encodings
    "rfc4861"  # Neighbor Discovery for IP version 6 (IPv6)
    "rfc4862"  # IPv6 Stateless Address Autoconfiguration (SLAAC)
    "rfc4918"  # HTTP Extensions for Web Distributed Authoring (WebDAV)
    "rfc4960"  # SCTP - Stream Control Transmission Protocol
    "rfc5246"  # The Transport Layer Security (TLS) Protocol Version 1.2
    "rfc5280"  # Internet X.509 Public Key Infrastructure Certificate and CRL Profile
    "rfc5321"  # Simple Mail Transfer Protocol (SMTP)
    "rfc5322"  # Internet Message Format
    "rfc5389"  # STUN - Session Traversal Utilities for NAT
    "rfc5424"  # The Syslog Protocol
    "rfc5766"  # TURN - Traversal Using Relays around NAT
    "rfc5905"  # NTPv4 - Network Time Protocol Version 4
    "rfc6234"  # US Secure Hash Algorithms (SHA and SHA-based HMAC and HKDF)
    "rfc6265"  # HTTP State Management Mechanism (Cookies)
    "rfc6376"  # DKIM - DomainKeys Identified Mail Signatures
    "rfc6455"  # The WebSocket Protocol
    "rfc6749"  # The OAuth 2.0 Authorization Framework
    "rfc6750"  # The OAuth 2.0 Authorization Framework: Bearer Token Usage
    "rfc6762"  # Multicast DNS (mDNS)
    "rfc6890"  # Special-Purpose IP Address Registries
    "rfc7208"  # SPF - Sender Policy Framework
    "rfc7489"  # DMARC - Domain-based Message Authentication, Reporting, and Conformance
    "rfc7519"  # JSON Web Token (JWT)
    "rfc7540"  # Hypertext Transfer Protocol Version 2 (HTTP/2)
    "rfc7932"  # Brotli Compressed Data Format
    "rfc8200"  # Internet Protocol, Version 6 (IPv6) Specification
    "rfc8259"  # The JavaScript Object Notation (JSON) Data Interchange Format
    "rfc8446"  # The Transport Layer Security (TLS) Protocol Version 1.3
    "rfc8484"  # DNS Queries over HTTPS (DoH)
    "rfc8878"  # Zstandard Compression and the 'application/zstd' Media Type
    "rfc9000"  # QUIC: A UDP-Based Multiplexed and Secure Transport
    "rfc9110"  # HTTP Semantics
    "rfc9112"  # HTTP/1.1
    "rfc9114"  # HTTP/3
  )


  for rfc in "${rfcs[@]}"; do
    cbackup "https://www.rfc-editor.org/rfc/${rfc}.txt" "$RFC_OUT/${rfc}.txt"
  done

  lrun sync
  log SUCCESS "RFC backup success"
}

requirements
out
gcc_backup
llvm_backup
linux_backup
wikimedia_backup
rfc_backup
