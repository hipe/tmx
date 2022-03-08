---
title: README
date: 2018-11-27T03:00:00-05:00
---

## objective & scope

a ridiculous
pipe dream
toy project: the
easy-to-understand
easy-to-work-with
ultra-light-duty
relational-ish
database-ish.

  - this is a toy project not suitable for production
  - data is stored in human-readable files (and directories)
  - files must be human-editable too
  - version control (like `git` or `hg`) will be used/abused for journaling

woah boy.




## (the identifier registry)

(Our range is [#880-899], a narrow allocation range for now.)
(EDIT: the above range needs an audit, search the world for [#!875])

|Id                         | Main Tag | Content |
|---------------------------|:------|:----|
|[#899.Z]                   | #eg   | eg
|[#877.6]                   | #open | when you create a new eno collection too deep, relative dirs are broken
|[#877.E]                   | #open | collection wrapping is so complicated
|[#877.4]                   | #trak | do we want to make string identifiers the default?
|[#877.C]                   | #trak | new pattern of holes in traversal streams that client can chose to skip
|[#877.B]                   | #open | CUSTOM_FUNCTIONS_OLD_WAY .. not sure what do
|[#877]                     |       | now, a third node for internal & external tracking
|[#875.3]                   |       | [entity edit history whitepaper]
|[#875.2]                   |       | digraph: LEGACY markdown parsing state machine
|[#874.9]                   | #open | sign off on what to do with this file marked LEGACY
|[#874.5]                   | #open | clean up the interface to this emitter
|[#874.4]                   |       | multi-tablism  (see also #multi-tablism)
|[#874.3]                   |       | the API (interface) for entity
|[#874.2]                   |       | the API (interface) for collection
|[#874]                     |       | largely an issue group for massive re-architecting - all on top of stack
|[#873.26]                  | #prov | whether and how we seek(0)
|[#873.Y]                   | #open | this tempfile logic is repeated
|[#873.24]                  | #trak | this one md line parser
|[#873.23]                  | #trak | parsing unified diff files the old way and the new way
|[#873.V]                   | #open | google sheets: learn & document this one thing
|[#873.21]                  | #API  | #provision: use underscores (not dashes or spaces) in eno document field names
|[#873.20]                  |       | places where we relied on toml types and lost them, also wish for type schema
|[#873.S]                   | #trak | eno has fixed storage schema for now
|[#873.R]                   | #open | unify error monitor
|[#873.Q]                   | #open | unify how we render markdown
|[#873.16]                  | #trak | track collection implementations outside of here and there
|[#873.O]                   | #open | this one markdown producer script needs several passes of rewrites
|[#873.N]                   |       | stream-based vs. memory-hog based markdown table parsing
|[#873.M]                   | #trak | wrapping classes changed to..
|[#873.12]                  |       | #experimental. we may remove this API point. capability functions
|[#873.K]                   | #spec | eno: the assumption of a document-meta section makes life easier
|[#873.J]                   | #open | debugging `print` statements for kiss-rdb commit
|[#873.I]                   | #trak | ugly
|[#873.H]                   | #wish | customizable functional pipelines (map, filter in any order etc)
|[#873.G]                   | #prov | #provision: our use of eno for storage must be line-isomorphic
|[#873.6]                   | #trak | would redis etc
|[#873.5]                   | #trak | #provision: where sparseness is implemented - prune "empty" cels
|[#873.D]                   | #trak | spots to change if we add this feature (see)
|[#873.C]                   | #wish | a `--oneline` option for CLI
|[#873.B]                   | #wish | this one smell in emissions
|[#873.A]                   | #open | modernize the CLI of this hidden exe
|[#873]                     |       | internal tracking (extended)
|[#872.B]                   | #edit | edit documentation
|[#872]                     |       | multi-line strings: the document
|[#871.1]                   | #prov | markdown provision: leftmost is identifier
|[#871]                     |       | numberspace: markdown provisions overflow
|[#870]                     |       | "backend roadmap again"
|[#869]                     |       | near term end game
|[#868]                     |       | test number allocation
|[#867.Z]                   |       | get rid of toml leaks
|[#867.Y]                   | #trak | parsing our own markdown is the wrong way
|[#867.W]                   | #trak | this #[#020] annoyance with python CLI argv
|[#867.V]                   | #open | the way we keep id (int) 0 free is hackish
|[#867.U]                   | #trak | injections (discussion)
|[#867.T]                   |       | top secret crazy plan
|[#867.S]                   |       | reference internal CLI somewhere else
|[#867.R]                   | #prov | provision: failure is None not False
|[#867.Q]                   | #prov | provision: do index file second
|[#867.P]                   | #trak | possible issue on windows
|[#867.N]                   | #trak | google sheets: dimensionality hardcoded to ROWS for now
|[#867.M]                   | #open | track some not all CLI endpoint stubs
|[#867.L]                   | #open | track complaints about click
|[#867.K]                   | #trak | places where we use the toml vendor lib
|[#867.J]                   | #open | redundancy
|[#867.I]                   | #hole | (document) recfiles capabilities plan
|[#867.H]                   | #open | blank lines during update move weirdly.
|[#867.G]                   | #wish | empty files would tell you they're empty
|[#867.F]                   | #trak | track where we use `'#' == line[0]` as etc
|[#867.E]                   | #prov | markdown provision: you must always employ an example row
|[#867.D]                   | #open | these datetime forms not supported in python toml
|[#867.C]                   | #open | known error cases yet to cover (not comprehensive)
|[#867.B]                   | #watc | API for getters?
|[#867]                     |       | (internal tracking, small issues)
|[#866.B]                   | #edit | edit documentation
|[#866]                     |       | the hack for detecting in-line comments
|[#865.B]                   | #edit | edit documentation
|[#865]                     |       | the toml adaptation for attributes
|[#864.B]                   | #edit | edit documentation
|[#864]                     |       | the toml adaptation
|[#863]                     |       | coarse parse toml state diagram
|[#862]                     |       | aws ec2
|[#861]                     |       | aws eks
|[#860]                     |       | kube journey notes
|[#859]                     |       | kubernetes documentation roadmap
|[#858]                     |       | aws journal
|[#857.11]                  | #prov | "delete" results in structure with entity (not dct) and diff lines
|[#857.10]                  | #prov | "create" results in structure with entity (not dct) and diff lines
|[#857.9]                   | #prov | whether or not the EID is an attribute is currently up in the air, up to SA
|[#857.8]                   | #prov | "update" results structure with before and after *entity* (not dct) AND diff lines
|[#857.G]                   | #open | turn diffing/patching into a "for free" feature for single-file collections
|[#857.6]                   |       | #watch we don't love `opn` - passing open resources can fix some of it
|[#857.E]                   | #prov | #provision: entity identifiers (eid's) are either integers or strings for now
|[#857.D]                   |       | logic diagram for resolving storage adapters and..
|[#857.C]                   |       | injectable custom identifier classes (near schema)
|[#857.2]                   |       | sentences via jumble
|[#857.1]                   |       | backend roadmap
|[#856]                     |       | example data model
|[#855]                     |       | not really SQL
|[#854]                     |       | plugin architecture
|[#853]                     |       | filetree schemas
|[#852]                     |       | ID system overview
|[#851]                     |       | (this README)



## (document-meta)

  - #born.
