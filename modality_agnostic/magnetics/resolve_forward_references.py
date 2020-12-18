"""DISCUSSION: you can see algorithms like this one played out over and over

again in our mono-repo (and the other one before it); something like:
1. traverse every node of a digraph while ensuring the graph doesn't cycle
and/or:
2. nodes depend on each other. line them up in an execution order so each
node's prerequisites (other nodes) are met at each node visitation.

We could have subjected ourselves to the pain of trying to abstract one
of the existing code instances of this into what we see here, but we're
saving that unification as an exercise for later or never

There are certainly algorithms out in the universe that do this already,
and perhpas better, but etc. Let this module be a placeholder for all of this
"""

def plan_via_dependency_graph(items):
    return tuple(_do_some_thing(items))


def _do_some_thing(items):
    cc = {k: v for k, v in items}
    dependers_via = {}
    dependencies_via = {k: v for k, v in _build_pool_table(dependers_via, cc)}
    counts = _build_key_via_counts(dependencies_via)

    # (Because we use this as a work pool too, duplicate something we do below)
    if (dct := counts.get(0)) is not None:
        for k in dct.keys():
            yield 'no_dependencies', k
            dependencies_via.pop(k)  # #here2

    while True:
        count_before = len(dependencies_via)

        # At each step through the loop, there must be new nodes that newly
        # have zero dependencies now. See if they free up some other components
        # that depend on only them

        zero_dependencies_dct = counts.get(0)
        if not zero_dependencies_dct:
            xx('circ depend?')
        zero_dependency_ks = tuple(zero_dependencies_dct.keys())
        zero_dependencies_dct.clear()  # because we're gonna add to it #here1

        for zero_dep_k in zero_dependency_ks:
            depdenders = dependers_via.get(zero_dep_k)
            if not depdenders:
                continue

            # These dependers depend on this zero-dependency component.
            # But maybe these dependers also depend on others. Anyway, we move:

            depender_ks = tuple(depdenders.keys())
            # (to be polite, don't delete from a dictionary while traversing)

            for depender_k in depender_ks:

                # Remove this zero-dependency component from the pool
                deps = dependencies_via[depender_k]
                former_num_remaining = len(deps)
                deps.pop(zero_dep_k)
                current_num_remaining = former_num_remaining - 1

                # Update the counts index to be correct (:#here1)
                counts[former_num_remaining].pop(depender_k)
                counts[current_num_remaining][depender_k] = None

                # If there are still other dependencies in the pool, leave it
                if current_num_remaining:
                    continue

                # We just removed the comp's last dependency from the pool.
                # That means we just freed up this component (the main thing).

                # Not only do we not need to know what this node depends on
                # any more, but take the entry out of the thing so we know
                # when we are done (could do it other ways) #here2

                dependencies_via.pop(depender_k)
                yield 'resolve', depender_k

        count_after = len(dependencies_via)
        if 0 == count_after:
            break
        if count_before == count_after:
            xx('hmm')


def _build_key_via_counts(dependencies_via):
    result = {}
    for k, v in dependencies_via.items():
        num = len(v)
        if (dct := result.get(num)) is None:
            result[num] = (dct := {})
        dct[k] = None
    return result


def _build_pool_table(dependers_via, cc):
    for k, v in cc.items():
        yield k, {k: v for k, v in _pool_table_row(dependers_via, k, v, cc)}


def _pool_table_row(dependers_via, k, v, cc):
    for kk in v.forward_references:
        if kk not in cc:
            xx(f"forward reference {kk!r} of component {k!r} never defined")  # noqa: E501

        if (dct := dependers_via.get(kk)) is None:
            dependers_via[kk] = (dct := {})
        dct[k] = None

        yield kk, None


def xx(msg=None):
    raise RuntimeError(''.join(('ohai', *((': ', msg) if msg else ()))))

# #born
