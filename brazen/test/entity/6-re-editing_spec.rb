require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity

  describe "[br] entity - 6. re-editing" do

    # (one context) ->

      before :all do

        Six_My_Extmod = Subject_[].call do

          o :ad_hoc_processor, :wizzzle, -> sess do

            sess.client.x = sess.upstream.gets_one
            KEEP_PARSING_
          end
        end

        class Six_My_Class

          singleton_class.send :attr_accessor, :x

          Six_My_Extmod.call self,
            :wizzzle, :_sure_,
            :properties, :foo, :bar

          :_sure_ == self.x or fail

          edit_entity_class :property, :baz, :wizzzle, :_yup_

          :_yup_ == self.x or fail

        end

      end

      it "`edit_entity_class` effects an edit session" do

        Six_My_Class.properties.get_names.should eql [ :foo, :bar, :baz ]

      end

      # <-
  end
end
