## ouroboros - a snake eating its own tail is a thing in cultures :[#069]

        ~ the following abbreviations will be used ~

`rc` = request client  `mc` = mode (root-ish) client `c` = client

the whole idea of everything is that we snap an entire node (that
could operate as a "mode client") onto a terminal end of another
client of the same modality. i.e. any application could be a
sub-command in any other application.

when it comes to CLI, it is tempting to want to set its
`@request_client` to the strange mc because it is after all the
actual request clien BUT it will have no utility and just confuse
things: Using the sub-client pattern whole-hog is untenable accross
frameworks because sub-clients will be making requests of super-
clients that they do not necessarily honor.
Setting the 2 (3) streams right and a fully qualified invocation
string is not only sufficient, it is literally the best we can do.
