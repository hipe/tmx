# the CLI argument syntax DSL :[#107]


## :#storypoint-5 introduction

we have written few nodes that were documented so poorly, yet work so well,
and yet are so hard to decipher as this one. so this "article" is a bit of a
stub for now.



## :#storypoint-105 vertical vs. horizontal

we had some trouble reconstructing this one, so our understanding may be
faulty: imagine that a grammar (syntax) for arguments consists of non-
terminal symbols that are either of type "sequence" or type "alternation".
"sequence" means "this then this then this." "alternation" means
"this or this or this".

these two categories of nonterminal lay at the foundation of most theory
of grammars, according to me.

so let's say that at its root, every grammar's root node is of type
"sequence". the terms of this sequence (elements even) are aech either
terminal or nonterinal, and when nonterminal that element is either of
type "alternation" or type "sequence", and so on.

furthermore the terminal symbol can either be "required' or "optional"
(something that probably has a straightforward translation into the above
existing mechanisms but regardless).

for the sake of parsing arguments, among the kinds of parsing failures that
can can occur, there exist two that correspond to the two above categories of
nonterminal..


### case study to understand kinds of argument failure

let's imagine a pseudo grammar 'A B C' (that is, some 'A' followed by
some 'B' followed by some 'C', it is a sequence). we aren't going to care
right now whether A, B and C are terminals or nonterminals, but let's just
say for simplicity's sake that the are the literal (terminals) "A", "B"
and "C" (the strings).

then let's say our input argv is ("A", "D"). it will parse the "A" ok, but
when it gets to the spot between "A" and "D", the parse in this state is
expecting a "B" but has a "D". it does not want the "D". just keep that
in mind for a second..


### case study 2 (case study 1 is on the side-burner)

now let's imagine a different grammar that is "A" { "B" | "C" }. so that is
the literal string "A" followed by one of "B" or "C". there are only two
valid inputs to satisfy this grammar: ("A", "B") and ("A", "C"). any other
permutations you might be thinking of are invalid. (invalid: "A", "B", "C".
invalid: "A". invalid: "A", "B", "B", invalid: "C").

again let's imagine that the input here is ("A", "D"). again it gets passed
the "A" but does want want the "D". keep that in mind as we attempt ..


### synthesis

for the first case, we want to report something like

    unexpected argument "D". expecting "B""

for the second case, we want something like

    unexpected argument "D". expecting "B" or "C"


all I can say for now is that the former kind we call "vertical" and the
latter kind we call "horizontal". i don't remember how it got that way;
i think it has to do with if you imagine a grammar as a tree and you imagine
that the branches on that tree represent alternation nonterminal nodes, then
it is the alternations that branch out *horizontally* (because, whether they
grow downwards like in computer science, or upwards as in nature; these trees
all grow up and down. NBA playoff brackets, those kind of trees grow laterally,
and this why I don't follow basketball.)

(hmm in order for the vertical axis to represent sequence nodes as it does
in this vocabulary, such nonterminals would not be nodes of the tree, but like
the length of the logs and sticks that make up the tree; or something. this
will have to be drawn out in ascii art to be proven rigorously.)
