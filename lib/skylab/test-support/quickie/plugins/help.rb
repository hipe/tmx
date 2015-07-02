module Skylab::TestSupport

  module Quickie

    class Plugins::Help

      def initialize svc
        @fuzzy_flag = svc.build_fuzzy_flag %w( -help )
        @svc = svc
        @y = svc.y
      end

      def opts_moniker
        @fuzzy_flag.some_opts_moniker
      end

      SWITCH__ = '--help'.freeze

      Match__ = QuicLib_::CLI_lib[].option.basic_switch_index_curry SWITCH__

      def args_moniker
      end

      def desc y
        y << "this screen" ; nil
      end

      def prepare sig
        idx = @fuzzy_flag.any_first_index_in_input sig
        if idx
          sig.nilify_input_element_at_index idx
          sig.carry :BEGINNING, :FINISHED
          sig
        end
      end

      def beginning_eventpoint_notify
        usage
        @y << "options:"
        Home_.lib_.CLI_table(
          :field, :field, :left, :show_header, false,
          :left, '  ', :sep, '     ', :right, EMPTY_S_,
          :write_lines_to, @y,
          :read_rows_from, @svc.plugins._a.reduce( [] ) do |row_a, p|
            Multiline_column_B__[ row_a, p.syntax_moniker, p.some_desc_a ]
            row_a
          end )
        nil
      end

      Multiline_column_B__ = -> row_a, cel_a, a do
        col_a = [ cel_a ]
        if a.length.zero?
          col_a.push EMPTY_S_
        else
          col_a.push a.fetch 0
        end
        row_a << col_a
        if 1 < a.length
          row_a.concat a[ 1 .. -1 ].map { |s| [ EMPTY_S_, s ] }
        end ; nil
      end

      def usage  # may be called directly
        @y << "usage: #{ @svc.program_moniker } #{ get_syntax_string }"
        nil
      end

    private

      def get_syntax_string
        s_a = [ ] ; a_a = [ ]
        @svc.plugins._a.each do |p|
          s = p.client.opts_moniker and s_a << s
          s = p.client.args_moniker and a_a << s
        end
        [
          ( "[#{ s_a * '] [' }]" if s_a.length.nonzero? ),
          ( "[#{ a_a * '] [' }]" if a_a.length.nonzero? )
        ].compact.join SPACE_
      end
    end
  end
end
