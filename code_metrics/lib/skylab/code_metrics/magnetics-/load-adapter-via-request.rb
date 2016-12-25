module Skylab::CodeMetrics

  class Magnetics_::LoadAdapter_via_Request < Common_::Actor::Dyadic  # :[#007.H]

    # the "load adapter" is what the recording session uses to ensure that
    # all files of interest are loaded.
    #
    # our decision to insulate this through this façade is informed by
    # experience: this is the third such would-be adapter. other efforts
    # have included a const-based "load ticket" as well as a single path
    # variant. (the latter is not in history, but is what brought us to the
    # ideas that led to the massive rearchitecting.)
    #
    # if ever we try to broaden this to general (non-[co]-autoloady) use,
    # such an adapter will be the means to do it by.

    # -
      def initialize load_tree, req, & p
        @_listener = p
        @load_tree = load_tree
        @require_paths = req.require_paths
        @head_const = req.head_const
        @head_path = req.head_path
      end

      def execute
        ok = true
        ok &&= __validate
        ok && self
      end

      def load_files_of_interest
        ok = true
        ok &&= __require_any_require_paths
        ok &&= __load_head_const
        ok &&= __load_load_tree
        ok
      end

      def __load_load_tree
        _lt = remove_instance_variable :@load_tree
        st = _lt.to_pre_order_normal_path_stream
        ok = true
        begin
          x = st.gets
          x || break
          ok = __load x
          ok || break
          redo
        end while above
        ok
      end

      def __load s_a

        ok = true
        _ = Autoloader_.const_reduce(
          :const_path, s_a,
          :from_module, @__head_module,
          :autoloaderize,
        ) do |*chan, &msg|
          ok = false
          @_listener[ *chan, &msg ]
        end
        ok
      end

      def __load_head_const
        mod = ::Object
        scn = remove_instance_variable :@__const_scanner
        begin
          _mod_ = mod.const_get scn.current_token, false
          mod = _mod_
          scn.advance_one
        end until scn.no_unparsed_exists
        @__head_module = mod
        ACHIEVED_
      end

      def __require_any_require_paths
        a = remove_instance_variable :@require_paths
        if a
          a.each do |path|
            ::Kernel.require path
          end
        end
        ACHIEVED_
      end

      def __validate
        s = remove_instance_variable :@head_const
        if s
          _ = Home_::Models_::Const::Scanner.via_string s, & @_listener
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
