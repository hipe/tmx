# Objective & Scope:

The goal is a frontend toolkit for drawing nodes (squares (tiles)) and
links between them, sort of in the spirit of the UI for [cables.gl][cab].

Now, one year and four months later, the goal is quite the same but we
are going to start from scratch in both our hunt and our techniques for
gathering notes.


# Development notes:

Experimentally we are going to gather notes with our new favorite
"recutils" storage format, with an ad-hoc as-yet-not-formalized schema.

Today (#history-C.1) when we google "javascript graph editor", we get
the vendor candidates populated in collection [#890.A].

At writing (a few days after the above), we believe we have found a library
that meets our (unspecified) critera; at least enough to begin prototyping
with.

For posterity, below is a post-hoc list of requirements for our library/code.
(That is to say, we came up with this criteria _formally_ (in writing) *after*
perusing many vendor candidates websites etc.)

Criteria:

- Web (not mobile) (to begin with)
- Let's avoid vue.js or React etc to begin with unless it's really compelling
  (that is, we would much prefer "pure", "raw" javascript to start)
- *all* of the below features working from mobile (browser) as well as web
  would be really great:
- Draw nodes
- Draw associations connecting the nodes
- Move nodes around arbitrarily (the arcs follow)
- Arbitrary, textual, editable properties with the nodes
- Pan the view
- Documentation must feel coherent & complete

Nice-to-haves:
- Zoom
- Documentation primarily in EN
- Active community (today)



# Old development notes:

  - `yarn run prepublish`

For the complete scattered notes leading up to this, see notecard
"TJ2" and "TK2" lol.


# Issues & Documentation Nodes

(Our range: [#890-#894])
| ID      | Main Tag | Content  |
|---------|:-----:|----|
|[#895]   | #exmp | This is an example issue
|[#890.A] |       | xx xx


[cab]: https://cables.gl/home

# (document-meta)

  - #history-C.1
  - #born
