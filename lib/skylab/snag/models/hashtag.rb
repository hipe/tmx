module Skylab::Snag

  class Models::Hashtag < ::Class.new  # origin story in [#056]

    class Stream

      class << self
        def [] * x_a
          if 1 == x_a.length
            x_a.unshift :input_string
          end
          new_via_iambic x_a
        end
      end  # >>

      extend Actor_as_Model_Module_Methods_

      Callback_::Actor.call self, :properties,
        :hashtag_class,
        :input_string,
        :string_scanner

      def initialize

        @end = nil
        @hashtag_class = nil
        @string_scanner = nil
        super
        @hashtag = if @hashtag_class
          @hashtag_class.category_symbol
        else
          :hashtag
        end
      end

      attr_writer :end

    private

      def process_iambic_fully( * )
        super

        scn = @string_scanner
        if ! scn
          scn = Snag_::Library_::StringScanner.new @input_string
          @string_scanner = scn
        end

        @end ||= scn.string.length

        begin_d = nil
        @try_d = 0

        state_a = [

          -> do  # try to parse a string (no newline)

            @try_d += 1  # next time try a hashtag first
              # (whether or not we match here)

            len = scn.skip STRING_RX___

            if len
              @result_for_string[ begin_d, len ]
            end
          end,

          -> do  # try to parse a hashtag

            @try_d = 0  # next time try a string
              # (whether we match a hashtag or a newline here)

            len = scn.skip HASHTAG_RX___

            if len
              @result_for_hashtag[ begin_d, len ]

            else
              len = scn.skip STRING_MULTILINE_RX___
              len or self._SANITY
              @result_for_string[ begin_d, len ]
            end
          end ]

        @p = -> do
          if scn.pos < @end
            begin_d = scn.pos
            begin
              x = state_a.fetch( @try_d )[]
              x and break
              redo
            end while nil
            x
          end
        end

        __init_piece_producers

        ACHIEVED_
      end

      _HASHTAG_ = '#[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*'
      HASHTAG_RX___ = /#{ _HASHTAG_ }/
      STRING_RX___           = /(?:(?!#{ _HASHTAG_ }).)+/
      STRING_MULTILINE_RX___ = /(?:(?!#{ _HASHTAG_ }).)+/m

      def __init_piece_producers

        @result_for_string = _build_piece_producer(
          :@result_for_string, String_Piece )

        @result_for_hashtag = _build_piece_producer(
          :@result_for_hashtag, ( @hashtag_class || Hashtag__ ) )

        NIL_
      end

      def _build_piece_producer ivar, cls

        -> begin_d, len do

          # the first time you build a piece, just build it

          x = cls.new
          x._reinitialize begin_d, len, @string_scanner.string

          instance_variable_set ivar, -> begin_d_, len_ do

            # the second time you build a piece, also just build it

            x_ = cls.new
            x_._reinitialize begin_d_, len_, @string_scanner.string

            a = [ x, x_ ]
            first = true

            instance_variable_set ivar, -> begin_d__, len__ do

              # the third time you build a piece, #note-125

              if first
                first = false
                fly = a.fetch 0
              else
                first = true
                fly = a.fetch 1
              end

              fly._reinitialize begin_d__, len__, @string_scanner.string
              fly

            end

            x_
          end

          x
        end
      end

    public

      def gets
        @p[]
      end

      def change_input_string_ s

        @end = s.length
        @string_scanner.string = s
        @try_d = 0
        NIL_
      end

      attr_reader :string_scanner
    end

    Piece__ = superclass
    Hashtag__ = self

    class Hashtag__  # subclass of Piece__

      def category_symbol
        :hashtag
      end

      def get_stem_string
        @_string[ @_begin + 1, @_length - 1 ]
      end
    end

    class String_Piece < Piece__

      def initialize s=nil
        if s
          _reinitialize 0, s.length, s
        end
      end

      def category_symbol
        :string
      end
    end

    class Piece__

      def _reinitialize begin_, length, s
        @_begin = begin_
        @_length = length
        @_string = s
        NIL_
      end

      def get_string
        @_string[ @_begin, @_length ]
      end

      attr_reader :_begin, :_string
    end

    # ~ begin name-value-scanner extension

    class Stream

      def to_name_value_scanner

        # with every tag piece that we would produce, peek ahead one piece
        #

        if ! @hashtag_class
          @result_for_hashtag = _build_piece_producer(
            :@result_for_hashtag, Hashtag_Possibly_with_Value___ )
        end

        upstream_p = @p
        @p = @main_p = -> do

          pc = upstream_p[]
          if pc
            if @hashtag == pc.category_symbol

              pc_ = upstream_p[]
              if pc_

                if :string == pc_.category_symbol && NAME_VALUE_SEPARATOR__ ==
                    pc_._string.getbyte( pc_._begin )

                  pc = __produce_altered_piece pc_, pc
                else

                  @p = -> do  # "put it back"
                    @p = @main_p
                    pc_
                  end
                end
              end
            end
            pc
          end
        end

        self
      end

      NAME_VALUE_SEPARATOR__ = ':'.getbyte 0

      def __produce_altered_piece pc_, pc  # assume offset 0 has the colon ..

        # .. and assume the name and value are in the same "whole string",
        # which is in the current string scanner..

        scn = @string_scanner
        scn.pos = pc_._begin
        d = scn.skip VALUE_HEAD___
        d or self._SANITY

        x = pc.dup
        x.__receive_knowledge_about_value(
          d,
          scn.skip( VALUE_TAIL___ ) )  # nil IFF colon was last char on the line
        x
      end

      VALUE_HEAD___ = /:[[:space:]]*/
      VALUE_TAIL___ = /[^[:space:],]+/  # might be at end of line
    end

    module Possibly_with_Value_Methods

      attr_reader :value_is_known_is_known, :value_is_known

      def _reinitialize( * )
        @value_is_known = @value_is_known_is_known = nil
        super
      end

      def get_name_string
        @_string[ @_name_r ]
      end

      def get_value_string
        @_string[ @_value_r ]
      end

      def __receive_knowledge_about_value d, d_

        @value_is_known_is_known = true

        name_begin = @_begin
        name_end = name_begin + @_length
        @_name_r = name_begin ... name_end
        if d_
          @value_is_known = true
          value_begin = name_end + d
          @_value_r = value_begin ... value_begin + d_
          @_length += ( d + d_ )
        else
          @_length += d
        end

        NIL_
      end
    end

    class Hashtag_Possibly_with_Value___ < Hashtag__

      include Possibly_with_Value_Methods
    end

    # ~ end name-value-scanner extension

  end
end
