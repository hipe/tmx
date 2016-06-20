module Skylab::DocTest

  class Models_::CommentBlock

    class << self

      def via_parse__ pa
        new( pa ).execute
      end

      private :new
    end  # >>

    def initialize pa
      @parse = pa
    end

    def execute

      pa = remove_instance_variable :@parse

      my_depth = pa.matchdata.offset( 1 ).last

      a = [ pa.release_matchdata_and_advance_ ]

      begin
        pa.has_current_line or break
        pa.current_line_has_comment or break

        if my_depth == pa.matchdata.offset( 1 ).last
          a.push pa.release_matchdata_and_advance_
          redo
        end

        break
      end while nil

      @_matchdatas = a
      freeze
    end

    def to_line_stream_  # might be #testpoint-only..
      to_line_matchdata_stream__.map_by do |md|
        md.string
      end
    end

    def to_line_matchdata_stream__  # and here
      Common_::Stream.via_nonsparse_array @_matchdatas
    end

    def category_symbol
      :comment
    end
  end
end
