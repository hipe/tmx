module Skylab::TestSupport

  module Quickie

    class Plugins::Help

      def initialize svc
        @svc = svc
        @y = svc.y
      end

      def opts_moniker
        SWITCH_
      end

      SWITCH_ = '--help'.freeze

      Match_ = Index_[ SWITCH_ ]

      def args_moniker
      end

      def desc y
        y << "this screen"
        nil
      end

      def prepare sig
        if (( idx = Match_[ sig.input ] ))
          sig.input[ idx ] = nil
          sig.carry :BEGINNING, :FINISHED
          sig
        end
      end

      def beginning_eventpoint_notify
        usage
        @y << "options:"
        fun = TestSupport_::Services::Face::CLI::Table::FUN
        fun.tablify[
          [[ :fields, [ :arg, :desc ]],
           [ :show_header, false ],
           [ :left, '  ' ], [ :right, '' ], [ :sep, ' |  ' ]],
          @y.method( :<< ),
          @svc.plugins._a.reduce( [] ) do |row_a, p|
            fun.multiline_column_b[ row_a, p.syntax_moniker, p.some_desc_a ]
            row_a
          end ]
        nil
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
