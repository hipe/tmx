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

  - currently we are *not* testing the web front but this is [\[#202\]](#202) in the works.

  - generally every major piece of backend work should take the form of
    a "magnetic" (a.k.a "magnet"), and every magnet should be covered.
    run these backend tests per the instructions [below](#running-backend-tests)




## <a name='running-backend-tests'></a>running backend tests

have [the particular version][018_pyver] of python installed.

have [activated our virtualenv](#venv-etc) as described above.

we use these <a name='aliases'>aliases</a>
(these lines are in our `~/.zshrc`, basically):

    alias py='python3 -W error::Warning::0'
    alias pud='py -m unittest discover'

to run one test file:

    py grep_dump_test/ohai_010/test_010_ohai.py -vvvf

(the options are optional)

to run the whole test suite:

    pud grep_dump_test -vvvf




## <a name="node-table"></a>the node table

(this table is explained at [\[#002\]] using the node table.)

| Id                        | Main Tag | Content
|---------------------------|:-----:|-
|                   [#207.C]| #open | hack for file touch
|                   [#207.B]| #open | secret key is in version control
|                [#204]     |       | (not sure what was intended with this)
|                [#203]     |       | [code node]
|<a name=202></a>[#202]     | #open | enzyme/mocha tests for web front like [bedjango1]




[018_pyver]: ../doc/118-installing-and-deploying-python.md#python-version
[\[#018\]]: ../README.md#018
[\[#002\]]: ../README.md#002


[bedjango1]: http://www.bedjango.com/blog/how-to-build-web-app-react-redux-and-flask/

[front-vs-back]: https://twitter.com/PainPoint/status/966749439963508736




## (document meta)

  - #born.
