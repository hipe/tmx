# the meta-properties justification :[#044]

## intro

before reading this, you should understand what [#022] formal properties
are.

the concept of meta-properties is all about tagging your formal
properties with "metadata" that is business specific to your
application. the entity library does not proscribe to you any
meta-properties of its own design. rather, this space is wide open for
you to first create meta-properties and then associate them with your
properties.




## deeper

a "meta-property" is simply a formal property whose purpose is to modify
other formal properties.

our pedagogical example of a meta-property is often "requiredness". but
actually, that is becoming a poor example of a meta-property with the
ideas we will formulate in [#088].

the defining characteristic of meta-properties is that they are
business-specific. (and yes, what constitues "business logic" apart from
lower level mechanics is the same kind of somehwat subjective blurry line
that delineates the boundary between for example a feature and a bug.)

as a bit of an abuse, we could make a case for a checkbox group being
implemented by metaproperties.

if HIPPA-compliance was your thing, and certain fields in certain formed
had to be flagged as needing to comply with HIPPA, this would be an
ideal case for meta-properties. but should the property *library*
provided by [br]  ("entity") need to know what HIPPA compliance is?
the fact that this answer is a resounding "no" is a justification for the
idea of meta-properties: although the idea of HIPPA compliance should not
be built into our property library, being able to work with something like
"HIPPA comliant flagged fields" is live-or-die for applications that
need to.

(EDIT: find a quintessential use-case for m.p's in the wild and examp it
here)
