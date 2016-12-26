module Skylab::CodeMetrics::TestSupport

  module Treemap_Node

    def self.[] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end

    module ModuleMethods___

      def given_expanded_path_stream & p
        Def__.call self, :load_tree_ do
          __TMN_build_load_tree
        end
        define_method :__TMN_proc_for_string_array_for_expanded_path_stream do
          p
        end
      end

      def given_request & p
        x = nil ; once = -> do
          once = nil
          x = __TMN_build_request p
        end
        define_method :operation_request_ do
          once && instance_exec( & once )
          x
        end
      end
    end

    module InstanceMethods___

      # -- expectations

      def build_treemap_node_statistics_

        __TMN_build_treemap_node_statistics_of treemap_node_
      end

      def __TMN_build_treemap_node_statistics_of root_node

        st = _TMN_non_root_stream_of root_node

        max_depth = 0
        number_of_leaf_nodes = 0
        begin
          tuple = st.gets
          tuple || break
          node, _column, depth = tuple
          if depth > max_depth
            max_depth = depth
          end
          if ! node.has_children
            number_of_leaf_nodes += 1
          end
          redo
        end while above

        Statistics___.new max_depth, number_of_leaf_nodes
      end

      def expect_every_non_root_terminal_child_has_weights_

        __TMN_expect_of_every_leaf_child_of treemap_node_ do |tr|
          d = tr.main_quantity
          d || fail
          d.zero? && fail
        end
      end

      def __TMN_expect_of_every_leaf_child_of root_node

        st = _TMN_leaf_child_stream_of root_node
        begin
          node = st.gets
          node || break
          yield node
          redo
        end while above
      end

      def expect_every_non_root_child_has_a_short_name_

        _TMN_expect_of_every_non_root_child do |tr|
          s = tr.label_string
          if ! s
            fail "no label at depth #{ depth_ }"
          end
          if s.include? CONST_SEP_
            fail "why include const sep? #{ s.inspect }"
          end
        end
      end

      def expect_root_node_has_an_appropriate_label_string_

        s = treemap_node_.label_string

        s || fail

        _d = Home_.lib_.basic::String.count_occurrences_in_string_of_string(
          s, ::File::SEPARATOR )

        ( 2..6 ).include? _d or fail  # shallowest is six
      end

      def number_of_leaf_nodes_of_ node
        _TMN_leaf_child_stream_of( node ).flush_to_count
      end

      def _TMN_leaf_child_stream_of root_node

        recurse = -> parent_node do

          parent_node.to_child_stream.expand_by do |child_node|
            if child_node.has_children
              recurse[ child_node ]
            else
              Common_::Stream.via_item child_node
            end
          end
        end

        recurse[ root_node ]
      end

      def _TMN_expect_of_every_non_root_child & p

        __TMN_expect_of_every_non_root_child_of treemap_node_, & p
      end

      def __TMN_expect_of_every_non_root_child_of root_node

        st = _TMN_non_root_stream_of root_node
        begin
          tuple = st.gets
          tuple || break
          yield( * tuple )  # 3
          redo
        end while above
      end

      def _TMN_non_root_stream_of root_node

        recurse = -> parent_node, parent_depth do

          col = -1
          child_depth = parent_depth + 1

          parent_node.to_child_stream.expand_by do |child_node|
            col += 1
            if child_node.has_children
              recurse[ child_node, child_depth ]
            else
              Common_::Stream.via_item [ child_node, col, child_depth ]
            end
          end
        end

        recurse[ root_node, 1 ]
      end

      # -- shared subjects

      def treemap_node_01_faboozle
        Treemap_node_01_faboozle___[]
      end

      # -- setup support

      def build_treemap_node_via_recording_file_ path
        _svcs = Home_::Mondrian_[]::SystemServices___.new(
          do_debug, debug_IO )
        _rec = Home_::Models_::Recording::ByFile.new path, _svcs
        _TMN_node_via_recording _rec
      end

      def build_treemap_node_via_recording_lines_
        a = []
        yield ::Enumerator::Yielder.new( & a.method( :push ) )
        _rec = Home_::Models_::Recording::ByArray.new a
        _TMN_node_via_recording _rec
      end

      def _TMN_node_via_recording rec
        _req = operation_request_
        _li = event_listener_
        _ = Home_::Magnetics_::Node_for_Treemap_via_Recording.call(
          rec, _req, & _li )
        _  # #todo
      end

      def __TMN_build_load_tree
        _st = Stream_[ get_string_array_for_expanded_path_stream_ ]
        _req = operation_request_
        _p = event_listener_
        _head_path = _req.head_path
        _wee = Home_::Magnetics_::LoadTree_via_PathStream[ _st, _head_path, & _p ]
        _wee  # #todo
      end

      def __TMN_build_request p
        Home_::Mondrian_[]::Request___.define do |o|
          instance_exec o, & p
        end
      end

      def get_string_array_for_expanded_path_stream_
        _p = __TMN_proc_for_string_array_for_expanded_path_stream
        s_a = []
        _y = ::Enumerator::Yielder.new do |path|
          s_a.push path
        end
        instance_exec _y, & _p
        s_a
      end
    end

    # ==

    common_head_const = nil
    common_path_head = nil

    Treemap_node_01_faboozle___ = Lazy_.call do
      CrazyLiveLoad___.new do |o|
        o.head_const = common_head_const[]
        o.paths = [
          ::File.join( common_path_head[], 'onezo/node01faboozle.rb' ),
        ]
      end.execute
    end

    common_head_const = Lazy_.call do
      "#{ Home_.name }::TestSupport::FixtureAssetNodesToLoadOnce".freeze
    end

    common_path_head = -> do
      FixtureAssetNodesToLoadOnce.dir_path
    end

    # ==

    class CrazyLiveLoad___

      def initialize
        @__request = Home_::Mondrian_[]::Request___.define do |o|
          yield o
          o.system_services ||= Build_real_system_services_[ o ]
        end
      end

      def execute  # #mon-spot-2 - massively hack the operation object

        req = remove_instance_variable :@__request
        op = Home_::Mondrian_[]::Operation__.new :_no_arg_scn_

        op.instance_variable_set :@_listener, method( :__emergency_doo_hah )
        op.instance_variable_set :@_request, req

        op.__resolve_recording || fail
        op.__resolve_node_for_treemap_via_recording || fail
        op.remove_instance_variable :@__node_for_tremap
      end

      def __emergency_doo_hah * i_a, & msg_p
        io = $stderr
        io.puts "UNEXPECTED: #{ i_a.inspect } (message following)"
        _y = ::Enumerator::Yielder.new do |line|
          o.puts "UH-OH: #{ line }"
        end
        fail
      end
    end

    # ==

    Statistics___ = ::Struct.new :max_depth, :number_of_leaf_nodes

    # ==

    Def__ = TestSupport_::Define_dangerous_memoizer

    # ==
  end
end
