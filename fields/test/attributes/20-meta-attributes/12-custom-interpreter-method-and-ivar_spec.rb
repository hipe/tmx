require_relative '../../test-support'

module Skylab::Fields::TestSupport

  TS_.require_ :attributes  # namespace antics #[#017] justified
  module Attributes

    TS_.describe "[fi] attributes - misc meta attributes one" do

      TS_[ self ]
      use :memoizer_methods
      Attributes[ self ]

      context "`ivar`" do

        given_the_attributes_ do
          attributes_(
            shenkberger: [ :ivar, :@_wazoo ],
          )
        end

        it "hi." do
          against_ :shenkberger, :_hey_
          @_wazoo.should eql :_hey_
        end
      end

      context "`custom_interpreter_method`" do

        given_the_attributes_ do

          attributes_(
            zizzie: :custom_interpreter_method,
            zozlow: :custom_interpreter_method,
          )
        end

        shared_subject :_some_class_over_here do

          class X_MMA_CW

            def zizzie=
              st = @_polymorphic_upstream_
              @zizzie = [ :_yes_, st.gets_one, st.gets_one ]
              true  # KEEP_PARSING_
            end

            attr_reader :zizzie

            self
          end
        end

        it "if the session object responds to it then yay" do

          sess = _some_class_over_here.new
          _attrs = the_attributes_
          _attrs.init sess, [ :zizzie, :wiffie, :skiffie ]
          sess.zizzie.should eql [ :_yes_, :wiffie, :skiffie ]
        end

        it "if the session does not respond then you get no grace" do

          sess = _some_class_over_here.new
          _attrs = the_attributes_

          begin
            _attrs.init sess, [ :zozlow, :_never_written ]
          rescue ::NoMethodError => e
          end

          e.message.should match %r(\Aundefined method `zozlow=')
        end
      end
    end
  end
end
