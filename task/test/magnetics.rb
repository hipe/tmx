module Skylab::Task::TestSupport

  module Magnetics

    def self.[] tcc, sym=nil
      tcc.include self
      if sym
        _mod = Autoloader_.const_reduce [ sym ], Here_
        _mod[ tcc ]
      end
    end

    # -

      def build_mock_manner_class_ sym
        Mock_Manner_Class__.new sym
      end

      def item_ticket_collection_via_ ir, * s_s_a
        _tss = token_stream_stream_via_ s_s_a
        item_ticket_collection_via_item_resolver_and_token_stream_stream_ ir, _tss
      end

      def item_ticket_collection_via_item_resolver_and_token_stream_stream_ ir, tss
        col = magnetics_module_::ItemTicketCollection_via_TokenStreamStream[ tss ]
        col.item_resolver = ir
        col
      end

      def token_stream_stream_via_ s_s_a
        Common_::Stream.via_nonsparse_array s_s_a do |s_a|
          Simple_Token_Stream_.new s_a
        end
      end

      def magnetics_module_
        Home_::Magnetics::Magnetics_
      end

      def models_module_
        Home_::Magnetics::Models_
      end

    # -

    # ==

    class Mock_Manner_Class__ < ::BasicObject

      def initialize sym
        @_sym = sym
      end

      def magnetic_manner_for client, collection
        Mock_Manner___.new @_sym
      end
    end

    class Mock_Manner___
      def initialize sym
        @mock_manner_shibboleth = sym
      end
      attr_reader :mock_manner_shibboleth
    end

    # ==

    class Simple_Token_Stream_

      # (we would just use etc but for the need for this `.ok` method)

      def initialize s_a
        @_s_a = s_a
        @_d = -1
        @_last = s_a.length - 1
      end

      def gets
        if @_last != @_d
          @_s_a.fetch( @_d += 1 )
        end
      end

      def ok
        true
      end
    end

    # ==

    class MockDirectory

      class << self
        alias_method :via_all_entries_array, :new
        undef_method :new
      end  # >>

      def initialize a
        @entries = a.frozen? ? a : a.dup.freeze
      end

      attr_reader(
        :entries,
      )
    end

    # ==

    Here_ = self
  end
end
# #history: assimilated & reconceived (now) mock directory from elsewhere
