module Skylab::Test

  class Plugins::Divide

    class Worker_

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
          integer, kw = Syntax_[ -> e do
            ok and bork[ "expecting arguments #{ e.syntax_proc.call }" ]  # once
            bork[ e.message_proc.call ]
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

      _Parse = Test_::Lib_::Parse_lib[]

      fields = _Parse.fields

      Syntax_ = _Parse.series.curry[
        :syntax, :monikate, -> a { a * ' ' },
        :field, :monikate, -> s { "[ #{ s } ]" },
        :field, :moniker, '<integer>',
        :token_scanner, fields.int.scan_token,
        :field, * fields.flag( :random ).to_a,
        :prepend_to_uncurried_queue, :exhaustion ]

      def execute
        @execute.call
      end
    end
  end
end
