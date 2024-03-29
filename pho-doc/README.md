---
title: "README"
date: 2019-05-14T08:06:54-04:00
excerpt: "introduction, objective & scope."
---
## Introduction, Objective & Scope

The main intended purpose for this project (currently codenamed "pho" and
(interchangeablely but somewhat more formally) "TMX notebook") is for taking
reading notes, inspired loosely by the popular [Evernote][ev].

(#edit [#880.B] get description from groupchat from around the time of #birth lol.)

The most ambitious conceit of "TMX Notebook" (and also something of an
offshoot, side-distraction) is perhaps "writing without borders":



## What is "Writing _With_ Borders"?

When doing this kind of writing, our immediate motivation is normally of
*content*: "What is the thing that I'm writing right now?" "What are the
essential pieces of information to jot down so I don't forget this?"

Another equally important category of questions plagues us around
*context*: "How do these new ideas fit in to the bigger picture of
[my collection of notes]?" "How will I find this content later when I'm
looking for it?"


### The document tree follows the structure of the ideas

These questions manifest as specific, structural decisions occurring
continually throughout the process: "Is this file too long yet?",
"Shouldn't this idea be 'closer' to this related idea in another file?",
"Are these related ideas voluminous enough to justify their own file (yet)?"

You could just as soon replace "file" above a with other, lower-level
"hierarchical containers" like "section": "Should these two ideas be in the
same section or should they each have their own section?" Or substitute
"paragraph" for "section"; and so on.


### Questions of taxonomy & boundaries go downward, upward & outward

And yes, "hierarchical containers" of content go upward too: surely a
bane to any would-be book author is questions like "Should this
[huge group of ideas] be _one_ chapter or _two_?" and "What order should these
chapters be in, relative to each other?"

Just as these "taxonomic" concerns cascade upwards, they also spill outwards
into various media: the origin story of Kill Bill I & II, or of George Lucas's
one sprawling script that got somehow partitioned out into nine (?) movies.
(Does "Einstein on the Beach" really need to be five hours long? Is there
a radio edit?)

These questions have affinity with the relatively recent idea of
_Information Architecture_, but they have probably been asked as long
as humankind has had narrative: Did the village elder, telling stories
around the fire, wonder if their rambling narrative was too long or
incoherent? I bet they did, and I bet I share a good portion of their DNA…



## Other editorial concerns, existential concerns

[There's a whole other, related concern of questions, those of _relevance_
and/or _level-of-detail_: "Is this information too low-level or otherwise
too parenthetical to my main point?". But we'll just leave here for now as
this dog-ear EDIT.]



## So what is Writing _Without_ Borders? (WWB)

Having established the ideas of writing for *content* and *context*, we
can now begin to suggest our main origin story/creation myth for
"TMX Notecards", which is mainly an experiment:

The dream is that we write little paragraph-sized ideas in "notecards" without
initially giving thought to how it fits in to the big picture. Then we place
the notecard into a giant hierarchy simply by assiging it a "parent" or a
"previous" notecard, again though not knowing necessarily what the "page"
will be.

Potential applications for this foundation include "dynamic taxonomification"
(I don't know how to pronounce it either); but such an imagined feature has
drawbacks for our immediate target use-case. (EDIT)

VCS integration (EDIT)



## About the names & origin

In antiquity (late 2000's) we wanted to use a wiki to keep our own reading
note for learning Ruby on Rails, because back then there was no central home
for authoritative, complete documentation & tutorials for RoR; it was a
scattered diaspopra of dozens of blogs, many of which were in various states
of out-of-date or accurate or best-practice-y.

The idea was that we make a Mediawiki-like graph of documents that relate to
each other (today we might consider asciidoc), that would not only aid in our
own learning, but it could be hosted on a github-like and distributed and
modified by the opensource community. We considered disqus-like comments. We
imagined that with vigilant enough curation and editors, it could become a
de-facto central source of documentation for the whole thing.

We got as far as starting a few files, then we had a hardware accident and
got waylaid.

The idea fell to the backburner as real life advanced for about 10 years, but
then in 2018 we revisted the desire to be able to take notes and publish them.
The awkardly named "sakin-agac" was born. (Its first documented mention may
be in what is now [#401] the SSG dim-sum.)

Then in late 2019 and into 2020 (initially not realizing this is what we were
doing) we came in with a ground-up rewrite (with one major new architectural
idea) codenamed "pho".



## quick sketch

when we say WASD we mean:

    PREV                     NEXT
    +---------------------------+
    |          (BODY)           |
    +---------------------------+
                          🔒 edit


when edit is unlocked:

    PREV       CREATE        NEXT
    +---------------------------+
    |        (TEXTAREA)         |
    +---------------------------+
                   cancel 🔓 save


when you click create

    NEW PREV              NEW NEXT
    +---------------------------+
    |        (TEXTAREA)         |
    +---------------------------+
                   cancel 🔓 save




## (the identifier registry)

(Our range: [#876-#900))
([#401-431] is (formally) the range for "TMX notebook" (app) SSG research)
(Put new issues in this range: [#887.A-#888))

|Id                         | Main Tag | Content  |
|---------------------------|:-----:|----|
|[#899]                     | #exmp | This is an example issue.
|[#887.B]                   | #open | images (and etc) #priority:0.75
|[#887.A]                   | #hole |
|[#886]                     | #open | jagged alignment of multiline descs (see "close") #is:[#603.2]
|[#885.2]                   |       | this one UI sketch
|[#884]                     |       | facets towards publication (graph)
|[#883.E]                   | #trak | in-place
|[#883.4]                   |       | provision: TEMPORARY document demarcation
|[#883.3]                   |       | provision: we never use the 1-depth header
|[#883.2]                   |       | the first fragment in a doc will have a heading
|[#883]                     |       | (internal provisions)
|[#882.Z]                   | #open | multiple collections
|[#882.Y]                   | #open | pho issues open breaks if eg row has minor component
|[#882.X]                   | #open | RSL parsing is too strict
|[#882.W]                   | #open | get placeholder AUTHOR and TIMEZONE out
|[#882.V]                   | #trak | track where we attempt to skip errors
|[#882.U]                   | #trak | where we insert or normalize newlines in generated markdown
|[#882.T]                   | #trak | two somewhat redunant implementations of parsing a function call
|[#882.S]                   | #trak | namespace for tracking provisions of "body function"
|[#882.R]                   | #open | dates! the date edited behemoth #priority:0.50
|[#882.Q]                   | #open | service
|[#882.P]                   | #trak | [graph via collection]
|[#882.15]                  |       | video editing dim-sum recfile
|[#882.N]                   | #open | someone is escaping newlines. we are accidentally supporting escape sequences
|[#882.M]                   | #trak | formal attributes (the model) is balkanized
|[#882.L]                   | #trak | really fragile DOM navigation but we don't want jquery
|[#882.K]                   | #open | detect cycles in notecard collection integrity check
|[#882.J]                   | #trak | timetrack syncing: local vs remote, time field
|[#882.I]                   | #edit | edits to do in fragments
|[#882.H]                   | #wish | feature: fswatch vs. everybody else
|[#882.7]                   |       | Moodboards recfile
|[#882.F]                   | #open | we need proper markdown parsing
|[#882.E]                   | #trak | [at writing this is a note in an unversioned document lol]
|[#882.D]                   | #feat | track implementation for feature: documents inside documents
|[#882.C]                   | #open | [see] some niche thing for invoking python from GUI
|[#882.B]                   | #trak | pelookan: track where you use '/pages/'
|[#882.1]                   | #open | ideally there should be no producer scripts not covered
|[#882]                     |       | (internal tracking)
|[#881.3]                   |       | a roadmaps table lol
|[#881.2]                   |       | roadmap-2.dot
|[#881]                     |       | roadmap.dot
|[#880.B]                   | #edit | edit documentation
|[#880]                     |       | README
|[#429.3] |       | algorithm: for document history data gathering
|[#429.2] |       | spec: page history whitepaper
|[#428]   |       | #see
|[#427]   |       | #see
|[#426]   |       | #see
|[#425]   |       | #see
|[#424]   |       | #see
|[#422]   |       | #see
|[#421]   |       | #see
|[#420]   |       | #see
|[#419]   |       | #see
|[#418]   |       | #see
|[#416.D] |       | CMS's
|[#416.C] |       | parser generators: turn soft notes into tags (for no real reason except posterity)
|[#416.B] |       | (nasim!)
|[#416]   |       | (numberspace for publishing wishlist)
|[#415]   |       | #see AND the "stream" script (see `/script`)
|[#413]   | #open | undefined: when row edited, does endcap get normalized-in or not?
|[#412]   | #open | "strict" "typing" (track true wishpoints)
|[#411]   |       | [the function that flushes stream processors]
|[#410.Y] | #open | pho: find nicer way to pull in the Alabaster theme
|[#410.W] | #edit | edit documentation
|[#410.V] | #open | (no taggings) sync on a markdown file with no table should complain
|[#410.N] | #trak | [html via markdown that isn't sync]
|[#410.G] | #trak | nested context managers closing each other
|[#410.5] | #trak | workaround to avoid particular dotfiles as reported by vendor script
|[#410.4] | #trak | the order that files are listed from the filesystem (even find) is indeterminate
|[#410.B] | #open | absorb small graph into big graph
|[#410]   |       | (internal tracking)
|[#409.7] |       | #see
|[#409.6] |       | #see
|[#409.5] |       | #see
|[#409.4] |       | #see
|[#409.3] |       | #see
|[#409.2] |       | #see
|[#407.D] | #trak | this smell of prev-next should be ordered children mebbe
|[#407.C] | #trak | loading modules
|[#407.B] |       | hardcoded values that should be env vars
|[#407]   |       | [reserved for internal tracking for now]
|[#406.23]| #open | this document might be obviated by "/TODO.dot" (of the mono-repo)
|[#406]   |       | #see
|[#405]   |       | #see
|[#404]   |       | #see
|[#403]   |       | #see
|[#402]   |       | #see
|[#401]   |       | #see
|[#400]   |       | [refers to the whole package]



[ev]: https://evernote.com/



## (document-meta)

  - #history-B.4: merge-in lots of older nodes from elsewhere
  - #birth.
