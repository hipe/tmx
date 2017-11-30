require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] entity - re-editing" do

    TS_[ self ]
    use :memoizer_methods
    use :entity

    # -
      shared_subject :_subject_class do

        X_e_ree_Extmod = subject_library_.call do

          o :ad_hoc_processor, :wizzzle, -> sess do

            sess.client.x = sess.upstream.gets_one
            KEEP_PARSING_
          end
        end

        class X_e_ree_Class

          singleton_class.send :attr_accessor, :x

          X_e_ree_Extmod.call self,
            :wizzzle, :_sure_,
            :properties, :foo, :bar

          :_sure_ == self.x or fail

          edit_entity_class :property, :baz, :wizzzle, :_yup_

          :_yup_ == self.x or fail

          self
        end
      end

      it "`edit_entity_class` effects an edit session" do

        _cls = _subject_class
        expect( _cls.properties.get_keys ).to eql [ :foo, :bar, :baz ]
      end
    # -
  end
end
