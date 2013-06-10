module Skylab::Face

  module Face::Namespace::Adapter::For::Face

    module Of

      Hot = -> lower_ns_cls, higher_sheet do
        -> higher_svcs, slug_frag=nil do  # this is `hot` being claled
          lower_ns_cls.new(
            Ouroboros_Sheet[ lower_ns_cls.story, higher_sheet ],
            higher_svcs, slug_frag
          ).instance_variable_get( :@mechanics )
        end
      end
    end

    Ouroboros_Sheet = MetaHell::Proxy::Nice.new :name, :set_a,
      :command_tree, :default_argv, :option_sheet_a,
      :has_default_argv, :has_option_sheets, :fetch_constituent,
      :has_partially_visible_op

    class Ouroboros_Sheet
      def self.[] lo, hi
        new(               name: -> do hi.name end,
                          set_a: -> do  # top trumps bottom (overwrites)
                                      a = hi.set_a ; b = lo.set_a
                                      [ *b, *a ] if a || b
                                    end,
                   command_tree: -> do lo.command_tree end,
                   default_argv: -> do hi.default_argv || lo.default_argv end,
                 option_sheet_a: -> do lo.option_sheet_a end,
               has_default_argv: -> do hi.has_default_argv || lo.has_default_argv end,
              has_option_sheets: -> do lo.has_option_sheets end,
              fetch_constituent: -> *a, &b do lo.fetch_constituent( *a, &b ) end,
       has_partially_visible_op: -> do lo.has_partially_visible_op end
        )
      end
    end
  end
end
