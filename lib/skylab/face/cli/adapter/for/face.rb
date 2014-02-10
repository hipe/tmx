module Skylab::Face

  module Face_::CLI::Adapter::For::Face

    Hotmm_ = -> slug, lo_class, arg_sht_p do  # hot maker maker
      -> hi_svcs, _slug_used_str=nil do
        pna = hi_svcs.get_normal_invocation_string_parts
        pna << slug
        h = {
          out: ( hi_svcs.ostream or fail "sanity - out?" ),
          err: ( hi_svcs.estream or fail "sanity - err?" ),
          program_name: ( pna * ' ' ),
          sheet: arg_sht_p[]
        }
        lo_class.new( h ).instance_variable_get :@mechanics
      end
    end

    module Of

      Sheet = -> hi_sheet, lo_sheet do
        Face_::CLI::Namespace::Adapter::For::Face::Ouroboros_Sheet[
          hi_sheet, lo_sheet ]
      end

      class Hot
      end
      def Hot.[] hi_sheet, lo_cli_class
        Hotmm_[ hi_sheet.name.as_slug, lo_cli_class,
                 -> { Sheet[ hi_sheet, lo_cli_class.story ] } ]
      end
      Hot.singleton_class.send :alias_method, :call, :[]
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

    class Of::Hot  # this is a generic base class used elsewhere

      # def `get_summary_a_from_sheet` - you do this one

      def initialize ns_sheet, my_client_class, mechanics
        @ns_sheet, @my_client_class, @mechanics =
          ns_sheet, my_client_class, mechanics
      end

      def pre_execute
        did = false
        @actual ||= begin
          did = true
          cli = @my_client_class.new( * @mechanics.three_streams )
          cli.program_name = get_anchored_program_name
          cli
        end
        did or fail "sanity - pre-execute should not be called > once"
        true
      end

      def is_visible  # when would you want an invisible ouroboros agent
        true
      end

      def invokee  # short-circuit the face CLI API early
        @actual
      end

      def help
        @actual.invoke [ '--help' ]
      end

      def name
        @ns_sheet.name
      end

    private

      def get_anchored_program_name
        get_anchored_program_name_separated_by ' '
      end

      def get_anchored_program_name_separated_by sep
        [ * @mechanics.get_normal_invocation_string_parts,
          @ns_sheet.name.local_normal ] * sep
      end
    end
  end
end
