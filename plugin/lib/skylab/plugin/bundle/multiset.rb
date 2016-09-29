module Skylab::Plugin

  # ->

    module Bundle::Multiset  # see [#002] NOTE this is legacy, for [hl] ONLY

      def self.[] mod
        mod.extend self
      end

      def edit_module_via_mutable_iambic client, x_a
        h = _hard_bundle_fetcher
        begin
          client.module_exec x_a, & h[ x_a.shift ].to_proc
        end while x_a.length.nonzero?
        NIL_
      end

      def _hard_bundle_fetcher
        @_hard_bundle_fetcher ||= _build_hard_bundle_fetcher
      end

      def _build_hard_bundle_fetcher

        h = ::Hash.new( & method( :__handle_bundle_not_found ) )

        constants.each do |const_i|
          # #storypoint-110 how bundle name resolution works
          str = const_i.to_s
          _k = if UCASE_RANGE___.include? str.getbyte( 1 )
            const_i
          else
            str[ 0 ] = str[ 0 ].downcase
            str.intern
          end
          h[ _k ] = const_get const_i
        end

        h
      end

      UCASE_RANGE___ = 'A'.getbyte( 0 ) .. 'Z'.getbyte( 0 )

      def __handle_bundle_not_found h, k
        raise ::KeyError, __say_bundle_not_found( k, h.keys )
      end

      def __say_bundle_not_found k, a

        Home_.lib_.basic::List::EN.say_not_found k, a
      end

      def to_proc
        @to_proc ||= __build_to_proc_proc
      end

      def __build_to_proc_proc
        h = soft_bundle_fetcher
        -> a do
          while a.length.nonzero?
            any_to_procable = h[ a[ 0 ] ]
            any_to_procable or break
            a.shift
            module_exec a, & any_to_procable.to_proc
          end ; nil
        end
      end

      def soft_bundle_fetcher
        @soft_bundle_fetcher ||= _build_soft_bundle_fetcher
      end

      def _build_soft_bundle_fetcher
        hard_h = _hard_bundle_fetcher
        -> i do
          hard_h.fetch i do end
        end
      end
    end

    module Directory

      def self.[] mod
        Autoloader_[ mod ]
        Multiset[ mod ]
        mod.extend self ; nil
      end

      def _build_hard_bundle_fetcher
        soft_bundle_fetcher  # kick
        -> i do
          const_i = @h[ i ] or raise ::KeyError, say_bundle_not_found( i, @a )
          const_get const_i, false
        end
      end

      def _build_soft_bundle_fetcher

        self._NOT_COVERD_might_still_work  # #cover-me or delete

        @a = [ ] ; @h = { }
        ::Pathname.new( dir_patn ).children( false ).each do |pn|
          stem = pn.sub_ext( EMPTY_S_ ).to_s
          WHITE_STEM_RX__ =~ stem or next
          stem.gsub! DASH_, UNDERSCORE_
          meth_i = stem.intern
          @a << meth_i
          @h[ meth_i ] = Constify___[ stem ]
        end

        -> i do
          const_i = @h[ i ]
          const_i and const_get const_i, false
        end
      end

      WHITE_STEM_RX__ = /[^-]\z/

      Constify___ = -> stem do
        "#{ stem[ 0 ].upcase }#{ stem[ 1 .. -1 ] }".intern
      end
    end
    # <-
end
