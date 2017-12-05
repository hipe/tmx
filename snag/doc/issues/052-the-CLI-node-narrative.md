# the CLI node narrative :[#052]

(EDIT: ancient!)


## introdcution

notable things about it:
  + it itself is not a pub sub emitter - kiss
  + it's a franken-client of both legacy and headless,
      with latter trumping former. that it works is a testament to
      something, i'm not sure what
  + legacy DSL gets turned on below and that's when it hits the fan



## #storypoint-5

we "strictify" the existing interface.

we are straddling two f.w's: all we want is our (modality) calls to to
`call_digraph_listeners` to "work". we follow the [#sl-114] good standard
which among other things makes testing easier. Even though `legacy` gets
priority on the chain, it won't overwrite the (IO adapter-based)
`call_digraph_listeners` we get from [hl] which is good.




## :[#here.B]

just a debugging tool (#overhead) that was several hours in the making
(ok days). experimentally we will result in trueish if there *were* warnings,
and falseish if not (just to see how it reads)
