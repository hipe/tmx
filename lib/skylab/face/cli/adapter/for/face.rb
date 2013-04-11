module Skylab::Face

  module Face::CLI::Adapter::For::Face

    module Of

      Hot = -> own_strange_app_class do
        -> sheet, rc, rc_sheet, slug_fragment do
          pn = "#{ rc.invocation_string } #{ sheet.name.as_slug }"
          sht = Ouroboros_Sheet[ sheet, own_strange_app_class.story ]
          own_strange_app_class.new(
            out: rc.out,
            err: rc.err,
            program_name: pn,
            sheet: sht
          )
        end
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

    Ouroboros_Sheet = MetaHell::Proxy::Nice.new :slug, :options, :command_tree,
      :method_name, :host_module, :default_argv, :normalized_local_command_name


    class Ouroboros_Sheet
      def self.[] tail, head
        new                slug: -> do tail.slug end,
                        options: -> do head.options end,
                   command_tree: -> do head.command_tree end,
                    method_name: -> do tail.method_name end, # NOTE b.c namesp.
                    host_module: -> do head.host_module end,
                   default_argv: -> do head.default_argv end,
  normalized_local_command_name: -> do tail.normalized_local_command_name end
      end
    end
  end
end
