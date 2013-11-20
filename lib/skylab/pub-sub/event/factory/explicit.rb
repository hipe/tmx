module Skylab::PubSub

  class PubSub::Event::Factory::Explicit

    # This was the third addition to the suite of factory-resolvers (after
    # isomorphic and late).  You construct it with 2 hashes - the first
    # is your "logical" hash - it maps stream names to logical factory
    # names (typically e.g :text or :datapoint). The second hash maps
    # logical names to physical factories.

    def dupe
      ba = base_args
      self.class.allocate.instance_exec do
        base_init(* ba )
        self
      end
    end

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

    def call arg1, stream_name, arg3
      @physical_h.fetch( @logical_h.fetch( stream_name ) ).event(
        arg1, stream_name, arg3 )
    end

    alias_method :[], :call  # #comport to look ::Proc-like

  private

    def initialize logical_h, physical_h
      @logical_h, @physical_h = logical_h, physical_h
    end

    def base_init lh, ph
      @logical_h = lh.dup
      @physical_h = ph.dup
      nil
    end

    def base_args
      [ @logical_h, @physical_h ]
    end

    def logical_box
      @logical_box ||= MetaHell::Formal::Box::Open.hash_controller @logical_h
    end

    def physical_box
      @physical_box ||= MetaHell::Formal::Box::Open.hash_controller @physical_h
    end
  end
end
