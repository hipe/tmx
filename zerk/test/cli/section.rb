module Skylab::Zerk::TestSupport

  # (currently CLI::Section is produced by the node loader)

  module CLI::Section::DSL

    def self.[] tcc
      tcc.include self
    end

    # -

      def yield_ * x_a
        @subject.receive x_a
      end

      def moniker_ sym
        -> expag do
          expag.calculate do
            highlight sym.id2name.upcase
          end
        end
      end

      def desc_ sym, d
        Desco__.new sym, d
      end

      def begin_invex_ sta
        _expag = Home_.lib_.brazen::API.expression_agent_instance
        # we need it because `highlight`
        Invex___.new sta, _expag, self
      end

      def subject_class_
        Subject_library__[]::DSL
      end

      def _My_State
        My_State___
      end

    # -

    # ==

    class Invex___  # "invocation expression"

      # not quite a mock, this is a recording { fake | stub }

      def initialize sta, ex, tc

        @__linecount = 0
        line_a = []
        sta.lines = line_a

        @__evp_h = {}
        sta.eventpoint_indexes = @__evp_h

        @expression_agent = ex

        _y = ::Enumerator::Yielder.new do |s|

          if ! s
            self._SANITY
          end

          if tc.do_debug
            tc.debug_IO.puts s
          end

          @__linecount += 1
          line_a.push Line___.new s
        end

        @_vendor = Subject_library__[]::Expression.new _y, ex
      end

      def express_section * x_a, & x_p
        _hi = @_vendor.express_section_via x_a, & x_p
        _hi
      end

      attr_reader(
        :expression_agent,
      )

      def option_parser
        OP_Metrics___[]
      end

      # --

      def _at_this_point_ sym
        @__evp_h[ sym ] = @__linecount
      end
    end

    # ==

    My_State___ = ::Struct.new(
      :eventpoint_indexes,
      :lines,
      :result,
      :screen,
    )

    # ==

    class Line___

      def initialize s
        @string = s
      end

      def is_blank
        @string =~ BLANK_RX___
      end

      attr_reader(
        :string,
      )

      BLANK_RX___ = /\A$/  # be indifferent to newlines (#cp of vendor)
    end

    # ==

    class Desco__

      def initialize sym, d

        @description_proc = -> y do

          y << "#{ highlight( sym.id2name ) } line 1"

          ( d - 1 ).times do |d_|
            y << "#{ sym } line #{ d_ + 2 }"
          end
          y
        end
      end

      attr_reader(
        :description_proc,
      )
    end

    # ==

    OP_Metrics___ = Lazy_.call do
      Metrics_as_Option_Parser___.new 3, 16
    end

    class Metrics_as_Option_Parser___  # :#spot-2

      def initialize si_d, si_w
        @_si_s = SPACE_ * si_d
        @_sw = si_w
      end

      def summary_indent
        @_si_s
      end

      def summary_width
        @_sw
      end
    end

    # ==

    Subject_library__ = -> do
      Home_::CLI::Section
    end

    # ==
  end
end
# #history: moved here from [br]
