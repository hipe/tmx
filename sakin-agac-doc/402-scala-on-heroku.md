# heroku & scala notes

## objective & scope of this document

  - mosty this exists for posterity as a reference for future such efforts.
  - curently this is a thin mesh of notes,
  - but it is however _comprehensive_ of what we did
    to start working with heroku, from zero.
  - the sections are meant to be followed in chronological order, but are
    placed in this document *from bottom to top*. (generally the more
    interesting/volatile parts come later, so this way are near the top
    of the document for easier reference.)
  - unless stated explicitly, all below section terminal commands happen
    from the _project_ root (not [sub-project][up1] root; that is, be at
    the tippy-top where the `.git` directory is).




## (NOTE the remaining sections go from last to first)

_(this way, the most interesting are usually at the top)_




## RANDOM "tickler"

look into these great things from [heroku7]

  - dropbox sync
  - heroku API




### scala play markdown extension

is [here][rando1].




## then, pray:

(in one terminal (on the right):)

    heroku logs --tail --remote heroku1

then:

    git push heroku1 main:master

then (after a while)

    heroku open --remote heroku1

(we use the name "main" not "master" for our local master branch,
but this is contingent on personal choice not reflected anywhere
in our docs!)





## IMPORTANT tell it remotely that this:

heroku will try to autodetect stuff by looking at the root of our
project. our project is weird because it has python and the rest.
heroku will see the Pipfile and assume we want to use python, unless
we tell it explicitly what "buildpack" to use:

    heroku buildpacks:set heroku/scala --remote heroku1
    heroku buildpacks:set heroku/scala --remote heroku2




## then, tell our local repository about the new remote

(intead of:)

    heroku git:remote -a botnoise

(we do:)

    git remote add heroku1 https://git.heroku.com/botnoise.git
    git remote add heroku2 https://git.heroku.com/botnoise2.git

NOTE - we have a main one and a spare. the main one (as a heroku app)
doesn't explicitly name itself as `1` so the URL is more attractive.
but we use numbers for both of the remote names when working locally
so we have to remember to think about it.



```
heroku1	https://git.heroku.com/botnoise.git (fetch)
heroku1	https://git.heroku.com/botnoise.git (push)
heroku2	https://git.heroku.com/botnoise2.git (fetch)
heroku2	https://git.heroku.com/botnoise2.git (push)
```




## then make some apps

(originally we used the web interface, but use the CLI instead)

    heroku create botnoise
    heroku create botnoise2




## then, generate public key

(no need. but we needed the email/password for our heroku account.)




## then, run it locally:

    heroku local




## now, get the heroku CLI (for OS X)..

..per [here][heroku1]:

    brew install heroku/brew/heroku




## then, compile

(something about rebuild ETC)

    sbt compile stage




## then, copy these certain file over with this script

  - this is a rough sketch for how we bring over only the files we
    need from the heroku scala/Play example project.

  - this IS IN FLUX because originally we tried to get these files
    into a [sub-project][up1], but things weren't working and there
    were too many moving parts so we had to simplify by sticking
    closer to the example structure. we violate our "sub-project"
    structure in the interest of moving on, for now.

```sh
dst=.

src=z/scala-getting-started

echo "/project/project\n/project/target\n/target" >> "$dst/.gitignore"
  # (clean up the above in the file)

for i in "app" "conf" "project" "public" ; do
    echo cp -R "$src/$i" "$dst/$i"
    cp -R "$src/$i" "$dst/$i"
done

s=""
s="$s app.json"
s="$s build.sbt"
s="$s .env"
s="$s Procfile"
s="$s system.properties"

for i in $( print "$s" ) ; do
    echo cp "$src/$i" "$dst/$i"
    cp "$src/$i" "$dst/$i"
done

echo "(done.)"
```




## then, check out the scala starter project

    mkdir z  # if necessary
    cd z
    git clone https://github.com/heroku/scala-getting-started.git




## first, get `sbt` (the scala build tool)

(per [this scala doc][scala1])

    brew install sbt@1




## (appendix - these)

(these had been on the work stack; now we're archiving them #history-A.1)

|duration|title|
|--|--|
|04:15|Tutorial #30 - Create Custom Error Pages|
|06:50|Tutorial #29 - Make PUT Request using jQuery in Play Framework|
|08:52|Tutorial #28 - Make Delete Request using jQuery in Play Framework|
|13:27|Tutorial #27 - Form Validations in Play|
|10:15|Tutorial #26 - Update Views Part 2|
|08:37|Tutorial #25 - Update Views Part 1|
|03:43|Tutorial #24 - Include Bootstrap and jQuery in Play Framework|
|07:28|Tutorial #23 - Add Support For MySQL Database in Play Framework|
|08:50|Tutorial #22 - Update Book Model And Perform CRUD Operations in H2 Database|
|08:34|Tutorial #21 - Enable Ebean ORM & JDBC Support|
|07:12|Tutorial #20 - Refactoring Views Of BookStore Application|
|04:31|Tutorial #19 - in Java: Implement Delete Method of BookStore Application|
|04:46|Tutorial #18 - Implement Show Method of BookStore Application|
|04:19|Tutorial #17 - Implement Update Method of BookStore Application|
|05:32|Tutorial #16 - Implement Edit Method Of BookStore Application|
|05:30|Tutorial #15 - Implement Save Method Of BookStore Application|
|10:08|Tutorial #14 - Implement Create Method Of BookStore Application|
|05:06|Tutorial #13 - Index Method of BookStore Application|
|07:43|Tutorial #12 - Implement Book Model in Play Framework|




[heroku7]: https://devcenter.heroku.com/articles/how-heroku-works
[heroku1]: https://devcenter.heroku.com/articles/heroku-cli
[rando1]: https://github.com/orefalo/play-markdown
[scala1]: https://www.scala-sbt.org/
[up1]: ../README.md#sub-projects




## (document-meta)

  - #history-A.1: archive scala/play for now
  - #born.
