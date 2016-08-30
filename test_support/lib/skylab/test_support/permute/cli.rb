module Skylab::TestSupport

  module Permute

    module CLI

      Node_mappings_for_permute_operation = -> o do

        # ~ confirm the constituency of the formal parameters -
        #   make sure it's an identical set for touchiness.
        #   if you turn any of the below to `false`, the parameter is reomved

        h = {
          permutations: nil,
          test_file: nil,
        }

        o.map_these_formal_parameters -> k do
          h.fetch k
        end

        # ~

        o.custom_option_parser_by do |fr|
          Build_custom_option_parser___[ fr ]
        end

        NIL
      end

      Build_custom_option_parser___ = -> fr do

        Require_permute_[]

        copg = Permute_::CLI::CustomOptionParserGeneration.begin_for fr

        fr.remove_positional_argument :permutations

        copg.mutate_didactic_syntax_parts_by do |args|
          args.push '--'
        end

        copg.absorb_a_double_dash

        copg.handle_value_name_stream_by do |vns, rsx|

          # [pe]'s custom o.p is for delivering a stream of normal pairs to
          # its core function (called from its backend) to create the stream
          # of tuples. our o.p, on the other hand, must go that further step
          # and ge to the stream of tuples here.

          if ::Array.try_convert vns  # see similar in [pe]
            vns = Common_::Stream.via_nonsparse_array vns
          end

          _ts  = Permute_::Magnetics::TupleStream_via_ValueNameStream[ vns ]

          _par = fr.formal_parameter :permutations

          _ast = rsx.lib::Assignment.new _ts, _par

          rsx.setter[ NOTHING_, _ast ]
          NIL
        end

        copg.finish
      end

      Require_permute_ = Lazy_.call do
        Permute_ = Home_.lib_.permute ; nil
      end
    end
  end
end
