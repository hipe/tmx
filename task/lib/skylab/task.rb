require 'skylab/callback'

class Skylab::Task

     # ~ as class

     # this is a blind, 4 years later rewrite of our task library.
     # it is not yet integrated with the legacy code

      def self.depends_on * sym_a

        deps = sym_a.map do | sym |
          User_Defined_Dependee_Reference___.new sym
        end.freeze

        define_singleton_method :_dependee_references do
          deps
        end
        NIL_
      end

      def self.depends_on_parameters * sym_a

        _deps = sym_a.map do | sym |
          Home_::Models_::Parameter::Dependee_Reference.new( sym )
        end

        deps_ = _dependee_references.dup
        deps_.concat _deps
        deps_.freeze

        define_singleton_method :_dependee_references do  # etc
          deps_
        end
        NIL_
      end

      def initialize & oes_p

        @name = Callback_::Name.via_module self.class
        @name_symbol = @name.as_const  # be careful

        @on_event_selectively = oes_p
      end

      # ~ behavior

      def execute_as_front_task

        # not for every task in the graph, only the "front" one

        o = Home_::Sessions::Execute_Graph::Newschool.new( & @on_event_selectively )

        if instance_variable_defined? :@_params
          o.parameter_box = remove_instance_variable :@_params
        end
        o.target_task = self
        o.execute
      end

      def accept index, & visit

        visit.call self do
          __to_dependee_stream_around index
        end
      end

      def __to_dependee_stream_around index

        Callback_::Stream.via_nonsparse_array dependee_references do | dref |

          dref.dereference_against_ index
        end
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

        @___derived_ivar ||= :"@#{ @name.as_const }"  # ! .as_ivar (downcases)
      end

      # ~ readers

      attr_reader(
        :name,
        :name_symbol
      )

      def dependee_references
        self.class._dependee_references
      end

      def self._dependee_references
        EMPTY_A_
      end

      def add_parameter sym, x
        ( @_params ||= Callback_::Box.new ).add sym, x
        NIL_
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

  # ~ as sidesystem

  class << self

    def test_support
      @___test_support ||= begin
        require_relative '../../test/test-support'
        Home_::TestSupport
      end
    end

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Callback_ = ::Skylab::Callback

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

end
