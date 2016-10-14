module Skylab::DocTest

  class AssetDocumentReadMagnetics_::BlockStream_via_LineStream_and_Single_Line_Comment_Hack < Common_::Actor::Monadic

    # (some of this is near [#ta-005]-ish magnetics composition (how?))

    def initialize line_stream

      @_parser = Parser___.new line_stream
    end

    def execute
      @_state = :__main
      Common_.stream do
        send @_state
      end
    end

    def __main
      if @_parser.has_current_line
        if @_parser.current_line_has_comment
          __parse_a_comment_block
        else
          __parse_a_static_block
        end
      else
        NOTHING_
      end
    end

    def __parse_a_comment_block
      Home_::Models_::CommentBlock.via_parse__ @_parser
    end

    def __parse_a_static_block
      Home_::Models_::StaticBlock.via_parse__ @_parser
    end

    class Parser___

      def initialize st
        @line_stream = st
        _advance
      end

      def release_matchdata_and_advance_
        x = @matchdata
        _advance
        x
      end

      def release_line_and_advance_
        x = @current_line
        _advance
        x
      end

      def _advance
        x = @line_stream.gets
        if x
          @has_current_line = true
          md = HACK_RX__.match x
          if md
            @current_line_has_comment = true
            @matchdata = md
          else
            @current_line_has_comment = false
            @matchdata = nil
          end
          @current_line = x
        else
          io = remove_instance_variable :@line_stream
          if io.respond_to? :close
            io.close
          end
          @has_current_line = false
          @current_line_has_comment = false
          @current_line = nil
          @matchdata = nil
        end
        NIL_
      end

      attr_reader(
        :current_line,
        :current_line_has_comment,
        :has_current_line,
        :matchdata,
      )
    end

    HACK_RX__ = /\A([^#]*)#/
  end
end
# #history: a blind rewite of "commet block stream via [same]"
