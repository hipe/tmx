# parser generators dilligence

## the list

|Name|Description|Comment|License|Updated|Version|Python|Module|Grammar|Used By|Notes|Tags|
|:--:|-----------|:-----:|:------|:------|:------|------|------|-------|-------|-----|----|
|x|||q||||mm|||2wr3||
|[ANTLR](http://www.antlr.org/)|Parser and lexical analyzer generator in Java. Generates parsing code in Python (as well as Java, C++, C#, Ruby, etc).|stand-alone tool in Java. Latest version can produce Python code|BSD|2014-07|v4.4||Python|LL(*)||    ||
|[Aperiot](https://sites.google.com/site/aperiotparsergenerator/)||uses separate grammar files|Apache 2.0|2012-01|v0.1.12||Python|LL(1)||    ||
|[Arpeggio](https://github.com/igordejanovic/Arpeggio)||Packrat parser. Works as interpreter. Multiple syntaxes for grammar definition. Lots of docs, examples and tutorials.| |||2.7+, 3.2+|Python|PEG||    ||
|[Berkeley YACC](http://invisible-island.net/byacc/byacc.html)|Classic YACC, extended to generate Python code. Python support seems to be undocumented.||Public Domain|2014-11|v20141128||  |LALR(1)||    ||
|[BisonGen](http://copia.posthaven.com/of-bisongen)||| |2005-04|v0.8.0b1||  |||    ||
|[Bison in a box](http://hyperreal.org/~est/freeware/)|Uses standard Bison to generate pure Python parsers. It actually reads the bison-generated .c file and generates Python code.||GPL|2001-06|v0.1.0||  |LALR(1)||    ||
|[Codetalker](https://github.com/jaredly/codetalker)|Python-based grammar definitions.||MIT|2014-03|v1.1||  |||    ||
|[Construct](http://construct.readthedocs.org/)|A declarative parser (and builder) for binary data.||BSD|2014-04|v2.5.2||  |||    ||
|[docopt](http://docopt.org/)|Generates a parser based on formalized conventions that are used for help messages and man pages for program interface description.||MIT|2014-06|v0.6.2||  |||    ||
|[DParser](http://dparser.sourceforge.net/)||grammar in doc strings| |||2.2+|C |GLR||    ||
|[DParser for Python](http://dparser.sourceforge.net/)|A scannerless GLR parser||BSD|2013-03|v1.3.0||  |||[Charming Python: DParser for Python: Exploring Another Python Parser](http://gnosis.cx/publish/programming/charming_python_b19.txt)||
|[FlexModule and BisonModule](http://www.crsr.net/Software/FBModule.html)|Macros to allow Flex and Bison to produce idiomatic lexers and parsers for Python. The generated lexers and parsers are in C, compiled into loadable modules.||Pythonesque|2002-03|v2.1||  |||    ||
|[funcparserlib](https://github.com/vlasovskikh/funcparserlib)|Recurisve descent parsing library for Python based on functional combinators.|Recursive descent parsing library for Python based on functional combinators|MIT|2013-05|v0.3.6|2.4+|Python|LL(*)||    ||
|[GOLD Parser](http://goldparser.org/)|||[zlib/libpng](http://opensource.org/licenses/zlib-license.html)|2012-08|v5.2.0||  |LALR||    ||
|[Grako](https://wiki.python.org/moin/Grako)||Tool that takes grammars in EBNF variant & and outputs memoizing (Packrat) PEG parsers in Python.  Grako is different from other PEG parser generators in that the generated parsers use Python's very efficient exception-handling system to backtrack.| |||2.7+, 3.3+, PyPy|Python|PEG||    ||
|[kwParsing](http://gadfly.sourceforge.net/kwParsing.html)|An experimental parser generator implemented in Python which generates parsers implemented in Python.||Python License||v1.3||  |SLR|[Gadfly](http://gadfly.sourceforge.net/)|    ||
|[LEPL](http://www.acooke.org/lepl/)|A recursive descent parser.|Recursive descent with full backtracking and optional memoisation (which can handle left recursive grammars). So equivalent to GLR, but based on LL(k) core.|dual licensed MPL/LGPL|2012-09|v5.1.3|2.6+,3+|Python|Any||Discontinued||
|[lrparsing](http://lrparsing.sourceforge.net/)|Differs from other Python LR(1) parsers in using Python expressions as grammars, and offers disambiguation tools.|A fast parser, lexer combination with a concise Pythonic interface.  Lots of documentation, include example parsers for SQL and Lua.|AGPLv3|2015-03|v1.0.11|2.6+|Python|LR(1) parser and a tokeniser||    ||
|[Martel](http://www.dalkescientific.com/Martel/)|Martel uses regular expression format definition to generate a parser for flat- and semi-structured files.  The parse tree information is passed back to the caller using XML SAX events.  In other words, Martel lets you parse flat files as if they are in XML.|requires mxTextTools|BSD|2001-12|v0.8|2.0+|Python||[BioPython](http://biopython.org/) [versions 1.4-1.48](https://github.com/biopython/biopython/blob/6f9e7a741fdc4598509292d911020995ba2a5241/DEPRECATED#L283-L287)|[Last version included in BioPython](https://github.com/biopython/biopython/tree/29aa4df3480cdee803694766f137ab2baf5625b2/Martel)||
|[ModGrammar](https://pythonhosted.org/modgrammar/index.html)|A general-purpose library for constructing language parsers and interpreters for context-free grammar definitions.|Recursive descent parser with full backtracking. Grammar elements and results are defined as Python classes, so are fully customizable. Supports ambiguous grammars.|BSD|2013-02|v0.10|3.1+|Python|GLR||    ||
|[mxTextTools]()|An unusual table-based parser. There is no generation step, the parser is hand-coded using primitives provided by the package. The parser is implemented in C for speed. (just above).|is not exactly a parser like we're used to, but it is a fast text-processing engine|eGenix Public License, similar to Python, compatible with GPL.|2014-07|v3.2.8||C |-|SimpleParse, Martel|    ||
|[parcon](http://me.opengroove.org/2011/06/parcon-new-parser-combinator-library.html)||Parser combinator library, similar to pyparsing| |||2.6+|Python|||    ||
|[parglare](https://github.com/igordejanovic/parglare)||A pure Python LR/GLR parser with integrated scanner (scannerless). Grammar in BNF format. Automata/GLR trace visualization. Full documentation and examples available.| |||2.7+, 3.3+|Python|LR/GLR||    ||
|[parsimonious](http://github.com/erikrose/parsimonious)||| |||2.5+|Python|PEG||    ||
|[Parsing](http://www.canonware.com/Parsing/)|LR(1) parser generator as well as CFSM and GLR parser drivers.||MIT|2012-12|v1.4|2.5+|Python|LR(1), CFSM, and GLR||    ||
|[picoparse](https://github.com/brehaut/picoparse/)||| |2009-03|v0.9||  |||    ||
|[Plex](https://pypi.python.org/pypi/plex/)|Python module for constructing lexical analysers.|lexical analysis module for Python, foundation for Pyrex and Cython. Plex 2.0.0 is Python 2 only, the version embedded in Cython works in Python 3.x. There is also an experimental port to Python 3 (tested on Python 3.3)|LGPL|2009-12|v2.0||C |||compiles all of the regular expressions into a single DFA.||
|[Plex3](https://github.com/uogbuji/plex3)|Python3 port of Plex|| |2012-08|||  |||No official release||
|[Ply](http://www.dabeaz.com/ply/)|Docstrings are used to associate lexer or parser rules with actions. The lexer uses Python regular expressions.|Python Lex-Yacc|LGPL|2015-04|v3.6||Python|LALR(1)|[lesscpy](https://github.com/lesscpy/lesscpy)|[ply-hack group](http://groups.google.com/group/ply-hack)||
|[PyBison](http://freenet.mcnabhosting.com/python/pybison/)|Python binding to the Bison (yacc) and Flex (lex) parser-generator utilities|bison grammar with python code actions|GPL|2004-06|v0.1.8||C |LALR(1)||Doesn't yet support Windows.||
|[pydsl](http://pydsl.org/)|A language workbench written in Python.||GPLv3|2014-11|v0.5.2|2.7+ 3+|Python|-||    ||
|[PyGgy](https://pypi.python.org/pypi/pyggy/0.3)|Lexes with DFA from a specification in a .pyl file. Parses GLR grammars from a specification in a .pyg file. Rules in both files have Python action code. Unlike most parser generators, the rule actions are all executed in a post-processing step. The parser isn't represented as a discrete object, but as globals in a module.||Public Domain|2004-08|v0.4||  |||[Python 3 compatible fork 0.4.1](https://github.com/sprymix/pyggy), [discussion group](https://groups.google.com/forum/#!forum/pyggy)||
|[PyGgy - (broken link)](http://www.lava.net/~newsham/pyggy/)||| |||2.2.1|Python|GLR||    ||
|[pyleri](https://github.com/transceptor-technology/pyleri)||A fast, stand-alone parser which can export a grammar to JavaScript (jsleri), Go (goleri) or C (libcleri).| |||3.2+|Python|LR||    ||
|[PyLR](https://github.com/Mappy/PyLR)|PyLR is a partial Python implementation of the [OpenLR specification](http://www.openlr.org)||Apache 2.0|2014-12|||  |||[announcement](http://techblog.mappy.com/PyLR,%20an%20OpenLR%20decoder%20in%20python.html)||
|[PyLR - (broken link)](http://starship.python.net/crew/scott/PyLR.html)||| ||||C |LR(1) LALR(1)||    ||
|[pyparsing](http://pyparsing.wikispaces.com/)|Direct parser objects in python, built to parallel the grammar.||MIT|2014-08|v2.0.3|2.2+|Python||[twill](http://twill.idyll.org/)|    ||
|[pyPEG](http://fdik.org/pyPEG/)|A parsing expression grammar toolkit for Python.||GPL|2015-01|v2.15|2.5+|Python|PEG||    ||
|[reparse](http://reparse.readthedocs.org/en/latest/)||Combines Regular Expressions| |||2.x, 3.x|Python/Regex|||    ||
|[RP](http://lparis45.free.fr/rp.html)||Simple parser using rule defined in BNF format| |||2.6+|Python|na||    ||
|[Rparse](https://sites.google.com/site/della1rv/therparseparsergenerator)|||GPL|2010-04|v1.1.0.||  |LL(1) parser generator with AST generation.||    ||
|[SableCC](http://sablecc.org/)|Java-based parser and lexical analyzer generator. Generates parsing code in Java, with [alternative generators](http://www.mare.ee/indrek/sablecc/) for other languages including Python.||LGPL|2012-11|v3.7||  |||    ||
|[shlex](http://docs.python.org/lib/module-shlex.html)||included in the main Python distribution| ||||C |||    ||
|[SimpleParse](http://simpleparse.sourceforge.net/)|Lexing and parsing in one step, but only deterministic grammars.|requires mxTextTools|BSD|2010-08|2.11a2|2.0+|  |-||    ||
|[SPARK](http://pages.cpsc.ucalgary.ca/~aycock/spark/)|Uses docstrings to associate productions with actions. Unlike other tools, also includes semantic analysis and code generation phases.||MIT|2002-05|v0.7 pre-alpha 7||Python|GLR||    ||
|[textX](https://github.com/igordejanovic/textX)||A high-level meta-language/parser for Domain-Specific Language implementation. Built on top of Arpeggio parser. Inspired by XText. Documentation, examples and tutorials available.| |||2.7+, 3.2+|Python|||    ||
|[Toy Parser Generator](http://cdsoft.fr/tpg/)|||LGPL|2013-12|v3.2.2|2.2+|  |||    ||
|[Trap](http://www.ercim.org/publication/Ercim_News/enw36/ernst.html)||| |||1.5.1+|  |LR||    ||
|[Wisent](http://seehuhn.de/pages/wisent)||has separate parser input file, parser output is a parse tree| |||2.4+|Python|LR(1)||    ||
|[Yapps](http://theory.stanford.edu/~amitp/yapps/)|Produces recursive-descent parsers, as a human would write. Designed to be easy to use rather than powerful or fast. Better suited for small parsing tasks like email addresses, simple configuration scripts, etc.||MIT|2003-08|v2.1.1|1-any, 2-1.5+|Python|LL(1)||    ||
|[Yappy](http://www.dcc.fc.up.pt/~rvr/naulas/Yappy/index.html)||| |2014-08|v1.9.4|2.2+|Python|SLR, LR(1) and LALR(1)||Uses python strings to declare the grammar.||
|[yeanpypa](http://freecode.com/projects/yeanpypa/)|Yeanpypa is (yet another) framework to create recursive-descent parsers in Python.|inspired by pyparsing and boost::spirit|Public Domain|2010-04|||Python|||Parsers are created by writing an EBNF-like grammar as Python expressions.||
|[ZestyParser](https://pypi.python.org/pypi/ZestyParser)||Object-oriented, Pythonic parsing|MIT|2007-04|v0.8.1||Python|||    ||




## (document-meta)

  - #history-A.2: machine import of second collection
  - #history-A.1: machine import of first collection
  - #born.
