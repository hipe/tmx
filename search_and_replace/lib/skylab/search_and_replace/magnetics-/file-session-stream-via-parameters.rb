module Skylab::SearchAndReplace

  class Magnetics_::FileSession_Stream_via_Parameters

    def initialize & p
      @_listener = p
    end

    o = Attributes_.call(
      for: nil,  # { read_only | for_interactive_search_and_replace }
      grep_extended_regexp_string: :_read,
      max_file_size_for_multiline_mode: :_read,
      replacement_parameters: :_read,
      ruby_regexp: :_read,
      upstream_path_stream: nil,
    )

    attr_writer( * o.symbols )

    attr_reader( * o.symbols( :_read ) )

    def execute
      _ok = __resolve_producer
      _ok && ___via_producer
    end

    def ___via_producer
      unordered_stream = remove_instance_variable :@upstream_path_stream
      possibly_unordered = unordered_stream.to_a
      use_stream = Common_::Stream.via_nonsparse_array possibly_unordered

      producer = @_producer

      path_count = 0
      use_stream.map_reduce_by do |path|
        path_count += 1
        producer.produce_file_session_via_ordinal_and_path path_count, path
      end
    end

    def __resolve_producer
      _producer_producer = FOR___.fetch( @for )[]
      _x = _producer_producer[ self, & @_listener ]
      __store_trueish :@_producer, _x
    end

    FOR___ = {
      for_interactive_search_and_replace: -> do
        Home_::Magnetics_::StringEditSession_Stream_via_FileSession_Stream
      end,

      read_only: -> do
        Home_::Magnetics_::ReadOnly_FileSession_Stream_via_FileSession_Stream  # 1x
      end,
    }

    define_method :__store_trueish, METHOD_DEFINITION_FOR_STORE_TRUEISH_

    Here__ = self
  end
end
