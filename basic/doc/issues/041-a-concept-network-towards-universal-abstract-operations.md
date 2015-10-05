# a concept network towards universal abstract operations :[#041]

## synopsis

we define what is meant by "universal abstract operations", and then
present a logical ontology intended to support the expression of same,
and then define several instances of them.




## objectives

we want to be able to refer unabiguously to certain kinds of
"operations"..




## conventions in this document

in the spirit but not the letter of of [#sg-056] hashtags, we experiment
with a custom notation in this document:

a key concept in this document is a .. concept that for lack of a better
term we will call .. "concept".

we will frequently use the term "term" in a way that may make it seem to
have the same meaning as "concept", but in this document, it does not
quite:

"term" and "concept" are not two terms for the same concept. like
Ferdinand de Saussure's [citation needed] duality of "signs" and
"referrants", we use the one to indicate the other. however in practice
this distinction may not have particular value to our objectives.




### missing antecedents

concepts without meaning are meaningless, and so in this document it is
our goal to define (in natural language, yet somehow "formally") all
"concepts" that we present.

ignoring the interesting question of whether or not it is absolutely
necessary to do so, at times we will use a "term" before it has been
"defined".

  • in such cases that a term is being used before it is defined,
    the term will *always* have double quotes around it.

  • however sometimes (but not always) we will use double quotes on
    terms even after they have been defined.

  • as well, we will use double quotes naturally in the way that they
    are used in the host written natural language.

so at present there is no formal, unambiguous notation in use for terms
being used as referrants to concepts that have not yet been defined,
other than we use quotes whenever (but not IFF) we do this.




### definitions

when a term is defined [pseudo-]formally here, the term will appear
surrounded by double quotes and immediately preceded by a colon (with no
interceding space). the doulbe quotes are used always, even when the
term is only one word long.

the natural language containing the [pseudo-]formal definition of the
term will appear either immediately before, immediately after, or
surrounding the notated term; as will be obvious by the formatting of
the copy.

this notation allows formal definitions to be presented in-line with
natural language without interrupting its flow.

for example:

  • :"some term" is a wizz banger.

  • we call a thing that does blah blah a :"hoofus doofus".

above, note that the terms don't always appear before their definitions.
note to that the bullets are cosmetic.

  • :"a second colon": means nothing. it is also comsmetic.

  • :"concept", :"term" - we sometimes these two interchangeably.

in the above bullet, to terms are given the same definition. note
however that the comma and dash that we used have no formal rules
governing their use.

this pattern is certainly subject to change.

if it looks strange, please bear in mind that this notation is valuable
to us precisely because it never occurs "naturally" in the host written
language, and so this pattern (although simple) is unambiguous, making
it easy to search for definitons of particular terms.




## introduction: a networks of concepts in support of "UAO's"

our objective is to be able to refer unambigously to certain "classes"
of operation. to give this this concept a name and a face, it needs a
dedicated term that will not be confused with pre-existing terms either
inside our outside of our bubble universe here. as such:


  • :"univeral abstract operations" is/are what we are
      defining here in the subject document. we may use the term
      :"UAO" for this too.

    * every UAO will have a single, unambiguos name. this name
      will consist of a series of one or more "words" separated
      by a single space, where a "word" is one or more of [a-z] (that
      is, no numbers, no puncation, no capital letters).

      the UAO's name will always appear in double quotes, even when
      it is only one word long (although this convention is subject to
      change).


it is assumed that the "platform" we are working in will have some
equivalent concept of "methods" and "formal arguments" to those methods:


  • :"platform": e.g the particular host programming language.

  • :"method", :"formal arguments" - we mean these in the usual sense
      of how they are used in the context of programming languages.
      although "method" is a term (and concept!) with meaning specific
      to object-oriented languages, OOP certainly does not confine the
      scope of the the ontology we are presenting in the topic document.

  • :"coroutine"..

  • :"shape"..

  • :"recommended"



## some "universal abstract operations" defined


  • UAO:"fetch": an instance of this UAO is for retrieving an existing
      constituent "item" from the receiver "container". the
      implementation must accept one required argument "key" that is
      of any shape (including nil), and one optional coroutine argument
      "coroutine". (the accepting of this argument is not optional,
      the passing of it is.)

      this opertion is received by a "container". if the container
      "has" the "item" referred to by the "key", the result is the
      item.

      if the container does not have an item referred to by the key,
      the result is determined by the particular presence or absence of
      the coroutine: if present, the result is the result of calling
      the coroutine with no arguments. if absent, the result is
      undefined (but it is "recommended" that an exception be thrown).




  • UAO:"add": an instance of this UAO is for adding one "item" to
      the receiver "container". the UAO accepts exactly two arguments:
      a "key" (whose shape may be constrained by the receiver pursuant
      to its implemented behavior), and an "item" (whose shape again may
      be but is not necessarily constrained by the receiver).

      if the receiver collection does not already "have" an item under
      this "key", the receiver collection is mutated: it adds the item
      to itself by the key.

      it is recommended that the item receive no messages during this
      operation.

      if the receiver already has an item with this key, the result
      and behavior is undefined but it is "recommended" that an exception
      be thrown.




  • UAO:"remove": an instance of this UAO is for removing an existing
      constituent "item" from the receiver "container". the
      implementation must accept one argument "key" and one optional
      argument "coroutine". (the accepting of this argument is not
      optional, the passing of it is.)

      if the receiver container "has" the item referred to by the key,
      the container is mutated: the association is deleted, i.e the
      item is removed from the collection. the result is the removed
      item.

      otherwise (when the receiver container does not have an
      association under the argument key), the result and behavior
      depends on the particular presence or absence of the coroutine: if
      present the coroutine is called with no arguments. if absent, the
      behavior and result is undefined, but it is recommended that an
      exception be thrown.

(there are terms in the above that are as yet not defined formally here.)
