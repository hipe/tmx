# the broad objectives of [the project codenamed "sakin agac"]

currently, this must start out as a hodgepodge scratch space.

broadly in terms of user experience "philosopy":

  - whenever relevant, we want the UX to be "familar" ("intuitive"). I am
    reminded of what _ruby_ creator Yukihiro "Matz" Matsumoto said of ruby
    and "the element of least surprise" - he said something like, "it's
    about _my_ surpise, not your surprise". here we would want users of
    wikis, users of jekyll etc to have things "just work" they way they
    expect (but for at first a pared down subset of their features).


in terms of content (and the user experience, sort of):

  - imagine a plain old tree of documents in readable text, (that are for
    example but not necessarily markdown), that are versioned using an
    existing SCM (that is probably not necessarily git).
  - content authors can check out the content repository, make edits
    locally as straightforwardly with their own favorite text editors.
  - content authors can preview their changes semi-styled locally with
    (e.g) the github-flavored markdown ruby gem.
  - one day it would be nice for content authors to be able to see a
    faithful preview with something like a static site generator.
  - imagine different view stuff as being user-configurable, like, for
    example, let an `ikiwiki`-style syle continue to look like one or
    not, based on a cookie.
  - imagine if github-flavored markdown was truly available to the
    enduser being not on github (for example, locally).


in terms of technology:

  - a "polyglot" approach would be nice, where we can bring in the
    appropriate solution for the job regardless of the language it is
    written in. (for example, when targeting "github flavored markdown",
    we will use their ruby in our pipeline, while not needing our core
    to be ruby itself.)

  - a lightweight core that acts as a sort of "dependency injection
    framework". in the spirit of so many other things, all of its
    useful functionality would derive from its sub-systems.
      - "git for journaling" would be a module.
      - "markdown for rendering" would be a module. etc.

  - be able to run on heroku from the start (in part because of
    [the][heroku5] [discipline][heroku3] it will force on us).

  - this lightweight core (and its plugins) would need to be able to
    operate from the command line as well, for authoring. (more on
    this at [essential functions](#essential-functions).)

  - it would be folly not to at least consider thinking of this as
    a static site generator with a web interface - and give serious
    consideration to leveraging this approach to some degree that's
    not overly absurd..

other notes

  - this is similar in spirit (but not content) to the
    [counterpart feature tree][wikijs2] of wiki.js.




## <a name='essential-functions'></a>essential functions

(this is VERY rough, but it's just a startingpoint)

  - convert a source representation to a target representation (i.e
    markdown to HTML). specifically, this "function" should be able to
    work with a file (e.g path) as input, and a stream of bytes as output
    (string). pursuant to one of our essential design objectives, this
    function should be equally exposed from web as well as CLI.

  - "watch" for changes on a whole directory tree (from terminal only).
    (look at jekyll etc). build pipeline.

  - use "git log" and "git blame" (from terminal) as an inspiration for
    the user experience on web.

  - imagine "web" as "GUI" if you like. imagine mobile.




[wikijs2]: https://github.com/Requarks/wiki
[heroku5]: https://devcenter.heroku.com/articles/architecting-apps
[heroku3]: https://12factor.net/




## (document-meta)

  - #born.
