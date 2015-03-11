# the CLI client narrative :[#006]


## :#storypoint-40

it's ugly to hard-code mocking awareness into this top client, but let's
consider the alterantives:

• if you had a singleton-like propery of a class that you overrode, it would
  have problem

• we don't want any mock awareness in the middle (in the API, or the VCS
  adapter).

we can keep mock-awareness out of the middle because the API takes a lot of
parameters.
