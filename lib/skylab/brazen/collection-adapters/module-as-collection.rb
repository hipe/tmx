module Skylab::Brazen

  class Collection_Adapters::Module_as_Collection

    class << self

      alias_method :[], :new

      def is_actionable
        false  # eek does this bring up a design issue?
      end
    end  # >>

    def initialize mod
      @_mod = mod
    end

    def to_entity_stream

      fly = Name_and_Module___.new
      mod = @_mod

      Callback_::Stream.via_nonsparse_array( mod.constants ) do | const |
        fly.reinitialize mod.const_get( const, false )
        fly
      end
    end

    class Name_and_Module___

      def reinitialize mod
        @module = mod
        @name = Callback_::Name.via_module mod
        NIL_
      end

      def initialize_copy _
        NIL_  # hello
      end

      attr_reader :module, :name
    end
  end
end