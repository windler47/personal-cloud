#!/usr/bin/env python3

import requests
import ipaddress
import datetime

YANDEX_SUBNETS_URL = 'https://yandex.com/ips'
GOOGLE_SUBNETS_URL = 'https://www.gstatic.com/ipranges/goog.json'
GOOGLE_CLOUD_SUBNETS_URL = 'https://www.gstatic.com/ipranges/cloud.json'

YANDEX_IP_RANGES = [
    '5.45.192.0/18',
    '5.255.192.0/18',
    '37.9.64.0/18',
    '37.140.128.0/18',
    '77.88.0.0/18',
    '84.252.160.0/19',
    '87.250.224.0/19',
    '90.156.176.0/22',
    '93.158.128.0/18',
    '95.108.128.0/17',
    '141.8.128.0/18',
    '178.154.128.0/18',
    '185.32.187.0/24',
    '213.180.192.0/19'
]

out_nets = [
    ipaddress.IPv4Network('172.17.3.0/26')  # Arbat
]


def get_google_subnets():
    result = []
    for url in (GOOGLE_SUBNETS_URL, GOOGLE_CLOUD_SUBNETS_URL):
        res = requests.get(GOOGLE_SUBNETS_URL).json()
        for prefix in res['prefixes']:
            if 'ipv4Prefix' in prefix:
                result.append(ipaddress.IPv4Network(prefix['ipv4Prefix']))
    return list(ipaddress.collapse_addresses(result))

def get_russian_subnets():
    result = []
    with open('scripts/russian_subnets.txt') as f:
        for line in f:
            if line.startswith('#'):
                continue
            else:
                result.append(ipaddress.IPv4Network(line.strip()))
    return list(ipaddress.collapse_addresses(result))


def main():
    result_set = []
    current_date = datetime.date.today()
    rus_subnets = get_russian_subnets()
    google_subnets = get_google_subnets()
    for subnet in rus_subnets:
        good_subnet = True
        for g_subnet in google_subnets:
            if subnet.overlaps(g_subnet):
                print(f'Subnet {subnet} overlaps with g_subnet {g_subnet}')
                good_subnet = False
        if good_subnet:
            result_set.append(subnet)
    result = [
        f'add address={subnet} comment="Russian Federation" list=RU\n'
        for subnet in ipaddress.collapse_addresses(result_set)
    ]
    result_lines = [
        '/ip/firewall/address-list\n',
    ] + result
    with open(f'subnet_list_{current_date.isoformat()}', 'w') as f:
        f.writelines(result_lines)
    

if __name__ == '__main__':
    main()
