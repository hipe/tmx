module Skylab::Snag

  class Models_::NodeIdentifier

    ExpressionAdapters = ::Module.new

    class << ( ExpressionAdapters::ByteStream = ::Module.new )

      # parsing the byte stream is like parsing the user argument but:
      #   • minus error reporting (because of its syntax) -AND-
      #   • plus the requirement of the open and close sequence

      def build_reinterpreter scn

        -> node_id do

          d = scn.pos

          if scn.skip OPEN_SEQUENCE_RX___

            ok = Parse__[ node_id, scn ]

            if ok
              ok = scn.skip CLOSE_SEQUENCE_RX___
            end

            if ! ok
              scn.pos = d
            end
          end

          ok
        end
      end

      def express_into_under_of_ y, expag, id

        y << ExpressionAdapters::CLI.express_of_via_under( expag )[ id ]
      end
    end  # >>

    module ExpressionAdapters::CLI ; class << self

      def express_of_via_under expag

        fmt = "%0#{ expag.identifier_integer_width }d"

        -> id do

          sfx = id.suffix
          if sfx
            _sfx = sfx.express_into_under "", expag
          end

          "#{ OPEN_SEQUENCE__ }#{
          }#{ fmt % id.to_i }#{
          }#{ _sfx }#{
          }#{ CLOSE_SEQUENCE__ }"
        end
      end
    end ; end

    CLOSE_SEQUENCE__ = ']'
    OPEN_SEQUENCE__ = '[#'

    CLOSE_SEQUENCE_RX___ = /#{ ::Regexp.escape CLOSE_SEQUENCE__ }/
    OPEN_SEQUENCE_RX___ = /#{ ::Regexp.escape OPEN_SEQUENCE__ }/

    class << self

      # parsing the user value is like parsing "byte upstream" (below) but:
      #   • plus error reporting -AND-
      #   • minus the recognition of the open and close sequence

      def new_via_user_value_ x, & oes_p

        # (oldschool handler b.c we bridge the gap between [br] and [co] API)

        oes_p_p = -> _ do
          oes_p
        end

        if x
          if x.respond_to? :bit_length
            edit_entity :set, :integer, x, & oes_p_p
          else

            id = new
            _scn = Home_::Library_::StringScanner.new x

            ok = Parse__[ id, _scn, & oes_p_p ]

            ok && id
          end
        else
          x
        end
      end

      def new_via__object__ x  # ..
        x
      end

      alias_method :new_empty, :new

      def new_via_integer d
        new nil, d
      end

      def new_via__integer__ d
        new nil, d
      end

      def new_via__suffix_and_integer__ x, x_
        new x, x_
      end

      def edit_entity * x_a, & oes_p_p

        ACS_[].create x_a, new, & oes_p_p
      end

      # ~ (for existing entities)

      def express_into_under_of_ y, expag, id

        _s = if expag.respond_to? :identifier_integer_width

          "%0#{ expag.identifier_integer_width }d" % id.to_i
        else
          id.to_i.to_s
        end

        sfx = id.suffix
        if sfx
          _s_ = sfx.description_under expag
        end

        y << "#{ OPEN_SEQUENCE__ }#{ _s }#{ _s_ }#{ CLOSE_SEQUENCE__ }"
      end

      private :new
    end  # >>

    Parse__ = ::Module.new
    class << Parse__  # experiment: stateless actor

      def [] id, scn, & oes_p_p

        d_s = scn.scan DIGITS___

        if d_s
          if scn.eos?
            id.reinitialize nil, d_s.to_i
            ACHIEVED_
          else
            __something_after_digit d_s.to_i, id, scn, & oes_p_p
          end
        else
          if oes_p_p
            _oes_p = oes_p_p[ nil ]
            _oes_p.call :error, :parse_error, :expecting_number do
              __build_uninterpretable_as_integer_event scn.string
            end
          end
          UNABLE_
        end
      end

      DIGITS___ = /\d+/

      def __build_uninterpretable_as_integer_event x

        Home_.lib_.basic::Number::Uninterpretable.new_with(
          :x, x,
          :property_name_symbol, :node_identifier_number_component,
          :minimum, 0,
          :number_set, :integer,
          :general_failure )

      end

      def __something_after_digit integer_d, id, scn, & x_p

        sfx = Here_::Models_::Suffix::Interpret[ scn, :ByteStream, & x_p ]

        if sfx
          id.reinitialize sfx, integer_d
          ACHIEVED_

        elsif x_p  # if error reporing was requested, it was delivered
          UNABLE_

        else  # take what we scanned and leave the rest for caller

          id.reinitialize nil, integer_d
          ACHIEVED_
        end
      end
    end  # >>

    # ~ initialization & related

    def reinitialize suffix_o=nil, d=nil

      @suffix = suffix_o
      @to_i = d
    end

    alias_method :initialize, :reinitialize

    def reinitialize_copy_ fly

      @suffix = fly.suffix
      @to_i = fly.to_i
      NIL_
    end

    def initialize_copy _
      # hello - nothing to do (i.e. assume constituents don't mutate)
      NIL_
    end

    # ~ ACS for creation & editing

    def __suffix__component_association

      yield :can, :set

      Here_::Models_::Suffix
    end

    def __integer__component_association

      yield :can, :set
      yield :stored_in_ivar, :@to_i

      Integer_component_model___[]
    end

    Integer_component_model___ = Common_.memoize do

      # expirimental near :+[#ba-050]
      # ->

        _n11n = Home_.lib_.basic::Number.normalization.new_with(
          :minimum, 1,
          :number_set, :integer,
        )
        # <-

      ACS_[]::Model::Via_normalization[ _n11n ]
    end

    def __set__component qk, & _x_p

      instance_variable_set qk.name.as_ivar, qk.value_x
      ACHIEVED_
    end

    # ~ outward reflection

    def description_under expag

      express_into_under expag.new_expression_context, expag
    end

    def express_under expag

      express_into_under expag.new_expression_context, expag
    end

    def express_into_ y

      y << OPEN_SEQUENCE__
      y << @to_i.to_s
      if @suffix
        @suffix.express_into_ y
      end
      y << CLOSE_SEQUENCE__
    end

    def == otr
      d = self <=> otr
      if d
        d.zero?
      else
        false
      end
    end

    alias_method :eql?, :==

    include ::Comparable

    def <=> otr
      if otr.kind_of? Here_
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

    attr_reader(
      :suffix,
      :to_i,
    )

    include Expression_Methods_

    ExpressionAdapters::EN = nil

    Here_ = self
  end
end
