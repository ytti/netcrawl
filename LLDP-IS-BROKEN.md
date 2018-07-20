Someone with energy to work on standard bodies should drive LLDP change in such
way that it is actually consumable by vendor-agnostic code.
Today working LLDP code would require per-vendor models to translate portID and
chassisID into something consumable, often cases requiring heuristics.
LLDP is extremely low value and with minor changes could be actually standard
tool to discover network.


```email
[802.1 - 9431] LLDP portID
To: STDS-802-1-L@.x
Subject: [802.1 - 9431] LLDP portID
From: Saku Ytti <saku@.x>
Date: Wed, 9 Jan 2013 15:03:08 +0200
Delivered-to: mhonarc@.x
Reply-to: Saku Ytti <saku@.x>
"Insanity is doing the same thing and expecting a different result."
Before sending a duplicate post, see "Sending->retrying" at
802.1 list help: www.ieee802.org/1/email-pages/zuwz1011.html
-----

Hi,

Why is there no snmp ifIndex subtype for portID?

It seems like obvious choice, which vendors actually do use. Only
problem is, you cannot know this programmatically as you must use
locally defined subtype, which we have to hard-code, i.e. discovery
needs to know each and every platform statically.

Today you can get LLDP implementation from vendor which is useless for
automated discovery, as you cannot guarantee to get useful information
how to connect to peer device nor useful information how to
discriminate correct interface at peer.
Wouldn't this be goal #1 for L2 discovery? That automated discovery is possible?

Would it be too complex to mandate that if system implements SNMP and
IPv4 or IPv6, it must send networkAddress (and define it as address
which responds to SNMP) and chassisID with
new ifIndex subtype? This way all real-world IP devices could be
programmatic discovered without vendor specific code to support it.
You'd still not require things which might be hard to implement in
some niche/embedded situations.

Why can't we have multiple subtypes advertised per chassisID and portID?


Also I see that ifAlias is often offered, and two major vendors both
have had bug in LLDP implementation where portID is ifAlias, which
mean (against MIB) that they are sending port description (which is
useful, as it typically only talks about the peer, not local names).
And vendors happily accept it is bug (while according to standard it
is not) and have fixed it.

                                           MIB           Real world
Interface description  ifDescr            ifAlias
Interface long name   ifName           ifDescr
Interface short name  ifAlias             ifName

Consequently leaving ifDescr out as valid subtype means in real world
you don't deliver what you intended to deliver.
(It is must unfortunate real-world has 'wrong' values in them, but
that historic problem probably won't be fixed ever, easier to fix MIB)

--
  ++ytti

===
Unsubscribe link: mailto:STDS-802-1-L-SIGNOFF-REQUEST@LISTSERV.IEEE.ORG
IEEE. Fostering technological innovation and excellence for the benefit of humanity.
```
