module Skylab::MetaHell::Modul::Creator

  Creator = self
  MetaHell = ::Skylab::MetaHell
  Modul = MetaHell::Modul
  SEP = '__'
  SEP_ = '::'

  def self.extended mod # #sl-109
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end

  module ModuleMethods # expects you to define your own let()
    extend MetaHell::Let # #impl

    o = ::Hash.new

    o[:build_meta] = -> name, *rest do
      Modul::Meta.new name, *rest
    end

    o[:build_module] = -> meta do
      fail "circular dependency on #{meta.name} - should you be using ruby #{
        }instead?" if meta._locked?
      meta._lock!
      created = meta.create_mod_f[ meta ]
      pretty = meta.name.to_s.gsub SEP, SEP_
      created.singleton_class.send(:define_method, :to_s) { pretty }
      meta.blocks.each do |module_body_f| # note that if you're expecting to
        created.module_exec(& module_body_f) # find children modules of yourself
      end                                 # here you probabaly will not!
      meta._unlock!
      created
    end

    o[:create_module] = ->(*){ ::Module.new } # creating modules is easy you see

    o[:convenience] = -> full_module_name do # OK   _Foo   self.Foo   send(:Foo)
      define_method( "_#{full_module_name}" ) { send full_module_name }
    end

    o[:define_methods] = -> me, name, build_module_f do # OK
      M.memoize[ me, name, build_module_f ]
      me.module_exec name, & M.convenience
      nil
    end

    o[:graph_bang] = -> me, known_graph, mod, full_name do
      # Find the module requested for by `full_name` starting from under `mod`.
      # If along the way you don't find the node you are looking for, assume
      # that it means that the tree at this branch node has not been vivified
      # yet.  In such cases, we then vivify *every* node at this level.
      # The result is the requested module.

      _memo = InstanceMethods::Memo.new mod
      M.reduce[ full_name, _memo, -> memo, const do # at each token of the path,
        if ! memo.mod.const_defined? const, false
          o = known_graph.fetch memo.name          # sanity too
          o.children.each do |child_full_name|     # remeber you can't go thru
            oo = known_graph.fetch child_full_name # the API to fetch these bc
            created = M.build_module[ oo ]         # they are not vivified yet
            memo.mod.const_set oo.const, created   # and now they are.
          end
        end
        memo.mod = memo.mod.const_get const, false # an iterating reduce.
        memo.seen.push const                       # this is what makes names.
        memo
      end ]
      known_graph.fetch(full_name).children.each do |name| # and now the time
        me.send name                               # has come to see you at the
      end                                          # the infinite recursion.
      _memo.mod                   # this memo is the same memo used throughout
    end

    o[:memoize] = -> me, name, build_module_f do # OK
      # memoize the module (e.g. class) around this very definition call
      # together with the anchor module.  Memoizing on the client alone will
      # get you possibly repeated definition block runs depending on how
      # you implement that .. in flux!

      memo_h = { }

      me.let name do
        # ( self here is the client, not the defining class / module )
        memo_h.fetch( meta_hell_anchor_module.object_id ) do |id|
          memo_h[id] = instance_exec(& build_module_f)
        end
      end

      nil
    end

    o[:meta_bang] = ->( me, memo, const, build_meta_f, update_meta_f,
                       create_mod_f, module_body_f
    ) do
      # 'bang' in this sense means "create iff necessary" (like '!' in this lib)
      # this is the central workhorse of the module methods.
      known_graph = memo.known_graph
      parent = known_graph.fetch memo.name # is :'' iff we are at root
      memo.seen.push const        # so each future (selfsame) memo is accurate
      name = memo.name            # and associate the child name with the ..
      parent.children.include? name or parent.children.push name # parent node
      meta = known_graph.fetch name do                 # we create new nodes
        known_graph[name] = build_meta_f[ name, create_mod_f ] # here
      end
      update_meta_f and update_meta_f[ meta ]          # generic hook
      module_body_f and meta.blocks.push module_body_f # associate client blocks
      memo
    end

    o[:name] = -> parts { parts.join(SEP).intern } # OK

    o[:parts] = -> full_name { full_name.to_s.split SEP } # OK

    o[:reduce] = -> full_name, memo, branch_f, leaf_f=nil do # OK
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

    M = ::Struct.new(* o.keys ).new ; o.each { |k, v| M[k] = v }

    let :__metahell_known_graph do
      if defined? super  # does this even make sense ? will it ever trigger?
        fail "implement me - dealing with ancestor chain ~meta hell" # #todo
      end
      { :'' => M.build_meta[:'', nil] } # root node representing "anchor module"
    end

    def modul full_name, &mod_body_f
      # When you declare the existence of a modul[e], what needs to happen is:
      # using the appropriate name(s) inferred from the full name and their
      # relationship to each other in a tree structrue,
      # 1) define some methods iff necessary and 2) update the graph
      # storing away any method body lamba somewhere.

      kg = __metahell_known_graph # (maybe try to avoid spreading this around)
      me = self

      build_meta_f = -> name, _create_mod_f do
        M.define_methods[ me, name, ->() do # build_module_f is:
          M.graph_bang[ self, kg, meta_hell_anchor_module, name ] # self=client
        end ]
        M.build_meta[ name, _create_mod_f]
      end

      M.reduce[ full_name, ModuleMethods::Memo[ kg ],
        -> m, o  do               # for each branch node of the path (not last)
          M.meta_bang[ me, m, o, build_meta_f, nil, M.create_module, nil ]
        end,
        -> m, o  do               # when you get to the leaf node (the last)
          M.meta_bang[ me, m, o, build_meta_f, nil, M.create_module, mod_body_f ]
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
    # remebering that there is no guarantee how we may be related to it.
    # Suffice it to say it is only safe to assume a module was defined
    # if there is an accessor method for it, and doing any reflection
    # on the module should be done directly on it, and not relying on
    # something like "known graph".  Furthermore, interesting and retarded
    # things will start happening with all the closures you have embedded
    # in your method definitions for getters when you start to combine
    # e.g. different modules with different graphs.  Meta Hell!

    M = ModuleMethods::M # hey can i borrow this

    o = { }

    # M_ = ::Struct.new(* o.keys).new ; o.each { |k, v| M_[k] = v }

    def modul! full_name, &module_body_f
      # get this module by name now, autovivifying any modules necessary to
      # get there.  once you get to it, run any `module_body_f` on it.

      bang_f = -> memo, const do
        memo.seen.push const
        memo.mod = if respond_to? memo.name   # elsewhere like above or client
          send memo.name                      # may have defined it
        else
          if memo.mod.const_defined? const, false
            _mod = memo.mod.const_get const, false
          else
            _meta = M.build_meta[ memo.name, M.create_module ]
            _mod = M.build_module[ _meta ]
            memo.mod.const_set const, _mod
          end
          -> sc, name do
            sc.send :define_method, name, do
              _modul name
            end
            sc.class_exec name, & M.convenience
          end.call self.singleton_class, memo.name
          _mod
        end
        memo
      end

      _memo = M.reduce[ full_name, Memo.new(meta_hell_anchor_module),
        bang_f,
        -> memo, const do
          bang_f[ memo, const ]
          if module_body_f
            memo.mod.module_exec(& module_body_f)
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
