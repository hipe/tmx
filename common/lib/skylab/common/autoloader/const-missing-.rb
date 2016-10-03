module Skylab::Common

  module Autoloader

    class ConstMissing_

      def initialize const_x, mod
        @const_string = const_x.to_s
        @const_symbol = const_x.intern
        @module = mod
      end

      def execute

        if __I_have_a_stowaway_record_for_this_name

          Here_::StowawayMagnetics__::Value_via_ConstMissing[ self ]
        else
          __value_via_lookup
        end
      end

      def __I_have_a_stowaway_record_for_this_name

        h = @module.stowaway_hash_
        if h
          stow_x = h[ @const_symbol ]
          if stow_x
            @stowaway_x__ = stow_x ; ACHIEVED_
          end
        end
      end

      def __value_via_lookup

        if __the_parent_module_has_an_associated_file_tree

          if __the_file_tree_has_an_associated_filesystem_entry_group

            if @_state_machine.value_is_known

              __when_value_has_already_been_determined

            else
              __maybe_load_then_cache_then_produce_the_value
            end
          else
            _msg = Here_::Say_::Uninitialized_constant[ _name, @module ]
            raise Here_::NameError, _msg
          end
        else
          self._COVER_ME_when_the_parent_module_has_no_associated_file_tree
        end
      end

      def __the_parent_module_has_an_associated_file_tree

        ft = @module.entry_tree
        if ft.is_file_tree
          @_file_tree = ft ; ACHIEVED_
        else
          self._DO_SOMETHING_WITH_the_fail_info_in_there
          UNABLE_
        end
      end

      def __the_file_tree_has_an_associated_filesystem_entry_group

        _sym = _name.as_approximation
        sm = @_file_tree.value_state_machine_via_approximation _sym
        if sm
          _receive_state_machine sm
          ACHIEVED_
        end
      end

      def __when_value_has_already_been_determined  # is #note-5

        _then = @_state_machine.const_symbol
        _message = Here_::Say_::Scheme_change[ @const_symbol, _then, @module ]
        raise Here_::NameError, _message
      end

      def finish_via__ load_path, sm

        _receive_state_machine sm
        @_load_path = load_path
        _load_and_reach_reflection
        _maybe_autoloaderize_the_value
        cache_and_produce_value_ @_the_value
      end

      def __maybe_load_then_cache_then_produce_the_value

        __reach_reflection_somehow
        _maybe_autoloaderize_the_value
        cache_and_produce_value_ @_the_value
      end

      def cache_and_produce_value_ x
        @_state_machine.write_value__ x, @const_symbol
        $stderr.puts "                       #{ @module }::#{ @const_string }"
        x
      end

      def _receive_state_machine sm
        @_state_machine = sm
        @_entry_group = @_state_machine.entry_group ; nil
      end

      def _maybe_autoloaderize_the_value

        kn = @_whether_to_autoloaderize_module
        if ! kn
          _yes = Should_probably_autoloaderize_[ @_the_value ]
          kn = Known_Known.yes_or_no _yes
        end
        if kn.value_x  # if yes
          __autoloaderize_the_module
        end
        NIL
      end

      def __autoloaderize_the_module

        _child_node_path = ::File.join(
          @_state_machine.parent_node_path,
          @_entry_group.head,
        )

        Here_[ @_the_value, _child_node_path ]

        NIL
      end

      def __reach_reflection_somehow

        if @_entry_group.includes_what_is_probably_a_file
          __reach_reflection_when_eponymous_file
        else
          __reach_reflection_when_directory
        end
      end

      def __reach_reflection_when_directory

        @_child_file_tree = @_file_tree.child_file_tree @_state_machine

        if __there_is_a_corefile
          __reach_reflection_via_loading_the_corefile
        else
          __reach_reflection_via_autovivifying_a_module
        end
      end

      def __there_is_a_corefile

        sm = @_child_file_tree.corefile_state_machine__
        if sm
          @_core_file_state_machine = sm ; ACHIEVED_
        end
      end

      def __reach_reflection_via_autovivifying_a_module

        x = ::Module.new
        @module.const_set @const_symbol, x
        @_the_value = x
        @_whether_to_autoloaderize_module = Known_Known.trueish_instance
        NIL
      end

      def __reach_reflection_via_loading_the_corefile

        @_load_path = ::File.join(
          @_core_file_state_machine.parent_node_path,
          @_core_file_state_machine.entry_group.filesystem_entry_string
        )

        _load_and_reach_reflection
        NIL
      end

      def __reach_reflection_when_eponymous_file

        @_load_path = ::File.join(
          @_state_machine.parent_node_path,
          @_entry_group.filesystem_entry_string
        )

        _load_and_reach_reflection
        NIL
      end

      def _load_and_reach_reflection  # init N things

        load @_load_path

        if @module.const_defined? @const_symbol, false
          @_the_value = @module.const_get @const_symbol, false
          @_whether_to_autoloaderize_module = nil
          NIL
        else
          _message = Here_::Say_::Not_in_file[ @_load_path, @const_string, @module ]
          raise Here_::NameError, _message
        end
      end

      def _name
        @___name ||= Name.via_valid_const_string_ @const_string
      end

      attr_reader(
        :const_symbol,  # #sm
        :module,  # #sm
      )
    end

    Should_probably_autoloaderize_ = -> x do  # #stowaway
      if x.respond_to? :module_exec
        # (hi.)
        ! x.respond_to? :dir_path
      end
    end
  end
end
# #history: broke out of sidesystem toplevel file after YEARS
