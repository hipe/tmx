"""
when running the whole sub-project test suite ("from the top")
(with "unittest discover"), it is NECESSARY that this file exist
so that its directory is recognized as a module (that has tests).

furthermore this is the ONLY circumstance where this file is loaded.
(i.e. it is NOT loaded if you run its directory as the test suite.)

it is therefor NEVER prudent for this file to contain any code.

in other words, #[#018.file-type-B].
"""

# #born.
