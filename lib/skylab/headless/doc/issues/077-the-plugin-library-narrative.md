# the `initialize` method in plugin clients :[#077]

it makes life much easier for the plugin implementor to know that there
is no hidden magic specifically with the `initialize` method of her
plugin client class.

although there may or may not be magic with regards to including
automatcally our plugin client instance methods module to the given
client class, we hereby promise not to add an `initialize` to your
ancestor chain, neither in the plugin client instance methods nor
in any plugin client base class if we ever use one.
