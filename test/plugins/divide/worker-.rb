module Skylab::Test

  class Plugins::Divide

    class Worker_

      include Test::Agent_IM_

      def self.[] *a
        new( *a ).execute
      end

      def initialize host_svcs, argv
        out, err = host_svcs[ :paystream, :infostream ]
        validate = -> do
          argv or break true  # defaults..
          ok = true ; bork = -> msg do
            err.puts msg
            ok &&= false
          end
          integer, kw = MetaHell::FUN._parse_series[
            [ -> x { /\A\d+\z/ =~ x },
              -> x { /\A[a-z]+\z/i =~ x } ],
            -> e do
              ok and bork[  # only once
                "expecting arguments [ <integer> ] [ random ]" ]
              bork[ e.message_function.call ]
            end,
            argv
          ]
          ok or break bork[ "please correct the above and try again." ]
          if kw
            ( idx = 'random'.index kw ) && ( idx.zero? ) or break bork[
              "for now, only 'random' is supported, not #{ kw.inspect }" ]
            kw = :random
          end
          integer and integer = integer.to_i
          [ ok, integer, kw ]
        end

        render = -> divs do
          pname = host_svcs.full_program_name
          divs.each do |div|
            out.puts "#{ pname } #{
              }#{ div.map { |subpro| subpro.local_normal_name } * ' ' }"
          end
          nil
        end

        @execute = -> do
          ok, integer, kw = validate[]
          ok or break ok
          divs = Divide::Divider_.new( err, host_svcs, integer, kw ).divide
          render[ divs ]
        end
      end

      def execute ; @execute.call end
    end
  end
end
