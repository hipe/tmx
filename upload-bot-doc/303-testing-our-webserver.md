# testing our webserver

## freeform discussion re: `postman`

there was one or two passing references to [postman][postman] in various
slack app [examples][here1] but no solid intro to using it for this purpose.

postman seems to come out of a chrome-extension and GUI backgrounds
and has the feel of a small IDE rather than of a testing or mocking library.

let's see how it fares for us..




## run those tests

some [installation](#c) may be necessary.

now:

    ./node_modules/newman/bin/newman.js run upload_bot_test/test_700_web/test-100-intro.postman-collection.json




## <a name=installation></a>installation: postman requires newman requires npm

in order to get newman in a versioned way, we made our whole project a
node module:

    npm init .

then:

    npm install --local newman

to confirm, remarkably:

    ./node_modules/newman/bin/newman.js -h




[here1]: https://github.com/slackapi/Slack-Python-Onboarding-Tutorial/blob/master/README.md#documentation-for-tools
[postman]: https://www.getpostman.com


## (document-meta)

  - #pending-rename: maybe mention postman in the name now for consistency with sibling files
  - #born.
