## current status

looking at hugo. hoping for hugo on heroku




## narrative

first we looked at the abstract idea of serving static pages off heroku
with things like [static sites ruby][thing01] build pack or the
[static buildpack][thing02].

GitHub pages

(to add somewhere else later: Pelican (discovered when reading gimp docs)

nginx

oh what's this? jekyll _on_ heroku is a thing (how?

then we learned of [hugo][thing03] and it of course tickled our fancy.

uptakes of this (15 month old) blog post is that
  - hugo sounds more compelling generally but doesn't have a plugin
    architecture (oh?)
  - was sad to discover how hard-coded markdown sounds like it is
    in the thing. (not that markdown is bad; we just want it to be
    more like pandoc.)

then in a [more recent][thing04] but similar article, we see weirldy that
TOML (supported by hugo not jekyll) is from tom preston warner, github
co-founder and creator of jekyll.

and then ugh i should probably get ready for a [gatsby][thing05] like thing.

ok so let's hope this hugo [buildpack][thing06] will work, then we can
worry about why hugo won't work for our needs later..

(oh and then say something about netlify)




## look it works on heroku

in a separate tab off to the right, do:
    $ h logs --tail -a botnoise

note: you won't see anything.



do:

```bash
$ heroku create --buildpack https://github.com/roperzh/heroku-buildpack-hugo.git
```


get:
```
›   Warning: heroku update available from 7.0.47 to 7.7.8
Creating app... done, ⬢ powerful-falls-33442
Setting buildpack to https://github.com/roperzh/heroku-buildpack-hugo.git... done
https://powerful-falls-33442.herokuapp.com/ | https://git.heroku.com/powerful-falls-33442.git
```

OR do:

```bash
$ heroku buildpacks:set "https://github.com/roperzh/heroku-buildpack-hugo.git" -a botnoise
```

get:

```
Buildpack set. Next release on botnoise will use https://github.com/roperzh/heroku-buildpack-hugo.git.
```

do:

```bash
$ heroku config:set -a botnoise HUGO_VERSION=0.46
```

get:

```
Setting HUGO_VERSION and restarting ⬢ botnoise... done, v3
HUGO_VERSION: 0.46
```




## how we installed hugo:

(note it wasn't actually necessary to have hugo installed locally to get it
to work on heroku, which seems obvious now)

do:

```bash
$ which hugo
```

get:

```
hugo not found
```

do:

```bash
$ brew install hugo
```

[get lots of output]


do:

```bash
$ hugo version
```

get:

```
Hugo Static Site Generator v0.46/extended darwin/amd64 BuildDate: unknown
```


do:
```bash
$ git submodule add https://github.com/budparr/gohugo-theme-ananke.git themes/ananke
```


do:
```bash
$ hugo new posts/my-first-post.md
```

do:
```bash
$ hugo server -D
```



later we upgraded hugo
do:
```bash
$ brew upgraded hugo
```




[thing01]: https://devcenter.heroku.com/articles/static-sites-ruby
[thing02]: https://github.com/heroku/heroku-buildpack-static.git
[thing03]: https://opensource.com/article/17/5/hugo-vs-jekyll
[thing04]: https://forestry.io/blog/hugo-and-jekyll-compared/
[thing05]: https://www.techiediaries.com/jekyll-hugo-hexo/
[thing06]: https://github.com/roperzh/heroku-buildpack-hugo




## (document-meta)
  - #pending-rename: hugo everyday usage
  - #born.
