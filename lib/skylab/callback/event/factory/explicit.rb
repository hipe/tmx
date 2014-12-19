module Skylab::Callback

  class Callback_::Event::Factory::Explicit  # [#025] :+#deprecation:pending

    # This was the third addition to the suite of factory-resolvers (after
    # isomorphic and late).  You construct it with 2 hashes - the first
    # is your "logical" hash - it maps stream names to logical factory
    # names (typically e.g :text or :datapoint). The second hash maps
    # logical names to physical factories.

    def initialize logical_h, physical_h
      @logical_h, @physical_h = logical_h, physical_h
    end

    # :+[#mh-056] typical base class implementation:
    def dupe
      dup
    end
    def initialize_copy otr
      lh, ph = otr.get_args_for_copy
      @logical_h = lh.dup
      @physical_h = ph.dup ; nil
    end
  protected
    def get_args_for_copy
      [ @logical_h, @physical_h ]
    end
    # ~

  public

    def add_logical_factory name, x
      logical_box.add name, x
    end

    def add_physical_factory name, x
      physical_box.add name, x
    end

    def change_logical_factory name, x
      logical_box.change name, x
    end

    def change_physical_factory name, x
      physical_box.change name, x
    end

    def call arg1, stream_symbol, arg3
      @physical_h.fetch( @logical_h.fetch( stream_symbol ) ).event(
        arg1, stream_symbol, arg3 )
    end

    alias_method :[], :call  # #comport to look ::Proc-like

  private

    def logical_box
      @logical_box ||= Callback_::Lib_::Boxlike_as_proxy_to_hash[ @logical_h ]
    end

    def physical_box
      @physical_box ||= Callback_::Lib_::Boxlike_as_proxy_to_hash[ @physical_h ]
    end
  end
end
