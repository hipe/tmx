module Skylab::CodeMetrics

  class Magnetics_::LoadAdapter_via_Request < Common_::Monadic  # :[#007.H]

    # the "load adapter" is what the recording session uses to ensure that
    # all files of interest are loaded.
    #
    # our decision to insulate this through this façade is informed by
    # experience: this is the third such would-be adapter. other efforts
    # have included a const-based "loadable reference" as well as a single path
    # variant. (the latter is not in history, but is what brought us to the
    # ideas that led to the massive rearchitecting.)
    #
    # if ever we try to broaden this to general (non-[co]-autoloady) use,
    # such an adapter will be the means to do it by.

    # -
      def initialize req, & li

        @_be_verbose = req.be_verbose
        @_debug_IO = req.debug_IO

        @_listener = li
        @_request = req

        @require_paths = req.require_paths
        @head_const = req.head_const
      end

      # (the division between what happens in one vs. the other is arbitrary)

      def execute
        @_mags = Home_::Magnetics_
        __resolve_const_scanner && self
      end

      def load_all_assets_and_support
        ok = true
        ok &&= _resolve_load_tree
        ok &&= __load_load_tree
        ok
      end

      def to_normal_paths
        ok = _resolve_load_tree
        ok && __flush_normal_paths
      end

      def __flush_normal_paths
        NormalPaths__.new(
          _load_tree.method( :to_pre_order_normal_path_stream ),
          @_request.head_path,
        )
      end

      NormalPaths__ = ::Struct.new :to_normal_path_stream_by, :head_path

      def _resolve_load_tree
        ok = true
        ok &&= __require_any_require_paths
        ok &&= __resolve_head_module
        ok &&= __resolve_head_path
        ok &&= __resolve_path_stream_via_modified_request
        ok &&= __resolve_load_tree_via_path_stream
        ok
      end

      def __load_load_tree
        st = _load_tree.to_pre_order_normal_path_stream
        ok = true
        begin
          s_a = st.gets
          s_a || break
          ok = __load s_a
          ok || break
          redo
        end while above
        ok
      end

      def _load_tree
        remove_instance_variable :@__load_tree
      end

      def __load s_a

        has = Autoloader_::CORE_ENTRY_STEM == s_a.last

        if @_be_verbose
          if has
            @_debug_IO.write "const reduce: #{ s_a.inspect } .. #{
              }('core' element will not be used in const path) .."
          else
            @_debug_IO.write "const reduce: #{ s_a.inspect } .."
          end
        end

        if has
          s_a = s_a[ 0 .. -2 ]
        end

        # while #open [#co-024.1], can't const reduce on a zero length path
        if s_a.length.zero?
          @_head_module && ACHIEVED_
        else
          __load_normally s_a
        end
      end

      def __load_normally s_a  # only while above is open

        ok = true

        _ = Autoloader_.const_reduce_by do |o|
          o.from_module = @_head_module
          o.const_path = s_a
          o.autoloaderize

        o.receive_name_error_by = -> *chan, &msg do
          ok = false
          @_listener[ *chan, &msg ]
          @_listener.call :error, :expression, :autoload_error do |y|
            y << "the above \"abstract path\" inferred from a filename #{
              }failed resolve to a const value."
          end
          :_no_see_CM_

        end ; end

        if @_be_verbose
          if ok
            @_debug_IO.puts " done."
          else
            @_debug_IO.puts EMPTY_S_
          end
        end

        ok
      end

      def __resolve_load_tree_via_path_stream
        _path_st = remove_instance_variable :@_path_stream  # ivar name is #testpoint :(
        _s_a = @_mags::LoadTree_via_PathStream.call(
          _path_st, @_request.head_path, & @_listener )
        _store :@__load_tree, _s_a
      end

      def __resolve_path_stream_via_modified_request  # #testpoint
        _ = @_mags::PathStream_via_MondrianRequest[ @_request, & @_listener ]
        _store :@_path_stream, _
      end

      def __resolve_head_path
        if @_request.head_path
          ACHIEVED_
        else
          __resolve_head_path_via_head_module
        end
      end

      def __resolve_head_path_via_head_module
        dir_path = @_head_module.dir_path  # ..
        if dir_path
          _use = @_request.system_services.normalize_system_path dir_path
          @_request = @_request.redefine do |o|
            o.head_path = _use
          end
          ACHIEVED_
        else
          __whine_about_no_head_path
        end
      end

      def __whine_about_no_head_path__
        self._CODE_SKETCH__needs_coverage__  # #todo
        mod = @_head_module
        @_listener.call :error, :expression, :primary_parse_error do |y|
          y << "unable to resolve a `dir_path` from #{ mod.name } alone."
          y << "use #{ prim :head_path }"
        end
        UNABLE_
      end

      def __resolve_head_module
        _scn = remove_instance_variable :@__const_scanner
        @_head_module = _scn.flush_to_value.value
        ACHIEVED_
      end

      def __require_any_require_paths
        a = remove_instance_variable :@require_paths
        if a
          a.each do |path_for_require|
            require path_for_require
              # (not `::Kernel.require`, you need the rubygems one)
          end
        end
        ACHIEVED_
      end

      def __resolve_const_scanner
        s = remove_instance_variable :@head_const
        if s
          _ = Home_::Models_::Const::ConstScanner.via_string s, & @_listener
          _store :@__const_scanner, _
        else
          __whine_about_no_head_const
        end
      end

      def __whine_about_no_head_const
        @_listener.call :error, :expression, :primary_parse_error do |y|
          y << "for now, #{ prim :head_const } is required."
        end
        UNABLE_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -
    # ==

    # ==
  end
end
# [#co-068] "resolve module" was vaguely similar once (this is not a tombstone)
# #born for mondrian
