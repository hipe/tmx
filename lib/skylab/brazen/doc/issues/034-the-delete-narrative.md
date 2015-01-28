# the delete narrative :[#034]


our primary workhorse method interface (family) for deleting is currently:


    receive_delete_entity <action>, <entity>, & <on event selectively>


## why not just pass some kind of entity identifier?

accepting an entity and not an identifier (of some sort) has several
advantages from the perspective of the collection controller:

• this lets us sidestep the issue of deciding what to do when zero or
  more than one entity is retrieved via the would-be query.

• more specifically on the above point, when the entity is not found we
  invoke the same mechanics we already had in place for when this would
  happen for a retrieve operation.

• your custom datastore can leverage existing logic you wrote do do
  things like persist.

• your custom silo may need to invoke logic that is better suited to live
  in the entity (class) itself rather than in the controller:
  the entity may be for example a datastore entity itself, (that is, an
  entity that represents a datastore), and have additional cleanup to do
  aside from just being deleted in its host datastore.

  to have the entity in place to do this lays out a better design.
