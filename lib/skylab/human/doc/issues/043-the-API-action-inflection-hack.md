# the API action inflection hack :[#018]


## introduction

this is the first ever document whose contents are gleaned from [#bs-014]
the `deliterate` utility.


## :#note-130

automagic is not without its price: in order to infer a noun stem from your action class name, we will start by assuming it is in either the second- or third-to-last 'name piece.' (assumption [#018]) To find the appropriate action constants for the noun, we crawl down the entire const tree and back up again

part-way bc of [#035] - if there is a pure box module, (that is, a module whose only purpose is to be a clean namespace to hold only constituent items), then such modules usually do *not* have business semantics - that is, they sometimes do *not* have a meaningful name as far as we're concerned here. So if there is such a module, we want to `hop` over it, thereby not using it as a basis for our noun stem, but rather the const above it
