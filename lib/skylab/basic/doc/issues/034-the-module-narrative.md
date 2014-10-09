# the module node narrative


## :#storypoint-55

`mutex`        - produce a function from another function. the produced
function is designed to enusre that it is never `module_exec`ed against
the same module more than once (using `object_id`). the first time that
the produced function is module_exec'd against some module the argument
function `func_for_module` is also module_exec'd on that module. if any
subsequent attempts are made to call this same function on the selfsame
argument module (HA) a runtime error is raised. produced function takes
no arguments, but `func_for_module` function may.
