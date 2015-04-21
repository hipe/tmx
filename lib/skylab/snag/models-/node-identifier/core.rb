module Skylab::Snag

  class Models_::Node_Identifier

    Actions = THE_EMPTY_MODULE_

    class << self

      def new_via_integer d
        new nil, d
      end

      def new_via_integer_and_suffix_string d, s

        new NI_::Models_::Suffix.interpret_out_of_under_( s, :String ), d
      end

      define_method :interpret_out_of_under, INTERPRET_OUT_OF_UNDER_METHOD_

    end  # >>

    CLOSE_SEQUENCE__ = ']'
    Parse__ = ::Module.new
    OPEN_SEQUENCE__ = '[#'

    Expression_Adapters = ::Module.new

    module Expression_Adapters::Byte_Stream

      # parsing the byte stream is like parsing the user argument but:
      #   • minus error reporting (because syntax) -AND-
      #   • plus the requirement of the open and close sequence

      class << self

        def build_reinterpreter scn

          -> node_id do

            pos = scn.pos

            if scn.skip OPEN_SEQUENCE_RX___

              ok = _reinit_object_via_parse_identifier_and_any_suffix(
                node_id,
                scn )

              if ok
                ok = scn.skip CLOSE_SEQUENCE_RX___
              end

              if ! ok
                scn.pos = pos
              end
            end

            ok
          end
        end
      end  # >>

      CLOSE_SEQUENCE_RX___ = /#{ ::Regexp.escape CLOSE_SEQUENCE__ }/
      OPEN_SEQUENCE_RX___ = /#{ ::Regexp.escape OPEN_SEQUENCE__ }/

      extend Parse__

      class << self

        def express_into_under_of_ y, expag, id

          y << "#{ OPEN_SEQUENCE__ }#{
            "%0#{ expag.identifier_integer_width }d" % id.to_i
            }#{ CLOSE_SEQUENCE__ }"
        end
      end  # >>
    end

    module Expression_Adapters::User_Argument

      # parsing the user argument is like parsing the "byte upstream" but:
      #   • plus error reporting -AND-
      #   • minus the recognition of the open and close sequence

      class << self

        def interpret_out_of_under_ arg, _, & oes_p

          x = arg.value_x
          if x

            o = NI_.new

            ok = if x.respond_to? :bit_length

              __reinit_object_via_number o, x, & oes_p

            else

              _reinit_object_via_parse_identifier_and_any_suffix(
                o,
                Snag_::Library_::StringScanner.new( x ),
                & oes_p )
            end

            ok and arg.new_with_value o
          else
            arg
          end
        end
      end  # >>

      extend Parse__
    end

    module Parse__

      def _reinit_object_via_parse_identifier_and_any_suffix id, scn, & oes_p

        d_s = scn.scan DIGITS___
        if d_s

          if scn.eos?
            yes = true
          else
            pos = scn.pos
            sfx = NI_::Models_::Suffix.interpret_out_of_under_(
              scn, :Byte_Stream, & oes_p )

            if sfx
              yes = true
            elsif oes_p
              yes = false
            else

              # this will end up begin a non-busines line

              scn.pos = pos
              yes = true
            end
          end

          if yes
            id.reinitialize sfx, d_s.to_i
          end
        elsif oes_p

          yes = false
          oes_p.call :error, :parse_error, :expecting_number do
            __build_etc_event scn.string
          end
        end

        yes
      end

      DIGITS___ = /\d+/

      def __reinit_object_via_number id, d

        id.reinitialize nil, d
        ACHIEVED_
      end

      def __build_etc_event x

        Snag_.lib_.brazen.model.entity.normalizers.number.new_event(  # #todo
          :against_value, x,
          :property_name_symbol, :node_identifier_number_component,
          :minimum, 0,
          :number_set, :integer )
      end
    end

    def reinitialize suffix_o=nil, d=nil
      @suffix = suffix_o
      @to_i = d
    end

    alias_method :initialize, :reinitialize

    attr_reader :suffix, :to_i

    define_method :express_into_under, EXPRESS_INTO_UNDER_

    def == otr
      ( self <=> otr ).zero?
    end

    alias_method :eql?, :==

    include ::Comparable

    def <=> otr
      if otr.kind_of? NI_
        d = @to_i <=> otr.to_i
        if d.zero?
          o = @suffix
          o_ = otr.suffix
          if o
            if o_
              o <=> o_
            else
              1
            end
          elsif o_
            -1
          else
            d
          end
        else
          d
        end
      end
    end

    # ~ begin suffixes

    def suffix_separator_at_index d
      if @suffix
        @suffix.separator_at_index d
      end
    end

    def suffix_value_at_index d
      if @suffix
        @suffix.value_at_index d
      end
    end

    # ~ end suffixes

    module Expression_Adapters
      EN = nil
    end

    NI_ = self
  end
end
