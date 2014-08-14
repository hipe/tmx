# the CLI node narrative :[#052]


## #storypoint-5

we "strictify" the existing interface.

we are straddling two f.w's: all we want is our (modality) calls to to
`call_digraph_listeners` to "work". we follow the [#sl-114] good standard
which among other things makes testing easier. Even though `legacy` gets
priority on the chain, it won't overwrite the (IO adapter-based)
`call_digraph_listeners` we get from [hl] which is good.
