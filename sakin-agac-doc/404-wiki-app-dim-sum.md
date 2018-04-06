# wiki app "dim sum"

## objective & scope

  - a "dim sum" (here) is a tabular comparison of alternatives.
  - mainly this document exists as a record of which serious contenders
    we knew about and (by proxy) which we have [mostly] eliminated from
    consideration (perhaps temporarily), and if so, why.
  - if the notes for any one challenger exceeds more than a few lines,
    it should break out into its own document.
  - the criteria of our "dim sum" table is vaguely informed by our
    [broad objectives][ours1].




## the challenger table

| Challenger                |[git?]|[markdown?]|[heroku?]|discussion
|---------------------------|:----:|:---------:|:-------:|-
| [ikiwiki][ikiwiki1]       | yes  | yes       | yes     | [discussion](#ikiwiki-discussion)
| [wiki.js][wikijs1]        | yes  | yes       | no      | [discussion](#wikijs-discussion)
| [XWiki][xwiki1]           |  no  | yes       | no      | [discussion](#xwiki-discussion)





## the questions

_(the components of the criteria - constitutes the input of the decision)_



### <a name=uses_git></a>is it git-backed?

for this question, we do _not_ mean "is the code for the wiki versioned
by git?". we mean ETC



### <a name=can_markdown></a>does it support markdown?

(currently ETC. later ETC.)



### <a name=can_heroku></a>can we run it on heroku?

this is the clincher.




## overview discussion

an essential startingpoint is the [Comparison of wiki software][wikipedia1]
wikipedia page.





## <a name='ikiwiki-discussion'></a>disussion: ikiwiki

Synopsis: overall this is the running model for what we're after. it's
very straightforward and unadorned and appears to achieve what it sets
out to dod.

  - CON: we don't like that clicking on "history" shows all history,
    not just document history
  - PRO: the bare-bones-ness of this is great.
  - CON: perl is old. hacking on this won't earn us any portfolio pieces.
  - CON: pretty sure this won't run on heroku for many [reasons][heroku2]




## <a name='wikijs-discussion'></a>disussion: wiki.js

  - PRO: amazingly we were able to get this to build and deploy (by all
    appearances) to heroku.
  - CON (possibly): the design that user-generated pages appears in sounds
    pretty locked-in..
  - CON: this claims to be using git as a backing for its version control
    but there's no way it was actually doing this.
  - CON: node.js coding style is pretty rough
  - other CONs.




## <a name='xwiki-discussion'></a>disussion: XWiki

  - is probably the most mature, built-out solution there is. corporate tilt.
  - CON it's MASSIVE
  - markdown (some flavor) is available thru an extension




[git?]: #uses_git
[heroku?]: #can_heroku
[markdown?]: #can_markdown




[heroku2]: https://devcenter.heroku.com/articles/architecting-apps
[ikiwiki1]: https://ikiwiki.info/
[ours1]: 403-broad-objectives.md
[wikijs1]: https://wiki.js.org/
[wikipedia1]: https://en.wikipedia.org/wiki/Comparison_of_wiki_software
[xwiki1]: http://www.xwiki.org/xwiki/bin/view/Main/WebHome




## (document-meta)

  - #born.
