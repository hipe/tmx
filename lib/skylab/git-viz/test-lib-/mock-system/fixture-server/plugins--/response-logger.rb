module Skylab::GitViz

  class Test_Lib_::Mock_System::Fixture_Server

    class Plugins__::Response_Logger

      def initialize client
        @y = client.stderr_line_yielder
        @default_max_width_s = '444'  # historical not whimsical
        @max_width_s = @default_max_width_s
      end

      def on_build_option_parser op
        op.on '--max-width=<m>',
          "what is the threshold for the line width at which #{
            }lines get", "truncated when logging the responses? #{
             }(default: #{ @default_max_width_s }) more may", "be useful #{
              }when debugging, less if the output seems crufty." do |s|
             @max_width_s = s
        end
        PROCEDE_
      end

      def on_options_parsed
        if /\A\d+\z/ =~ @max_width_s
          @max_width_d = @max_width_s.to_i
          PROCEDE_
        else
          @y << "fatal: invalid --max-width: #{ @max_width_s.inspect }"
          GENERAL_ERROR_
        end
      end

      def on_response s_a  # obnoxiously truncate long responses from log
        buffer_a = [] ; d = -1
        last = s_a.length - 1 ; length = 0 ; limit = @max_width_d
        while true
          d < last or break( last_reached = true )
          str = s_a.fetch( d += 1 ).inspect
          next_length = length + 2 + str.length  # ', '.length
          case next_length <=> limit
          when -1 ; buffer_a << str
          when  0 ; buffer_a << str ; break
          when  1 ; limit_reached = true ; break
          end
          length = next_length
        end
        s = "#{ buffer_a * ', ' }#{ '[..]' if ! last_reached && limit_reached }"
        @y << "sending back an array of #{ last + 1 } string(s): [#{ s }]"
        PROCEDE_
      end
    end
  end
end
