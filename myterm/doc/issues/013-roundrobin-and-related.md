# roundrobin and related (#open)

design some solution for multiple images (e.g if you have
multiple windows, tabs or panes open and you resize any of
them). as it is now, in this scenaro, the most recently
produced image becomes *the* image for all panes that are
resized (of course).

you want the image to persist on the filesystem 1-to-1 with
an open pane, but we aren't gonna mess with filehandles or
listeners for this (for now).

but we need to design some way to stop it from producing new
files infinitiely..

the easiest solution we can come up with is a roundrobin
with some fixed number: image-1, image-2.. to image-5.
write a file containing the name of the last used image,
and use the next one and update the file. this will at least
give the user some hard-coded maxium numer of different panes
she can have with different background images until we come
up with another solution.

(but not cleaning up after ourselves in some way is *not* an
option. e.g to just write imagefiles with a datestamp and
never remove them, that would get real ugly real quick and
look really bad.)
