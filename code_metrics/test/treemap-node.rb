module Skylab::CodeMetrics::TestSupport

  module Treemap_Node

    def self.[] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
      tcc.include ConstantsAndInstances__
    end

    module ModuleMethods___

      def given_paths_for_load_tree & p
        x = nil ; once = -> do
          once = nil
          x = __mondrian_lowlevel_build_load_tree p
        end
        define_method :load_tree_ do
          once && instance_exec( & once )
          x
        end
      end

      def given_request & p
        x = nil ; once = -> do
          once = nil
          x = __mondrian_lowlevel_build_request p
        end
        define_method :operation_request_ do
          once && instance_exec( & once )
          x
        end
      end
    end

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

      def __mondrian_lowlevel_build_load_tree p
        _s_a = __mondrian_lowlevel_build_string_array p
        _st = Home_::Stream_[ _s_a ]
        _req = operation_request_
        _p = event_listener_
        _head_path = _req.head_path
        _wee = Home_::Magnetics_::LoadTree_via_PathStream[ _st, _head_path, & _p ]
        _wee  # #todo
      end

      def __mondrian_lowlevel_build_request p
        Home_::Mondrian_[]::Request___.define do |o|
          instance_exec o, & p
        end
      end

      def __mondrian_lowlevel_build_string_array p
        s_a = []
        _y = ::Enumerator::Yielder.new do |path|
          s_a.push path
        end
        instance_exec _y, & p
        s_a
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
