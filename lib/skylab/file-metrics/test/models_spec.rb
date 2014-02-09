require_relative 'test-support'

module Skylab::FileMetrics::TestSupport::Models

  ::Skylab::FileMetrics::TestSupport[ Models_TestSupport = self ]

  module Sandbox
    ::Skylab::TestSupport::Sandbox.enhance( self ).kiss_with 'KLS_'
  end

  include CONSTANTS

  Lib_ = Lib_

  Lib_::DSL_DSL_enhance_module[ self, -> do
    block :with_klass
  end ]

  module ModuleMethods

    include CONSTANTS

    extend Lib_::Let[]

    let :klass do
      Models_TestSupport::Sandbox.kiss with_klass_value.call
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

  describe "#{ FileMetrics }::Models - Node::Structure" do

    extend Models_TestSupport

    context "a produced subclass with one field" do

      with_klass do
        FileMetrics::Model::Node::Structure.new :foo
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
        FileMetrics::Model::Node::Structure.new :fee, :fi, :fo, :fum
      end

      it "internally, nils are set for all fields" do
        me = klass.new :A, fum: :D
        ( a = me.instance_variables ).sort_by! { |x| x.to_s }
        a.should eql( [ :@fee, :@fi, :@fo, :@fum ] )
        a.map { |ivar| me.instance_variable_get ivar }.should eql(
          [ :A, nil, nil, :D ]
        )
      end

      it "it complains about strange fields in the hash" do
        -> do
          klass.new fizzle: :F
        end.should raise_error( ::KeyError, /key not found: :fizzle/ )
      end

      it "it complains if there is a conflict btwn hash and positional" do
        -> do
          klass.new :A, :B, :C, fi: :B, fo: :C, fum: :D
        end.should raise_error( ::ArgumentError,
          /hash argument in conflict with positional argument - index 1, "fi"/ )
      end
    end

    context "but it gets kray - what is the one thing you can't do w/ struct" do

      it "does" do
        kls1 = ::Class.new(
          FileMetrics::Model::Node::Structure.new :foo, :bar )

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
