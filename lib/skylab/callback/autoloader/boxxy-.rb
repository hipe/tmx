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
          scn = et ? et.to_stream : Scn.the_empty_stream
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
        scn = et ? et.to_stream : Scn.the_empty_stream
        stem = Distill_[ i ]
        while (( np = scn.gets ))
          stem == np.corename_as_distilled_stem or next
          :not_loaded == np.state_i and break found = true
          np.assert_state :loaded
        end
        found
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

    module Boxxy_

      # ~

      NAMES_METHOD_P = -> do
        ::Enumerator.new do |y|
          fly = Names__::Get_fly[]
          constants.each do |i|
            fly.replace_with_constant_i i
            y << fly
          end ; nil
        end
      end

      module Methods
        define_method :names, & NAMES_METHOD_P
      end

      module Names__

        Get_fly = Callback_.memoize do

          class Fly_ < Callback_::Name

            def replace_with_constant_i sym
              @as_const = sym
              @as_slug = nil
              nil
            end

            def _init
              @const_is_resolved = true
              self
            end

            self
          end.allocate._init
        end
      end

      # ~

      EACH_CONST_VALUE_METHOD_P = -> & p do
        if p
          constants.each do |i|
            p[ const_get i, false ]
          end ; nil
        else
          enum_for :each_const_value
        end
      end

      module Methods
        define_method :each_const_value, & EACH_CONST_VALUE_METHOD_P
      end

      # ~

      module Methods
        def each_const_pair
          if block_given?
            constants.each do |const_i|
              yield const_i, const_get( const_i, false )
            end ; nil
          else
            enum_for :each_const_pair
          end
        end
      end
    end
  end
end
