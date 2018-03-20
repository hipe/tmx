# grep dump

## objective & scope

  - expose "JSON dump" search thru a web interface
  - learn flask, React & related full stack




## development on the full stack

the stack breaks (logically if not physically) into the two parts of
frontend and backend. ([front-vs-back]).

currently the back is in python's flask and the front is in React.

to run the web app it is required (of course) to run the webserver.

whether or not you need to be running the server when you are working
on the backend depends on what you are doing: generaly you won't need
to - the backend is mostly implemented thru pure-python [#017]
"magnetics" (plain old functions) which generally won't interact
with the webserver in a highly coupled way.

when working on the frontend, you will often want to be running the
webserver but also one other process as well: the below process that
watches for changes in certain files and runs the web-pack build chain
as necessary.

(we use these [aliases](#aliases))


typically you always want to do this:

    cd «the root of the project (the git repo)»
    source ./my-venv/bin/activate

(this table is explained at [\[#018\]] developing under python.)
then in any order:


so that you can see the web application, run the webserver:

    py grep_dump/server.py

if the server is running OK you should be able to go to
`http://localhost:5000` in your browser to see the app.

when developing javascript etc, run the watch on the frontend files:

    cd grep_dump/static
    npm run watch

[front-vs-back]: https://twitter.com/PainPoint/status/966749439963508736




## the function of the test suite

  - the full test suite must pass at every commit to master (every "pull request").

  - currently we are *not* testing the web front but this is [\[#202\]](#202) in the works.

  - generally every major piece of backend work should take the form of
    a "magnetic" (a.k.a "magnet"), and every magnet should be covered.
    run these backend tests per the instructions [below](#running-backend-tests)




## <a name='running-backend-tests'></a>running backend tests


run one test file

    python3 grep_dump_test/ohai_010/test_010_ohai.py


run the whole test suite

    python3 -m unittest discover grep_dump_test


(what i actually do now is say `python` not `python3` (and use
virtualenv), and i set up these <a name='aliases'>aliases</a>:)

    alias py='python -W error::Warning::0'
    alias pud='py -m unittest discover'




## <a name="node-table"></a>the node table

(this table is explained at [\[#002\]] using the node table.)

| Id                        | Main Tag | Content
|---------------------------|:-----:|-
|                [#204]     |       | this one import issue is ugly for now
|                [#203]     |       | [code node]
|<a name=202></a>[#202]     | #open | enzyme/mocha tests for web front like [bedjango1]



[\[#018\]]: ../README.md#018
[\[#002\]]: ../README.md#002
[bedjango1]: http://www.bedjango.com/blog/how-to-build-web-app-react-redux-and-flask/




## (document meta)

  - #born.
