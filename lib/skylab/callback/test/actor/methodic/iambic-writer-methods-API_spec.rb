require_relative 'test-support'

module Skylab::Callback::TestSupport::Actor::Methodic::IWM

  Parent_TS_ = Skylab::Callback::TestSupport::Actor::Methodic

  Parent_TS_[ self ]

  include Constants

  extend TestSupport_::Quickie

  Grandparent_Subject_ = Parent_TS_::Parent_subject_

  describe "[cb] actor - methodic - iambic writer methods API" do

    context "`iambic_writer_method_to_be_provided`" do

      before :all do

        class A
          Grandparent_Subject_[].methodic self, :simple, :properties,
            :iambic_writer_method_to_be_provided, :zippy

        private
          def zippy=
            @tungsten = iambic_property
            @bungsten = iambic_property
          end

          alias_method :initialize, :instance_exec
        end

      end

      it "loads" do
      end

      it "staves off the creation of the writer method." do
        o = A.new do
          process_iambic_fully [ :zippy, :wiffy, :shiffy ]
        end
        o.instance_variable_get( :@tungsten ).should eql :wiffy
        o.instance_variable_get( :@bungsten ).should eql :shiffy
      end
    end

    context "`iambic_writer_method_proc_proc`" do

      before :all do

        Do_this_thing = -> prop do
          _IVAR = prop.as_ivar
          -> do
            x = iambic_property
            instance_variable_set _IVAR, "<< #{ x.upcase } >>"
          end
        end

        class B
          Grandparent_Subject_[].methodic self, :simple, :properties,
            :iambic_writer_method_proc_proc, Do_this_thing, :ohai,
            :hey

          alias_method :initialize, :instance_exec
        end
      end

      it "loads" do
      end

      it "pass a proc that makes a proc, this proc defines your I.W.M" do
        o = B.new do
          process_iambic_fully [ :ohai, 'zeep', :hey, 'zoop' ]
        end
        o.instance_variable_get( :@hey ).should eql 'zoop'
        o.instance_variable_get( :@ohai ).should eql '<< ZEEP >>'
      end
    end
  end
end
