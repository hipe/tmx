module Skylab::MetaHell
  class Modul::Meta
    extend MetaHell::Let

    SEP  = '::'
    SEP_ = Modul::Creator::SEP_

    attr_reader :name, :children, :blocks

    def build_product(*)          # args are probably client and known graph,
      o = ::Module.new            # but creating modules is easy you see
      _init_product o
      o
    end

    let( :const ) { @name.to_s.split( SEP_ ).last.intern }

    def safe? ; true end

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
