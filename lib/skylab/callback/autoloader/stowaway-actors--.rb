module Skylab::Callback

  module Autoloader

    class Actors__::Resolve_relpath

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
          name = Name.from_slug s
          _et = et.normpath_from_distilled name.as_distilled_stem
          _et or et.add_imaginary_normpath_for_correct_name name
        end
      end

      def when_is_different
        const_a = @mod.name.split CONST_SEP_
        const_a[ - ( @existant_a.length ) .. -1 ] = EMPTY_A_
        _mod = const_a.reduce( ::Object ) { |m, s| m.const_get s, false }
        _mod_ = Autoloader.const_reduce do |cr|
          cr.from_module _mod
          cr.const_path @imagined_a
        end
        _mod_.entry_tree
      end
    end
  end
end
