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


    Bzn_ = TestSupport_::Lib_::Bzn_[]

    class << self

      def comment_block_stream_via_line_stream_using_single_line_comment_hack x
        DocTest_::Input_Adapters__::
          Comment_block_stream_via_line_stream_using_single_line_comment_hack[ x ]
      end
    end

    module API

      extend Bzn_::API.module_methods

      class << self

        def call * x_a, & oes_p

          # don't ever write events to stdout / stderr by default.

          if oes_p
            x_a.push :on_event_selectively, oes_p
          elsif x_a.length < 2 || :on_event_selectively != x_a[ -2 ]
            x_a.push :on_event_selectively, -> i, *, & ev_p do
              if :error == i
                raise ev_p[].to_exception
              end
            end
          end
          super( * x_a, & nil )
        end

        def expression_agent_class
          Bzn_::API.expression_agent_class
        end
      end
    end

    class Kernel_ < Bzn_::Kernel_  # #todo

    end

    # ~ support for parsing

    class State_
      class << self
        alias_method :[], :new
      end

      def initialize h
        @i_i_h = h
      end

      def method_name_for_state state_symbol
        @i_i_h.fetch state_symbol
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
        TestSupport_._lib.event_lib.
          inline_not_OK_via_mutable_iambic_and_message_proc x_a, msg_p
      end

      def build_neutral_event_with * x_a, & msg_p
        TestSupport_._lib.event_lib.
          inline_neutral_via_mutable_iambic_and_message_proc x_a, msg_p
      end

      def maybe_send_event * i_a, & ev_p
        @on_event_selectively[ * i_a, & ev_p ]
      end

      def handle_event_selectively
        @on_event_selectively
      end
    end

    BLANK_RX_ = /\A[[:space:]]*\z/

    DASH_ = '-'.freeze

    DocTest_ = self

    IDENTITY_ = -> x { x }

    UNDERSCORE_ = '_'.freeze
  end
end
