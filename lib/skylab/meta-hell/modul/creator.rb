module Skylab::MetaHell::Modul::Creator

  Creator = self
  MetaHell = ::Skylab::MetaHell
  Modul = MetaHell::Modul
  SEP_ = '__'

  def self.extended mod # #sl-109
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end

  module ModuleMethods # expects you to define your own let()
    extend MetaHell::Let # #impl

    o = ::Hash.new

    o[:build_meta_f] = -> me, known_graph do
      build_meta = -> name do
        M.define_methods[ me, name, M.get_product_f[ known_graph, name ] ]
        M.create_meta[ name ]
      end
    end

    o[:convenience] = -> full_module_name do  # _Foo   self.Foo   send(:Foo)
      define_method( "_#{full_module_name}" ) { send full_module_name }
    end

    o[:create_meta] = ->( name ) { Modul::Meta.new name }

    o[:define_methods] = -> me, name, build_module do
      M.memoize[ me, name, build_module ]
      me.module_exec name, & M.convenience
      nil
    end

    o[:get_product_f] = -> kg, name do
      -> do
        M.graph_bang[ self, kg, self.meta_hell_anchor_module, name ]
      end
    end

    o[:graph_bang] = -> client, graph, mod, name do
      # Find the module requested for by `full_name` starting from under `mod`.
      # If along the way you don't find the node you are looking for, assume
      # that it might that the tree at this  node has not been vivified
      # yet.  In such cases, we then vivify *every* node at this level.
      # (then in theory, depending on how this is called, it might for a
      # given static tree only ever get called once .. we'll see)
      # The result is the requested module.

      mem =  InstanceMethods::Memo.new mod
      M.reduce[ name, mem, -> memo, const do
        if ! memo.mod.const_defined? const, false
          M._build_product[ client, graph, mod, memo.mod, memo.name, const ]
        end
        memo.mod = memo.mod.const_get const, false # an iterating reduce.
        memo.seen.push const                   # this is what makes names.
        memo
      end ]
      mem.mod
    end

    o[:_build_product] = -> client, g, mod, node_mod, node_name, target_const do
      node = g.fetch node_name
      deferred = [] # breadth first?
      node.children.each do |_name|
        child = g.fetch _name
        if node_mod.const_defined? child.const, false
          if target_const == child.const
            fail "sanity" # -- why did u ask for it if it was already set?
          end
        else
          if child.safe? or target_const == child.const
            built = child.build_product client, g  # recurses?
            if child.children.any?
              deferred.push child
            end
            node_mod.const_set child.const, built
          end
        end
      end
      deferred.each do |child|
        child.children.each do |_name|
          M.graph_bang[ client, g, mod, _name ]
        end
      end
      nil
    end

    o[:memoize] = -> me, name, build_module do
      # memoize the module (e.g. class) around this very definition call
      # together with the anchor module.  Memoizing on the client alone will
      # get you possibly repeated definition block runs depending on how
      # you implement that .. in flux!

      memo_h = { }

      me.let name do
        # ( self here is the client, not the defining class / module )
        memo_h.fetch( meta_hell_anchor_module.object_id ) do |id|
          memo_h[id] = instance_exec(& build_module)
        end
      end

      nil
    end

    o[:meta_bang] = ->(
      me, memo, const, build_meta, update_meta, module_body
    ) do
      # 'bang' in this sense means "create iff necessary" (like '!' in this lib)
      # this is the central workhorse of the module methods.
      known_graph = memo.known_graph
      parent = known_graph.fetch memo.name # is :'' iff we are at root
      memo.seen.push const        # so each future (selfsame) memo is accurate
      name = memo.name            # and associate the child name with the ..
      parent.children.include? name or parent.children.push name # parent node
      meta = known_graph.fetch name do         # we create new nodes
        known_graph[name] = build_meta[ name ] # here
      end
      update_meta and update_meta[ meta ]      # generic hook
      module_body and meta.blocks.push module_body # associate client blocks
      memo
    end

    o[:name] = -> parts { parts.join( SEP_ ).intern }

    o[:parts] = -> full_name { full_name.to_s.split SEP_ }

    o[:reduce] = -> full_name, memo, branch_f, leaf_f=nil do
      leaf_f ||= branch_f
      parts = M.parts[ full_name ]
      done = parts.empty?
      until done
        const = parts.shift.intern
        done = parts.empty?
        if done
          memo = leaf_f[ memo, const ]
        else
          memo = branch_f[ memo, const ]
        end
      end
      memo
    end

    M = MetaHell::Struct[ o ] #  turns a hash into an ad-hoc struct object

    let :__metahell_known_graph do
      # #todo the below causes core dumps yay
      # if defined? super  # does this even make sense ? will it ever trigger?
      #   fail "implement me - dealing with ancestor chain ~meta hell"
      # end
      { :'' => M.create_meta[:''] } # root node that reps "anchor module"
    end

    def modul full_name, &mod_body
      # When you declare the existence of a modul[e], what needs to happen is:
      # using the appropriate name(s) inferred from the full name and their
      # relationship to each other in a tree structrue,
      # 1) define some methods iff necessary and 2) update the graph
      # storing away any method body lamba somewhere.

      kg = __metahell_known_graph # (maybe try to avoid spreading this around)
      me = self

      build_meta = M.build_meta_f[ me, kg ]

      M.reduce[ full_name, ModuleMethods::Memo[ kg ],
        -> m, o  do               # for each branch node of the path (not last)
          M.meta_bang[ me, m, o, build_meta, nil, nil ]
        end,
        -> m, o  do               # when you get to the leaf node (the last)
          M.meta_bang[ me, m, o, build_meta, nil, mod_body ]
        end
      ]
      nil
    end
  end

  module InstanceMethods
    extend MetaHell::Let::ModuleMethods

    # (note: although we have a "sophisticated" mechanism for managing
    # definitions of module graphs in our complimentary module above,
    # we have to remain decoupled from aspects of its implementation,
    # remembering that there is no guarantee how we may be related to it.
    # Suffice it to say it is only safe to assume a module was defined
    # if there is an accessor method for it, and doing any reflection
    # on the module should be done directly on it, and not relying on
    # something like "known graph".  Furthermore, interesting and retarded
    # things will start happening with all the closures you have embedded
    # in your method definitions for getters when you start to combine
    # e.g. different modules with different graphs.  Meta Hell!

    M = ModuleMethods::M # hey can i borrow this


    def modul! full_name, &module_body
      # get this module by name now, autovivifying any modules necessary to
      # get there.  once you get to it, run any `module_body` on it.

      define_methods = -> sing_class, name do
        sing_class.send :define_method, name, do
          _modul name
        end
        sing_class.class_exec name, & M.convenience
      end

      bang = -> memo, const do    # 'bang' here means "retrieve, creating if
        memo.seen.push const      # necessary.
        memo.mod = if respond_to? memo.name # Elsewhere like above or client
          send memo.name          # may have defined this.
        else
          if memo.mod.const_defined? const, false
            _mod = memo.mod.const_get const, false
          else
            _mod = M.create_meta[ memo.name ].build_product self, nil
            memo.mod.const_set const, _mod
          end
          define_methods[ self.singleton_class, memo.name ]
          _mod
        end
        memo
      end
                                  # break the name into tokens, which each one:
      _memo = M.reduce[ full_name, Memo.new(meta_hell_anchor_module),
        bang,                     # this is for "branch" (intermediate) tokens
        -> memo, const do         # and when we get to the target, final node,
          bang[ memo, const ]     # we "bang" it (autovivify it if necessary)
          if module_body          # and if a module body was passed above,
            memo.mod.module_exec(& module_body) # we run that here and now
          end
          memo
        end
      ]
      _memo.mod
    end

    def _modul full_name
      M.reduce[ full_name, meta_hell_anchor_module, -> mod, const do
        mod.const_get const, false
      end ]
    end
  end

  module Memo_Methods
    M = ModuleMethods::M
    def name
      M.name[ seen ]
    end
    def initialize mixed
      super mixed, [ ]
    end
  end

  class ModuleMethods::Memo < ::Struct.new :known_graph, :seen
    include Memo_Methods
  end

  class InstanceMethods::Memo < ::Struct.new :mod, :seen
    include Memo_Methods
  end
end
