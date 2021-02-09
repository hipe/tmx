---
title: "SSG dim sum"
date: "2018-04-04T13:55:22-04:00"
---

## objective & scope

(For posterity, the original objectives of this whole host package:)

  - learn react.
  - experiment with unobtrusive static pages
  - do that one static thing with tables
  - do that one static pipeline with webpack

In this document we keep track (at a high level) of which static site
generators (SSG's) we've surveyed and possibly used..

At this exact moment of writing, there are a jaw-dropping 316 different
static site generators listed at this one site:

```bash
    curl https://jamstack.org/generators/ > x.html
    dp scrape x.html section.cards div.generator-card \
            'a:nth-of-type(1)>div:nth-of-type(1)'
```

Finding the perfect static site generator is both out-of-scope at this
moment, AND ALSO sort of the whole point of a lot of our efforts...



## SSG dim sum table

(order: the most recent ones we are looking at at the top)

| SSG Name | Freeform description |
|:---|:---|
| Generic Static Site Generator | (example, max width at writing) |
| hugo                          | #implementation-language:ruby #we-have-used-it
| jekyll                        | #implementation-language:ruby #we-have-used-it



## Skipping over some intermediate steps..

We like a lot of the architecture and vocabulary of pandoc. Looking at "parcel"

We expect that we'll adopt a lot of the vocabulary, idioms and some
architecture of things like:

- Task execution tools like "make" (and python's nativization "invoke")
- Application bundlers like "parcel" (not looking at "webpack" rn)
- "pandoc", the "universal document converter"
- Static site generators like "pelican" (or hugo or jekyll etc)


From build tools like "make" we'll use concepts like EDIT.
(See [invoke][4] (found thru [pelican docs][3]).)

Like "parcel" we may have [trees of "assets"][2].

We will likely share [pandoc's vocaulary][1] of "input formats",
"output formats", "readers", "writers" and mabe even generic AST's.



[1]: https://pandoc.org/using-the-pandoc-api.html#pandocs-architecture
[2]: https://parceljs.org/how_it_works.html
[3]: https://docs.getpelican.com/en/latest/publish.html#invoke
[4]: https://www.pyinvoke.org/




## (document-meta)

  - #history-B.4: re-purpose file from an issues index to an SSG dim-sum
  - #born.
