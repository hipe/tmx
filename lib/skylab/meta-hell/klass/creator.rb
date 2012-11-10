module Skylab::MetaHell::Klass::Creator

  # DSL for creating classes, for things like testing metaprogramming,
  # or testing libraries that do extensive reflection on class hierarchies,
  # class names, etc.
  # (it's not usually viable to test such things in static namespaces.)
  #
  #   **very** #experimental

  MetaHell = ::Skylab::MetaHell
  Klass = MetaHell::Klass
  Modul = MetaHell::Modul


  def self.extended mod # #sl-109
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end

  module ModuleMethods
    include Modul::Creator::ModuleMethods # needed for impl. e.g. `M`

    o = { }

    o[:build_and_update] = -> me, kg, a do # Create these two lambdas.
                                  # We process the extra args `a` differently
                                  # depending on if this is a create or update:

      create = -> name do         # Lambda for creating the metadata for the kls
        m = Klass::Meta.new name  # The only chance in the DSL you can set the
        if ! a.empty?             # parent class (symbolically) is now so
          m.optionals! a          # we process it here and then below validate
        end                       # that you're not trying to change it.
        a = nil                   #   --** overwrite in outer scope! **--
        m._freeze!                # Whether it was or wasn't empty, we
        m                         # we processed `a` so we nilify it.
      end

      build = -> name do          # build the metadata node and define the meths
        M.define_methods[ me, name, M.get_product_f[ kg, name ] ] #copy-pasta
        create[ name ]            # this is easier as a closure trust me ^_^
      end

      update = -> meta do         # When accessing an existing node subsequently
        meta.optionals! a if a    # we want to make sure that we aren't trying
      end                         # e.g. to change the parent class. The above
                                  # borks in those cases.
      [build, update]
    end

    K = MetaHell::Struct[ o ]

    def klass full_name, *a, &class_body # `a` is extra args, e.g. extends:

      let( :_nearest_klass_full_name ) { full_name } # for i.m. klass()

      kg = __metahell_known_graph # (avoid spreading this around)

      me = self                   # make self scope-visible for the below

      build, update = K.build_and_update[ me, kg, a ] # see

                                  # Process every token in `full_name` in a
      M.reduce[ full_name, Memo[ kg ], # reduce operation, branch vs leaf ..
        -> m, o  do               # For each branch node of the path (not last)
          M.meta_bang[ me, m, o,  M.build_meta_f[ me, kg ], nil, nil ]
        end,                      # we just duplicate the other guy's version.
        -> m, o  do               # When we get to the leaf node (the last)
          M.meta_bang[ me, m, o, build, update, class_body ] # is the only
        end                       # time we build our own nodes.
      ]
    end
  end


  module InstanceMethods
    extend MetaHell::Let::ModuleMethods

    include Modul::Creator::InstanceMethods

    let( :klass ) { send _nearest_klass_full_name } # courtesy

    let( :object ) { klass.new } # courtesy

  end
end
