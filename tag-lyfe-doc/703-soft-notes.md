## objective of soft notes

this document serves the same (unstated) ultimate objectives of [#702].

one of our goals is to turn unknown unknowns into known unknowns, i.e.,
to develop a "formal feature set", to discover/learn the lexicon, etc.

so one thought is that we discuss things in a "soft" manner here, then
we formalize them into a tags that obliquely form a "tag lexicon" over
there. in a perfect world, all of the qualitative data we gather here
could be turned into quantitative data over there and we could sunset
this document back into nonexistence.

here's components of the formal set, as we encounter them:



### history of URL's

one of the main dimensions of change immediately visible from doing our
big sync of two data sources .. _is_ when the URL for the thing changes.

"the URL survey" is where we merely google each alternative and see if its
google-eigen-value is the same as what we have listed. similary, for each
alternative we will include whether its URL changed between the first and
second datasets. so, a two-bit value, yes?

  - whether what's on file differs from what was in the first import
    (and if so, what was the URL previously)

  - whether the google-eigen-value is different from what's on file
    (and if so, what the google-favored URL is) (ok, re-word this to
    be "what is the current "home" (most reliable) URL for the thing
    (a discretionary judgement)?)



### "inspired by", etc.

when one parser generator is "like [this other alternative] but ..", we
see that as being the new alternative is being made in the shadow of slash
on the shoulders of giants of the referent (the referent being the giant).

in such cases it may behoove us to study the giant one first, maybe?




## soft notes on each alternative (the main body of this document)

note about this list:
  - for no good reason we did it in reverse alphabetical order
    (zesty-parser first, ANTLR last). depending what revision of this
    document you are seeing, you will notice a qualitative difference
    in how we go about summarizing/categorizing/qualifying the particular
    alternative. (closer to the Z's (when we were starting out) we cared
    more about determining what URL to use. closer to the A's (once we
    got a feel for the kinds of things we did and didn't like (COARSELY))
    we started making more practical judgements of the alternatives across
    a broader spectra of ..  dimensions)




### ANTLR

- motherfucking terrence parr. strong contender.



### aperiot

- disqualifying: does not live at github or the like
- documentation is spread throughout a slide deck and PDF's



### arpeggio

- (use the façade provided by textx)



### Berkeley YACC

- not enough documentation of the integration
- seems historically hugely signficant



### BisonGen

- from a blog post 2005-04. dead links in post.
- nontheless interesting.
- may be of historical significance, or have roots therein



### Bison in a box

- penalized for awful name
- ANCIENT



### CodeTalker

- maybe, but i'm not sure what its value-prop is. oh. as bernstein says.



### Construct

- penalized for having a terrible name
- BERNSTEIN UPDATE w/ re: to version
- very interesting approach that echoes stuff i've thought of (2-way)



### docopt

- sounds like a thing i did
- ad-hoc/specialized
- yes this is the thing i started to try to make. cute.



### dparser

- its web presence is rough
- there might be some confusion - it has an example grammar for python
- BERNSTEIN #edit [#703.B]



### FlexModule and BisonModule

- last commit: 2013-12-28
- old, but perhaps a unique value prop.



### funcparserlib

- random comment: this sounds like that thing i made in ruby
- last commit: 2016-02-24
- this is a good contender.



### GOLD Parser

- seems fishy but is interesting
- not that pythonic (seems most comfortable being run from windows)
- disqualifier: requirements are not listed from home page. no github or equiv.



### Grako

- abandoned. yay. references "tatsu" DING DING DING new thing to add.
  ("tatsu" is probably the winner.)



### kwParsing

- unclear what its distinguishing features are. sources/installation unclear.



### LEPL

- abandoned



### lrparsing

- interesting



### martel

- woah. meh. depends on: mx text tools



### ModGrammar

- interesting



### mxTextTools

- lol wtf



### parcon

- interesting



### parglare

- comment: interesting. well documented. looks mature. has many features
  that crossover with a lot of the other interesting new work.
- comment: many commits, 3 contributers
- last commit: 2018-06-05



### parsimonious

- comment: interestng: "The fastest pure-Python PEG parser I can muster"
  compare-to: pyPEG



### Parsing

- comment: HUGE penalty for the name
- comment: server down MWAHAAH



### picoparse

- comment: "abandoned" (the description here is a real hoot. i asked friends about it)



### Plex

- old. last release 2009-12-13.
- note: don't get confused with some other media thing.



### Plex3

- old. last commit 2012. interesting. python3 port of plex. incomplete.



### PLY

- interesting
- on-shoulders-of: SPARK
- see David Beazley's PyCon 2018 talk "Reinventing the Parser Generator"



### pyBison

- interesting



### pydsl

- comment: lost their domain. interesting.
- last commit: 2017-10-01
- blog is down



### PyGgy

- comment: still refers to broken link



## pyleri

- comment: interesting
- last commit: 2018-06-20-ish



## PYLR

- comment: INCOMPLETE. implementation of: "OPEN LR"



## pyparsing

- comment: wtf



### pyPEG

- comment: you are familiar with treetop so etc.
- last commit: 2017-01-08



### reparse

- comment: interesting etc
- last commit: 2017-06-13
- CI CI CI CI CI CI CI CI CI CI CI CI



### RP

- comment: ugly as hell doc, sorry
- comment: but interesting enough to try



### Rparse

- comment: very ad-hoc
- when googling: https://pypi.org/project/rparse/
- but actually: https://github.com/requirements/rparse
- (A to B: added by bernstein)



### SableCC

- neat. etc.
- added by bernstein



### schlex

- woah. etc.



### SimpleParse

- revisit (read the doo-hah)
- based on mxTextTools (ok so what does this mean?)
- last commit on github: 2015-11-11 (but ignore github - yikes)



### SPARK

- comment: revisit this: when googling "SPARK parser generators", first
  of all there's a bunch of talks, then also there's this which is
  redundant with (and more extant than) this whole project:
  [this](https://en.wikipedia.org/wiki/Comparison_of_parser_generators)
- (A to B URL did not change. bernstein added comment.)



### textX

- comment: looks mature
- on-shoulders-of: arpeggio
- last commit: 2018-07-04 (8 hours ago as of this typing)
- when googling, http://www.igordejanovic.net/textX/
- github: https://github.com/igordejanovic/textX
- (A only of A to B. strange not in B.)



### toy parser generator

- comment: sounds good
- first google hit: http://cdsoft.fr/tpg/, its B of A to B



### trap

- comment: not very prominent. saw one passing reference in a paper.
  the link on file is an academic paper from 1999.



### wisent

- comment: worth a further look
- last commit Apr 6, 2016
- now: first google hit is its github
  (now: https://github.com/preusser/wisent)
- was in dataset A only.
  (before: http://seehuhn.de/pages/wisent)



### yapps

- last commit May 16, 2014
- now: first google hit is its github
  (now: https://github.com/smurfix/yapps)
- from A to B: changed
  (before: https://wiki.python.org/moin/Yapps)
  (after: http://theory.stanford.edu/~amitp/yapps/)



### yappy

- comment: subjective feeling is this one seems not to be very pronounced
- now: googling it shows you an academic paper
  (now: https://www.researchgate.net/publication/237445856_Yappy_Yet_another_LR1_parser_generator_for_Python)
- from A to B: changed
  (before: ???)
  (after: ???)



### yeanpypa

- comment: opened issue on its github about broken documentation link
- now: first google hit is its github
  (https://github.com/DerNamenlose/yeanpypa)
- from A to B: changed
  (before: http://bitbucket.org/namenlos/yeanpypa)
  (after: http://freecode.com/projects/yeanpypa/)



### zesty parser

- from A to B: same
- now: changed to https://pypi.org/project/ZestyParser/
  (from https://pypi.python.org/pypi/ZestyParser)
  (old URL redirects to new URL anyway).



## video watching notes (just before zz)

(almost ZZ: 5:23) david beazly is great. PLY might win

(at 31:20 in the video and 5:35AM here, there's SLY)

SLY, (#edit [#703.B]: we discovered TaTsu shortly after and it won via discretion)



## (document-meta)

  - #born
