module Skylab::Basic

  module Module

    Models_ = ::Module.new

    # <-

  class Models_::Plan

    Home_.lib_.test_support::Let[ self ]

    NAME_SEP__ = Module::Creator::NAME_SEPARATOR

    attr_reader :name, :children, :blocks

    def build_product client
      o = ::Module.new            # creating modules is easy you see
      _init_product o, client
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

    let( :const ) { @name.to_s.split( NAME_SEP__ ).last.intern }

    def _lock!   ; @locked and fail('sanity') ; @locked = true end
    def _locked? ; @locked end
    def _unlock! ; @locked or fail('sanity') ; @locked = false end

  private

    def initialize name
      @locked = false
      @name, @children, @blocks = [name, [], []]
      @name.freeze
    end

    def _init_product o, client
      class << o
        alias_method :meta_hell_original_name, :name
        alias_method :meta_hell_original_to_s, :to_s
      end
      pretty = name.to_s.gsub NAME_SEP__, CONST_SEP_
      o.define_singleton_method :to_s do pretty end
      o.singleton_class.send :alias_method, :name, :to_s
      fail "circular dependency on #{name} - should you be using ruby #{
        }instead?" if _locked?
      _lock!
      blocks.each do |body|       # note that if you're expecting to
        o.module_exec client, &body # find children modules of yourself
      end                         # here you probabaly will not!
      _unlock!
      nil
    end
  end
# ->
  end
end
