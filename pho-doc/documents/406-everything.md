(This is a "pho issues"-style markdown table that demonstates the ability
of nodes to model associations with other nodes through our extended
hashtag syntax. This can then be used to generate a GraphViz dotfile:)


```bash
pho issues graph -r pho-doc/documents/406-everything.md
```


## "Everything"

(Our range is [#876-#900), a narrow allocation range)
(do not ignore this table (here for toggling on and off))

|ID|main tag|content|
|---|---|---|
|[#886.F]|       | career #part-of:[#886.B] #after:[#884.M] #after:[#881.B] #after:[#882.D]
|[#886.E]|       | art #part-of:[#886.B] #after:[#881.B] #after:[#882.D] #after:[#884.B]
|[#886.D]|       | space #part-of:[#886.B] #after:[#882.G]
|[#886.C]|       | body #part-of:[#886.B] #after:[#883.C] #after:[#883.B]
|[#886.B]|       | Every day: body, space, art, career
|[#886.A]|       | Maslow's Self-Actualization #part-of:[#886.B] #after:[#886.F] #after:[#886.E] #after:[#886.D] #after:[#886.C]
|[#884.R]|       | finish React tut #after:[#880.D]
|[#884.M]|       | That One Cables Application #after:[#884.R]
|[#884.F]|       | (cook up in the lab) #after:[#884.M] #after:[#881.P]
|[#884.B]|       | Mix 1 #after:[#884.F]
|[#883.C]| #done | Have bike! #after:[#883.A] #after:[#882.G]
|[#883.B]|       | Every day: weights & stretch #after:[#883.A]
|[#883.A]|       | body #part-of:[#880.B] #after:[#880.C]
|[#882.L]| #done | The floor cleaned of trash in three rooms #after:[#882.A]
|[#882.I]| #done | Unify clothes across three rooms #after:[#882.L]
|[#882.G]| #done | Begin purge of maid's room #after:[#882.I]
|[#882.D]|       | Castle of Dust (Minecraft) #after:[#882.G]
|[#882.A]|       | space #part-of:[#880.B] #after:[#880.C]
|[#881.Z]|       | Backend for "Media Tree" #after:[#881.M]
|[#881.Y]|       | Frontend for "Media Tree" #after:[#881.M]
|[#881.W]|       | finish skimming "anim" book #after:[#881.A]
|[#881.V]|       | external HDD #after:[#881.A]
|[#881.U]|       | assets off old phone #after:[#881.V]
|[#881.T]|       | assets off broken phone #after:[#881.V] #after:[#880.E]
|[#881.S]| #done | video editing DIM-SUM #after:[#881.A]
|[#881.R]| #done | Research asset management #after:[#881.A]
|[#881.Q]|       | Learn Blender VSE scripting #after:[#881.N] #after:[#881.S]
|[#881.P]|       | assets off all phones #after:[#881.T] #after:[#881.U]
|[#881.O]| #done | Research making UI's with Unity #after:[#881.A]
|[#881.N]| #done | Free up space on laptop #after:[#881.I] #after:[#881.V]
|[#881.M]| #done | Install Unity #after:[#881.O] #after:[#881.N]
|[#881.L]|       | "Media Tree" format & micro-DAM #after:[#881.R] #after:[#881.Y] #after:[#881.Z]
|[#881.K]|       | Comprehensive Survey of Jamie Hewlett lol #after:[#881.L]
|[#881.J]|       | Finding Wacom Tablet would be Great #after:[#882.G]
|[#881.I]|       | Research treemap for disk usage
|[#881.H]|       | Content generated w (e.g) DaVinci (write code) #after:[#881.L] #after:[#881.P] #after:[#881.Q]
|[#881.D]|       | The Content (semi-dynamic) #after:[#881.H]
|[#881.C]|       | Jamie Hewlett OP #after:[#881.J] #after:[#881.K] #after:[#881.W]
|[#881.B]|       | Story 1 (3 formats) #after:[#881.C] #after:[#881.D]
|[#881.A]|       | art #part-of:[#880.B] #after:[#880.C]
|[#880.F]|       | get paid how ??? #after:[#880.D]
|[#880.E]|       | a paycheck lol #after:[#880.F]
|[#880.D]|       | career #part-of:[#880.B] #after:[#880.C]
|[#880.C]|       | Every day #part-of:[#880.B]
|[#880.B]|       | Every day: body, space, art, career


## Issues and doc nodes

(ignore this table (here for toggling on and off))

|ID|main tag|content|
|---|---|---|
|[#879.11]|       | end game #part-of:[#879.1] #after:[#879.10]
|[#879.10]|       | music #part-of:[#879.4] #after:[#879.9]
|[#879.9] |       | procgen #part-of:[#878.8] #after:[#879.8]
|[#879.8] |       | mixed skills #part-of:[#879.3] #after:[#879.7]
|[#879.7] |       | scrapers #part-of:[#878.1] #after:[#879.6]
|[#879.6] |       | near wapps #part-of:[#877.26] #after:[#879.5]
|[#879.5] |       | physical body #part-of:[#879.2]
|[#879.4] |       | music (again)
|[#879.3] |       | mixed skills
|[#879.2] |       | physical body
|[#879.1] |       | end game
|[#878.26]| #open | unfrozen caveman gamer (twitch/youtube) #part-of:[#879.1]
|[#878.25]| #open | unfrozen caveman anime fan #part-of:[#879.1]
|[#878.24]| #open | TikTok brand lol #part-of:[#879.1]
|[#878.23]| #open | game dev #part-of:[#879.3]
|[#878.22]| #open | producer/DJ brand lol #part-of:[#879.4]
|[#878.21]| #open | toon boom #part-of:[#879.3]
|[#878.20]| #open | learn video editing #part-of:[#879.3]
|[#878.19]| #open | making clothes #part-of:[#879.3]
|[#878.18]| #open | accents #daily #part-of:[#879.3]
|[#878.17]| #open | learn ableton & music theory oishi thing #part-of:[#879.4]
|[#878.16]| #open | bossa nova guitar #daily #part-of:[#879.2]
|[#878.15]| #open | gain flexibility #daily #part-of:[#879.2]
|[#878.14]| #open | freestyling (like parkour) #daily #part-of:[#879.2]
|[#878.13]| #open | synthesize dances: gliding, ballroom, afro, tecktonik #daily #part-of:[#879.2]
|[#878.12]| #open | 3D print glasses #part-of:[#879.3]
|[#878.11]| #open | arduino siri do i have #app
|[#878.10]| #open | 90's patterns #app #part-of:[#878.8]
|[#878.9] | #open | toronto keith harring #app #part-of:[#878.8]
|[#878.8] |       | proc gen art gen
|[#878.7] | #open | oculus rift graffitti #app
|[#878.6] | #open | minecraft server
|[#878.5] | #open | scrape/tag IG #app #part-of:[#878.1]
|[#878.4] | #open | scrape/tag twitter #app #part-of:[#878.1]
|[#878.3] | #open | scrape/tag photos #app #part-of:[#878.1]
|[#878.2] | #open | view/tag slack history #app #part-of:[#878.1]
|[#878.1] |       | scrapers
|[#877.26]|       | near wapps
|[#877.25]| #open | AHA #app #part-of:[#877.26]
|[#877.24]| #open | project grow #part-of:[#877.26]
|[#877.23]| #open | n10.as app hogwarts #app #part-of:[#877.26]
|[#877.22]| #open | hogwarts #app #part-of:[#877.26]
|[#877.21]| #open | tmx notebook #app
|[#877.20]| #open | (the DANCE app!!) #after:[#877.19] #part-of:[#877.1] #app
|[#877.19]| #open | (LANGUAGE APP!!) #after:[#877.17] #after:[#877.18] #part-of:[#877.1] #app
|[#877.18]| #open | (tagging app) #after:[#877.16] #part-of:[#877.1] #app
|[#877.17]| #open | (n10.as) #after:[#877.16] #part-of:[#877.1] #app
|[#877.16]| #open | (castle of dust) #after:[#877.15] #part-of:[#877.1] #app
|[#877.15]| #open | (CMS thing (rough)) #after:[#877.14] #part-of:[#877.1] #app
|[#877.14]| #open | (these) #after:[#877.7] #after:[#877.13] #part-of:[#877.1]
|[#877.13]| #open | CRAZY GIT THING #after:[#877.12]
|[#877.12]| #open | talk to git on cloud #after:[#877.10]
|[#877.11]| #open | (upload bot) #after:[#877.8] #app
|[#877.10]| #open | talk to git local #after:[#877.6]
|[#877.9] | #open | (game server) #after:[#877.6] #app
|[#877.8] | #open | (grep dump!) #after:[#877.6] #after:[#877.7] #app
|[#877.7] | #open | (react roadmap)
|[#877.6] | #open | now that you have storage #after:[#877.5]
|[#877.5] | #open | write file on cloud #after:[#877.4]
|[#877.4] | #open | write file local #after:[#877.3]
|[#877.3] | #open | read file on cloud #after:[#877.2]
|[#877.2] | #open | with docker read file off local FS
|[#877.1] |       | zippy dippy toopy
|[#876.24]| #open | things that excite you #after:[#876.19] #after:[#876.20] #after:[#876.21] #after:[#876.22] #after:[#876.23] |
|[#876.23]| #open | music |
|[#876.22]| #open | movies |
|[#876.21]| #open | videogames |
|[#876.20]| #open | dance #after:[#876.18] |
|[#876.19]| #open | tech things that excite you #after:[#876.13] #after:[#876.14] #after:[#876.15] #after:[#876.16] #after:[#876.17] #after:[#876.18] |
|[#876.18]| #open | dance app #after:[#876.5] #app
|[#876.17]| #open | versiony CMS #after:[#876.4] |
|[#876.16]| #open | physical object index #after:[#876.4] #app
|[#876.15]| #open | search chat logs #after:[#876.4] #app
|[#876.14]| #open | image upload #after:[#876.12] #app
|[#876.13]| #open | the ASCII game #after:[#876.12] #app
|[#876.12]| #open | grok slack bots |
|[#876.11]| #open | Crate and Crowbar DIM SUM #after:[#876.10]  #part-of:[#876.2] |
|[#876.10]| #open | youtube channel Extra Credits DIM SUM #after:[#876.9]  #part-of:[#876.2] |
|[#876.9]| #done | hugo theme DIM SUM #after:[#876.8]  #part-of:[#876.2] |
|[#876.8]| #done | SSG feature DIM SUM #after:[#876.7]  #part-of:[#876.2] |
|[#876.7]| #done | heroku plugin DIM SUM #after:[#876.6]  #part-of:[#876.2] |
|[#876.6]| #done | parser generator DIM SUM  #part-of:[#876.2] |
|[#876.5]| #open | asssets storage (images/video) #after:[#876.3] #part-of:[#876.1] |
|[#876.4]| #open | filesystem as storage #after:[#876.3] #part-of:[#876.1] |
|[#876.3]| #open | heroku-ish storage #part-of:[#876.1] |
|[#876.2]|       | waiting for frontend |
|[#876.1]|       | you need some kind of storage |




# (document-meta)
```
#history-B.4 markdown not dotfile, re-absorb another graph
#history-A.1 re-focused purpose
#born.
```
