# the API narrative :[#006]

## introduction

at the time of this writing the API "client" is conceived of as a
would-be long-running (daemon-like) process that would possibly serve
serveral clients in tandem.

its two main functions are 1) in a config stack it may serve as the
lowest frame, that is the last-line-of-defense defaults for business
constants or configuration values.

2) it provides the "models" shell, which in turn provides shells with
which the clients may make controllers, collections or collection
controllers etc.

externally there is both the 'API' module and a class 'Client' within
that module. internally they are the same class for one reason of
convenience but this is subject to change.


the primacy of the API client is evinced by the arguments to its
constructor: it is built only with a reference to the toplevel business
application module and nothing else (no references to system resources
like stdout, no configuration files etc).




## :#note-25

keep the new name function from infecting upwards passed this point



keeping for #posterity, primordial boxxy:

    path.reduce(self.class) { |m, s| m.const_get(constantize(s)) }.new(self)
