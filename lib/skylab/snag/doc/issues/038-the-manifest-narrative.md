# the manifest narrative :[#038]

## new introduction

the horizontal rule divides the old from the new.

## objective

we fill a bit overwhelmed with a bit more than halfway to go in our
grand rewrite, not being very sure of the right steps to take, or where
all of the components *should* fit together. SO:

we will attempt "the 5-phase action spike technique". below is phase 1.
but first:


## pre-planning

broadly we can break the remaining work up (that we know of) into two
categories: reading nodes and writing nodes. for a curveball, we are
going to do the writing first before the reading because

  1) hypothetically writing has more moving parts than reading. we
     do the harder thing first? maybe laying down the industrial
     strength groundwork down first will set out a scalable husk
     for the easier thing to fall into.

  2) this way it's chronological: when we read we can read data that we
     know we could have written "in real life".

     spoiler: writing will have to read anyway, so hopefully reading
     will be a bit of an afterthought.

also, withing "writing" there are two important categories: "adding" vs.
"editing", to be expanded upon below.


## rough sketch of assuptions and introduction to components

for now, assume we are reading from a file but know that a primary design
objective is to modularize storage away from the model as much as is
optimal to do so. this said:

some "thing" (probably a silo) can be given an "upstream-" or
"downstream identifier". from this it can resolve a "collection", with
the possibility of expressive failure.

the collection (here) is a lightweight persistence-agnostic façade for
the persistence-modality-specific adapters for the common collection
verbs described in [ba], as implemented by sessions etc here.

also, the collection (here) is storage modality agnostic. some other
thing (the input adapter / output adapter?) will route the action calls
to sessions given the resource identifier.

-OR- the silo will manage a pool of cached somethings.

let's start with what we are doing first: an edit. let's say we want to
add a node to the collection. we don't know what "valid" means (yet) in
terms of the model object ("entity")..

random list of [components/operations] that we can probably [use/need]:

for edit, an edit session will have a "line upstream", holding the zero
or more lines existing in the line-based collection datastore.

  • a stream-like (but not just a common stream) that reads every line
    from a file, maybe knows its upstream identifier, but definitely knows
    its line number. definitely no random access. make this a session.
    probably needs to be able to process "signals" like for e.g of early
    realease of the resource (i.e closing the file). abstraction candidate.
    we will call this a :"line upstream".

  • an :"document edit session" is the higher-level component described here.

this edit session won't actually hold this line stream directly. rather:

  • a :"node stream" is the higher-level abstraction of a line stream.
    this too is not random-access: the nodes come at you in some
    arbitrary order that you can't control, but during which we may
    use the :+[#br-011] lexical-esque insertion strategy when relevant.


so, the edit session *adapter* knows that it's going to rewrite every
line of the file as-is except the changed lines. it does this through

  • a :"tempfile" that needs to be resolved.

so, for each node in the collection, compare the node's identifier

  • :"identifiers" (an agnostic model) need to be comparable,
    and incrementable by integer amounts.

to the node to be edited. if we are adding not editing. based on
perhaps some parameter, when adding, we will either:

  • add new node at the top [#xxx], creating  new identifier that is
    one greater that the greatest exiting identifer, and writing this
    new node to the top of the file -OR-

  • find the lowest unused identifier in the collection, inserting
    the new node in the appropriate place thru lexical-esque insertion -OR-

  • re-appropriate an existing identifier to this new node, "archiving"
    the previous message content with the special `#was` encloser.

Now, for document edit, there are three important cases to cover:

  1) add a node by re-appropriating an existing identifer

  2) add a node by allocating a new identifer

  3) edit an existing node


so, for 1) (add a node by re-appropriating if possible)

    lock the file

    find any existing re-appropriable node

    if a re-appropriable node was found

      archive this node (which is an in-memory operation altering its content)
      pre-pend the new node's content into the existing node
      notify the collection that this node was mutated

    otherwise

      give the new node an identifier by finding the first available node
      identifer given the dictionary
      add this node to the collection

    # etc w/ tempfile
    unlock the file

    here is how we find any existing re-appropriable node

      the criteria is that
      the node is tagged with "#done" or "#hole" and has
      no extended content

      for each of the zero or more nodes in the file

        if the current node matches the criteria

          memoize this node's identifer in a dictionary

          if there is no memoized node
            memoize this node
          otherwise
            with the number of deep "#was" tags that this node has compared
            to the memoized node
              if this node has less
                memoize this node
              otherwise if this node has the same amount
                if this node has an identifier that is lower than
                that of the memoized node
                  memoize this node


    the above has given you zero or one memoized node.
    this node (if any) has the lowest re-appropriable identifier

    here is how we find the first available node identifier

      from the lowest possible node identifer

        if the current identifier is in the dictionary
          increment the identifier and try again
        otherwise
          stop

    the above has given you the first available node identifier


    here is what a collection does when it gets notified that
    a node was mutated

       we assume the file is locked

       start a tempfile

       for each node in the collection
         if this node is the node
           memoize this node
           stop
         write the lines around this node to the tempfile

       if that node was found
         write the node to the tempfile
         for each remaining line in the collection
           write the line to the tempfile
         we did it
       otherwise
         erase the tempfile
         we are unable to persist the node because it was not found

    the above is what the collection does when etc


    here is how we add a node to the collection

      # (this is exactly :+[#br-011], perhaps flipped)

      start a tempfile

      for each node in the collection
        if this node greater than the node
          write the lines around this node to the tempfile
        otherwise
          memoize this node as the highest lower neighber
          stop

      write the node to the tempfile

      if we found a highest lower neighbor
        write the lines around it to a tempfile

      for each remaining line in the collection
        write it to the tempfile

      we did it





----------------------

## introduction

would that it needs any introduction



## #note-75

using a hacky regex, scan all msgs emitted by the file utils client and with
any string that looks like an aboslute path run it through a
proc (*of the modality client*, e.g). in turn, `call_digraph_listeners`
these messages as info to `info_event_p`, presumably to the same modality client.

this hack grants us the novelty of letting FileUtils render its own messages
(which it does heartily) while attempting possibly to mask full filenames for
security reasons. but at the end of day, it is still a hack




## (random historical)

from stack overflow #3024372, thank you molf for a tail-like
implementation if we ever need it.



## (historical introduction to the next section)

when you save a file in vi it appears to append a "\n" to the last line
if there was not one already. we follow suit here when rewriting the
manifest. however we leave the below commented out comments in place for
now in case we ever decide to revert back to the dumb way. but see the
next section:



## #line-terminators-versus-line-separators :[#020]

more broadly this has applicability to writing text file in general: we
may typically think of the newline sequence as a line "separator"; but
in fact in UNIX land (and perhaps more broadly than that) the newline
sequence is generally used as more of a line "terminator" than
"separator" [1][1]. the difference is subtle but important: wheras a
separator would separate lines, a terminator terminates every line,
including the last one.

from the manpage for the wc utility [2][2]

   A line is defined as a string of characters delimited by a <newline>
   character.  Characters beyond the final <newline> character will not
   be included in the line count.



### understanding the difference

consider a file whose contents consist of one character, the "\n"
newline character. when using "separator" semantics, this file could be
said to have two lines -- two empty strings separated by the separator.

whereas if we use terminator semantics, this file ("correctly") would be
said to have one line -- one empty string terminated by the terminator.

but then consider the null file, a file with no bytes. using separator
semantics we would say that this file has one item, the empty string.
wheras using terminator semantics the number of lines might be
considered to be zero (because there are no terminators).

but what about a file with one character (or more) and that character
(or characters) is not or do not contain the newline sequence anywhere
at all? using separator semantics we consider this file to have one
item, whereas using terminator semantics this file might be considered
to be invalid or undefined or have zero lines etc.



### as it pertains to the behavior we implement

where it matters we will typically implement a middle-groud behavior,
where we employ terminator (not separator) semantics, but in cases where
the trailing line item does not end in a newine sequence (that is, the
file does not end in a newline sequence), we still consider it a line
(and where it matters we will not automatically add the newline
sequence ourselves, and where it matters we might).



### references

[1]: see `man git-log`, near "the final entry of a single-line format
     will be properly terminated with a new line". the use of that term
     "proper" is taken to support our claim.

     also the behavior in editors like `vi` is taken as "evidence" that the
     terminator semantics are more conventional than separator semantics.

[2]: BSD `wc` February 23, 2005
