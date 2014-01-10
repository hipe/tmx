# the fixtures building narrative :[#017]


## introduction

we just spent six hours gleefully reading all about the zsh completion system
before realzing that it's pretty much useless for our puproses. sob.



## but why all the scripts?

a) they act as 'proof' that this thing works on 'real' output from the target
environemnt. they let us quarrantine & inspect edge cases. they are fun.



## why the change to zsh?

one goal of this mini-system is to allow the different nodes at different
levels to build however they want. so in fact we only changed to zsh at one
particular level. each sub-node's build script is spawned in a new process,
it is not merely sourced from the parent script; so each such build script
is not really a script at all per se, but an arbitrary executable. hence
the sub-nodes can use whatever technology they want. so we are not locked
into any particular shell per se.

(yes we had something in particular in mind)

but this avoids the question. we switched from bash to zsh first because our
model was the plugin "architecture" of "oh-my-zsh", and then we found this,
which we found compelling: http://spencertipping.com/posts/2013.0814.bash-is-irrecoverably-broken.html)



## #we-can-have-happiness: naming conventions in our zsh

an interesting dynamic has grown out of the fact that the custom zsh
functions we write all share the same global namespace: because we (nowadays)
like to write lots of small, straightforward functions with descriptive names,
we thought that our namespace would get hopelessly crowded unles we resorted
to an ugly convention of fully-qualified prefixes on all function names, and
we thought that we would never have happiness.

but then something occurred to us: given that we only have one namespace,
no matter where we are we must be aware of every name ever within our process.
but as long as we always chose the "correct" name for the function we are
writing, then it will always work out: whenever we chose a name for a function
and that name has already been taken, then we should either use that existnig
function or rename both of them! maybe this is why C has remained so popular
all of these decades.



## #pain-with-regexen-in-find

our manpage for `find` (from BSD, february 2008) explains an `-E` options,
yet the `find` on our system (whatever it is) supports no such option.
(and apparently the regex engine it uses is not of the extended variety -
there appears to be no support for the "kleene-plus" postfix operator '+' on
my `find`). the topic regex works on our system without the `-E` flag, but if
this ever causes pain we should switch to ruby for this, if for no other
reason than to reduce the number of dependencies.
