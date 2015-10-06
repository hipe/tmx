require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] attribute" do

    extend TS_
    use :attribute_support

    it "creates getter/setters on classes" do

      klass = one_such_class_ do
        attribute :foo
      end

      o = klass.new
      o.foo.should eql(nil)
      o.foo = 'bar'
      o.foo.should eql('bar')
    end

    it "allows reflection of what attribute names have been defined" do

      klass = one_such_class_ do
        attribute :foo
        attribute :bar
      end

      klass.attributes.a_.should eql [ :foo, :bar ]
    end

    context "when dealing with class inheritance" do

      klass_a = one_such_class_ do
        attribute :foo
      end

      klass_b = ::Class.new(klass_a).class_eval do
        attribute :bar
        self
      end

      it "inherits the getters and setters" do
        b = klass_b.new
        b.foo = 'x'
        b.foo.should eql('x')
      end

      it "inherits the reflection" do
        klass_b.attributes.a_.should eql [ :foo, :bar ]
      end
    end

    context "class inheritance with regards to metaproperties" do

      let :klass_a do
        one_such_class_ do
          meta_attribute :fooish
          attribute :foo, :fooish => true
        end
      end

      let :klass_b do
        ::Class.new(klass_a).class_eval do
          attribute :foo, :fooish => false
          self
        end
      end

      it "child classes must be able to override metaproperties" do
        klass_b.attributes.fetch(:foo)[:fooish].should eql(false)
        klass_a.attributes.fetch(:foo)[:fooish].should eql(true)
      end
    end

    context "with meta attributes" do

      it "won't let you make them willy nilly" do
        lambda do
          one_such_class_ do
            attribute :derp, :herp => :lerp
          end
        end.should raise_error(::RuntimeError, /meta attributes must first be declared: :herp/)
      end

      context "they get inherited from parent" do

        let :klass_a do
          one_such_class_ do
            meta_attribute :height
            class << self
              public :meta_attribute, :meta_attributes
            end
          end
        end

        let :klass_b do
          ::Class.new( klass_a).class_eval do
            meta_attribute :weight
            self
          end
        end

        it "as here" do
          klass_b.meta_attributes.a_.should eql [ :height, :weight ]
        end

        it "but adding things to the parent dynamically won't inherit" do

          same = [ :height, :age, :weight ]

          klass_a.meta_attribute :age
          klass_b.meta_attributes.a_.should eql same
          klass_a.meta_attribute :volume
          klass_b.meta_attributes.a_.should eql same
        end
      end

      context "you can define hooks" do

        it "that are called when you define attributes with those meta attributes" do

          klass_a = one_such_class_ do
            meta_attribute :whoopie
            def self.on_whoopie_attribute name, meta
              remove_method name
              define_method(name) { "A:#{instance_variable_get("@#{name}")}:B" }
              touched.push [name, meta]
            end
          end

          klass_b = ::Class.new(klass_a).class_eval do
            @touched = []
            class << self
              attr_reader :touched
            end
            attribute :wankers, whoopie: :nerp
            self
          end

          who, hah = klass_b.touched.first
          who.should eql :wankers
          hah.get_names.should eql([:whoopie])
          hah[:whoopie].should eql(:nerp)
          obj = klass_b.new
          obj.wankers = 'derp'
          obj.wankers.should eql('A:derp:B')
        end
      end
    end

    context "lets you import meta attribute definitions from modules" do

      before :all do

        module Defining_Module

          A_Subject_Module_::Definer[ self ]

          meta_attribute :regex do |name, meta|
            alias_method(after = "#{name}_after_regex=", "#{name}=")
            define_method("#{name}=") do |str|
              if meta[:regex] =~ str
                send(after, str)
              else
                call_digraph_listeners(:error, "#{str.inspect} did not match regex: /#{meta[:regex].source}/")
                str
              end
            end
          end
          class << self
            public :meta_attributes
          end
        end

        class Importing_Class

          A_Subject_Module_::Definer[ self ]

          meta_attribute Defining_Module

          class << self
            public :meta_attributes
          end
        end

        class Child_Class < Importing_Class

          def initialize espy
            @emit_spy = espy
          end

          attribute :first_name, :regex => /^[A-Z]/

          def call_digraph_listeners i, s
            @emit_spy.call_digraph_listeners i, s ; nil
          end
        end
      end

      def defining_module
        Defining_Module
      end

      def importing_class
        Importing_Class
      end

      def child_class
        Child_Class
      end

      it "which transfers the same matr object to child (should be ok)" do

        _ = importing_class.meta_attributes[ :regex ]
        _.should be_kind_of A_Subject_Module_::MetaAttribute___
        importing_class.meta_attributes[:regex].object_id.should eql(defining_module.meta_attributes[:regex].object_id)
      end

      it "also it transfers the attribute definition hook from the module" do

        defining_module.should be_respond_to(:on_regex_attribute)
        importing_class.should be_respond_to(:on_regex_attribute)
      end

      it "and which will work e.g. from an object of a child class" do

        o = child_class.new __build_and_attach_to_emit_spy
        o.first_name.should be_nil
        o.first_name = "Billford Brimley"
        o.first_name.should eql "Billford Brimley"
        @em_a.length.should be_zero
        o.first_name = "toff tofferson"
        @em_a.length.should eql 1
        em = @em_a.shift
        em.stream_symbol.should eql :error
        em.payload_x.should eql '"toff tofferson" did not match regex: /^[A-Z]/'
        o.first_name.should eql "Billford Brimley"
      end

      def __build_and_attach_to_emit_spy

        es = Callback_.test_support.
          call_digraph_listeners_spy(
            :do_debug_proc, -> { do_debug },
            :debug_IO, debug_IO )

        @em_a = es.emission_a
        es
      end
    end
  end
end