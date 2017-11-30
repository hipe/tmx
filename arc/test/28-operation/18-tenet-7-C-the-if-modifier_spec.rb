require_relative '../test-support'

module Skylab::Arc::TestSupport

  describe "[arc] operation - tenet 7C - the `if` modifer" do

    TS_[ self ]
    use :memoizer_methods

    it "does yes when yes" do

      o = _new

      _ok = o.edit_entity(
        :if, :color_starts_with_g,
        :add, :color, :green,
      )

      expect( _ok ).to eql [ :last_delivery_result, :green ]
      expect( o._a ).to eql [ :green ]
    end

    it "does no when no" do

      o = _new

      _ok = o.edit_entity(
        :if, :color_starts_with_g,
        :add, :color, :red,
      )

      expect( _ok ).to eql :welff_nothing_happened
      expect( o._a.length ).to be_zero
    end

    it "does the second of two" do

      o = _new

      _ok = o.edit_entity(

        :if, :color_starts_with_g,
        :add, :color, :red,
        :if, :color_starts_with_g,
        :add, :color, :greena,
      )

      expect( _ok ).to eql [ :last_delivery_result, :greena ]
      expect( o._a ).to eql [ :greena ]
    end

    def _new
      __subject_class.new
    end

    shared_subject :__subject_class do

      class ACS_28_6_18

        def initialize
          @_a = []
        end

        attr_reader(
          :_a,
        )

        def edit_entity * x_a, & x_p
          ACS_[].edit x_a, self, & x_p
        end

        def __color__component_association

          yield :can, :add

          -> st do
            Common_::KnownKnown[ st.gets_one ]
          end
        end

        def component_is__color_starts_with_g__ qk, & _

          if 'g' == qk.value[ 0 ]
            true
          else
            false
          end
        end

        def __add__component qk, & _x_p
          x = qk.value
          @_a.push x
          x
        end

        def result_for_component_mutation_session_when_changed o, & __

          [ :last_delivery_result, o.last_delivery_result ]
        end

        def result_for_component_mutation_session_when_no_change & __

          :welff_nothing_happened
        end

        ACS_ = -> do
          Home_
        end

        self
      end
    end
  end
end
