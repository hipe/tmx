# grep dump

## objective & scope

  - expose "JSON dump" search thru a web interface
  - learn flask, React & related full stack




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
virtualenv), and i set up these aliases:)

    alias py='python -W error::Warning::0'
    alias pud='py -m unittest discover'




## <a name="node-table"></a>the node table

(this table is explained at [\[#002\]] using the node table.)

| Id                        | Main Tag | Content
|---------------------------|:-----:|-
|                [#204]     |       | this one import issue is ugly for now
|<a name=202></a>[\[#202\]] | #open | enzyme/mocha tests for web front like [bedjango1]



[\[#002\]]: ../README.md#002
[bedjango1]: http://www.bedjango.com/blog/how-to-build-web-app-react-redux-and-flask/




## (document meta)

  - #born.
