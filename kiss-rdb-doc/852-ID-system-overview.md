---
title: ID system overview
date: 2018-11-27T05:04:00-05:00
---

_this is a thread from slack transcribed exactly as-is but with
this formatting applied:_

  - _long lines broken_
  - _pointing finger emoji turned into markdown bullet list_
  - _two places parenthesis are used to editorialize_



Nov 27th at 5:04 AM (2018)

[..] Hey are u up


I want to inventory all the things I own for reasons.

 - I estimate I might get into the tens of thousands but not
   hundred of thousands
 - I needed to come up with a naming/numbering system kind of like git
   commit sha’s or that Microsoft numbering system everybody uses (for MAC
   addresses? Or maybe that’s different) or like the geotagging system(s).
   But easier ..


So what I came up with was

 - initially my “system” will have a capacity of 32 thousand whatever items
 - which is 5 bits (for reasons explained next)


Oh some important design constraints/objectives

 - I’m going to be hand-lettering and data entering these fuckers
 - so I want to avoid common typographic errors
 - and I want to optimize for having these identifiers have as few characters
   as I can by with and still have like a capacity of items in the thousands,
   say..


So what I “came up” with is that my system looks sort of like hexadecimal BUT

 - 0’s and O’s get confused so we don’t use EITHER of them
 - same 1’s and I’s. (A note about “l” below)

SO: the system is that each character of an “identifier” can be the 26 letters
of the alphabet minus those two, and 0-9 minus those two. Thats 24+8 = 32. So
as it works out, each character in an identifier has FIVE bits of information.

 - so if my system is limited to identifiers only one character wide,
   I can have only 32 items
 - with two-character wide identifiers, 32^2 or 1,024 items
 - with (what I’m going with for now) three characters, 32^3 or
   32,768    ANYWAY


(Oh • even though lowercase “L” is danger, I allow “L” (written uppercase
not lower) just so we reach a power of two and things are more familiar.
A corollary of this is we should write all the letters in uppercase only,
even though it’s not strictly necessary to differentiate them (edited)

This took wayyy longer to specify my “simple” system than I thought, but at
least I have it written down. My actual problem is that I want to .. write
a script that generates each next identifier for me but have them randomly
distributed. (I’ll get really OCD about things down the road if I know the
identifiers were assigned in sequence).. so, seeding a random number
generator and asking for a number between 0 and 32^3 is no problem ..


But like I want to be able to run this script in small batches (“give me
the next 5 identifiers”. “Ok now give me the next 10”. “Ok i need 2 more”).
And of course I don’t want to have any one identifier (ie number) ever be
produced more than once..


Like, a random number generator, as I write this I’m just now realizing it
already doesn’t work like this.  So really what I’m gonna want to do is keep
a dictionary in memory that’s a pool of all the remaining available
identifiers. And like use some kind of datastore (I’m using the filesystem)
in between invocations to persist which identifiers are taken. Then like,
each next invocation of the thing, I will ask for a number between zero and
the number of identifiers remaining in the pool (minus one), and whatever
random number it gives me I will take the available identifier
_at that offset_ egads


Ok sorry to spit all that out here. Apparently all I had to do was describe it


(sms:) thank god you don't have adderall anymore or you'd *do* it


hahahaha I’ve mulled this project over and over in my head since literal the
last time I moved to New York. (I actually started a rails app with the
intention of doing a project like this, to help me pack)


With each passing year my desire for such an app only grows stronger. Also I
need a stupid simple database backed web application that’s mine and mine
alone to get back on track with all the crap like Nima’s continually barfing
single page millennial


And like 8 other reasons why I need this app.


But yes, @sms, to your point, I definitely felt the adderall spirit, the
adderall nature, about halfway into that rant .. and I couldn’t .. stop


I’m pretty sure that my “system” described above is a re-hashing of ideas I
was exposed to when I was learning about geo-tagging for use in Matt’s
Pokémon Go related app. But I wanted to put the whole thing out there because
it kinda felt like one of those programming interview questions




## (document-meta)

  - #born.
