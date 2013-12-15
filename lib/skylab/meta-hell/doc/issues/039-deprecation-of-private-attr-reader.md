# the deprecation of `private_attr_reader` :[#039]

(amusingly we deprecated this as we wrote it. we changed from 'p-rotected' to
'private' everywhere and suddenly found ourselves "needing" this.)

creating an attr reader in a private context of course triggers a warning.
typically the only reason we think we want such behavior is that we are
writing a module (not a class) and we want to detect in an API-private way
whether or not some ivar has been set yet, or whether or not some flag-like
ivar is true-ish; without the inline ugliness of `instance_variable_defined?`
and without triggering a warning. (as a module, we don't have the luxury of
having any guarantee about what methods ran before us, unlike a class that
has `initialize` (well yes, we could, but that never turns out well..))
(EDIT: wrong. ignore everything.)

thinking that you need such behavior is probably an indication that you
should not be using a module to house what you are doing but rather one or
more (smaller) dedicated classes. but this is a fundamental design issues
that is not a "quick-fix" so we opted for deprecation instead.

~
