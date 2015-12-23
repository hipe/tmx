module Skylab::SearchAndReplace

  class Magnetics_::File_Session_Stream_via_Parameters

    class << self

      def with * x_a, & p
        p ||= On_event_selectively_
        new.__init( x_a, & p ).execute
      end
    end  # >>

    o = Home_.lib_.fields::Parameters[
      do_highlight: :_downwards,
      for_interactive_search_and_replace: :flag,
      grep_extended_regexp_string: :_downwards,
      max_file_size_for_multiline_mode: :_downwards,
      read_only: :flag,
      ruby_regexp: :_downwards,
      upstream_path_stream: nil,
    ]

    attr_reader( * o.symbols( :_downwards ) )

    def __init x_a, & p
      PARAMS___.write_ivars self, x_a
      @_oes_p = p
      self
    end

    PARAMS___ = o

    def execute

      _ = if @for_interactive_search_and_replace
        Home_::Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream
      elsif @read_only
        Home_::Magnetics_::Read_Only_File_Session_Stream_via_File_Session_Stream
      end

      producer = _[ self, & @_oes_p ]

      path_count = 0
      @upstream_path_stream.map_reduce_by do |path|
        path_count += 1
        producer.produce_file_session_via_ordinal_and_path path_count, path
      end
    end

    Here__ = self
  end
end
