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

      Match__ = -> do

        load = -> do
          Home_.lib_.brazen::CLI::Actors::Build_basic_switch_proc[ SWITCH__ ]
        end
        p = nil

        -> x do
          p ||= load[]
          p[ x ]
        end
      end.call

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
        Home_.lib_.brazen::CLI::Expression_Frames::Table::Actor.call(

          :field,
          :field, :left,
          :header, :none,
          :left, '  ', :sep, '     ', :right, EMPTY_S_,
          :write_lines_to, @y,
          :read_rows_from, @svc.plugins.a_.reduce( [] ) do |row_a, p|
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

        @svc.plugins.a_.each do | pu |
          s = pu.dependency_.opts_moniker
          s and s_a.push s
          s = pu.dependency_.args_moniker
          s and a_a.push s
        end
        [
          ( "[#{ s_a * '] [' }]" if s_a.length.nonzero? ),
          ( "[#{ a_a * '] [' }]" if a_a.length.nonzero? )
        ].compact.join SPACE_
      end
    end
  end
end
