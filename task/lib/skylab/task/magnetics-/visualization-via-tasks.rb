class Skylab::Task

  class Magnetics_::Visualization_via_Tasks < Common_::MagneticBySimpleModel

    # -

      def self.describe_into_under__ y, expag
        expag.calculate do
          # (hack for CLI meh)
          y << "output a dotfile rendering of"
          y << "the dependency graph of #{ par Par__[ :target_task ] }."
          y << "for now name must be a fully qualified class name."
        end
      end

      def initialize
        @require = nil
        super
      end

      attr_writer(
        :listener,
        :require,
        :target_task,
      )

      def execute
        ok = __resolve_task_class
        ok && __init_task_instance
        ok &&= __resolve_index
        ok && __build_that_M_F_ing_graph
      end

      def __build_that_M_F_ing_graph  # meh

        # because A) we never get tired of writing this same thing over
        # and over and B) we couldn't figure out how to get a write context
        # (a stdout); here's a passively built digraph

        sym_st = nil ; pair_st = nil ; pair = nil ; main = nil ; p = nil
        descended = -> do
          sym = sym_st.gets
          if sym
            "  #{ pair.name_symbol } -> #{ sym }"
          else
            ( p = main )[]
          end
        end
        change_to_descended = -> do
          sym_st = Stream_[ pair.value ]
          ( p = descended )[]
        end
        main = -> do
          pair = pair_st.gets
          if pair
            change_to_descended[]
          else
            p = EMPTY_P_
            "}"
          end
        end
        change_to_main = -> do
          _idx = remove_instance_variable :@__index
          pair_st = _idx.box_of_dependees_via_depender.to_pair_stream
          ( p = main )[]
        end
        p = -> do
          p = change_to_main
          "digraph g {"
        end
        Common_.stream do
          p[]
        end
      end

      def __resolve_index
        _ = Magnetics_::Index_via_ParameterBox_and_TargetTask.call_by do |o|
          o.target_task = remove_instance_variable :@__task_instance
          o.parameter_box = NOTHING_
          o.listener = @listener
        end
        _store :@__index, _
      end

      def __init_task_instance
        _ = remove_instance_variable( :@__task_class ).new() { never }
        @__task_instance = _ ; nil
      end

      # -- B.

      def __resolve_task_class
        s = remove_instance_variable :@target_task
        pc = '[A-Z][a-zA-Z0-9_]*'
        if /\A(?:::)?#{ pc }(?:::#{ pc })*\z/ =~ s
          __resolve_task_class_via_sanitized_name s
        else
          @listener.call :error, :expression do |y|
            y << %<didn't look like class name (e.g "Foo::Bar"): #{ s.inspect }>
          end
          UNABLE_
        end
      end

      def __resolve_task_class_via_sanitized_name s

        req = remove_instance_variable :@require
        if req
          require req
        end

        _wee = s.split( '::' ).reduce ::Object do |m, c|
          m.const_get c, false
        end
        @__task_class = _wee
        ACHIEVED_
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

    class Par__  # MEH we're busy
      class << self
        alias_method :[], :new
      end  # >>
      def initialize sym
        @name_symbol= sym
      end
      def parameter_arity_is_known
        false
      end
      attr_reader :name_symbol
    end

    # ==
    # ==
  end
end
