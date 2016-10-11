module Skylab::Common

  module Autoloader

    class ConstMissing_

      def initialize const_x, mod
        @__autoloaderization_node_path_knownness = nil
        @const_defined = nil
        @const_string = const_x.to_s
        @const_symbol = const_x.intern
        @module = mod
        @on_const_missing_after_loaded_file = nil
        @_whether_to_autoloaderize_module = nil
      end

      def do_autoloaderize= x  # #cr
        @_whether_to_autoloaderize_module = Known_Known.yes_or_no x
        x
      end

      def autoloaderization_node_path= x  # #sm
        @__autoloaderization_node_path_knownness = Known_Known[ x ]
        x
      end

      attr_writer(
        :const_defined,  # #bo
        :file_tree,  # #cr, #bo
        :on_const_missing_after_loaded_file,  # #cr
      )

      def execute

        if __I_have_a_stowaway_record_for_this_name

          Here_::StowawayMagnetics__::Knownness_via_ConstMissing[ self ]
        else
          __knownness_via_lookup
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

      def __knownness_via_lookup

        if __the_parent_module_has_an_associated_file_tree

          if __the_file_tree_has_an_associated_filesystem_entry_group

            name_value_pair_via_state_machine_
          else
            _msg = Here_::Say_::No_filesystem_node[ name_, @module ]
            raise Here_::NameError, _msg
          end
        else
          # the parent module has no associated file tree
          NOTHING_  # covered, follow
        end
      end

      def __the_parent_module_has_an_associated_file_tree

        ft = @module.entry_tree
        if ft && ft.is_file_tree
          @file_tree = ft ; ACHIEVED_
        else
          UNABLE_  # covered, follow
        end
      end

      def __the_file_tree_has_an_associated_filesystem_entry_group

        # open [#067] why do we do approximation why not etc
        _sym = name_.as_approximation
        sm = @file_tree.value_state_machine_via_approximation _sym
        if sm
          self.state_machine = sm
          ACHIEVED_
        end
      end

      def name_value_pair_via_state_machine_  # #cr

        if @_state_machine.value_is_known

          __when_value_has_already_been_determined
        else
          name_value_pair_after_maybe_load_then_cache_
        end
      end

      def __when_value_has_already_been_determined  # is #note-5

        _then = @_state_machine.const_symbol
        _message = Here_::Say_::Scheme_change[ @const_symbol, _then, @module ]
        raise Here_::NameError, _message
      end

      def name_value_pair_after_maybe_load_then_cache_  # #bo

        __reflect_somehow

        if __should_autoloaderize_the_value
          __autoloaderize_the_value
        end

        cache_and_produce_pair_via_value_ @the_asset_value_
      end

      def cache_and_produce_pair_via_value_ x  # #sm
        $stderr.puts "#{ MARGIN___ }#{ @module }::#{ @const_string }"
        @_state_machine.write_and_produce_pair_ x, @const_symbol
      end

      MARGIN___ = "#{ SPACE_ * 22 } - "

      def state_machine= sm
        @_state_machine = sm
      end

      def __should_autoloaderize_the_value  # #spot-4 does similar

        kn = @_whether_to_autoloaderize_module
        if kn
          kn.value_x  # was decided externally. user's choice

        elsif @_state_machine.entry_group.includes_what_is_probably_a_directory

          if Is_probably_module[ @the_asset_value_ ]

            ! @the_asset_value_.respond_to? NODE_PATH_METHOD_
          end
        else
          UNABLE_  # hi.
        end
      end

      def __autoloaderize_the_value

        kn = @__autoloaderization_node_path_knownness

        _child_node_path = if kn
          kn.value_x
        else
          @_state_machine.get_node_path
        end

        # #open [#158] why not etc below
        Here_[ @the_asset_value_, _child_node_path ]
        NIL
      end

      def __reflect_somehow

        if @_state_machine.entry_group.includes_what_is_probably_a_file
          __reflect_when_eponymous_file
        else
          __reflect_when_directory
        end
      end

      def __reflect_when_directory

        @_child_file_tree = @file_tree.child_file_tree @_state_machine

        if __there_is_a_corefile
          __reflect_via_loading_the_corefile
        else
          __reflect_via_autovivifying_a_module
        end
      end

      def __there_is_a_corefile

        sm = @_child_file_tree.corefile_state_machine
        if sm
          @_core_file_state_machine = sm ; ACHIEVED_
        end
      end

      def __reflect_via_autovivifying_a_module

        x = ::Module.new
        @module.const_set @const_symbol, x
        @the_asset_value_ = x
        @_whether_to_autoloaderize_module ||= Known_Known.trueish_instance
        NIL
      end

      def __reflect_via_loading_the_corefile

        @_load_path = @_core_file_state_machine.get_filesystem_path
        _load_and_reflect
        NIL
      end

      def __reflect_when_eponymous_file

        @_load_path = @_state_machine.get_filesystem_path
        _load_and_reflect
        NIL
      end

      def load_path= x  # #sm
        @_load_path = x
      end

      def _load_and_reflect  # init N things

        load_the_file_
        reflect_
        NIL
      end

      def load_the_file_
        ::Kernel.load @_load_path
        NIL
      end

      def to_known__  # #sm
        # (we could result in a pair, but why)
        Known_Known[ @the_asset_value_ ]
      end

      def reflect_  # #sm

        begin

          if __constant_is_defined
            @the_asset_value_ = @module.const_get @const_symbol, false
            break
          end

          p = @on_const_missing_after_loaded_file
          if p
            @on_const_missing_after_loaded_file = nil
            p[]
            redo
          end

          _message = Here_::Say_::Not_in_file[ @_load_path, @const_string, @module ]
          raise Here_::NameError, _message

        end while above
        NIL
      end

      def __constant_is_defined
        p = @const_defined
        if p
          p[ @const_symbol, false ]
        else
          @module.const_defined? @const_symbol, false
        end
      end

      def name_
        @___name ||= Name.via_valid_const_string_ @const_string
      end

      def const_symbol= sym
        @const_string = sym.id2name
        @const_symbol = sym
      end

      attr_reader(
        :const_symbol,  # #sm, #cr
        :module,  # #sm
        :the_asset_value_,  # #sm
      )
    end
  end
end
# #history: broke out of sidesystem toplevel file after YEARS
