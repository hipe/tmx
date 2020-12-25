## NOTE

Before you can use this theme, it is required that you run this task
(run from the root of the mono repo):


```bash
invoke -r pho-themes copy-sphinx-CSS-over
```

which creates a minimal sphinx project and generates its html and moves
two of its CSS files into our pelican theme.

This is done in this convoluted way because we don't want to version
files that are part of another project.

(And if we end up needing to modify the Alabaster theme in any way, we would
make a dedicated repository where we fork their repository under their
license, so authorship of the individual lines of code etc is preserved.)

But #open [#410.Y] is to find a nicer way.



## (document-meta)

  - #born
