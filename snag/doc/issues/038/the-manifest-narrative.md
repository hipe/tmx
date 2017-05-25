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
or more lines existing in the line-based collection collection.

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


## on locking (:#note-35) and related concerns

### what do we mean by "mutating" the collection?

let a node collection "mutation" be this:

  1) there is a node collection that can give us a node upstream:

     • as much as possible we should avoid knowing where this
       collection came from (that is, its modality, i.e how or if
       it is stored).

     • the node upstream this collection can give us can yield each
       of its nodes one by one, in a particular order decided by the
       modality that is mostly meaningless to us.

     • we do not have random access to the collection behind this
       stream. we can only rewind the stream to start the reading
       over from the beginning.

  2) at some point we will have some or all of a node that represents
     a "new" node we want to add or a presumed existing node that
     based on ID we want to edit (actually, replace), or a node to
     remove.

  3) we effect the collection "mutation" by writing from beginning to
     end our new, modified collection as a stream to some given
     modality. so note there is really no direct way that we
     "mutate" the "collection"; we really just write functions that
     help output our desired collection, given an input collection.

this is what is meant by "mutation" is the sometimes parallel process
of reading from an upstream and writing to a downstream, with whatever
filters we write in between.




### we face special challenges in certain modalities

when working with collection "mutations" under the "byte stream"
modality, under certain conditions we have extra work to: both upstream
and downstream can be but are not necessarily files.

problems when the upstreams and/or downstreams are files:

  1) if the upstream is a file, if it were to get mutated by another
     process while we are reading from it, that would be problematic.

  2) if the downstream is a file, we (of course) want no other process
     to write to it while we are writing to it.

  3) if the upstream and downstream are both files and both the same
     file (which is the typical case), despite the `RDWR` mode we have
     no idea whether and how this would work.




### how we face problem (3)

we can write our "mutated" collection to a tmpfile and once this is
complete we can replace the main file with the tmpfile. writing the whole
collection to an intermediate tmpfile solves two problems:

  • it is the only reasonably feasible way we have come up with to get
    around (3) above, the issue with reading from and simultaneously
    mutating the same file.

  • writing to an intermediate tmpfile can help us avoid (but does not
    prevent) accidental corruption or loss of ** ALL THE DATA **, if
    for example any error is encountered anywhere during the operation.
    (this has certainly happened in the past, so we have always used
     tmpfiles for "production" cases).

*however*, using an intermediate tmpfile may counteract the desired
mechanic based on what the downstream identifier is: specifically, if
the downstream is something like a pipe, some arbitrary open IO handle,
or even a simple string; then writing to the intermediate tmpfile itself
may introduce its own problems:

  • it may effect more moving parts than were intended (e.g it would
    require access to resources like filesystem that it does not have
    and does not need, given its operating environment and its
    particular upstream and downstream shapes; respectively.)

  • if the downstream is something like an open IO handle (or even a file
    that is intended to be tailed), it may be that progressive, streaming
    throughput is desired.

  • if the downstream IO is something as simple as a string, including
    an intermediate tmpfile in this pipeline is awkward at best.

we will pick back up with tmpfiles in our stirring conclusion below.




### how we face problems (1) & (2) and sythesize the rest:

DURING the entire "muation session":

  • IFF the upstream is a file (path) or filehandle, try to get a lock
    on it. see appendix A for how to try to get this lock and what to
    do in the else-case.

  • likewise with the downstream, exactly as the previous bullet.

  • this is something of a design choice, but for now let's say we'll
    use the intermediate tmpfile IFF the upstream and downstream are
    both file-based and (as far as we can tell) the same file. leave
    open an upgrade path if we decide to make this an option. but as-is,
    this is a solution for the tmpfile-related issues raised in the
    previous section. (:#note-80)



### appendix A - how to do lockfiles (:#note-65)

because concurrency is something we want to build for but is not
something we need on the ground floor, we request locks on filehandles
with passing the "nonblock" bit turned on. this way if the file is busy
we fail right away rather than blocking (perhaps for a long time)
waiting for the file to become available. other options would include
waiting indefinitely or waiting with a timeout.


----------------------


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
"separator" [1][1]. the difference is subtle but important: whereas a
separator would separate lines, a terminator terminates every line,
including the last one.

from the manpage for the `wc` utility [2][2],

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
