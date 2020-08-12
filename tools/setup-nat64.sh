#!/bin/sh

ipv6_subnet="$1"
ipv4_subnet="$2"

ipv6_prefix=`expr "$ipv6_subnet" : '\([^:]\+:[^:]\+:[^:]\+:[^:]\+\)::\/64$'`
if [ -z "$ipv6_prefix" ]; then
	echo "*** Invalid IPv6 subnet: $ipv6_subnet" >&2
	exit 1
fi

ipv4_prefix=`expr "$ipv4_subnet" : '\([0-9]\+\.[0-9]\+\)\.0\.0\/16$'`
if [ -z "$ipv4_prefix" ]; then
	echo "*** Invalid IPv4 subnet: $ipv4_subnet" >&2
	exit 1
fi

rmmod tayga 2>/dev/null

set -x

insmod tayga.ko ipv6_addr=$ipv6_prefix:0:ffff:0:2 ipv4_addr=$ipv4_prefix.255.2 \
	prefix=$ipv6_prefix::/96 dynamic_pool=$ipv4_prefix.0.0/17 || exit 1

ip link set nat64 up
ip addr add $ipv6_prefix:0:ffff:0:1/64 dev nat64
ip addr add $ipv4_prefix.255.1/16 dev nat64
