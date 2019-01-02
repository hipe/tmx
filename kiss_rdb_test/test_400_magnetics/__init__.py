"""experiment: be a #[#019.file-type-C] but simpler

below, when we say "pud" we mean `python -m unittest discover`
"""

from sys import path as a
from os import path

dn = path.dirname
head = a[0]

top_test_dir = dn(dn(__file__))
mono_repo_dir = dn(top_test_dir)

if top_test_dir == head:
    # top test dir is entrypoint
    a[0] = mono_repo_dir
else:
    raise Exception('sanity')

# #born.
