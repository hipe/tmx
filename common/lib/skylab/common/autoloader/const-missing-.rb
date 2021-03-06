module Skylab::Common

  module Autoloader

    class ConstMissing_

      # central workhorse for general autoloading for user.
      # also exposures to help implement:
      #
      #   - boxxy (:#bo)
      #   - const reduce (:#cr)
      #   - stowaway magnetics (:#sm)

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
        @_whether_to_autoloaderize_module = KnownKnown.yes_or_no x
        x
      end

      def autoloaderization_node_path= x  # #sm
        @__autoloaderization_node_path_knownness = KnownKnown[ x ]
        x
      end

      attr_writer(
        :const_defined,  # #bo
        :file_tree,  # #cr, #bo
        :on_const_missing_after_loaded_file,  # #cr
      )

      def execute
        if has_stowaway_hash_ && has_stowaway_record_for_const_as_is_
          name_and_value_via_stowaway_
        else
          __knownness_via_lookup
        end
      end

      def has_stowaway_hash_  # #bo
        @module.stowaway_hash_ && ACHIEVED_
      end

      def has_stowaway_record_for_const_as_is_  # #bo
        @module.stowaway_hash_[ @const_symbol ] && ACHIEVED_
      end

      def name_and_value_via_stowaway_  # #bo
        Here_::StowawayMagnetics__::NameAndValue_via_ConstMissing[ self ]
      end

      def __knownness_via_lookup

        if __the_parent_module_has_an_associated_file_tree

          if __the_file_tree_has_an_associated_filesystem_entry_group

            name_value_pair_via_asset_reference_
          else
            raise_name_error_no_filesystem_node_
          end
        else
          # the parent module has no associated file tree
          NOTHING_  # covered, follow
        end
      end

      def raise_name_error_no_filesystem_node_
        _nm = _name
        _msg = Here_::Say_::No_filesystem_node[ _nm, @module ]
        raise Here_::NameError, _msg
      end

      def __the_parent_module_has_an_associated_file_tree

        ft = @module.entry_tree
        if ft
          @file_tree = ft ; ACHIEVED_
        else
          UNABLE_  # covered, follow
        end
      end

      def __the_file_tree_has_an_associated_filesystem_entry_group

        # open [#067] why do we do approximation why not etc
        _slug = _name.as_slug
        ref = @file_tree.asset_reference_via_entry_group_head _slug
        if ref
          self.asset_reference = ref
          ACHIEVED_
        end
      end

      def name_value_pair_via_asset_reference_  # #cr

        if @_asset_reference.value_is_known

          __when_value_has_already_been_determined
        else
          __name_value_pair_after_maybe_load_then_cache
        end
      end

      def __when_value_has_already_been_determined  # exactly [#here.E]

        _then = @_asset_reference.const_symbol
        _message = Here_::Say_::Scheme_change[ @const_symbol, _then, @module ]
        raise Here_::NameError, _message
      end

      def __name_value_pair_after_maybe_load_then_cache

        become_loaded_via_filesystem_ or become_loaded_via_autovivifying_a_module_
        name_and_value_after_loaded_
      end

      def name_and_value_after_loaded_  # #bo

        if __should_autoloaderize_the_value
          __autoloaderize_the_value
        end

        cache_and_produce_pair_via_value_ @the_asset_value_
      end

      def cache_and_produce_pair_via_value_ x  # #sm

        if DO_DEBUG_
          __express_trace_info
        end

        @_asset_reference.write_and_produce_pair_ x, @const_symbol
      end

      margin = nil
      define_method :__express_trace_info do
        margin ||= "#{ SPACE_ * 22 } - "
        DEBUG_IO_.puts "#{ margin }#{ @module }::#{ @const_string }"
      end

      def asset_reference= ref
        @_asset_reference = ref
      end

      def __should_autoloaderize_the_value  # #spot-4 does similar

        kn = @_whether_to_autoloaderize_module
        if kn
          kn.value  # was decided externally. user's choice

        elsif @_asset_reference.entry_group.includes_what_is_probably_a_directory

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
          kn.value
        else
          @_asset_reference.get_node_path
        end

        # #open [#158] why not etc below
        Here_[ @the_asset_value_, _child_node_path ]
        NIL
      end

      def become_loaded_via_filesystem_  # #bo

        if __has_eponymous_file
          __become_loaded_when_eponymous_file

        elsif __has_corefile
          __become_loaded_when_corefile
        end
      end

      # ~ has means X to become loaded

      def __has_corefile

        @_child_file_tree = @file_tree.child_file_tree @_asset_reference

        ref = @_child_file_tree.corefile_asset_reference_
        if ref
          @_core_file_asset_reference = ref ; ACHIEVED_
        end
      end

      def __has_eponymous_file
        @_asset_reference.entry_group.includes_what_is_probably_a_file
      end

      # ~ become loaded via X

      def become_loaded_via_autovivifying_a_module_  # #bo

        x = ::Module.new
        @module.const_set @const_symbol, x
        @the_asset_value_ = x
        @_whether_to_autoloaderize_module ||= KnownKnown.trueish_instance
        ACHIEVED_
      end

      def __become_loaded_when_corefile

        @_load_path = @_core_file_asset_reference.get_filesystem_path
        _become_loaded_via_load_path
      end

      def __become_loaded_when_eponymous_file

        @_load_path = @_asset_reference.get_filesystem_path
        _become_loaded_via_load_path
      end

      # ~

      def load_path= x  # #sm
        @_load_path = x
      end

      def _become_loaded_via_load_path  # init N things

        load_the_file_
        become_loaded_assuming_assets_are_loaded_
        ACHIEVED_
      end

      def load_the_file_  # #sm
        ::Kernel.load @_load_path
        NIL
      end

      def to_known_  # #sm
        # (we could result in a pair, but why)
        CorrectConst_[ @the_asset_value_ ]
      end

      def become_loaded_assuming_assets_are_loaded_  # #sm

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

      def _name
        @__name ||= Name.via_valid_const_string_ @const_string
      end

      def const_symbol= sym
        @__name = nil
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
