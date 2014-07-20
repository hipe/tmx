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

      Match__ = QuicLib_::CLI_basic_switch_index[ SWITCH__ ]

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
        TestSupport_::Lib_::CLI_table[
          :field, :field, :left, :show_header, false,
          :left, '  ', :sep, '     ', :right, '',
          :write_lines_to, @y.method( :<< ),
          :read_rows_from, @svc.plugins._a.reduce( [] ) do |row_a, p|
            Multiline_column_B__[ row_a, p.syntax_moniker, p.some_desc_a ]
            row_a
          end ]
        nil
      end

      Multiline_column_B__ = -> row_a, cel_a, a do
        col_a = [ cel_a ]
        if a.length.zero?
          col_a << ''
        else
          col_a << a.fetch( 0 )
        end
        row_a << col_a
        if 1 < a.length
          row_a.concat a[ 1 .. -1 ].map { |s| [ '', s ] }
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
        ].compact.join ' '
      end
    end
  end
end
