module Skylab::CodeMetrics::TestSupport

  module Mondrian_Lowlevel

    def self.[] tcc
      tcc.include InstanceMethods___
      tcc.include ConstantsAndInstances__
    end

    module InstanceMethods___

      def expect_of_every_non_root_child_

        recurse = -> tree, depth do
          depth_ = depth + 1
          st = tree.to_child_stream
          col = -1
          while tr=st.gets
            col += 1
            yield tr, col, depth_
            if tr.has_children
              recurse[ tr, depth_ ]
            end
          end
        end

        _hi = treemap_node_
        recurse[ _hi, 0 ]
      end
    end

    module ConstantsAndInstances__

      def treemap_node_01_faboozle
        Treemap_node_01_faboozle___[]
      end
    end  # wil re-open

    Treemap_node_01_faboozle___ = Lazy_.call do
      Treemap_node___[ "#{ Common_const_head__[] }::Onezo::Node01Faboozle" ]
    end

    Common_const_head__ = Lazy_.call do
      "#{ Home_.name }::TestSupport::FixtureAssetNodesToLoadOnce".freeze
    end

    module Treemap_node___ ; class << self

      def [] require_path=nil, const_path

        const_load_ticket = const_load_ticket_via_const_path_and_require_path(
          const_path, require_path )

        const_load_ticket || fail

        _hi = node_for_treemap_via_const_load_ticket const_load_ticket

        _hi  # #todo
      end

      include ConstantsAndInstances__
    end ; end

    module LIB__
      extend ConstantsAndInstances__
    end

    module ConstantsAndInstances__

      def node_for_treemap_via_const_load_ticket nt, & p
        node_for_treemap_via_const_load_ticket_module[ nt, & p ]
      end

      def const_load_ticket_via_const_path_and_require_path cp, rp, & p

        const_load_ticket_module.via_const_path_and_require_path(
          cp, rp, & p )
      end

      def node_for_treemap_via_const_load_ticket_module
        Home_::Magnetics_::Node_for_Treemap_via_ConstLoadTicket
      end

      def const_load_ticket_module
        const_model::LoadTicket
      end

      def const_scanner_model
        const_model::Scanner
      end

      def const_model
        Home_::Models_::Const
      end
    end
  end
end
