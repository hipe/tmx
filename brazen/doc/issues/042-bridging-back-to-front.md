# bridging back to front :[#042]


## introduction

this document will weigh the relative merits of the various operations
we have done to this end, in search of a good fit approach. design
vectors are:

  + something that is easy to grok in once glance, without a lot of API
    beyond what already exists and is well known (boxes).

  + something that can be made declarative or otherwise procedural.




## formal properties, actual values

currently the way this is done with the defaulting hack is ugly. it
would be more expressive to be able to put the values in the argument
box directly but this will require re-architecting so that ..
