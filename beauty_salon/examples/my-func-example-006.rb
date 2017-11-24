module Skylab::BeautySalon

  CrazyTownFunctions::MyFuncExample006 = -> sn do  # sn = structured node

    # this is the first *non-trivial* replacement function we wrote for a
    # real production use of this whole doo-hah.
    #
    #   - it replaces oldschool uses of `should` with newschool uses
    #     of `expect( .. ).to`
    #
    #   - we're adding it to start tracking small changes we make to it,
    #     some that reflect features that perhaps aren't quite covered yet;
    #     but that we discuss in the birth commit.
    #
    #   - we call it "non-trivial" because it's not just renaming a method
    #     or similar; it's actually changing the feature structurally
    #
    #   - note that when there is no receiver for `should`, we "correctly"
    #     do nothing. (it seems that these very oldschool uses of it
    #     with `specify` are still OK.)
    #
    #   - one way this could be improved is to break it up the replacement
    #     *string* into multiple lines, but yikes eyeblood will cometh
    #
    # when we run it, it happens as an alias calling an alias or somesuch,
    # but here is roughly the complete command we are using:
    #
    #     tmx-beauty-salon crazy-town replace \
    #       -code-selector "send(method_name=='should')" \
    #       -replacement-function file:beauty_salon/examples/my-func-example-006.rb \
    #       -whole-word-filter should \
    #       -file some_sidesystem/test

    rcvr = sn.any_receiver_expression
    list = sn.zero_or_more_arg_expressions

    1 == list.length || ok_fine_whatever
    _arg1 = list.dereference 0

    _arg_code = _arg1.to_code_LOSSLESS_EXPERIMENT__

    if rcvr

      _rcvr_code = rcvr.to_code_LOSSLESS_EXPERIMENT__

      "expect( #{ _rcvr_code } ).to #{ _arg_code }"  # yikes
    else
      NOTHING_
    end
  end
end
# #born.
