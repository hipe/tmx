module Skylab::Callback

  module Autoloader

    module Boxxy_  # read [#030] #the-boxxy-narrative

      module Methods  # ~ constants
        def constants
          a = super
          a_ = boxxy_infrrd_constants a
          [ * a, * a_ ]
        end
      private
        def boxxy_infrrd_constants a
          et = entry_tree
          stem_p = fuzzy_stem_cache
          have_h = ::Hash[ a.map { |i| [ stem_p[ i ], true ] } ]
          scn = et ? et.get_normpath_scanner : Scn.the_empty_scanner
          y = []
          while (( np = scn.gets ))
            have_h[ stem_p[ np.corename_as_const ] ] and next
            if :not_loaded == np.state_i
              y << np.corename_as_const
              next
            end
            np.assert_state :loaded
          end
          y
        end
        def fuzzy_stem_cache
          @fuzzy_stem_cache ||= ::Hash.new{ |h, k| h[ k ] = Distill_[ k ] }
        end
      end
    end

    module Boxxy_::Methods  # ~ const_defined?
      def const_defined? i, ascend=true
        _yes = super
        _yes or const_might_load_boxxily i
      end
    private
      def const_might_load_boxxily i
        et = entry_tree ; found = false
        scn = et ? et.get_normpath_scanner : Scn.the_empty_scanner
        stem = Distill_[ i ]
        while (( np = scn.gets ))
          stem == np.corename_as_distilled_stem or next
          :not_loaded == np.state_i and break found = true
          np.assert_state :loaded
        end
        found
      end
    end

    class Entry_Tree_  # ~ #the-fuzzily-unique-entry-scanner
      def get_normpath_scanner  # (#fuzzy-sibling-pairs)
        @did_index_all ||= index_all
        a = @stem_i_a ; d = -1 ; last = a.length - 1
        Scn.new do
          if d < last
            _stem_i = a.fetch d+= 1
            _x = @normpath_lookup_p[ _stem_i ]
            _x
          end
        end
      end
    end

    class Normpath_
      def corename_as_const
        name_for_lookup.as_const
      end
      def corename_as_distilled_stem
        name_for_lookup.as_distilled_stem
      end
    end
  end
end
