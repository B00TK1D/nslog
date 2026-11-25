#!/bin/sh
set -eu

domain="${DOMAIN:?DOMAIN must be set}"
ns_name="${NS_NAME:-ns1.${domain}}"

case "$domain" in
    *.) ;;
    *) domain="${domain}." ;;
esac

case "$ns_name" in
    *.) ;;
    *) ns_name="${ns_name}." ;;
esac

mkdir -p /tmp/nslog /run/named /var/log/bind
chown -R bind:bind /tmp/nslog /run/named /var/log/bind
chmod 0775 /var/log/bind

sed \
    -e "s|@DOMAIN@|${domain}|g" \
    -e "s|@NS_NAME@|${ns_name}|g" \
    /etc/nslog/named.conf.template > /tmp/nslog/named.conf

sed \
    -e "s|@DOMAIN@|${domain}|g" \
    -e "s|@NS_NAME@|${ns_name}|g" \
    /etc/nslog/zone.template > /tmp/nslog/db.zone

chown bind:bind /tmp/nslog/named.conf /tmp/nslog/db.zone
chmod 0644 /tmp/nslog/named.conf /tmp/nslog/db.zone

exec /usr/sbin/named -u bind -f -c /tmp/nslog/named.conf
