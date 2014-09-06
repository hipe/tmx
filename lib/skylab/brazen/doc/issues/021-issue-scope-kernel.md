

this is a quick fix for a deeper problem. the problem is that the
@properties shell is (reasonably) cached, so if subsequently we mutate
the set of properties, the shell will be stale.

the better fix for this is that the "scope kernel" is actually used as a
true kernel and not a shell. we need a scope shell whose only interface
is an "edit session". the edit session passes 


