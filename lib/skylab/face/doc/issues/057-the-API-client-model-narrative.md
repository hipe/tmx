# the API client model narrative :[#057]


## :#intro

the API Client having model facilities is opt-in, and for now activated by
calling the below enhancment method(s).

this is designed to be #idempotent: each additional time the below logic is
run on the same API client class, it should have no additional side-effects.



## :#storypoint-30

part of our underlying plugin API - this is what implements calls to `host[]`
from e.g inside the models.

the plugin story is ignored because we do not validate access - we do not
require that plugins (e.g models) declare what models they want to access,
with the reasoning that it will be clunky to need to list every name of every
model that every other model wants access to, but this may change.

on this subject, this is related to why we don't have pretty accessor methods
for the model names, (e.g we have `host[:config]`, not `host.config`) so we do
not need to eager load our entire model.


# #storypoint-35

called from host proxy - a service we expose to model clients - note the
signature change.


# #storypoint-40

signuature might change. this is a service used by clients that employ the
face API model API
