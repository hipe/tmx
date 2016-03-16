require 'skylab/callback'

class Skylab::Task

  class << self

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>


     # ~ as class (code notes in [#003])

     # this is a blind, 4 years later rewrite of our task library.
     # it is not yet integrated with the legacy code

      class << self

        def depends_on * sym_a

          col = _writable_dependee_references_collection

          sym_a.each do |sym|
            col._add User_Defined_Dependee_Reference___.new sym
          end

          NIL_
        end

        def depends_on_parameters * x_a

          col = _writable_dependee_references_collection

          cls = Home_::Models_::Parameter::DependeeReference

          if 1 == x_a.length
            x = x_a.fetch 0
            if x.respond_to? :each_with_index
              col.__add_unparsed x
            else
              col._add cls.new x
            end
          else
            x_a.each do |sym|
              col._add cls.new sym
            end
          end
          NIL_
        end

        def _writable_dependee_references_collection
          @_dependee_references ||= References___.new
        end

        attr_reader :_dependee_references
      end  # >>

      def initialize & oes_p

        @_name_ = Callback_::Name.via_module self.class
        @_name_symbol_ = @_name_.as_const  # be careful

        @_oes_p_ = oes_p
      end

      # ~ behavior

      def execute_as_front_task

        # not for every task in the graph, only the "front" one

        o = Home_::Sessions::Execute_Graph::Newschool.new( & @_oes_p_ )

        if instance_variable_defined? :@_params
          o.parameter_box = remove_instance_variable :@_params
        end
        o.target_task = self
        o.execute
      end

      def accept index, & visit

        visit.call self do
          ___to_dependee_stream_around index
        end
      end

      def ___to_dependee_stream_around index

        _ = ___dependee_references
        _st = _.to_stream
        _st_ = _st.map_by do |dref|
          dref.dereference_against_ index
        end
        _st_
      end

      def ___dependee_references
        self.class._dependee_references
      end

      def receive_dependency_completion dc

        dc.task.visit_dependant_as_completed_ self, dc
      end

      def visit_dependant_as_completed_ dep, dref

        dep.receive_dependency_completion_value self, dref
      end

      def receive_dependency_completion_value x, dc

        instance_variable_set dc.derived_ivar, x
        NIL_
      end

      def derived_ivar_

        @___derived_ivar ||= :"@#{ @_name_.as_const }"  # ! .as_ivar (downcases)
      end

      def add_parameter sym, x
        ( @_params ||= Callback_::Box.new ).add sym, x
        NIL_
      end

      def name_symbol  # see #note-1 about these method names
        @_name_symbol_
      end

      def name
        @_name_
      end

      class References___

        def initialize
          @_unparsed_indexes = nil
          @_a = []
        end

        def __add_unparsed x
          ( @_unparsed_indexes ||= [] ).push @_a.length
          @_a.push x ; nil
        end

        def _add o
          @_a.push o ; nil
        end

        # --

        def to_stream
          if @_unparsed_indexes
            ___parse
          end
          Callback_::Stream.via_nonsparse_array @_a
        end

        def ___parse

          # for every position in the array that was an unparsed hash (in
          # reverse order because etc.) parse it using the dependency lib,
          # then wrap each such formal attribute in its adapter

          Require_field_library_[]

          d_a = @_unparsed_indexes
          @_unparsed_indexes = nil

          cls = Home_::Models_::Parameter::DependeeReference_via_Attribute
          begin
            d = d_a.pop
            d or break

            _h = @_a.fetch d
            _attrs = Field_::Attributes[ _h ]
            st = _attrs.to_defined_attribute_stream

            a = []
            begin
              atr = st.gets
              atr or break
              a.push cls.new atr
              redo
            end while nil

            @_a[ d, 1 ] = a

            redo
          end while nil

          NIL_
        end
      end

      class Dependee_Reference_

        def initialize sym
          @sym = sym
          freeze
        end
      end

      class User_Defined_Dependee_Reference___ < Dependee_Reference_

        def dereference_against_ index

          bx = index.box

          bx.fetch @sym do
            x = __build_against index
            bx.add @sym, x
            x
          end
        end

        def __build_against index

          _cls = index.box_module.const_get @sym, false

          _cls.new( & index.on_event_selectively )
        end
      end

  # -- these

  Callback_ = ::Skylab::Callback
  Lazy_ = Callback_::Lazy

  Require_field_library_ = Lazy_.call do
    Field_ = Home_.lib_.fields  # idiomatic name
    NIL_
  end

  # -- these

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    ACS = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]

    String_IO = -> do
      require 'stringio' ; ::StringIO
    end
  end

  module Models_
    Autoloader_[ self ]
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_A_ = [].freeze
  Home_ = self
  NIL_ = nil
  UNABLE_ = false

  if false

  module TaskClassMethods
    def task_type_name
       to_s.match(/([^:]+)\z/)[1].gsub(/([a-z])([A-Z])/){ "#{$1} #{$2}" }.downcase
    end
  end

  # was class

    extend Home_::Interpolate
    extend TaskClassMethods
    def action= action
      @actions.push action
    end
    def initialize opts=nil
      @name = nil
      init_parenthood
      block_given? and yield self
      if opts
        opts = opts.dup
        opts.key?(:name) and self.name = opts.delete(:name)
      end
      super(name, rake_application) # nil name ok, we need things from above
      opts and opts.each { |k, v| send("#{k}=", v) }
      @arg_names ||= [:context] # a resonable, harmless default
    end
    meta_attribute :interpolated
    def self.on_interpolated_attribute name, meta
      if meta[:interpolated]
        remove_method name
        define_method name do
          self.class.interpolate instance_variable_get("@#{name}"), self
        end
      else
        attr_reader name
      end
    end

    def name
      if @name
        @name
      elsif LegacyTask != self.class # awful #todo
        self.class.task_type_name
      end
    end

    def name= name
      result = name
      name = name.to_s # per rake
      begin
        if @name == name
          break # noop
        end
        if @name.nil? or '' == @name
          @name = name
          break
        end
        fail "for now, won't clobber existing names (#{ name.inspect } #{
          }on top of #{ @name.inspect })"
      end while nil
      result
    end
    def prerequisites= arr
      @prerequisites.any? and raise RuntimeError.new("prerequisites= cannot be used to overwrite nor concat to any existing prereqs")
      @prerequisites.concat arr
      arr
    end
  end  # if false
end

# #tombstone: we no longer subclass rake task
# #tombstone: (temporary) Home_.lib_.fields::Attribute::DSL[ self ]
# #tombstone: we no longer associate parenthood strongly to nodes
