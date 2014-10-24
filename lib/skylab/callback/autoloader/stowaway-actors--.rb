module Skylab::Callback

  module Autoloader

    Stowaway_Actors__ = ::Module.new

    class Stowaway_Actors__::Produce_x

      Actor[ self, :properties, :const_missing, :core_relpath ]

      def execute
        init_ivars
        begin_np_a
        load_host_file
        finish_np_a
        produce_some_value
      end

    private

      def init_ivars
        @d = 0
        cm = @const_missing
        @mod = cm.mod
        @et = @mod_et = @mod.entry_tree
        @name = cm.name
        @s_a = @core_relpath.split PATH_SEP_
        @last_d = @s_a.length - 1
        @token = @s_a.first
      end

      def begin_np_a  # #stow-1
        :not_loaded == @mod_et.state_i and @mod_et.change_state_to :loading
        @np_a = []
        if DOT_DOT__ == @token
          go_upwards
        end
        go_downwards
      end

      def go_upwards  # similar to [#ba-034] but don't touch this :P
        mod = @mod
        while DOT_DOT__ == @token
          const_s_a = mod.name.split CONST_SEP_
          const_s_a.pop
          mod = const_s_a.reduce( ::Object ) { |m, x| m.const_get x, false }
          @et = mod.entry_tree
          @np_a.push @et
          @token = @s_a.fetch @d += 1
        end
      end

      def go_downwards
        while true
          et = visit
          @d == @last_d and break
          @token = @s_a.fetch @d += 1
          @et = et
        end
      end

      def visit
        et = @et.normpath_from_distilled Distill_[ @token ]  # #todo:inelegant
        if ! et
          et = build_terminal_normpath
        end
        :not_loaded == et.state_i and et.change_state_to :loading
        @np_a.push et
        et
      end

      DOT_DOT__ = '..'.freeze

      def build_terminal_normpath
        # et or fail "wat gives: #{ @et.norm_pathname } (~ #{ @token }) #{
        #   }(for #{ @mod } ( ~ #{ @name.as_variegated_symbol } )"
        slug = @name.as_slug
        _dir_entry = Dir_Entry_.new slug
        Entry_Tree_.new @et.norm_pathname, nil, _dir_entry
      end

      def load_host_file  # #stow-2
        real_dpn = @mod.dir_pathname.join @core_relpath
        @pn = if ! @mod_et.normpath_from_distilled @name.as_distilled_stem
          real_dpn
        end
        np = produce_prepared_np
        @load_file_path = real_dpn.to_path
        require @load_file_path
        :loaded == @mod_et.state_i or @mod_et.change_state_to :loaded
        @stwy_normpath = np ; nil
      end

      def produce_prepared_np
        np = @mod_et.normpath_from_distilled @name.as_distilled_stem
        np ||= @mod_et.add_imaginary_normpath_for_correct_name @name, @pn
        if :not_loaded == np.state_i
          np.change_state_to :loading
        else
          np.assert_state :loading
        end
        np
      end

      def finish_np_a
        d = -1 ; mod = @mod
        begin
          np = @np_a.fetch d += 1
          if np.value_is_known
            x_ = np.known_value
          else
            np.change_state_to :loaded
            is_broken = false ; const_i = nil
            @const_missing.fzzy_lookup_name_in_mod np.name_for_lookup, mod,
              -> c { const_i = c }, -> { is_broken = true }
            is_broken and break
            x_ = mod.const_get const_i, false
            # as soon as one of these nodes it not defined, the chain of
            # isomorphicisms is broken and we need not look any further
            mod.autoloaderize_with_normpath_value np, x_
          end
          mod = x_
        end while d < @last_d ; nil
      end

      def produce_some_value
        np = @stwy_normpath
        if np.value_is_known
          x = np.known_value
        else
          x = @const_missing.lookup_x_after_loaded
          if x.respond_to?( :dir_pathname ) &&
              x.dir_pathname != np.some_dir_pathname
            np = Stowaway_Actors__::Resolve_relpath__[ @mod, x.dir_pathname ]
            np.assert_state :loaded
          end
          if np.value_is_known
            x.entry_tree.object_id == np.object_id or self._SANITY
          else
            @mod.autoloaderize_with_normpath_value np, x
          end
        end
        x
      end
    end

    class Stowaway_Actors__::Resolve_relpath__

      Actor[ self, :properties, :mod, :dpn ]

      def execute
        init_ivars
        ignore_common_head
        flush
      end

    private

      def init_ivars
        @existant_a = @mod.dir_pathname.to_path.split PATH_SEP_
        @imagined_a = @dpn.to_path.split PATH_SEP_
        @same_a = []
      end

      def ignore_common_head
        @is_different = false
        d = -1 ; last = [ @existant_a.length, @imagined_a.length ].min - 1
        while d < last
          d += 1
          if @existant_a[ d ] != @imagined_a[ d ]
            d -= 1
            @is_different = true
            break
          end
        end
        @imagined_a[ 0, d + 1 ] = EMPTY_A_
        @existant_a[ 0, d + 1] = EMPTY_A_ ; nil
      end

      def flush
        if @is_different
          when_is_different
        else
          @existant_a.length.zero? or self._HOLE
          @imagined_a.length.nonzero? or self._HOLE  # paths are same
          when_only_theirs_is_left
        end
      end

      def when_only_theirs_is_left
        @imagined_a.reduce @mod.entry_tree do |et, s|
          name = Name.via_slug s
          i = name.as_distilled_stem
          et_ = et.normpath_from_distilled i
          if ! et_
            et_ = et.imaginary_h[ i ]
          end
          if ! et_
            et_ = et.add_imaginary_normpath_for_correct_name name
          end
          :loading == et_.state_i and et_.change_state_to :loaded
          et_
        end
      end

      def when_is_different  # near :+[#ba-034]
        const_a = @mod.name.split CONST_SEP_
        const_a[ - ( @existant_a.length ) .. -1 ] = EMPTY_A_
        _mod = Module_path_value_via_parts[ const_a ]
        _mod_ = Autoloader.const_reduce do |cr|
          cr.from_module _mod
          cr.const_path @imagined_a
        end
        _mod_.entry_tree
      end
    end
  end
end
