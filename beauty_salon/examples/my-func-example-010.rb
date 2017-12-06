module Skylab::BeautySalon

  class CrazyTownFunctions::MyFuncExample010 < Common_::Monadic

    # here's an experiment to see what it feels like to write the
    # replacement "function" as a "magnetic" ("actor"-ish) pattern, which
    # (in theory) can make the code more readable, at a cost of length.
    #
    # this was used in real life, for the second ever large-scale
    # programmatic search-and-replace.

    # for example:
    #     ct replace -code-selector "send(method_name=='via_array')" \
    #       -replacement-function file:beauty_salon/examples/my-func-example-010.rb \
    #       -whole-word-filter via_array -file zerk

    def initialize sn
      @structured_node = sn
      @stderr = $stderr  # #wish [#007.Y]
    end

    def execute
      if __receiver_looks_right
        __go_money
      end
    end

    def __really_go_money
      _wow = @__arg.to_code_LOSSLESS_EXPERIMENT_
      "Home_::Stream_[ #{ _wow } ]"
    end

    def __go_money
      list = @structured_node.zero_or_more_arg_expressions
      if 1 == list.length
        @__arg = list.dereference 0  # #wish [#007.W] - more elegant doo hah
        __really_go_money
      else
        _mention "SKIPPING MULTI ARGS GUY"
      end
    end

    def __receiver_looks_right
      rcvr = @structured_node.any_receiver_expression
      if rcvr
        nt_sym = rcvr._node_type_
        if :const == nt_sym
          c = rcvr.symbol  # const
          if :Stream == c
            # NOTE - we don't actally need the receiver any more
            ACHIEVED_
          else
            _mention "ingoring receiver with const name of #{ c }"
          end
        else
          _mention "ignoring receiver that is this grammar symbol type: #{ nt_sym }"
        end
      else
        _mention "(didn't have receiver, skipping)"
      end
    end

    def _mention msg
      @stderr.puts msg
      STOP_
    end
  end
end
# #born.
