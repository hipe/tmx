require 'skylab/common'

class Skylab::Task

  class << self

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end

    def lib_
      @lib ||= Common_.produce_library_shell_via_library_and_app_modules Lib_, self
    end

    def sidesystem_path_
      @___ssp ||= ::File.expand_path '../../..', __FILE__
    end
  end  # >>

  # this file is meant to contain all of the code necessary to load the
  # definition of a task (that is, the task class and its use of the static
  # dependency DSL); but none of the code used in resolving its dependencies
  # or executing the task itself. code notes in [#008]. more about types of
  # dependencies in [#008].

  # - (the task base class *is* the toplevel node of this lib FOR NOW)
    # -
      class << self

        def depends_on_parameters * x_a
          __writable_parameter_collection.__add_args x_a
        end

        def depends_on * sym_a

          col = _writable_dependee_references_collection

          sym_a.each do |sym|
            col._add User_Defined_Dependee_Reference___.new sym
          end

          NIL_
        end

        def depends_on_call * x_a
          __writable_synthesis_dependency_collection.__add_args x_a
        end

        def __writable_synthesis_dependency_collection
          @__synthies ||= Unparsed_Synthesis_Dependency_Collection___.new
        end

        def __writable_parameter_collection
          @__formal_parameter_collection ||= begin
            o = Unparsed_Parameter_Collection_as_Dependee_Reference___.new self
            _writable_dependee_references_collection._add o
            o
          end
        end

        def _writable_dependee_references_collection
          @_dependee_references ||= DependencyReferences___.new
        end

        attr_reader(
          :_dependee_references,
          :__formal_parameter_collection,
          :__synthies,
        )

        def _task_name
          @___task_name ||= Common_::Name.via_module self
        end
      end  # >>

      def initialize & p
        @_listener_ = p
      end

      # ~ behavior

      def execute_as_front_task

        # not for every task in the graph, only the "front" one

        o = Home_::Magnetics_::Execution_via_ParameterBox_and_TargetTask.new( & @_listener_ )

        if instance_variable_defined? :@_params
          o.parameter_box = remove_instance_variable :@_params
        end
        o.target_task = self
        o.execute
      end

      def accept index, & visit

        dr = ___dependee_references
        if dr
          visit.call self do
            __to_dependee_stream_around dr, index
          end
        else
          visit[ self ]
        end
      end

      def ___dependee_references
        self.class._dependee_references
      end

      def __to_dependee_stream_around dr, index

        _st = dr.to_stream
        _st_ = _st.map_by do |dref|
          dref._dereference_against index
        end
        _st_
      end

      def receive_dependency_completion dc

        dc.task.visit_dependant_as_completed_ self, dc
      end

      def visit_dependant_as_completed_ dep, dc

        dep.receive_dependency_completion_value_and_name_(
          self, dc.name_for_storing )
      end

      def receive_dependency_completion_value_and_name_ x, name  # near [#fi-027]

        instance_variable_set name.as_ivar, x
        NIL_
      end

      def name_symbol_for_storage_
        name.as_const
      end

      def add_parameter sym, x
        ( @_params ||= Common_::Box.new ).add sym, x
        NIL_
      end

      def synthies_
        self.class.__synthies
      end

      def formal_parameters__
        self.class.__formal_parameter_collection
      end

      def name_symbol  # see [#here.B] about these method names
        self.class._task_name.as_const
      end

      def name
        self.class._task_name
      end

      DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
        if x
          instance_variable_set ivar, x ; true
        else
          x
        end
      end

    # -
  # -

  # -- when a task is completed

  class Dependency_Completion_  # a task receives its completed dependee thru

    def initialize task
      @task = task
    end

    # (names not ivars so that depender tasks can use any kind of store)

    def name_for_storing
      @_NfS ||= ___derive_name_function
    end

    def ___derive_name_function
      sym = @task.name_symbol_for_storage_
      nf = Common_::Name.via_variegated_symbol sym
      nf.as_ivar = :"@#{ sym }"  # don't lowercase it, [#003.B]
      nf
    end

    attr_reader(
      :task,
    )
  end

  # -- shared support for converting a reference to a referrant

  class Dereference_

    def initialize sym, index
      @sym = sym
      @index = index
    end

    def to_task_

      _cls = @index.box_module.const_get @sym, false

      _cls.new( & @index.listener )
    end
  end

  # -- collections of un-parsed references to dependencies

  class DependencyReferences___

    def initialize
      @_a = []
    end

    def _add o
      @_a.push o ; nil
    end

    # --

    def to_stream
      Stream_[ @_a ]
    end
  end

  class Unparsed_Synthesis_Dependency_Collection___

    def initialize
      @_a = []
    end

    def __add_args args
      @_a.push args ; nil
    end

    def execute_task__ task, index
      Home_::Magnetics_::SynthesisExecution_via_Args_and_Index_and_Task[ task, @_a, index ]
    end
  end

  class Unparsed_Parameter_Collection_as_Dependee_Reference___

    # subject is one-to-one with a task that has parameters in the
    # *static*, formal graph. we generate a "unique" name which it
    # will use etc..

    def initialize cls
      @_a = []
      @_sym = :"_#{ cls._task_name.as_const }_Parameters_"
    end

    def __add_args args  # availability is volatile
      @_a.push args ; nil
    end

    def _dereference_against index

      index.cache_box.touch @_sym do
        ___build_dereference index
      end
    end

    def ___build_dereference index

      _attrs = as_attributes_
      _ = index.listener
      Home_::Models_::Parameter::Collection_as_Dependency.new @_sym, _attrs, & _
    end

    def as_attributes_
      @___attrs ||= Home_::Models_::Parameter::Parse[ remove_instance_variable( :@_a ) ]
    end
  end

  # -- unparsed references

  class Dependee_Reference_

    def initialize sym
      @sym = sym
      freeze
    end
  end

  class User_Defined_Dependee_Reference___ < Dependee_Reference_

    def _dereference_against index

      index.cache_box.touch @sym do
        Dereference_.new( @sym, index ).to_task_
      end
    end
  end

  # -- these

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  # -- these

  Autoloader_ = Common_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    String_IO = -> do
      require 'stringio' ; ::StringIO
    end

    String_scanner = -> do
      require 'strscan' ; ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    ACS = sidesys[ :Arc ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    System_lib = sidesys[ :System ]
    Zerk = sidesys[ :Zerk ]
  end

  module Magnetics

    class << self

      def collection_via_directory_object_and_module dir_o, mod

        o = Home_::Magnetics::Magnetics_  # (wants [#005])

        _tss = o::TokenStreamStream_via_DirectoryObject[ dir_o ]

        col = o::ItemReferenceCollection_via_TokenStreamStream[ _tss ]

        col.item_resolver = -> reference do
          mod.const_get reference.const, false  # NOTE  just the const's value here
        end

        col
      end

      p = -> do

        rx = /(?<=^|_)[a-z]/

        -> sym do
          sym.id2name.gsub rx, & :upcase
        end
      end

      define_method :upcase_const_string_via_snake_case_symbol_ do
        @___ ||= p[]
      end
    end  # >>

    Autoloader_[ self ]
    Here_ = self
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Scanner_ = -> a do
    Common_::Scanner.via_array a
  end

  ArgumentError = ::Class.new ::ArgumentError

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''.freeze
  Home_ = self
  IDENTITY_ = -> x { x }
  NEWLINE_ = "\n"
  NIL_ = nil
  NIL = nil  # open [#sli-016.C]
    FALSE = false ; TRUE = true
  NOTHING_ = nil
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'

  def self.describe_into_under y, _
    y << "experiments with dependency graphs. now home of the \"magnetics\" dream."
  end
end
# #tombstone: we no longer subclass rake task
# #tombstone: (temporary) Home_.lib_.fields::Attribute::DSL[ self ]
# #tombstone: we no longer associate parenthood strongly to nodes
