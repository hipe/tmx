require_relative '../test-support'

module Skylab::Fields::TestSupport

  # this is a somewhat built-out convolution we used to discover a wicked
  # trip-up we hit when refactoring attributes. it revealed how important
  # the delta changeset logic was when dealing with inheritance graphs
  # together with hook chains. You may recognize some of the names from
  # elsewhere, which was where the issue was first discovered.

  # EDIT: broadly this sort of "pattern" could perhaps be better achieved
  # with a "normalization box" (which is ordered) of [#br-022] properties,
  # which would avoid the below nastiness with alias method chains.

  build_modules_into = -> o do

    class o::Lib_Task
      A_Subject_Module_::DSL[ self ]
    end

    class o::Task < o::Lib_Task
      attribute_metadata_class do
        def [] k ; fetch( k ) { } end
      end

      meta_attribute :pathname
      meta_attribute :from_context
      meta_attribute :required

      def self.on_from_context_attribute name, meta
        before = "#{ name }_before_from_context"
        alias_method before, name
        define_method name do
          if instance_variable_defined? "@#{ name }" # verrry experimental
            return instance_variable_get "@#{ name }"
          end
          fail 'never'
        end
      end

      def self.on_pathname_attribute name, meta
        before = "#{ name }_before_pathname"
        alias_method before, name
        define_method name do
          if pn = send( before ) and ! pn.kind_of?(::Pathname)
            instance_variable_set "@#{ name }", ( pn = ::Pathname.new(pn) )
          end
          pn
        end
      end
    end

    class o::Get < o::Task
      attribute :build_dir, required: true, from_context: true
    end

    class o::TarballTo < o::Get
      attribute :build_dir, required: true, pathname: true, from_context: true
    end

    NIL_
  end

  next_id = Build_next_integer_generator_starting_after[ 0 ]

  scenario_module = -> do

    mod = TS_.const_set :"A_S1_#{ next_id[] }", ::Module.new

    build_modules_into[ mod ] # we could module_exec but it's not much prettier

    scenario_module = -> { mod }

    mod
  end

  describe "[fi] attribute - scenario 1" do

    extend TS_
    use :attribute_support

    it "four-node inheritance chain and hook chain - whew" do

      mod = scenario_module[]
      o = mod::TarballTo.new
      o.build_dir = "ok/yes"
      o.build_dir.should be_kind_of( ::Pathname )
    end
  end
end
