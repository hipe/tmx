class Skylab::Task

  class Magnetics_::Index_via_ParameterBox_and_TargetTask < Common_::MagneticBySimpleModel  # 2x

    attr_writer(
      :listener,
      :target_task,
      :parameter_box,
    )

    def execute

      index = Index___.new @target_task, & @listener

      state_h = {}

      visit = -> task, & dependees do

        x = state_h.fetch task.name_symbol do | k |
          state_h[ k ] = false
          NIL_
        end

        if x
          ACHIEVED_  # the task is already resolved, do not descend

        elsif false == x

          ___on_cycle task, index
          UNABLE_

        else

          if dependees
            st = dependees[]
            de = st.gets
          end
          ok = true
          if de
            begin
              index.add_subscription task.name_symbol, de.name_symbol
              ok = de.accept index, & visit
              ok or break
              de = st.gets
            end while de
          else
            index.receive_one_base_case_task_symbol task.name_symbol
          end

          if ok
            state_h[ task.name_symbol ] = true
          end
          ok
        end
      end

      ok = @target_task.accept index, & visit
      if ok
        index.finish
      else
        ok
      end
    end

    def ___on_cycle task, index  # assume the last dootily is frootily

      build = -> do
        Home_::Events::CircularDependency.build_via__ task, index
      end

      oes_p = @listener
      if oes_p  # #[#ca-066]
        oes_p.call :error, :circular_dependency do
          _ = build[]
          _
        end
        NIL_
      else
        _ev = build[]
        _ex = _ev.to_exception
        raise _ev
      end
    end

    # ~

    class Index___

      def initialize tsk, & p

        @cache_box = Common_::Box.new
        @cache_box.add tsk.name_symbol, tsk

        @box_module = Home_.lib_.basic::Module.
          value_via_relative_path( tsk.class, '..' )  # DOT_DOT_

        @_oes_p = p

        @dependers_via_dependee = ::Hash.new { |h, k| h[k] = [] }

        @box_of_dependees_via_depender = Common_::Box.new
      end

      def add_subscription dependant_sym, dependee_sym

        @dependers_via_dependee[ dependee_sym ].push dependant_sym

        @box_of_dependees_via_depender.touch_array_and_push dependant_sym, dependee_sym

        NIL_
      end

      def receive_one_base_case_task_symbol sym

        @dependers_via_dependee[ :_NOTHING_ ].push sym
        @box_of_dependees_via_depender.touch_array sym
        NIL_
      end

      def finish

        # remove_instance_variable :@box_module
        @dependers_via_dependee.default_proc = nil
        self
      end

      def on_event_selectively
        @_oes_p
      end

      attr_reader(
        :cache_box,
        :box_module,

        :box_of_dependees_via_depender,
        :dependers_via_dependee,
      )
    end
  end
end
