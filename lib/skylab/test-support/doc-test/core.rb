module Skylab::TestSupport

  module DocTest  # see [#015]

    # synopsis:
    #
    # these first few lines of a text span, you can write whatever you want &
    # they will not appear in the generated spec file. the last line however,
    # will appear as the description string of your context or example.
    #
    #     THIS_FILE_ = TestSupport_::Expect_Line::File_Shell[ __FILE__ ]
    #
    #     # this comment gets included in the output because it is indented
    #     # with four or more spaces and is part of a code span that goes out.
    #
    #
    # now that we are back under four spaces in from our local margin, this
    # is again a text span. the previous code span is treated as a before
    # block because it has no magic "# =>" predicate sequence. it becomes a
    # before `all` block because it looks like it starts with a constant
    # assignment.
    #
    # this line here is the description for the following example
    #
    #     o = THIS_FILE_
    #
    #     o.contains( "they will not#{' '}appear" ) # => false
    #
    #     o.contains( "will appear#{' '}as the description" )  # => true
    #
    #     o.contains( "this comment#{' '}gets included" )  # => true
    #
    #     o.contains( "this line#{' '}here is the desc" )  # => true
    #
    #
    # we now strip trailing colons from these description lines:
    #
    #     THIS_FILE_.contains( 'from these description lines"' ) # => true

    module API

      class << self

        def call * x_a, & oes_p

          # don't ever write events to stdout / stderr by default.

          if oes_p
            x_a.push :on_event_selectively, oes_p
          elsif x_a.length < 2 || :on_event_selectively != x_a[ -2 ]
            x_a.push :on_event_selectively, -> i, *, & ev_p do
              if :error == i
                raise ev_p[].to_event.to_exception
              end
            end
          end

          bc = DocTest_.application_kernel_.bound_call_via_mutable_iambic x_a
          bc and bc.receiver.send bc.method_name, * bc.args
        end

        def expression_agent_class
          Brazen_::API.expression_agent_class
        end
      end  # >>
    end

    class << self

      define_method :application_kernel_, ( Callback_.memoize do
        Brazen_::Kernel.new DocTest_
      end )

      def comment_block_stream_via_line_stream_using_single_line_comment_hack x
        DocTest_::Input_Adapters__::
          Comment_block_stream_via_line_stream_using_single_line_comment_hack[ x ]
      end

      def get_output_adapter_slug_array
        self::Output_Adapters_.entry_tree.to_stream.map_by do | et |
          et.name.as_slug
        end.to_a
      end
    end  # >>

    # ~ support for parsing

    class State_Machine_  # ( mentors :+[#ba-044] )

      def initialize & p
        @h = {}
        sess = Edit_Session__.new method :receive_state_
        sess.instance_exec( & p )
      end

      class Edit_Session__

        def initialize p
          @p = p
        end

        def o symbol, h
          @p[ State_.new h, symbol ]
          nil
        end
      end

      def receive_state_ state
        @h[ state.symbol ] = state
        nil
      end

      def fetch symbol
        @h.fetch symbol
      end
    end

    class State_

      class << self
        alias_method :[], :new
      end

      def initialize h, symbol=nil
        @i_i_h = h
        @symbol = symbol
      end

      attr_reader :symbol

      def method_name_for_state state_symbol
        @i_i_h.fetch state_symbol do
          when_key_not_found state_symbol
        end
      end

    private

      def when_key_not_found x

        if @symbol
          _for_symbol = " for '#{ @symbol }'"
        end

        raise ::KeyError, "key not found#{ _for_symbol }: #{ x.inspect }"

      end
    end

    module Intermediate_Streams_

      module Node_stream_via_comment_block_stream

        class << self
          def [] cb_stream
            x = Self_::Span_stream_via_comment_block__[ cb_stream ]
            x and Self_::Node_stream_via_span_stream__[ x ]
          end
        end

        Self_ = self
        Autoloader_[ self ]
      end

      module Models_
        Autoloader_[ self ]
      end

      Autoloader_[ self ]
    end

    module Output_Adapters_
      Autoloader_[ self ]
    end

    module Lazy_Selective_Event_Methods_

    private

      def build_not_OK_event_with * x_a, & msg_p
        Callback_::Event.
          inline_not_OK_via_mutable_iambic_and_message_proc x_a, msg_p
      end

      def build_neutral_event_with * x_a, & msg_p
        Callback_::Event.
          inline_neutral_via_mutable_iambic_and_message_proc x_a, msg_p
      end

      def maybe_send_event * i_a, & ev_p
        @on_event_selectively[ * i_a, & ev_p ]
      end

      def handle_event_selectively
        @on_event_selectively
      end
    end

    class Parameter_Function_

      class << self

        def arity
          instance_method( :initialize ).arity
        end

        def call gen, * a, & oes_p
          new( gen, * a, & oes_p ).execute
        end

        attr_reader :description_proc

      private

        def description & p
          @description_proc = p ; nil
        end
      end

      def initialize gen, & oes_p
        @generation = gen
        @on_event_selectively = oes_p
      end

      def execute
        _ok = normalize
        _ok && flush
      end

    private

      def build_unrecognized_param_arg ok_x_a
        TestSupport_.lib_.entity.properties_stack.
          build_extra_properties_event(
            [ @value_x ],
            ok_x_a,
            "parameter argument" )
      end

      def maybe_send_event * i_a, & oes_p
        @on_event_selectively.call( * i_a, & oes_p )
      end

      Build_property_for_function = -> category, prop_cls, x, sym do  # #curry-friendly

        argument_arity_symbol = case x.arity
        when 1 ; :zero
        when 2 ; :one
        end

        if argument_arity_symbol

          if x.respond_to? :description_proc
            desc_p = x.description_proc  # might be nil
          end

          prop_cls.new do

            @name = Callback_::Name.via_const sym
            @argument_arity = argument_arity_symbol
            @origin_category = category

            if desc_p
              accept_description_proc desc_p
            end
          end
        end
      end
    end

    Mutate_string_by_removing_trailing_dashes_ = -> s do
      s.gsub! Callback_::Name::TRAILING_DASHES_RX, EMPTY_S_  # ick/meh
      nil
    end

    class Shared_Resources_

      def initialize
        @h = {}
      end

      def fetch * i_a, & p
        touch_tail_hash( i_a ).fetch( i_a.last, & p )
      end

      def cached * i_a, & build_p
        h = touch_tail_hash i_a
        h.fetch i_a.last do
          h[ i_a.last ] = build_p[]
        end
      end

      def cache * i_a, x
        touch_tail_hash( i_a )[ i_a.last ] = x
        nil
      end

      def touch_head_hash i
        @h.fetch i do
          @h[ i ] = {}
        end
      end

    private

      def touch_tail_hash i_a
        i_a[ 0 .. -2 ].reduce @h do | m, i |
          m.fetch i do
            m[ i ] = {}
          end
        end
      end
    end

    Brazen_ = TestSupport_.lib_.brazen
    BLANK_RX_ = /\A[[:space:]]*\z/
    DocTest_ = self
    IDENTITY_ = -> x { x }
  end
end
