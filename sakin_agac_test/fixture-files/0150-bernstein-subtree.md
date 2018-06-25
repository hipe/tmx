# Python Parsing Tools
A list of Python parsing tools initially imported from [@nedbat's](https://github.com/nedbat) [blog post](http://nedbatchelder.com/text/python-parsers.html).

## The List

|Name|Description|License|Updated|Parses|Used By|Notes|
|:--:|-----------|:-----:|-------|------|-------|-----|
|[pyparsing](http://pyparsing.wikispaces.com/)|Direct parser objects in python, built to parallel the grammar.|MIT|v2.0.3 8/2014||[twill](http://twill.idyll.org/)||
|[LEPL](http://www.acooke.org/lepl/)|A recursive descent parser.|dual licensed MPL/LGPL |v 5.1.3 9/2012||| Discontinued|
|[Plex3](https://github.com/uogbuji/plex3)|Python3 port of Plex||8/2012|||No official release|
|[SPARK](http://pages.cpsc.ucalgary.ca/~aycock/spark/)|Uses docstrings to associate productions with actions. Unlike other tools, also includes semantic analysis and code generation phases.|MIT|v 0.7 pre-alpha 7 5/2002||||
|[Berkeley YACC](http://invisible-island.net/byacc/byacc.html)|Classic YACC, extended to generate Python code. Python support seems to be undocumented.|Public Domain|v 20141128 11/2014|LALR(1)|||

## Standard Modules

The Python standard library includes a few modules for special-purpose parsing problems. These are not general-purpose parsers, but don't overlook them. If your need overlaps with their capabilities, they're perfect:

* [shlex](https://docs.python.org/2/library/shlex.html) lexes command lines using the rules common to many operating system shells.
* [ConfigParser](https://docs.python.org/2/library/configparser.html) implements a basic configuration file parser language which provides a structure similar to what you would find on Microsoft Windows INI files.
* [ArgParse](https://docs.python.org/2/library/argparse.html) makes it easy to write user-friendly command-line interfaces. The program defines what arguments it requires, and argparse will figure out how to parse those out of sys.argv. The argparse module also automatically generates help and usage messages and issues errors when users give the program invalid arguments.
* [email](https://docs.python.org/2/library/email.html) provides many services, including parsing email and other RFC-822 structures.
parser parses Python source text.
* [cmd](https://docs.python.org/2/library/cmd.html) implements a simple command interface, prompting for and parsing out command names, then dispatching to your handler methods.
* [json](https://docs.python.org/2/library/json.html) is a JSON (JavaScript Object Notation) encoder and decoder
* [tokenize](https://docs.python.org/2/library/tokenize.html) is a lexical scanner for Python source code, implemented in Python.

## Articles

* [Simple Top-Down Parsing in Python](http://effbot.org/zone/simple-top-down-parsing.htm) - A methodology for writing top-down parsers in Python. (7/2008)
* [Pysec: Monadic Combinatoric Parsing in Python](http://www.valuedlessons.com/2008/02/pysec-monadic-combinatoric-parsing-in.html) - An exposition of using monads to build a Python parser. (2/2008)

## Licensing and Attribution

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/80x15.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/Text" property="dct:title" rel="dct:type">Python Parsing Tools</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://www.michaelbernstein.com" property="cc:attributionName" rel="cc:attributionURL">Michael R. Bernstein</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.<br />Based on a work at <a xmlns:dct="http://purl.org/dc/terms/" href="https://github.com/webmaven/python-parsing-tools/" rel="dct:source">https://github.com/webmaven/python-parsing-tools/</a>.

## (document-meta)

* this section (bulleted list) was not in the original source document.
* other than this section, this file is an exact subslice (in terms of lines)
  of the original source document at the time of this file's creation.
* the URL of the received form of this document is hard-coded into a producer
  script in an edit committed at this document's birth commit.
* as stated, the constituency of interesting items here is a "subslice": we
  have reduced the constituency of the list of parsers so that it contains
  only those constituents that are used in *another* test that is similar to
  the inspiration test. (that constituency is a superset and larger than the
  set we need, but we want to future-proof ourselves if we end up wanting
  more items or to more further mirror the other test file. also symmetry OCD.)
* #born.
