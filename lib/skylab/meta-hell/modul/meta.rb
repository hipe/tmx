module Skylab::MetaHell
  class Modul::Meta
    extend MetaHell::Let

    SEP  = '::'
    SEP_ = Modul::Creator::SEP_

    attr_reader :name, :children, :blocks

    def build_product _=nil
      o = ::Module.new            # creating modules is easy you see
      _init_product o
      o
    end

    attr_accessor :_pending       # hack to avoid autovivification circ. deps.:
                                  # If a class has a superclass, we don't have
                                  # or want the logic to untangle a true
                                  # dependency graph when autovivification
                                  # happens. But be warned the whole thing
                                  # will hence feel inconsistent..

    def child_nodes known_grammar
      ::Enumerator.new do |y|
        children.each do |child_name|
          y << known_grammar.fetch(child_name)
        end
      end
    end

    let( :const ) { @name.to_s.split( SEP_ ).last.intern }

    def _lock!   ; @locked and fail('sanity') ; @locked = true end
    def _locked? ; @locked end
    def _unlock! ; @locked or fail('sanity') ; @locked = false end

  protected

    def initialize name
      @locked = false
      @name, @children, @blocks = [name, [], []]
      @name.freeze
    end

    def _init_product o
      pretty = name.to_s.gsub SEP_, SEP
      o.singleton_class.send(:define_method, :to_s) { pretty }
      fail "circular dependency on #{name} - should you be using ruby #{
        }instead?" if _locked?
      _lock!
      blocks.each do |body|       # note that if you're expecting to
        o.module_exec(& body)     # find children modules of yourself
      end                         # here you probabaly will not!
      _unlock!
      nil
    end
  end
end
