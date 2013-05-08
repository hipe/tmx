module Skylab::Face

  module Face::Namespace::Adapter::For::Face

    module Of

      Hot = -> own_strange_ns_class do

        -> sheet, rc, rc_sheet, slug_fragment do
          sht = Ouroboros_Sheet[ own_strange_ns_class.story, sheet ]
          own_strange_ns_class.new rc, slug_fragment, sheet: sht
        end
      end
    end

    Ouroboros_Sheet = MetaHell::Proxy::Nice.new :slug, :options, :command_tree,
      :default_argv, :fetch_element

    class Ouroboros_Sheet
      def self.[] inner, strange
        new(               slug: -> do strange.slug end,
                        options: -> do inner.options end,
                   command_tree: -> do inner.command_tree end,
                   default_argv: -> do
                     strange.default_argv || inner.default_argv
                   end,
                  fetch_element: -> *a, &b do
                    inner.fetch_element( *a, &b )
                  end,
        )
      end
    end
  end
end
