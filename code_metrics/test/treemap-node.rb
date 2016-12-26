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

      def expect_every_non_root_terminal_child_has_weights_

        _TMN_expect_of_every_non_root_child do |tr|
          if ! tr.has_children
            d = tr.main_quantity
            d || fail
            d.zero? && fail
          end
        end
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

      def _TMN_expect_of_every_non_root_child

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

      # -- shared subjects

      def treemap_node_01_faboozle
        Treemap_node_01_faboozle___[]
      end

      # -- setup support

      def build_treemap_node_via_recording_lines_
        a = []
        yield ::Enumerator::Yielder.new( & a.method( :push ) )
        _rec = Home_::Models_::Recording::ByArray.new a
        _req = operation_request_
        _li = event_listener_
        _ = Home_::Magnetics_::Node_for_Treemap_via_Recording.call(
          _rec, _req, & _li )
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

    Def__ = TestSupport_::Define_dangerous_memoizer

    # ==
  end
end
