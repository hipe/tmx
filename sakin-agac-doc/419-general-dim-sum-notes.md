## current status

looking at hugo. hoping for hugo on heroku




## narrative

first we looked at the abstract idea of serving static pages off heroku
with things like [static sites ruby][thing01] build pack or the
[static buildpack][thing02].

GitHub pages

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




[thing01]: https://devcenter.heroku.com/articles/static-sites-ruby
[thing02]: https://github.com/heroku/heroku-buildpack-static.git
[thing03]: https://opensource.com/article/17/5/hugo-vs-jekyll
[thing04]: https://forestry.io/blog/hugo-and-jekyll-compared/
[thing05]: https://www.techiediaries.com/jekyll-hugo-hexo/
[thing06]: https://github.com/roperzh/heroku-buildpack-hugo




## (document-meta)
  - #born.
