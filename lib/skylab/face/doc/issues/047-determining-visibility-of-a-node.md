# determining the visibility of a node :[#047]

within the context of the face universe it is decidedly *not* within the
domain of responsibility of the node sheet (e.g command or namespace) to
represent the visibility of the node.

we defer this to the hot node itself as engineering grease because visibility/
invisibility in practice is something that changes dynamically, and we want
to lay the tracks down specifying properties "statically" (e.g with `set`
in the main class definition) and then allow them to change dynamically.

(more broadly this presupposes the implied but not stated notion that sheets
at present must not be dynamically mutated by a running application, insomuch
as they reside one-to-one with classes ..)

however, specifically in the case of visibility and adapters for strange
nodes, rather than worry about whether the strange node itself models
visibility (and if it did it would probably be irrelevant because whether
something should be visibile frequently comes down from parent, and when
crossing a library divide and doing ouroboros, we can't (for practical
purposes) have parents and children talking to each other - the strange child
namespace, if a modality client, has to believe it is a true level-1 modality
client, and should not be engineered otherwise. given all of this, we allow
the local sheet to model the strange node's visibility, in violation of
above. (we give the methods different names for this.)
