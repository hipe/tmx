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

        def __writable_parameter_collection
          @___wpc ||= begin
            o = Unparsed_Parameter_Collection_as_Dependee_Reference___.new self
            _writable_dependee_references_collection._add o
            o
          end
        end

        def _writable_dependee_references_collection
          @_dependee_references ||= References___.new
        end

        attr_reader(
          :_dependee_references,
        )

        def _task_name
          @___task_name ||= Callback_::Name.via_module self
        end
      end  # >>

      def initialize & oes_p
        @_oes_p_ = oes_p
      end

      # ~ behavior

      def execute_as_front_task

        # not for every task in the graph, only the "front" one

        o = Home_::Sessions::Execute_Graph.new( & @_oes_p_ )

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
      # ___to_dependee_stream_around index

      def ___dependee_references
        self.class._dependee_references
      end

      def __to_dependee_stream_around dr, index

        _st = dr.to_stream
        _st_ = _st.map_by do |dref|
          dref.dereference_against_ index
        end
        _st_
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

        @___derived_ivar ||= :"@#{ name.as_const }"  # ! .as_ivar (downcases)
      end

      def add_parameter sym, x
        ( @_params ||= Callback_::Box.new ).add sym, x
        NIL_
      end

      def name_symbol  # see #note-1 about these method names
        self.class._task_name.as_const
      end

      def name
        self.class._task_name
      end

      class References___

        def initialize
          @_a = []
        end

        def _add o
          @_a.push o ; nil
        end

        # --

        def to_stream
          Callback_::Stream.via_nonsparse_array @_a
        end
      end

      class Dependee_Reference_

        def initialize sym
          @sym = sym
          freeze
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

        def __add_args args  # this method's availability is volatile
          @_a.push args ; nil
        end

        def dereference_against_ index

          index.cache_box.touch @_sym do
            ___build_dereference index
          end
        end

        def ___build_dereference index

          _ = index.on_event_selectively
          Models_::Parameter::Collection_as_Dependency.new @_sym, @_a, & _
        end
      end

      class User_Defined_Dependee_Reference___ < Dependee_Reference_

        def dereference_against_ index

          index.cache_box.touch @sym do
            ___build_against index
          end
        end

        def ___build_against index

          _cls = index.box_module.const_get @sym, false

          _cls.new( & index.on_event_selectively )
        end
      end

  # -- these

  Callback_ = ::Skylab::Callback
  Lazy_ = Callback_::Lazy

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
  NOTHING_ = nil
  UNABLE_ = false
end
# #tombstone: we no longer subclass rake task
# #tombstone: (temporary) Home_.lib_.fields::Attribute::DSL[ self ]
# #tombstone: we no longer associate parenthood strongly to nodes
