# ouroboros and strange modules :[#044]

the original description of the `ouroboros` phenomenon first appears in
"cli/client/adapter/for/face.rb" which is left intact for historical reasons. we then
touch on it a bit more and justify it in [#hl-069] with some glimmer of what's
to come w/ plugins .. but here we re-explain ouroboros anew.

if you understand the `matryoshka doll triforce` explained in [#040] then you
know that we like to think in terms of "modality clients", "namespaces", and
"actions", and in fact at a concpetual level each one descends from each next
one. (an application is one big giant action; an action is one little tiny
appication, and so on.)

                     +-----+   +----------+   +--------+
                     | app |-->| namepace |-->| action |
                     +-----+   +----------+   +--------+
                                    |              O
                                    +--------------+

    (fig.1 an app is a namespace is an action. a namespace can have many
    actions. HENCE: an application (just like a namespace) is made up of
    many actions, some of those actions may themselves be namespaces,
    and so on.)

let's say you have an application with a total of five terminal commands,
and four of them are nested accross two namespaces. your graph might be:

                                 +-[ act1 ]
                                 |
                       +-[ ns1 ]-+-[ act2 ]
                       |
               [ app ]-+-[ ns1 ]-+-[ act3 ]
                       |         |
                       |         +-[ act4 ]
                       |
                       +-----------[ act5 ]

    (fig2. - a typical small-sized application topology)

to be continued #todo ..
  + explain strange modules
  + explain what the ouroboros proxy is for
