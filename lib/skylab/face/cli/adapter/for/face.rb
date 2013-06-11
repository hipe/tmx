module Skylab::Face

  module Face::CLI::Adapter::For::Face

    Hotmm_ = -> slug, lo_class, arg_sht_f do  # hot maker maker
      -> hi_svcs, _slug_used_str=nil do
        pna = hi_svcs.get_normal_invocation_string_parts
        pna << slug
        h = {
          out: ( hi_svcs.ostream or fail "sanity - out?" ),
          err: ( hi_svcs.estream or fail "sanity - err?" ),
          program_name: ( pna * ' ' ),
          sheet: arg_sht_f[]
        }
        lo_class.new( h ).instance_variable_get :@mechanics
      end
    end

    module Of

      Sheet = -> hi_sheet, lo_sheet do
        Face::Namespace::Adapter::For::Face::Ouroboros_Sheet[
          hi_sheet, lo_sheet ]
      end

      Hot = -> hi_sheet, lo_cli_class do
        Hotmm_[ hi_sheet.name.as_slug, lo_cli_class,
                 -> { Sheet[ hi_sheet, lo_cli_class.story ] } ]
      end
    end

    # here we have "ouroboros" - a particular hot action's particular sheet
    # is a very important thing - it determines all of the below properties
    # from its sheet, which in turn go on to determine largely the action's
    # behavior. "ouroboros" is an experiment in combining some aspects from
    # the action's intrinsic inner ("head") sheet and some more superifical
    # aspects from the `mod_ref`-having namespace ("tail") sheet that first
    # references the node and puffs it into life. The upstream client maybe
    # wants to give the child node e.g a different slug or different aliaes
    # than what it has in its inner sheet. One wrong way to accomplish this
    # would be to mutate the intrinsic sheet. In an imaginary world this is
    # very bad, for reasons. A less wrong but still wrong way would be that
    # you write for each such property an ad-hoc getter in your client that
    # ancicipates there maybe being e.g an ivar having been set which holds
    # the strange value for that property. But the wrongmost way of all is:

    # (NOTE here are the different terms we have used at various times for
    # the two sides of the duality:
    #   tail = surface   = extrinsic = outer = higher = upper = hi
    #   head = intrinsic = intrinsic = inner = lower  = lower = lo )

  end
end
