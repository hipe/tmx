module Skylab::Basic

  module Class

    module Creator

  # DSL for creating classes, for things like testing metaprogramming,
  # or testing libraries that do extensive reflection on class hierarchies,
  # class names, etc.
  # (it's not usually viable to test such things in static namespaces.)
  #
  #   **very** #experimental

      class << self

        def extended mod
          self._PLEASE_UPDATE_YOUR_SYNTAX  # :+[#sl-109] deprecated
        end

        def [] mod
          mod.extend ModuleMethods
          mod.include InstanceMethods
          NIL_
        end
      end  # >>

      Let__ = Basic_.lib_.test_support::Let

      # <- 2

  module ModuleMethods

    include Basic_::Module::Creator::ModuleMethods  # `metahell_known_graph_`

    o = { }

    o[:build_and_update] = -> me, kg, a do # Create these two lambdas.

      create, update = K.create_and_update[ a ] # create *these* two lambdas

      build = -> name do          # build the metadata node and define the meths
        M.define_methods[ me, name, M.get_product_p[ kg, name ] ] #copy-pasta
        create[ name ]            # call the closure created above
      end

      [build, update]
    end

    o[:create_and_update] = -> a do
                                  # We process the extra args `a` differently
                                  # depending on if this is a create or update:

      create = -> name do         # Lambda for creating the metadata for the kls
        m = Class_::Models_::Plan.new name  # The only chance in the DSL you can set the
        if ! a.empty?             # parent class (symbolically) is now so
          m.optionals! a          # we process it here and then below validate
        end                       # that you're not trying to change it.
        a = nil                   #   --** overwrite in outer scope! **--
        m._freeze!                # Whether it was or wasn't empty, we
        m                         # we processed `a` so we nilify it.
      end

      update = -> meta do         # When accessing an existing node subsequently
        meta.optionals! a if a    # we want to make sure that we aren't trying
      end                         # e.g. to change the parent class. The above
                                  # borks in those cases.
      [create, update]
    end

    K = Basic_::Struct.via_hash o

    def klass full_name, *a, &class_body # `a` is extra args, e.g. extends:
                                  # see extensive comments at klass! for now.

      if method_defined? :_nearest_klass_full_name and
          public_instance_methods( false ).include? :_nearest_klass_full_name
        undef_method :_nearest_klass_full_name  # -w
      end
      -> do
        ::Symbol == full_name.class or fail "(fullname must be immutable!)"
        fullname = full_name  # (no need to dup since above)
        define_method :_nearest_klass_full_name do fullname end
      end.call

      kg = metahell_known_graph_  # (avoid spreading this around)

      me = self                   # make self scope-visible for the below

      build, update = K.build_and_update[ me, kg, a ] # see


                                  # Process every token in `full_name` in a
      M.reduce[ full_name, Memo[ kg ], # reduce operation, branch vs leaf ..
        -> m, o  do               # For each branch node of the path (not last)
          M.meta_bang[ me, m, o,  M.build_meta_p[ me, kg ], nil, nil ]
        end,                      # we just duplicate the other guy's version.
        -> m, o  do               # When we get to the leaf node (the last)
          M.meta_bang[ me, m, o, build, update, class_body ] # is the only
        end                       # time we build our own nodes.
      ]
    end

    define_method :let, Let__::LET_METHOD
  end

  module InstanceMethods

    define_singleton_method :let, Let__::LET_METHOD

    K = ModuleMethods::K # hey can *i* borrow *this*
    mc = Basic_::Module::Creator
    mm = mc::ModuleMethods
    im = mc::InstanceMethods

    include im  # you can say `modul!` too
    M = mm::M
    Memo = im::Memo
    M_IM = im::M_IM

    let( :klass ) { send _nearest_klass_full_name } # courtesy

    let( :object ) { klass.new } # courtesy

    def klass! full_name, *opts, &class_body
      # Resolve `full_name` e.g. "Foo__Bar__Baz" into Foo::Bar::Baz (that is,
      # class 'Baz' inside of module 'Bar' inside of module 'Foo'), creating
      # each interceding node (class or module) as necessary.
      #
      # `opts` if provided is used only for indicating the parent class,
      # e.g. "extends: :Fiz__Bang__Bizzle".  This parent class too will be
      # autovivified iff necessary, but in such cases cannot descend from any
      # class (for how would you specify that?) and furthermore it cannot
      # reside module-icly inside of the target class (as in life).
      # You may also indicate an actual class object instead of a symbol
      # here.
      #
      # If a block is provided (`class_body`) it wil be class_exec'd
      # on the resulting class.
      #
      # If an existing module is found in that spot with that name (and it
      # is not a class kind of module) a runtime exception will be raised.

      # (implementation: in contrast to klass(), we never have an object
      # graph, yet we still spoof a metadata node at each level for its logic)
      # (There is logic here about early vivification of parents that hasn't
      # made it up yet into there [#010] but note it's fragile and won't be
      # easy because the logic is quite different b/c we don't have a
      # "known graph" to work with here so do that carefully!)

      vivify_parent = -> meta do  # validate that parent is not in child
        p, c = [meta.extends, meta.name].map { |n| M.parts[ n ] }
        if c.length < p.length && ! (0 .. c.length - 1).detect{|i| c[i] != p[i]}
          raise "cannot autovifiy parent class that is inside child class: #{
            meta.name } < #{ meta.extends }"
        end
        klass! M.name[ p ]        # normalize name, recurse *once*
      end

                                  # Resolve and normalize parent now:
      if ! opts.empty?            # iff you were given a symbolic name for a
        m = Class_::Models_::Plan.new full_name # parent class, any autovivification of it
        m.optionals! opts         # must come early, in the edge case that the
        if ::Symbol === m.extends # child you will autovivify would be inside
          opts = [ { extends: vivify_parent[ m ] } ] # parent (weird, why?) you
        end                       # don't want the child vivifying and inter-
      end                         # cedeing module where the parent should be.

      create_meta, update_meta = K.create_and_update[ opts ]

      run_body = ->( mod ) { class_body and mod.class_exec(& class_body) }

      update = -> memo do         # an existing module nerp was found
        existing = memo.mod
        ::Class == existing.class or fail ::TypeError.exception "#{
        full_name} is not a class (it's a #{ existing.class })"
        meta = Class_::Models_::Plan.new memo.name # spoof one
        parent = existing.ancestors[1..-1].detect { |x| ::Class == x.class }
        meta.extends = (::Object == parent) ? nil : parent # ick ?
        update_meta[ meta ]       # Process `opts`, tripping validation about
        run_body[ existing ]      # changing superclass, and run any body
        nil
      end

      build = -> memo do
        meta = create_meta[ memo.name ] # This will process `opts` (extends)
        mod = meta.build_product self   # which should have been normalized and
        run_body[ mod ]           # vivified by now if any.
        mod
      end

      M.reduce[ full_name, Memo.new(meta_hell_anchor_module),   # At each branch
        M_IM.bang_p[ self ],             # same behavior as M:C:IM, for branches
        M_IM._bang_p[ self, build, update ]    # and similar behavior for leaves
      ].mod
    end
  end
# -> 2
    end

    Class_ = self
  end
end
