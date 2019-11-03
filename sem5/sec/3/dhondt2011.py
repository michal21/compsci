#!/usr/bin/python
import csv


def lastlost(seats, parties):
    parties = parties.copy()
    lastscr = 0
    for p in parties:
        parties[p]['div'] = 1
    while seats > -1:
        mx = 0
        mp = ''
        for p in parties:
            if int(parties[p]['votes'] / parties[p]['div']) > mx:
                mx = int(parties[p]['votes'] / parties[p]['div'])
                mp = p
        seats -= 1
        if seats == 0:
            lastscr = int(parties[mp]['votes'] / parties[mp]['div'])
            print('Last: ', mp, ', scr: ', lastscr)
        if seats == -1:
            lostscr = int(parties[mp]['votes'] / parties[mp]['div'])
            print('Lost: ', mp, ', scr: ', lostscr)
            print('Diff: ', (lastscr - lostscr) * parties[mp]['div'])

        parties[mp]['div'] += 1


total = {}
sects = {}

with open('2011.csv', 'r') as csvfile:
    rdr = csv.reader(csvfile, delimiter=';', quotechar='"')
    for row in rdr:
        #print(', '.join(row))
        num=row[0]
        name=row[1]
        party=row[3]
        chosen=row[12]
        votes=row[13]
        #print(num, name, party, chosen, votes)
        if not name in total:
            total[name] = {}
        if not party in total[name]:
            total[name][party] = {}

        if not name in sects:
            sects[name] = {}
        if not party in sects[name]:
            sects[name][party] = {}
        
        if not 'votes' in total[name]:
            total[name]['votes'] = 0
        if not 'seats' in total[name]:
            total[name]['seats'] = 0

        if not 'votes' in total[name][party]:
            sects[name][party]['votes'] = 0
        if not 'seats' in total[name][party]:
            sects[name][party]['seats'] = 0
        
        total[name]['votes'] += int(votes)
        sects[name][party]['votes'] += int(votes)
        if chosen == 'T':
            total[name]['seats'] += 1
            sects[name][party]['seats'] += 1


for sect in sects:
    seats = total[sect]['seats']
    lastlost(seats, sects[sect])

#lastlost(8, {'A':{'votes':720},'B':{'votes':300},'C':{'votes':480}})

