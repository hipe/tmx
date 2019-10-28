---
title: extra conventional conventions
date: 2018-01-22T23:45:57-05:00
---
## objective & scope

for any given programming language we will encounter, there will exist
conventions (either formal or practical, ideally both) that govern
things like how spacing is used and how named components are named (in
terms of things like capitalization and use of underscores); to whatever
extent is not already dictated by the syntax of the language.

for any given language that we employ in this project (the "platform
language"), we will draw first from that existing ecosystem of conventions
before we effect our own.

(#open [#007.D] it is a known issue that our older python violates PEP8.)

this document, then, is for those conventions that we employ *beyond*
what is proscribed by the existing culture(s).

at present, this covers our use of python but it may broaden it to include
any other utilized languages as necesssary.

(to restate somewhat (and put a finer point on it), we attempt to follow
the general python conventions (as proscribed by "PEP"'s and so on) to the
extent that we are aware of them. where any convention here conflicts with
those in the existing culture, we should probably correct them here.)




## brief overview/TOC

we've got:

  - [paranoiacally-private method names](#c)
  - [broadly utilized class-name conventions refined](#d)
  - [project-private method names](#e)
  - [regression-friendly test ordering][#6]




## <a name=c></a>the name convention for paranoiacally-private method names

### synopsis/scope

this convention is utilized by classes that for one reason or another want
to guarantee "paranoiacally private" methods. as it works out, this tends
to be not needed by most classes, as we'll explore in [the next major section](#d).



### how

for the equivalent of truly private methods, we name them like this:

          __name_the_method_like_this__FOO


the significant components of this are:

          __name_the_method_like_this__FOO
          ^                          ^  ^
          |                          |   \
          |                          |    +- the module "sigil" here
          |                          |
    two leading spaces         two spaces here


the module "sigil" is any string of two or more letters [A-Z] that (as a
string) are unique to the project (and in effect "belong to" the file),
for all conceivable inheritence chains.

for example: at the moment our sigil for `helper_for_generic_CLIs` is
"CLI", because although there will be other modules related to CLI, we
will ensure that for any given inheritence chain, of the classes in that
chain, those that come from a module with the sigil "CLI" will all be
from the same module (whew).



### why

the TL;DR: is: "because python's not java". the details:

in order to explain the problem this convention aims to solve (the "design
objective"), consider these axioms and some interceding corollaries:

  - whether or not it's built-in to the language, in practice any module
    (think "file") may have classes (e.g mixin modules) that are part of
    its public API, and others that are not. for parsimony we'll refer to
    these simply as "public" and "private" classes respectively. (although,
    what we're calling "private" is perhaps more akin to java's "package"
    visibility, maybe. more on this in [the next major section](#d).)

  - this convention is *not* useful (so, not applicable) to private
    classes (more [below](#d)), so for those you can ignore everything
    about this convention.

  - private *methods* (practical or formal) help to make the intent
    of code clearer, and help to make it more self-documenting.

  - creating private methods (again practical or formal) is part of the
    normal flow of improving and refactoring classes.

  - however, the platform language (here python) does not support private
    methods formally.

  - either rigidly or casually, the broad ecosystem around the platform
    language encourages methods (viz members) that are (for practical
    purposes) private to be named `_like_this`.

  - (as an aside: the lack of formal recognition for (this sense of)
    "private-ness", *and* the proxy for it being `_this_convention`; both of
    these can be seen bleeding across all the cultures of perl, python,
    ruby, and others. conventions with similar semantics are employed in
    C cultures (albeit non-OOP such as they are).)

so, what does all this have to do with our use of the convention in python?
consider this:

if a class subclasses another class or mixes in a mixin, and that class
names its private methods `_like_this`, that class has no guarantee that
this name won't collide with a same-named method in a parent [class] that
it does not intend to override.

this potential conflict could cause bugs that are hard to track down.
not only does this hold for the present, but it holds indefinitely into the
future, which is to say your code is not as future-proof as it could be.

our antidote to this is to say that for practical purposes we should know
whether or not we intend for a class to serve as a base for other classes
outside of our module (file), and when it does we must give the client
the full reign to the namespace of methods named `_like_this`. (java solves
this problem by giving each class (and similar) its own private method
namespace, but we don't have mixed luxury of java here.)

by naming our applicable private methods `__like_this__FOO`, we can
"guarantee" to be safeguarded against this problem (provided that all
participating code .. participates).



### practical considerations

this is one reason (but not the only one) why you see some cultures
(ObjC/Cocoa, swift) advocating for "composition over inheritence"; that is,
avoiding inheritence altogether.

in our own code we avoid subclasssing almost as a rule, except:

  - where the use of the class makes it almost more like a DSL (for
    example, our [#502] agnostic parameter modeling API).

  - in test code, where "test case" base classes and helper mixings
    make the code (again) approach something like a DSL. (a bit more
    on this [below](#e.2).)




## <a name=d></a>broadly utilized class-name conventions refined

if you say a class is "part of" a public API, what does that mean exactly?

  - does it mean that the class can serve as a base class for client code
    to descend child classes from?

  - alternately, does it mean that client code will construct objects of
    the class directly, but that the class is not intended to serve as a
    base class to be extended (a visibility that java uses the keyword
    `final` for)?

  - or alternately (again), does it mean that the client code should *not*
    construct the class directly, but will somehow come into contact with
    instances of this class?

by our conventions, a class named `LikeThis` falls into the first category,
unless it is stated in the *first line* of its docstring that it is final
(with the word `final`), in which case it's in the second category.

this leaves the third category, for which we use the (broadly recognized)
convention of classes named `_LikeThis`. to restate:

  - a class that is subclassable and otherwise part of the public API
    is named `LikeThis` (except for what is explained in the next bullet).

  - a class that is part of the public API but is would-be `final` also
    uses the `LikeThis` convention, but its final-ness must be specified
    in the first line of its docstring.

  - any class named `_LikeThis` must *not* be constructed directly or
    subclassed by client code. (as for what the owning module (file) does
    with a class named like this, that is up to the module.)

given all the above, the concerns raised in [the above section](#c) about
how to name private methods should only pertain to classes in the first
category and exposed mixins (the distinction begin a soft one in python).




## <a name=e></a>name convention for project-private method names

### what

this convention exists mainly to ameliorate refactoring.

"project-private" is a level of visibility we made up. it might (again)
be akin to java's `package` visibility, but it has particular semantics
we delineate here.



### how

name your project-private methods `like_this_`.  that is, lowercase
with underscores, no leading underscores, and *one* trailing underscore.



### why

this perhaps weird-looking convention exists mainly as an optimization
for refactoring. the qualifications necessary to employ this convention
are all of:

  1. this method is *not* part of the public API of the project (in the
     [semver] sense).

  1. this method *is* tied to various points within the project. (more
     formally, that the set of all files that either call or define
     the method (or both) is a set of files greater than one in size.)

the purpose of conventions like this is so that at a glance one can get
a sense for the relative cost of changing the method (variously in terms
of name, signature, behavior, deleting the method; etc).

because the method is not part of your public API (in the [semver] sense),
you do not have to bump your version number when you change the method.

however, to change the method *will* impact your "whole" project (for
definitions of); so you should consider that impact when you consider
the cost of changing the method.



### <a name="e.2"></a>in practice

in practice we don't use this convention as often as its "qualifications"
may suggest. typically we only use it when we really want to highlight to
ourselves that the method is not [yet] part of our public API, but that
the method (in terms of definitions and/or calls) leaves a footprint larger
than just the file you are looking at.

as it works out, we often see this convention used in test support module
methods ("helpers") and their client code (the test classes). this is
because typically helpers have lots of short methods meant to be called by
the test classes, and conversely test classes (and collaborators) frequently
need to implement methods ("hook-in methods") to participate with the
helpers. the kinship between test *files* and test *support* files is often
tighter than kinships between files elsewhere; and the use of this
convention aims to highlight that kinship where it holds.




## <a name="6"></a>regression-friendly ordering (testing)

this article is a stub and you can help expand it. probably what we
will do is refer to articles in #[#008.10] that-other-project. #edit [#010.B]




## <a name="7"></a>case numbers

(in its own file adjacent to this one.)




[semver]: http://semver.org

## (document-meta)

  - this document is identified by `:[#010]` (without the colon)
  - #born
