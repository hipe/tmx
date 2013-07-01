module Skylab::Test

  class Plugins::Divide

    class Worker_

      include Test::Agent_IM_

      Field_ = Test::Field_

      def self.[] *a
        new( *a ).execute
      end

      Syntax_ = MetaHell::FUN.parse_series.curry[
        :syntax, :monikizer, -> a { a * ' ' },
        :field, :monikizer, -> s { "[ #{ s } ]" },
        :field, :moniker, '<integer>',
          :token_scanner, Field_::Int_::Scan_token,
        :field, * Field_::Flag_[ :random ].to_a,
        :prepend_to_curry_queue, :exhaustion
      ]

      def initialize host_svcs, argv
        out, err = host_svcs[ :paystream, :infostream ]
        validate = -> do
          argv or break true  # defaults..
          ok = true ; bork = -> msg do
            err.puts msg
            ok &&= false
          end
          integer, kw = Syntax_[ -> e do
            ok and bork[ "expecting arguments #{ e.syntax_proc.call }" ]  # once
            bork[ e.message_function.call ]
          end, argv ]
          ok or break bork[ "please correct the above and try again." ]
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
          divs = Divide::Divider_.new( err: err, subtree_provider: host_svcs,
                                       is_random: kw, count: integer ).divide
          render[ divs ]
        end
      end

      def execute ; @execute.call end
    end
  end
end
