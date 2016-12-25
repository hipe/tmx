module Skylab::CodeMetrics::TestSupport

  module Treemap_Node

    def self.[] tcc
      tcc.send :define_singleton_method, :given_request, Defn_for_meth_called_given_request___
      tcc.include InstanceMethods___
      tcc.include ConstantsAndInstances__
    end

    # -
      Defn_for_meth_called_given_request___ = -> & p do
        define_method :__mondrian_lowlevel_proc_for_definition_of_request do
          p
        end
      end
    # -

    module InstanceMethods___

      # -- expectations

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

      # -- setup support

      def build_request
        _p = __mondrian_lowlevel_proc_for_definition_of_request
        Home_::Mondrian_[]::Request___.define do |o|
          instance_exec o, & _p
        end
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

        _hi = Home_::Magnetics_::Node_for_Treemap_via_Recording[ const_load_ticket ]

        _hi  # #todo
      end

      include ConstantsAndInstances__
    end ; end

    module LIB__
      extend ConstantsAndInstances__
    end

    module ConstantsAndInstances__

      def const_load_ticket_via_const_path_and_require_path cp, rp, & p

        const_load_ticket_module.via_const_path_and_require_path(
          cp, rp, & p )
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
