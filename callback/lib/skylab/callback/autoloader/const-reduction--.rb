module Skylab::Callback

  module Autoloader

    class Const_Reduction__  # sed [#029]

      def initialize a, & p

        @do_correct_name = false
        @do_result_in_name_and_value = false
        @__did_require = false
        @_else_p = p
        @final_path_to_load = nil
        @_try_these_const_method_i_a = ALL_CONST_METHOD_I_A___

        @__a = a
      end

      ALL_CONST_METHOD_I_A___ = %i( as_const as_camelcase_const ).freeze

      def execute
        __init_arguments
        __work
      end

      # --

      def __init_arguments

        a = remove_instance_variable :@__a
        st = Polymorphic_Stream.via_array a
        @_st = st

        if 2 == a.length
          path_x
          from_module
        else
          begin
            send st.gets_one
          end until st.no_unparsed_exists
        end

        remove_instance_variable :@_st
        NIL_
      end

    private

      def correct_the_name  # see #correct-the-name
        @do_correct_name = true ; nil
      end

      def const_path
        @const_x_a = @_st.gets_one ; nil
      end

      def final_path_to_load  # hack to support filenames w/o extensions. [ta]
        @final_path_to_load = @_st.gets_one ; nil
      end

      def from_module
        @from_module = @_st.gets_one ; nil
      end

      def path_x
        x = @_st.gets_one
        @const_x_a = ::Array.try_convert( x ) || [ x ] ; nil
      end

      def result_in_name_and_value
        @do_result_in_name_and_value = true ; nil
      end

      # --

      def __work  # see #"general algorithm"

        _x_a = remove_instance_variable :@const_x_a  # assume 0 or more

        st = Polymorphic_Stream.via_array _x_a

        @_current_node = Value___[ remove_instance_variable( :@from_module ) ]

        ok = true

        unless st.no_unparsed_exists

          begin
            @__unsanitized_const_name_x = st.gets_one

            @_is_last = st.no_unparsed_exists  # for 1 place in [tm] :(

            if @_is_last && @final_path_to_load
              ::Kernel.load @final_path_to_load
            end

            ok = ___step
            ok or break
            @_is_last and break
            redo
          end while nil
        end

        if ok
          if @do_result_in_name_and_value
            @_current_node
          else
            @_current_node.value_x
          end
        else
          @_user_result_for_error
        end
      end

      def ___step
        _ok = __resolve_valid_const
        _ok && __resolve_next_current_node_via_sanitized_const_name
      end

      # --

      def __resolve_next_current_node_via_sanitized_const_name

        # we are sure that we are using the current node as a module
        # (and assuming it represents one) so..

        @_current_module = remove_instance_variable( :@_current_node ).value_x

        ks = ___maybe_seek_current_pair_because_const_defined
        ks &&= _seek_current_pair_fuzzily
        ks &&= __maybe_seek_current_pair_via_loading
        if ks
          __stop_when_zero
        else
          ACHIEVED_
        end
      end

      def ___maybe_seek_current_pair_because_const_defined

        if @_current_module.const_defined? @_valid_const, false

          if @do_correct_name && @_is_last
            ___correct_the_name
          else
            _seek_current_pair_when_one @_valid_const
          end
        else
          KEEP_SEEKING_
        end
      end

      def ___correct_the_name  # see #correct-the-name

        # the below `const_get` is meant to trigger (boxxy) or whatever to
        # actually load the file. then fuzzy match to find the correct name.

        _possibly_wrong_const = remove_instance_variable :@_valid_const

        @_current_module.const_get _possibly_wrong_const, false

        _keep_seeking = _seek_current_pair_fuzzily

        _keep_seeking and self._SANITY  # someone already said it was defined

        STOP_SEEKING_
      end

      # -- via loading

      def __maybe_seek_current_pair_via_loading

        if @_current_module.respond_to? :dir_pathname

          tree = ___tree
          if tree
            _ = @_name.as_distilled_stem
            np = tree.normpath_from_distilled _
          end

          if np
            __maybe_seek_current_pair_via_loading_some_file_in_normpath np
          else
            KEEP_SEEKING_
          end
        else
          KEEP_SEEKING_
        end
      end

      def ___tree

        if @_current_module.respond_to? :entry_tree
          tree = @_current_module.entry_tree
        else
          dpn = @_current_module.dir_pathname
          if dpn
            tree = LOOKAHEAD_[ dpn ]
          end
        end
        tree
      end

      def __maybe_seek_current_pair_via_loading_some_file_in_normpath np

        if np.can_produce_load_file_path

          ___seek_current_pair_via_loading_file_in_normpath np

        else
          KEEP_SEEKING_
        end
      end

      def ___seek_current_pair_via_loading_file_in_normpath file_np

        file_np.change_state_to :loaded

        _path = file_np.get_require_file_path
        require _path

        @__did_require = true
        @__normpath_that_was_required = file_np

        _ks = _seek_current_pair_fuzzily
        _ks
      end

      # --

      def _seek_current_pair_fuzzily

        a = []
        stem = @_name.as_distilled_stem

        @_current_module.constants.each do |const|
          if stem == Distill_[ const ]
            a.push const
          end
        end

        case a.length <=> 1
        when 0
          _seek_current_pair_when_one a.first
        when -1
          KEEP_SEEKING_
        when 1
          ___seek_current_pair_when_many a
        end
      end

      def ___seek_current_pair_when_many a

        idx = a.index @_valid_const

        if ! idx  # when there are multiple matches with
          # the same stem, use the first one because meh
          idx = 0
        end

        const = a.fetch idx

        _x = @_current_module.const_get const, false
        @_current_pair = Pair.via_value_and_name _x, const

        STOP_SEEKING_
      end

      def __stop_when_zero

        _express_this_error :___build_name_error_event, :uninitialized_constant
        UNABLE_
      end

      def ___build_name_error_event

        Home_::Event.inline_not_OK_with(

          :uninitialized_constant,
          :name, @_name.as_variegated_symbol,
          :mod, @_current_module,
          :error_category, :name_error,

        ) do |y, o|

          y << "uninitialized constant #{ o.mod }::( ~ #{ o.name } )"
        end
      end

      def _seek_current_pair_when_one const

        x = @_current_module.const_get const, false

        if @__did_require
          @__did_require = false
          if @_current_module.respond_to? :autoloaderize_with_normpath_value
            @_current_module.autoloaderize_with_normpath_value @__normpath_that_was_required, x
          end
        end

        @_current_node = Pair.via_value_and_name x, const
        STOP_SEEKING_
      end

      # -- sanitize const name

      def __resolve_valid_const

        # a lot of the below is "see what happens". it works out because in
        # practice the kinds of names we used are of a small set of patterns
        # but sadly this is not formally documented yet per se.

        x = remove_instance_variable :@__unsanitized_const_name_x
        if x

          if VALID_CONST_RX_ =~ x  # assume it's string-ish

            if x.respond_to? :id2name

              valid_const = x
              nf = Name.via_const_symbol x

            else

              # that it is a string not certain but "very likely" ick
              valid_const = x.intern
              nf = Name.via_const_string x

            end
          else

            nf = if x.respond_to? :id2name
              Name.via_variegated_symbol x
            else
              Name.via_slug x  # assume string; hazard a guess at its "shape"..
            end
            valid_const = nf.as_const  # nil if for eg "123foo"

          end
        else
          nf = Name.empty_name_for__ x  # ..
        end

        @_name = nf

        if valid_const
          @_valid_const = valid_const
          KEEP_PARSING_
        else
          _express_this_error :__build_wrong_const_name_event, :wrong_const_name
        end
      end

      def __build_wrong_const_name_event

        Home_::Event.inline_not_OK_with(
          :wrong_const_name,
          :name, @_name.as_variegated_symbol,
          :error_category, :name_error,
        ) do |y, o|
          y << "wrong constant name #{ ick o.name } for const reduce"
        end
      end

      # -- support

      def _express_this_error build_event_m, second_channel_sym

        p = @_else_p
        if p
          case 0 <=> p.arity
          when 0
            @_user_result_for_error = p[]
          when -1
            @_user_result_for_error = p[ send( build_event_m ) ]
          when 1
            @_user_result_for_error = p.call :error, second_channel_sym do
              send build_event_m
            end
          end
          UNABLE_
        else
          raise send( build_event_m ).to_exception
        end
      end

      # ==

      Value___ = ::Struct.new :value_x

      KEEP_SEEKING_ = true
      STOP_SEEKING_ = false
    end
  end
end
# #tombstone: assume_is_defined
