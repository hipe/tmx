class Skylab::Task

  module Magnetics

    class Magnetics_::TokenStreamStream_via_DirectoryObject < Common_::Monadic

      def initialize dir_object
        @directory_object = dir_object
      end

      def execute

        @_entries_array = remove_instance_variable( :@directory_object ).entries
        __init_prepared_entry_stream
        __init_token_stream_prototype

        o = @_token_stream_prototype

        @_prepared_entry_stream.map_reduce_by do |entry|
          o.token_stream_via_string entry  # (hi.)
        end
      end

      def __init_token_stream_prototype

        o = Here_::Models::TokenStream.begin

        o.add_head_anchored_skip_regex %r(_)

        o.end_token = Autoloader_::EXTNAME
        o.word_regex = /[a-z0-9]+/
        o.separator_regex = /-/
        o.end_expression_is_required = false  # allow directories thru for now

        @_token_stream_prototype = o.finish ; nil
      end

      def __init_prepared_entry_stream

        _ = remove_instance_variable :@_entries_array
        st = Common_::Scanner.via_array _
        rx = /\A\.+\z/
        while rx =~ st.head_as_is
          st.advance_one
        end
        @_prepared_entry_stream = st.flush_to_stream
        NIL_
      end
    end
  end
end
# #history: rewrote from old version
