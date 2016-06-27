module Skylab::DocTest

  class Models_::StaticBlock

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
      a = [ pa.release_line_and_advance_ ]
      while pa.has_current_line && ! pa.current_line_has_comment
        a.push pa.release_line_and_advance_
      end
      @lines = a
      self  # we don't freeze because of #spot-N
    end

    def to_line_stream  # might be #testpoint-only..
      Common_::Stream.via_nonsparse_array @lines
    end

    def category_symbol
      :static
    end
  end
end
