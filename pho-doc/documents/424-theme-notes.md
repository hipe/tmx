---
title: "theme notes"
date: "2018-11-13T16:07:32-05:00"
---
# theme notes

## main learning points ("content management" section of documentation tree):
  - holy jeez theme components, nestable.
  - template lookup order
  - NOTE HERE: i have no idea how to make a theme after reading this far
  - NOTE HERE: generally i'm not happy with this documentation in the given order
  - the section called "formats" is a confusing misnomer: this is actually lowlevel
    markdown directives (as in "Configure Blackfriday Markdown Rendering")
  - the "page resources" document is written like a reference with absolutely NO context
  - the document about shortcodes says use `{ {% sc-foo param-bar %} }`,
    but in the giraffeacademy youtube it says use `{ {< sc-foo param-bar >} }`.
    which is it!?? ok they explain it further on down but it would be nice etc.
  - builtin shortcodes:
    - figure - like img
    - gist - a github gist
    - highlight - for syntax highlighting
    - instagram
    - rel & relref - gives permanant link from a relative reference
    - tweet
    - vimeo
    - youtube
  - "content type" is not what you think it is
  - section called "type" left us with lots of confusion
  - section called "archetypes" again would make a lot more sense after a hands-on
  - at the point when reading "taxonomies" and watching the giraffeacademy video,
    decided it would be best to follow their videos from the beginning rather
    than use a depth-first traversal of the documentation tree as a tutorial.
    nonetheless, gonna keep on keeping on with the tree walk first, so we can
    notice and note (write down) things that don't make sense to us.
  - the "menus" document is a great example of context-free reference documentation




## main learning points ("templates" section of documentation tree):

(a fair amount of the content in this section is transcribed from
hand-written notes (taken in the small moleskin lol).)

as it worked out, we ended up swallowing some kind of bitter pill and
admitting defeat at the challenge of learning about hugo templates from
the official documentation alone. it is our contention that it's something
of a dark art whose documentation is spread across different resources in
a non-linear, decentralized manner.

anyway, the excellent mike dean youtubes (which _are_, come to think of it,
linked to in the official docs), .. these proved  be essential for us to
get an introduction to themes and the template language.

the remainder of this section is a transcription of some hand-written
notes we took (in the little moleskin) while watching the excellent mike
dean youtubes.

> there's a deep lesson here. not only were my fears proven unfounded
> (that i had some kind of unsurmountable hurdle), but more broadly a
> deep assumption i had held was dismantled: that learning this way
> (on youtube) was somehow sub-optimal. in fact, giraffe academy guy
> (mike dean) seems to be teaching me stuff at like the same speed it would
> take me to read the thing and understand it.


### mike's template-related vids

|name|duration||
|---|---|---|
|template basics      | 8:34||
|list page templates  | 9:37||
|single page templates| 6:53||
|home page templates  | 2:50||
|section templates    | 3:45||
|base templates & bxxx| 7:15||
|variables            | 8:38||
|functions            | 6:05||
|if statements        |11:32||
|data files           | 4:03||
|partial templates    | 6:02||
|shortcode templates  | 9:24||
|building your site   | 4:17||



### notes & errata

- list page templates
  - 8:52 bad (weird) html structure
- home page template
  - its function is intuitive but its interface is not
- variables
  - only from template files
- conditionals
  - that weird syntax
  - AND and OR are functions
  - tiny erratum at 8:41




## (document-meta)

  - #born.
