## this architecture


  + The cornerstone of the headless design pattern (let's say) is that
    things emit events from the same graph, regardless of modality.
    Exceptions to this guideline are possible but annoying.

all of this is experimental and exploratory.

  * root runtime has singletons
  * experimentally, error_emitter is used to emit validation errors

