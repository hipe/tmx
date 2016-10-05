module Skylab::Common

  module Autoloader

    class ConstReduction__  # see [#029]

      def initialize a, ftc=nil, & p

        @correct_the_name = nil
        @file_tree_cacher = ftc
        @final_path_to_load = nil
        @listener = p
        @result_in_name_and_value = nil

        if 2 == a.length
          @const_path, @from_module = a
        else
          @const_path = nil
          @from_module = nil
          __store_named_arguments a
        end
        __normalize
      end

      def __store_named_arguments a
        @_st = Polymorphic_Stream.via_array a
        until @_st.no_unparsed_exists
          send OPTIONS___.fetch @_st.current_token
        end
        remove_instance_variable :@_st
        NIL
      end

      OPTIONS___ = {
        const_path: :_mixed_value,
        correct_the_name: :_boolean,
        final_path_to_load: :_mixed_value,
        from_module: :_mixed_value,
        result_in_name_and_value: :_boolean,
      }

      # -- (or [#fi-013])

      def _boolean
        instance_variable_set :"@#{ @_st.gets_one }", true ; nil
      end

      def _mixed_value
        instance_variable_set :"@#{ @_st.gets_one }", @_st.gets_one ; nil
      end

      # --

      def __normalize
        @_frame_prototype = Framer___.new @file_tree_cacher
        x = remove_instance_variable :@const_path
        @__sanitized_const_path_mixed_array = ::Array.try_convert( x ) || [ x ]

        if @final_path_to_load
          self._KILL_ME
        end
        NIL
      end

      def execute

        __init

        while __there_are_more_tokens

          if __the_current_frame_is_for_a_module

            if __the_current_token_is_a_valid_const

              if ! __find_a_defined_const_by_any_means

                break __when_could_not_find_a_defined_const_by_any_means
              end
            else
              break __when_the_current_token_is_not_a_valid_const
            end
          else
            break __when_the_current_frame_is_not_for_a_module
          end
        end

        if __encountered_an_error
          __express_the_error
        else
          __flush_final_result
        end
      end

      def __there_are_more_tokens
        @_token_stream.unparsed_exists
      end

      def __the_current_frame_is_for_a_module
        @_frame.is_for_module
      end

      def __when_the_current_frame_is_not_for_a_module
        self._SOMETHING
      end

      def __the_current_token_is_a_valid_const
        cx = CharacterizeToken__.new( @_token_stream.gets_one ).execute
        @_token_characterization = cx
        cx.is_valid_const
      end

      def __when_the_current_token_is_not_a_valid_const
        @_error_eventer = remove_instance_variable :@_token_characterization
        NIL
      end

      def __find_a_defined_const_by_any_means

        tuple = @_frame.__tuple_via_token_characterization @_token_characterization

        if tuple.found

          if @_token_stream.no_unparsed_exists

            __at_final_tuple tuple
          else

            @_frame = @_frame_prototype.for_value tuple.mixed_value
          end

          ACHIEVED_
        else
          @__lookup_not_found_tuple = tuple
          UNABLE_
        end
      end

      def __when_could_not_find_a_defined_const_by_any_means

        @_error_eventer = remove_instance_variable :@__lookup_not_found_tuple
        NIL
      end

      def __at_final_tuple tuple

        @__discovered = tuple

        if @correct_the_name
          ::Kernel._K_wipped_but_we_can_bring_it_back  # #todo
        end
        NIL
      end

      def __encountered_an_error
        @_error_eventer
      end

      def __flush_final_result

        di = remove_instance_variable :@__discovered

        if @result_in_name_and_value
          Pair.via_value_and_name di.mixed_value, di.const_symbol
        else
          di.mixed_value
        end
      end

      def __init
        @_error_eventer = nil
        @_frame = @_frame_prototype.for_value @from_module
        @_token_stream = Polymorphic_Stream.via_array @__sanitized_const_path_mixed_array
        NIL
      end

      def __express_the_error
        if @listener
          case 0 <=> @listener.arity
          when 0
            __when_error_and_listener_for_which_no_arguments_are_received
          when -1
            __emit_the_emittable_error_when_one_argument_is_received
          when 1
            __emit_the_emittable_error_when_looks_like_selective_listener
          end
        else
          __emit_the_emittable_error_when_no_listener
        end
      end

      def __emit_the_emittable_error_when_looks_like_selective_listener
        ee = @_error_eventer
        @listener.call :error, ee.error_name_symbol do
          ee.to_event
        end
        UNABLE_
      end

      def __emit_the_emittable_error_when_one_argument_is_received
        _em = @_error_eventer.to_event
        _x = @listener.call _em  # result is result
        _x
      end

      def __emit_the_emittable_error_when_no_listener
        _em = @_error_eventer.to_event
        _e = _em.to_exception
        raise _e
      end

      def __when_error_and_listener_for_which_no_arguments_are_received
        _x = @listener.call  # result is result
        _x
      end

      class Framer___

        def initialize ftc
          @file_tree_cacher = ftc
        end

        def for_value x
          if Is_probably_module[ x ]
            ModuleFrame___.new x, self
          else
            NonModuleFrame___.new x, self
          end
        end

        attr_reader(
          :file_tree_cacher,
        )
      end

      class ModuleFrame___

        def initialize x, fp
          @_frame_prototype = fp
          @module = x
        end

        def __tuple_via_token_characterization cx
          @_name = cx.name
          @_const_symbol = @_name.as_const

          if @module.const_defined? @_const_symbol, false
            __tuple_for_const_is_defined_as_is

          elsif __match_const_fuzzily
            __tuple_for_matched_fuzzily

          elsif __attempt_to_lookup_awkwardly
            __tuple_for_matched_awkwardly

          else
            __tuple_for_const_not_matched
          end
        end

        # -- fuzzy

        def __match_const_fuzzily
          Fuzzy_matcher_prototype___[].dup.execute_for @module, @_name, self
        end

        Fuzzy_matcher_prototype___ = Lazy_.call do
          Here_::FuzzyLookup_.new do |o|
            o.method_name_when_exactly_one = :__when_one
            o.method_name_when_many = :__when_many
            o.method_name_when_zero = :__when_zero
          end
        end

        def __when_zero
          UNABLE_
        end

        def __when_many sym_a
          self._READ_THIS_here  # we used to do etc but now etc
        end

        def __when_one sym
          _receive_corrected_const_symbol sym
          ACHIEVED_
        end

        def __tuple_for_matched_fuzzily
          # (hi.)
          _tuple_for_found
        end

        # -- awkward

        # the idea here (years old at writing) is that the module can be
        # boxxy-like without actually employing boxxy - peek the filesystem

        def __attempt_to_lookup_awkwardly

          if @module.respond_to? NODE_PATH_METHOD_

            ftc = @_frame_prototype.file_tree_cacher
            if ftc
              @__file_tree_cache = ftc.call
              __do_attempt_to_lookup_awkwardly
            else
              self._RECONSIDER_YOUR_LIFES_CHOICES
            end
          else
            UNABLE_
          end
        end

        def __do_attempt_to_lookup_awkwardly

          # currently we assume that if there's a `dir_path` then there's
          # a real life dir behind it, otherwise the below will throw

          _node_path = @module.send NODE_PATH_METHOD_
          @_file_tree = @__file_tree_cache[ _node_path ]
          _sym = @_name.as_approximation
          sm = @_file_tree.value_state_machine_via_approximation _sym
          if sm
            @__state_machine = sm
            ACHIEVED_
          else
            self._HOLIO
          end
        end

        def __tuple_for_matched_awkwardly

          # there is a filesystem "node" that approximately matches the const

          _sm = remove_instance_variable :@__state_machine

          cm = Here_::ConstMissing_.new @_const_symbol, @module

          cm.file_tree = @_file_tree

          cm.state_machine = _sm

          cm.do_autoloaderize = false  # this could change, but for now in
            # keeping with the non-invasive spirit of this facility, we
            # do not enhance the (any) loaded module/class with autoloading.

          cm.on_const_missing_after_loaded_file = -> do
            @_const_missing = cm
            __name_correction_when_loaded_awkwardly
          end

          @_name_was_corrected = false  # this must get set, so default to
            # false for those cases where the name is already correct

          cm.value_via_state_machine_  # if the const is not defined as-is,
            # triggers the name correction hook we set above. if after that
            # attempt at correction it's still not defined, ad hoc exception.

          _tuple_for_found
        end

        def __name_correction_when_loaded_awkwardly

          o = Here_::FuzzyLookup_.new

          o.on_zero = EMPTY_P_  # don't error here, error there

          o.on_exactly_one = -> const do
            _receive_corrected_const_symbol const
            @_const_missing.const_symbol = const
          end

          o.execute_for @module, @_name
          NIL
        end

        # -- simple

        def __tuple_for_const_is_defined_as_is
          @_name_was_corrected = false
          _tuple_for_found
        end

        # -- not

        def __tuple_for_const_not_matched

          NotFound__.new @module, @_name do |o|
            o.error_name_symbol = :uninitialized_constant
            o.__build_error_event_method_name = :__build_uninitialized_constant_event
          end
        end

        # -- support

        def _receive_corrected_const_symbol sym
          @_name_was_corrected = true
          @__previous_const_symbol = @_const_symbol
          @_const_symbol = sym ; nil
        end

        def _tuple_for_found

          _x = @module.const_get @_const_symbol, false

          Discovered___.new _x, @_const_symbol do |o|
            yes = remove_instance_variable :@_name_was_corrected
            if yes
              o.NAME_WAS_CORRECTED = yes
              o.PREVIOUS_CONST_SYMBOL = remove_instance_variable :@__previous_const_symbol
            end
          end
        end

        def mixed_value
          @module
        end

        def is_for_module
          true
        end
      end

      class NonModuleFrame___

        def initialize x, fp
          @_frame_prototype = fp
          @non_module = x
        end

        def mixed_value
          @non_module
        end

        def is_for_module
          false
        end
      end

      class NotFound__

        def initialize mod, name
          @module = mod
          @name = name
          yield self
          freeze
        end

        attr_accessor(
          :__build_error_event_method_name,
          :error_name_symbol,
        )

        def to_event
          send @__build_error_event_method_name
        end

        def __build_uninitialized_constant_event
          Build_uninitialized_constant_event[ @module, @name ]
        end

        def found
          false
        end
      end

      class Discovered___

        def initialize mixed, sym
          @const_symbol = sym
          @mixed_value = mixed
          yield self
          freeze
        end

        attr_accessor(
          :const_symbol,
          :mixed_value,
          :NAME_WAS_CORRECTED,
          :PREVIOUS_CONST_SYMBOL,
        )

        def found
          true
        end
      end

      class CharacterizeToken__

        def initialize x
          @is_valid_const = false  # guilty until proven innocent
          @mixed = x
        end

        def execute
          if @mixed
            if VALID_CONST_RX_ =~ @mixed
              __when_valid_const_outright
            else
              __when_maybe_not_valid_const
            end
          else
            __when_falseish
          end
        end

        def __when_falseish
          @name = Name.empty_name_for__ remove_instance_variable :@mixed
          _finish
        end

        def __when_maybe_not_valid_const

          x = remove_instance_variable :@mixed
          @name = if x.respond_to? :id2name
            Name.via_variegated_symbol x
          else
            Name.via_slug x  # assume string, but this is a hole
          end
          _const = @name.as_const  # eg nil if "123foo"
          if _const
            @is_valid_const = true
          else
            @is_valid_const = false
            @__error_name_symbol = :wrong_const_name
            @__build_event_method_name = :__build_event_for_wrong_const_name
          end
          _finish
        end

        def __when_valid_const_outright

          @is_valid_const = true
          x = remove_instance_variable :@mixed
          @name = if x.respond_to? :id2name
            Name.via_const_symbol x
          else
            Name.via_const_string x
          end
          _finish
        end

        alias_method :_finish, :freeze

        def to_event
          send @__build_event_method_name
        end

        def __build_event_for_wrong_const_name
          Build_wrong_const_name_event[ @name ]
        end

        def error_name_symbol
          @__error_name_symbol
        end

        attr_reader(
          :is_valid_const,
          :name,
        )
      end

      # ==

      Build_uninitialized_constant_event = -> mod, name do

        _ = Home_::Event.inline_not_OK_with(

          :uninitialized_constant,
          :name, name.as_variegated_symbol,
          :mod, mod,
          :exception_class_by, -> { Here_::NameError },
          :error_category, :name_error,

        ) do |y, o|

          y << "uninitialized constant #{ o.mod }::( ~ #{ o.name } )"
        end
        _
      end

      Build_wrong_const_name_event = -> name do

        _ = Home_::Event.inline_not_OK_with(
          :wrong_const_name,
          :name, name.as_variegated_symbol,
          :exception_class_by, -> { Here_::NameError },
          :error_category, :name_error,
        ) do |y, o|
          y << "wrong constant name #{ ick o.name } for const reduce"
        end
        _
      end

      # ==
    end  # :#cr
  end
end
# #tombstone: full rewrite
# #tombstone: assume_is_defined
