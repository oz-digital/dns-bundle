# DNS Bundle BY OZ DAO

DNS Bundle is a powerful instrument to serve and manage your domain name system. The DNS Bundle is made up of a number of dockerized services including PowerDNS, MariaDB, PowerDNS Admin, Nginx, and Certbot.

## Services
- MariaDB: The DNS server uses MariaDB, a popular MySQL fork, for database management. The database is exposed on port 3306 and is always kept running for immediate access.
- PowerDNS: PowerDNS is a DNS server with a strong focus on security, scalability, and reliability. This service depends on the MariaDB service and listens on port 53 (TCP/UDP) and port 8081.
- PowerDNS Admin: This web application allows for easy management of PowerDNS. The app is accessible on port 8080 and depends on MariaDB for its data.
- Nginx: Nginx is used as a web server and reverse proxy for the PowerDNS Admin web app. The server listens on ports 80 and 443, and reloads configuration every 6 hours.
- Certbot: Certbot is a client that fetches certificates from Let's Encrypt and renews them automatically. It is configured to renew certificates every 12 hours.

# Getting Started

## Prerequisites
Ensure you have the following tools installed on your machine:
- Docker
- Docker-compose
- rsync
- SSH client

## Initial Setup

1. Clone the repository to your local machine.
2. Copy `.env.example` to `.env` and modify the `.env` file to match your setup.

## Nginx Setup

Before starting your services, make sure to set up Nginx. Update the provided Nginx configuration file to match your DNS address and obtain SSL certificates. 

1. First, start the MariaDB, PowerDNS, and PowerDNS Admin services. Use the following command:
    ```bash
    docker-compose -p dns.oz.digital up db pdns web_app 
    ```

2. Next, run the `init.sh` script. This script will:
    - Issue self-signed certificates.
    - Start Nginx.
    - Start Certbot and renew the certificates.
    - Set up an SSL reverse proxy for your DNS server's admin panel.

    Run the script using the following command:
    ```bash
    ./init.sh
    ```

You should now have your DNS server up and running with an SSL reverse proxy for the admin panel.

# Setting Up a Public NS Server

Follow this detailed step-by-step guide to setting up a public NS (Nameserver) server for a domain, using the example of `oz.digital`.

## Step 1: Enable SOA record visibility

Before starting, make sure that you have enabled the display of SOA (Start of Authority) records in your DNS settings. You can find this under SETTINGS/RECORDS in the PowerDNS Admin interface. Enabling this feature will allow you to see and manage SOA records, which is crucial for setting up your public nameserver.

## Step 2: Create a zone for your domain

The first step is to create a DNS zone for your domain. A DNS zone is a portion of the DNS namespace that is managed by a specific organization or administrator. It contains the DNS records for all the resources under that particular domain.

For the domain `oz.digital`, you would create a DNS zone titled `oz.digital`.

## Step 3: Add an SOA record

SOA stands for Start of Authority. It's the first record in any standard zone file, and it indicates the general properties of the domain and zone. The SOA record is used by the server to determine how to deal with requests and updates for the domain's records.

Add the following SOA record to the `oz.digital` zone:
`@ SOA Active 1500 ns1.oz.digital. hello.oz.digital. 2023052703 10800 3600 604800 3600`

## Step 4: Add an NS record

A Nameserver (NS) record identifies the DNS servers responsible (authoritative) for a zone. A zone should contain one NS record for each of its own DNS servers (primary and secondaries).

Add an NS record for `ns1.oz.digital` in your `oz.digital` zone:
`ns1 NS Active 60 185.209.162.125.`

## Step 5: Add an A record

An 'A' record maps a domain name to the IP address (Version 4) of the computer hosting the domain. An 'A' record is used for converting hostnames to their respective IP.

Add an A record for `dns.oz.digital` in your `oz.digital` zone, with the IP address of your DNS server:
`dns A Active 60 185.209.162.125`

## Step 6: Create a reverse zone for your domain

The reverse DNS zone is used for a process called reverse DNS lookup. It allows clients to determine a domain name associated with an IP address - the reverse of the usual "forward" DNS lookup of an IP from a domain name. Reverse DNS is used for logging the hostname associated with an IP address and for various network protocols.

For the IP address `185.209.162.125`, the reverse DNS zone would be `125.162.209.185.in-addr.arpa.` The `in-addr.arpa` is a special domain for IP address to domain mappings in the DNS system.

## Step 7: Add a PTR record

A Pointer (PTR) record, also known as a Reverse DNS record, resolves an IP address to a domain name. It is the counterpart to the 'A' record and is used in reverse DNS lookups.

Add a PTR record in your reverse DNS zone (`125.162.209.185.in-addr.arpa.`) that points to `ns1.oz.digital`:
`@ PTR Active 60 ns1.oz.digital.`

## Step 8: Add an NS record to the reverse zone

In the reverse DNS zone, it's also important to have a Nameserver (NS) record. This record indicates which DNS server is authoritative for the reverse zone and thus responsible for responding to queries about the IP address.

Add an NS record to your reverse DNS zone (`125.162.209.185.in-addr.arpa.`) that points to `ns1.oz.digital`:
`@ NS Active 60 ns1.oz.digital.`

Congratulations! Your public NS server setup is now complete. Please remember that changes to DNS settings can take up to 48 hours to propagate worldwide.

## Contribution and Support

We're thrilled to see that you're interested in our project. Your help and contributions are more than welcome!

Despite our best efforts, there's still a lot to be done. We're actively seeking contributions to enhance this project and make it even more efficient and easy to use. If you have ideas for improvement or if you've noticed a bug that needs fixing, don't hesitate to get involved.

You can help us in various ways:

- Reporting bugs: If you encounter any issues or bugs, please open an issue in our GitHub repository.
- Suggesting enhancements: We are open to any and all suggestions. Feel free to create an issue to suggest new features or improvements to existing ones.
- Code contribution: Feel free to fork the repository, make your changes and create a Pull Request.

We are committed to fostering an open and welcoming environment. Please read our Code of Conduct before participating or contributing.

To get started, please submit a Pull Request with a clear list of changes. Together, we can build a robust and user-friendly tool that can make a real difference. Thank you for your support and contribution!

## License

This library is licensed under the [GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.txt), so make sure to check out the license file for more details.
