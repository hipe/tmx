# thoughts on expression frames :[#034]

## introduction

the idea here is that we get linear, natural-language-esque output
("expression") from structured, nonlinear input ("ideas"). the inuput:

    :object, 'correct',
    :subject, 'that'

might produce:

    "that is correct"

note several things already:

   1) the order of the terms with respect to each other does not matter,
      (but for those terms that take arguments the argument must follow
      immediately the name).

   2) we can pass freeform strings as arguments to these terms. the
      pronoun "that" has already been inflected by the human in this
      case.

   3) we abuse the idea of "object" - the argument is not an object
      noun phrase, it is an adjective. here we have a loose treatment
      of this syntactic category.

   4) when we are given a "subject" and an "object", the system assumes
      they are related. a verb is typically chosen (somehow) to express
      this relationship. in such cases where an object and subject are
      provided and no verb is indicated, the copula ("to be", that is, "is")
      is made as a default assumption, so it need not be provided explicitly
      (but we will show a `verb` parameter below).


watch how we put a slightly more refined set of "ideas" together to get a
different expression:

    :object, 'correct', :subject, 'that', :past

might produce:

    "that was correct"

we can exploit the loosey-goosey nature of this 'object' term to use it
as an adverbial phrase:

    :negative, :noun, 'he', :object, 'here'  # => "he is not not here"

note that `negative` is a standalone term (or "keyword", that is, its
formal property has an argument arity of zero). as stated above, terms
are order-insensitive with respect to each other, so this keyword
`negative` can appear anywhere in the arguments (provided it doesn't
break apart other terms). it is not the case that it modifies this or
that particular term, so:


    :object, 'here', :noun, 'he', :negative  # => [ same ]

but:

    :object, 'here', :noun, :negative, 'he'  # => [ undefined ]

## correctness

"correctness" is not a classification we apply to expressions (yet).
classifications we apply to expressions:

    • complete-ness

(ETC)




## context of implementation

this is similar in spirit to #[#054] list expression, but different
enough in interface that we neither borrow from thar nor intend to merge
that effort into this one (for now). it may be that some expression
frames in this facility will use that one for their implementation, but
that is an implementation detail for each frame to decide.




## corollary of the central mechanic

the central mechanic (described below) has an intentional and
interesting behavioral by-product: the relationship between constituency
(the arguments provided) and the syntactic category produced is not a
strong one (experimentally).

the idea is that whether on the surface the particular constituency of
ideas is expressed as a noun phrase ("the out of work developer",
"the developer, out of work", "the developer, who is out of work")
or a sentence phrase ("the developer is out of work"); these decisions
are seen as tactical and pragmatic (as well as there begin important
vectors of expression that go into these decisions). this stands in
contrast to the reasonable assumption one might make that such decisions
should be a function of the constituency alone.

that is to say, whether a contituency of ideas should be expressed as a
noun phrase, as one sentence or as several; etc is seen as something to
be determined largely by context. (which is a facility we will probably
model as an adjunct and tightly coupled facility to this one described
here.)

indeed as speakers or writers we may see these as issues of style. it is
this "sense of style" that we are trying to bottle and sell.




## the central mechanic

the "value algorithm" that this facility offers is: [ selection of frame ]
