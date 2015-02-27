require_relative 'test-support'

module Skylab::FileMetrics::TestSupport::Models

  ::Skylab::FileMetrics::TestSupport[ TS_ = self ]

  module Sandbox
    ::Skylab::TestSupport::Sandbox.enhance( self ).kiss_with 'KLS_'
  end

  include Constants

  FM_.lib_.DSL_DSL_enhance_module self, -> do
    block :with_klass
  end

  module ModuleMethods

    include Constants

    extend FM_.lib_.let

    let :klass do
      TS_::Sandbox.kiss with_klass_value.call
    end
  end

  module InstanceMethods
    Sandbox = Sandbox
    def klass
      self.class.klass
    end
  end

  # --*--

  extend TestSupport::Quickie

  describe "[fm] models" do

    extend TS_

    context "a produced subclass with one field" do

      with_klass do
        FM_::Model::Node::Structure.new :foo
      end

      it "trying to pass too many args - arg error" do
        -> do
          k = klass
          k.new :one, :two
        end.should raise_error( ::ArgumentError, /wrong number.+\(2 for 1\)/ )
      end

      it "trying to pass too few args - ok, you get nil (and reader)" do
        me = klass.new
        me.foo.should eql( nil )
      end

      it "you can set the same field with either hash or positionally" do
        me = klass.new :zing
        m2 = klass.new foo: :zang
        me.foo.should eql( :zing )
        m2.foo.should eql( :zang )
      end
    end

    context "a produced subclass with multiple fields" do

      with_klass do
        FM_::Model::Node::Structure.new :fee, :fi, :fo, :fum
      end

      it "internally, nils are set for all fields" do
        me = klass.new :A, fum: :D
        ( a = me.instance_variables ).sort_by! { |x| x.to_s }
        a.should eql( [ :@child_a, :@fee, :@fi, :@fo, :@fum ] )
        a.map { |ivar| me.instance_variable_get ivar }.should eql(
          [ nil, :A, nil, nil, :D ]
        )
      end

      it "it complains about strange fields in the hash" do
        -> do
          klass.new fizzle: :F
        end.should raise_error( ::KeyError, /\Akey not found: :fizzle/ )
      end
    end

    context "but it gets kray - what is the one thing you can't do w/ struct" do

      it "does" do
        kls1 = ::Class.new(
          FM_::Model::Node::Structure.new :foo, :bar )

        Sandbox.kiss kls1

        kls2 = Sandbox.kiss( kls1.subclass :wing, :wang )

        kls2.members.should eql( [ :foo, :bar, :wing, :wang ] )

        kls1.class_exec do
          def bar
            @bar.upcase
          end
          def wang
            "nosee: #{ @wang }"
          end
        end
        o2 = kls2.new 'fo', 'bar', wang: :wung
        o2.bar.should eql( 'BAR' )
        o2.wang.should eql( :wung )
      end
    end
  end
end
