# the bundle narrative :[#002]


## :#storypoint-110 the way bundle name resolution works

### bundle "storage" names as const names

every typical bundle (as implemented by this library) has at least two names.
these names are derivaties of each other. to understand how the typical bundle
names work it helps to understand that typical bundles are stored as
constants in a module (and incidentally they are usually implemented either as
a proc or like a module that is shaped sort of like a proc).

we were guided to this choice by parsimony (although it took some getting
there.) this same principle leads us to use the module name (more specificaly
the const namee) to constitute the name of the bundle.

constants in ruby must follow the name-pattern of (something like)
/^[A-Z][A-Za-z0-9_]+$/. as stated above, the bundle gets its name from the
const name, so this pattern also dictates how we may name our bundles.

### bundle "employment" names are const names un-title-cased

however when a client wishes to employ a bundle, it does not typically use
this (const) name. it is designed like so both for aesthetics and for the
sake of implementation hiding: the client module musn't have knowledge of the
particulars of the way the bundles are implemented; that's the whole point of
using them.

currently the logic is this: typically your bundle's "storage" name (that is,
the const name) is two or more characters long and the second character is not
a capital letter (or weirdly the name is one character long, but don't do
this). in such a case, the "employment" name (that is, the name by which the
bundle is referenced to be employed) is simply the storage name with the
first character (necessarily in uppercase) downcased.

we typically use underscores instead of camel-casing to demarcate mutli-termed
names because no sophisticated regexp logic is employed to translate the
name:

so if the const name is 'Magical_methods', the "employment" name is
'magical_methods'. if it's 'WiERD_NAME', it becomes 'wiERD_NAME'. with this
scheme you simply cannot have an employment name that is title-cased:
'Sly_Fox' becomes 'sly_Fox'.

### a special exception for TLA's

however, if your bundle is stored under a const name that is 2 characters or
longer and the second character is a capital letter [A-Z], then we assume that
the first term of the name is something like a TLA (a three letter acronym):
so, if the const name is 'NSCA_spy', we assume that all those letters are to
remain capitalized when it in the "employment" name. in such cases, to derive
the employement name we use the storage name as-is.

### conclusion & implementation

this deceivingly simple name translation scheme somehow garnished a page-long
description. but the uptake is, employment names look sort of like constant
names, and whether or not they are exactly the same as the constant name is
determined by the case of the second character of the constant name.

we used to provide this #hook-in, but it was removed due to a total absence of
distribution in the current branch:

    k = if x.respond_to? :bundles_key then x.bundles_key

because the name translation rules are deterministic and we do no fuzzy
matching, we eagerly pre-calculate the employment names for each of the
bundles and cache an index of them this way. we do this with the expectation
that there is a greater number of bundle employments than there are bundles,
and as such it would feel wasteful to re-calculate name translations for the
same bundle name multiple times.

so what you are seeing at the code-point is this indexing being calculated.
