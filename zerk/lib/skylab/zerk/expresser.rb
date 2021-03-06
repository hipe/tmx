module Skylab::Zerk

  class Expresser

    class << self
      alias_method :via_expression_agent, :new
      undef_method :new
    end  # >>

    # -
      def initialize expag

        @_filters_by_channel = nil
        @expression_agent = expag
        @_expression_first_line_string_mapper = nil
      end

      def initialize_copy otr
        if @_filters_by_channel
          self._WAHOO_write_me_by_deep_duping_this_array
        end
      end

      # -- content mapping

      def prefix_first_expression_lines_with s

        @_expression_first_line_string_mapper = -> s_ do
          "#{ s }#{ s_ }"
        end ; nil
      end

      # -- channel-based filtering

      def maybe_ignore_emissions_starting_with * i_a, & p
        _starting_with i_a, p
      end

      def maybe_ignore_emissions_ending_with * i_a, & p
        _ending_with i_a, p
      end

      def ignore_emissions_ending_with * i_a
        _ending_with i_a, MONADIC_FALSEHOOD_
      end

      def _starting_with i_a, p

        _r = 0 ... i_a.length
        _etc _r, i_a, p
      end

      def _ending_with i_a, p

        _r = ( -( i_a.length ).. -1 )
        _etc _r, i_a, p
      end

      def _etc r, i_a, p

        _add_filter_by_channel do |channel|

          if i_a == channel[ r ]
            p
          end
        end
      end

      def _add_filter_by_channel & p

        ( @_filters_by_channel ||= [] ).push p ; nil
      end

      def downstream_stream= io
        @downstream_yielder = ::Enumerator::Yielder.new do |s|
          io.puts s
        end
        io
      end

      attr_writer(
        :downstream_yielder,
      )

      # --

      def finish

        @_determine_pass = if @_filters_by_channel
          :__determine_pass_via_etc
        else
          :__pass_everything
        end

        @_express_expression = if @_expression_first_line_string_mapper
          :__express_expression_via_string_mapper
        else
          :__express_expression_normally
        end

        self
      end

      def listener
        # (if you memoize this you gotta clear it at the `dup`)
        -> * i_a, & ev_p do
          handle i_a, & ev_p
        end
      end

      def handle i_a, & ev_p

        Express_Emission___.new( i_a, ev_p, self ).execute
      end

      attr_reader(
        :_determine_pass,
        :downstream_yielder,
        :_express_expression,
        :expression_agent,
        :_expression_first_line_string_mapper,
        :_filters_by_channel,
      )

    # -
    # ==

    class Express_Emission___

      def initialize i_a, ev_p, up
        @ev_p = ev_p
        @i_a = i_a
        @_ = up
      end

      def execute

        send @_._determine_pass

        if @_pass
          if :expression == @i_a[1]
            send @_._express_expression
          else
            __express_event
          end
        end

        :_unreliable_
      end

      def __pass_everything
        @_pass = true ; nil
      end

      def __determine_pass_via_etc

        p = nil
        @_._filters_by_channel.each do |p_|
          p = p_[ @i_a ]
          p and break
        end
        if p
          @_pass = p[]  # ..
        else
          @_pass = true
        end
        NIL_
      end

      def __express_event

        _event = @ev_p[]
        _event.express_into_under @_.downstream_yielder, @_.expression_agent
        NIL_
      end

      def __express_expression_via_string_mapper

        a = @_.expression_agent.calculate [], & @ev_p
        a[ 0 ] = @_._expression_first_line_string_mapper[ a[0] ]
        a.each do |s|
          @_.downstream_yielder << s
        end
        NIL_
      end

      def __express_expression_normally

        @_.expression_agent.calculate @_.downstream_yielder, & @ev_p

        NIL_
      end
    end

    # ==

    Autoloader_[ self ]
    lazily :NLP_EN_ExpressionAgent do

      # (a weird but parsimonious way to achieve this..

      cls = ::Class.new

      Home_.lib_.human::NLP::EN::SimpleInflectionSession.edit_module cls,
        :public, [
          :and_,
          :both,
          :indefinite_noun,
          :noun_phrase,
          :or_,
          :plural_noun,
          :preterite_verb,
          :progressive_verb,
          :s,
          :sentence_phrase_via_mutable_iambic,
        ]

      cls
    end

    class LEGACY_Brazen_API_TwoStreamEventExpresser

      def initialize * a
        @out, @err, @expag = a
      end

      def maybe_receive_on_channel_event i_a, & ev_p
        ev = ev_p[]
        ev_ = ev.to_event
        if ev_.has_member :ok
          if ev_.ok
            recv_success_event ev
          elsif ev_.ok.nil?
            recv_neutral_event ev
          else
            recv_error_event ev
          end
        else
          recv_info_event ev
        end
      end

      def app_name_string
        @expag.app_name_string
      end

    private

      def recv_success_event ev
        y = ::Enumerator::Yielder.new do |s|
          @out.puts "OK: #{ s }"
        end
        ev.express_into_under y, @expag
        ACHIEVED_
      end

      def recv_error_event ev

        if ev.respond_to? :inflected_verb
          n_s = ev.inflected_noun
          v_s = ev.inflected_verb
          a = [ n_s, v_s ]
          a.compact!
          if a.length.nonzero?
            _to = " to \"#{ a * SPACE_ }\""
          end
        end

        y = ::Enumerator::Yielder.new do |s|
          @err.puts "API call#{ _to } failed: #{ s }"
        end
        ev.express_into_under y, @expag

        UNABLE_
      end

      def recv_info_event ev
        recv_neutral_event ev
      end

      def recv_neutral_event ev
        y = ::Enumerator::Yielder.new do |s|
          @err.puts s
        end
        ev.express_into_under y, @expag
        nil
      end
    end

    # ==
    # ==

    MONADIC_FALSEHOOD_ = -> do
      false
    end

    # ==
  end
end
# #history: reconceived of ANCIENT [br] "two stream expresser" as [ze] "expresser"
#   while assimilating a much newer file, whose content was originally a stowaway in "expression agent"
