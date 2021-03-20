# grep dump :[#201]

## objective & scope

  - expose "JSON dump" search thru a web interface
  - learn flask, React & related full stack




## development on the full stack

the stack breaks (logically if not physically) into the two parts of
frontend and backend. ([front-vs-back]).

although the boundary between where the backend ends and frontend begins
can seem artificial at times, these concepts serve to compartmentalize the
kinds of work we find ourselves doing in terms of what technologies we use
and how we develop under them.

currently the back is in python's flask and the front is in React.

to run the web app it is required (of course) to run the webserver.

details for under what circumstances and how you will want to work on these
two ends (variously) appear in the next two below sections; one for
[backend](#venv-etc) and one for [frontend](#d).




## <a name='venv-etc'></a>developing on the backend

whether or not you need to be running the server when you are working
on the backend depends on what you are doing: generally you won't need
to - the backend is mostly implemented thru pure-python [#019.3]
"magnetics" (plain old functions) which generally won't interact
with the webserver in a highly coupled way.

typically you always want to do this:

    cd «the root of the project (the git repo)»
    source ./my-venv/bin/activate

(this action is explained at [\[#018\]] developing under python.)

if you're just working on magnetics then typically all you will do
is write tests and asset code and [run those tests](#running-backend-tests)
as described below.

if you're (for example) integrating your backend work with the web
appliation then see the [next section](#d) about starting the web server.




## <a name=d></a>developing on the frontend

when working on the frontend, you will often want to be running the
webserver but also one other process as well: the below process that
watches for changes in certain files and runs the web-pack build chain
as necessary.

we will be using [these aliases](#aliases) described below. also we'll
assume you [activated the virtual environment](#venv-etc) as described above.

so that you can see the web application, run the webserver:

    py grep_dump/server.py

if the server is running OK you should be able to go to
`http://localhost:5000` in your browser to see the app.

when developing javascript etc, run the watch on the frontend files:

    cd grep_dump/static
    npm run watch


xx xx xx




## <a name=e></a>(notes about installing new react components)

xxx

    npm install --save react-progressbar.js




## the function of the test suite

  - the full test suite must pass at every commit to master (every "pull request").

  - currently we are *not* testing the web front but this is [#202] in the works.

  - generally every major piece of backend work should take the form of
    a "magnetic" (a.k.a "magnet"), and every magnet should be covered.
    run these backend tests per the instructions [below](#running-backend-tests)




## <a name='running-backend-tests'></a>running backend tests

have [the particular version][018_pyver] of python installed.

have [activated our virtualenv](#venv-etc) as described above.

we use these <a name='aliases'>aliases</a>
(these lines are in our `~/.zshrc`, basically):

    # alias py='python3 -W default::Warning::0'  at 3.8.0 this is annoying
    alias py=python3
    alias pud='py -m unittest discover'

to run one test file:

    py grep_dump_test/ohai_010/test_010_ohai.py -vvvf

(the options are optional)

to run the whole test suite:

    pud grep_dump_test -vvvf




## <a name="node-table"></a>the node table

(this table is explained at [\[#002\]] using the node table.)

| Id                        | Main Tag | Content |
|---------------------------|:-----:|---
| [#299.99] | #eg   | example
| [#219]    | #open | get main out of the bundle names #priority:0.40
| [#218]    | #open | get purple ranger etc out #after:[#219] #priority:0.45
| [#217]    | #open | mocked frontend for indexing #after:[#218] #priority:0.50
| [#216]    | #open | real backend for indexing #after:[#217] #priority:0.55
| [#215]    | #open | integrate with front #after:[#216] #priority:0.60
| [#214]    | #open | dummy ajax interface for "indexing" #after:[#215] #priority:0.65
| [#213]    | #open | implement & cover real backend for "indexing" #after:[#214] #priority:0.7
| [#212]    | #open | integrate (& redesign as necessary) full integration for indexing #after:[#213] #priority:0.75
| [#211]    | #open | integrate dummy story: no pagination, hard-coded limit #after:[#212] #priority:0.8
| [#210]    | #open | integrate dummy story: ajax-pagination YIKES #after:[#211] #priority:0.85
| [#209]    | #open | implement & cover real backend for search #after:[#210] #priority:0.9
| [#208]    | #open | integrate real search #after:[#209] #priority:0.95
|                   [#207.C]| #open | hack for file touch
|                   [#207.B]| #open | secret key is in version control
|                [#204]     |       | (not sure what was intended with this)
|                [#203]     |       | [code node]
| [#202]    | #open | enzyme/mocha tests for web front like [bedjango1]



### Historical note on some of the above issues:

A note on ~14 of the above issues: in a spike that occurred on #history-B.4,
these issues took only the last of several hops:

- First, they were originally housed in what is now the modern-day ".stack" file.
- Then they moved to a "roadmap"-style dotfile.
- Then (at cited historical moment) we sunsetted the dotfile and put the
  content of these items into this issues file.

We were able to move this issues to here (the "correctmost" place) because we
finally realized the "isomorphicism" where README.md-style issues can be
rendered to a GraphViz graph when they use the `#after` tag. See:

    python3 pho/cli/commands/issues.py graph --help

The items were conceived on these four dates: 2018 02-13, 02-19, 03-13, 03-21.
We have arranged them in the order they originally occured in the .todo file.

However, (and here is perhaps the main point of all this) we should see the
issues as mainly provided for historical context. The only objective for now
is to reproduce the list of items as they originally occurred (in the original
order with the original body-copy) as they existed some three years ago.

We will probably rearrange them, delete some etc in forthcoming commits.




[018_pyver]: ../doc/118-installing-and-deploying-python.md#python-version
[\[#018\]]: ../README.md#018
[\[#002\]]: ../README.md#002


[bedjango1]: http://www.bedjango.com/blog/how-to-build-web-app-react-redux-and-flask/

[front-vs-back]: https://twitter.com/PainPoint/status/966749439963508736




## (document meta)

  - #history-B.4: absorbed dotfile that had original creation dates of issues
  - #born.
