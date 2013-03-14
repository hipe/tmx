require_relative 'test-support'

module Skylab::FileMetrics::TestSupport::Models
  ::Skylab::FileMetrics::TestSupport[ Models_TestSupport = self ]

  module SANDBOX
    -> do
      last_id = 0
      define_singleton_method :kls do |x|
        const_set "KLS_#{ last_id += 1 }", x
      end
      class << self
        alias_method :kiss, :kls
      end
    end.call
  end

  include CONSTANTS

  module ModuleMethods

    include CONSTANTS

    extend MetaHell::DSL_DSL

    dsl_dsl do
      block :with_klass
    end

    extend MetaHell::Let

    let :klass do
      Models_TestSupport::SANDBOX.kls get_with_klass.call
    end
  end

  module InstanceMethods
    SANDBOX = SANDBOX
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

        SANDBOX.kiss kls1

        kls2 = SANDBOX.kiss( kls1.subclass :wing, :wang )

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
