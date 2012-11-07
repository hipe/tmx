module Skylab::MetaHell
  module ModulCreator
    def self.extended mod                                             # #sl-109
      mod.extend        ModulCreator::ModuleMethods
      mod.send :include, ModulCreator::InstanceMethods
    end

    SEP = '__'
  end

  module Modul end

  class Modul::Meta < ::Struct.new :name, :children, :blocks
    def initialize n, cx=[], bx=[]
      @locked = false
      super n, cx, bx
    end
    def _lock!   ; @locked and fail('sanity') ; @locked = true end
    def _locked? ; @locked end
    def _unlock! ; @locked or fail('sanity') ; @locked = false end
  end


  module ModulCreator::ModuleMethods
    # *note* this does not exclusively pull in a let() implementation,
    # but expects one.

    extend MetaHell::Let # used for convenience in our implementation

    include ModulCreator # #constants

    def modul full_name, &f
      parts = full_name.to_s.split SEP
      memo = parts.shift.intern
      prev = nil
      g = __meta_hell_known_graph
      meta_f = -> name do
        g.fetch( name ){ |k| g[k] = Modul::Meta.new k }
      end
      loop do
        name = memo # localized variable - important!
        if prev # relate cx to parent
          m = meta_f[ prev ]
          m.children.push(name) unless m.children.include? name
        end
        if parts.empty? # then you have target doohah
          m = meta_f[ name ]
          f and m.blocks.push f
          __meta_hell_module!(name) { modul! name, g }
          break
        else # then you have interceding doohah, send along the block
          __meta_hell_module!(name) { modul! name, g }
          prev = memo
          memo = "#{memo}#{SEP}#{parts.shift}".intern
        end
      end
      nil
    end

    let :__meta_hell_known_graph do
      a = ancestors # ACK skip Object, Kernel, BasicObject ACK ACK ACK
      o = a[ ((self == a.first) ? 1 : 0 ) .. -4 ].detect do |x|
        x.respond_to? :__meta_hell_known_graph
      end
      o and fail("ACK try to implement this crazy shit ~meta hell")
      { }
    end

    def __meta_hell_module! full_module_name, &f
      ___meta_hell_memoize_module full_module_name, &f
      ___meta_hell_define_module_convenience_accessor full_module_name
      nil
    end

    def ___meta_hell_define_module_convenience_accessor full_module_name
      # _Foo self.Foo send(:Foo)
      define_method( "_#{full_module_name}" ) { send full_module_name }
    end

    def ___meta_hell_memoize_module full_module_name, &f
      # memoize the module (e.g. class) around this very definition call
      # together with the anchor moudule.  Memoizing on the client alone will
      # get you possibly repeated definition block runs depending on how
      # you implement that .. in flux!

      memo_h = { }

      let full_module_name do
        memo_h.fetch( meta_hell_anchor_module.object_id ) do |mod|
          memo_h[mod] = instance_exec(& f)
        end
      end
    end
  end


  module ModulCreator::InstanceMethods
    extend MetaHell::Let::ModuleMethods

    include ModulCreator # #constants

    def modul! full_name, g=nil, &f
      # get this module by name now, autovivifying where necessary, and, when
      # you autovivify, run any and all known blocks on the module iff you
      # are creating it.
      anchor = meta_hell_anchor_module
      const_a = full_name.to_s.split SEP
      first = true
      name = nil
      const_a.reduce anchor do |mod, const|
        name = (name ? "#{name}#{SEP}#{const}" : const).intern
        if ! mod.const_defined? const, false
          m = ::Module.new
          _my_name = ( first ? const.to_s : "#{mod}::#{const}" ).freeze
          m.singleton_class.send(:define_method, :to_s) { _my_name }
          meta = g && g[name]
          if meta
            if meta._locked?
              fail("circular dependency with #{name} - you should be #{
                }using ruby instead.")
            end
            meta._lock!
            meta.blocks.each do |_f|
              m.module_exec(& _f)
            end
            meta._unlock!
          end
          mod.const_set const, m
          if meta
            # this totally will be broken if you think of it as ruby
            meta.children.each do |ch|
              modul! ch, g
            end
          end
        end
        first = false
        mod.const_get const, false
      end
    end
  end
end
