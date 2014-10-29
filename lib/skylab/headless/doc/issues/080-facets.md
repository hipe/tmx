# facets are.. :[#080]

(#todo between [#fa-025] and this one will assimilate the other.)

facets are like inversion of control / dependency injection 'plugins', but
not always as clean. we leverage ruby's re-openable classes for dependency
injection. sometimes they are loaded (in different files) dynamically,
sometimes multiple facets are defined in one file. `facets` are as much
logical as they are physical.

(this is all just a fancy way of saying "we break files into sections".)

one advantage of breaking a file up into facets is that it can make top-down
narratives [#058] more focused and readable. often it is the case that in
order to add a feature, we need to touch a series of several clases in a
certain way. for each new feature we add, we often touch a subset of these
same classes. it makes more sense from a narrative standpoint to keep these
changes grouped by feature rather than grouped by class.

another advantage launches from the first - if the times comes to "break out"
the feature in any of a number of ways, it is of immense help to have the
feature-specific changes all collected together in one place already.
