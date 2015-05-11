require_relative 'test-support'

module Skylab::FileMetrics::TestSupport::Models

  ::Skylab::FileMetrics::TestSupport[ TS_ = self ]

  include Constants

  TestSupport_ = TestSupport_

  module Sandbox
    TestSupport_::Sandbox.enhance( self ).kiss_with 'KLS_'
  end

  FM_.lib_.DSL_DSL_enhance_module self, -> do
    block :with_klass
  end

  module ModuleMethods

    # exeriment - is this worth it? this is for the "nonstandard thing" below
    # that memoized **into** the test context **class**

    define_singleton_method :let, TestSupport_::Let::LET_METHOD

    let :klass do
       TS_::Sandbox.kiss with_klass_value.call
    end

    define_method :__memoized, TestSupport_::Let::MEMOIZED_METHOD
  end

  module InstanceMethods

    def klass  # nonstandard thing: ..
      self.class.klass
    end
  end

  # --*--

  extend TestSupport_::Quickie

  describe "[fm] models" do

    extend TS_

    context "a produced subclass with one field" do

      with_klass do
        FM_::Model::Node::Structure.new :foo
      end

      it "trying to pass too many args - arg error" do
        cls = klass
        begin
          cls.new :one, :two
        rescue ::ArgumentError => e
        end
        e.message.should match %r(\bwrong number.+\(2 for 1\))
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
        begin
          klass.new fizzle: :F
        rescue ::KeyError => e
        end
        e.message.should match %r(\Akey not found: :fizzle)
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
