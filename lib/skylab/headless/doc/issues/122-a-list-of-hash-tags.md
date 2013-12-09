# a list of hash tags and their tentative meanings :[#122]


• #comport, #hook-in, #hook-out

#comport should probably be replaced with '#hook-out' or '#hook-in' as
appropriate. the tags in this family each take one argument: a string
describing a subsystem or otherwise some library or node.

 •• a #hook-in means to override a method recognized and used by the library
    to acheive some behavior effect / customization. unlike a #hook-out,
    if you fail to do a #hook-in the system may still operate (maybe).
 •• a #hook-out is a method defintion required by that library to work,
    that in some way defined the desired behavior for your client or
    provides a necessary object for whose creation your client is responsible.
    the difference between this and a #hook-in may be a bit semantic, but
    generally a #hook-out is "required", and failure to provide one will
    typically result in a run-time error.

tagging methods with #hook-out/#hook-in as appropriate is crucial in
understanding the narrative and in knowing what can be refactored and what
cannot. also it can be used in an inverted direction to determine the
dependency distribution for certain libraries or perhaps even their
particular hook-out-able and hook-in-able methods.


• #hook-in: see #comport.
• #hook-out: see #comport.

• #orphage: this long-sought after term describes perfectly this pattern:
we don't like to "bother" creating a whole new file that will have to load
if it is only say 25 lines or less. regarless of the filesystem "overhead",
just as importantly is that we don't like the feeling of opening a file
just to find a piddly small number of e.g officious or uninteresting lines
that are just there because they have to be. it makes us sad.

this tag, then, is used to demarcate a top-level section within a file.
when we see it we know exacty what we wil find in that section: small
defintiions for child nodes that would otherwise be in child files.


•• discussion of "stowaway"

we used to tag the "orphans" once they were moved into a parent node as
'#stowaway', and even named an method in the autoloader API after this.
this is up for review:

formally, an 'orphan' technically means any "short" file (with a node in it).
an "orhpanage" is the content that would otherwise be in one or more short
files (but note that formally an orphanage does not actually contain orphans
because they cease to be orphans once they are in an orphanage, but this is
splitting hairs).

a "stowaway" is any node in any file other that the file it "should" be in per
its name. by these definitions, an orphanage consists only of stowaways, and
there is no intersect between on the one hand orphans and on the other hand
stowaways or orphanages.

one sentence that covers it all is 'orphans should be turned into stowaways
in orphanages.' it breaks the analogies a bit but it a neglibible offense:
after all these are just tags and clearly their names evolve all the time.


• #stowaway: see #orphanage.
