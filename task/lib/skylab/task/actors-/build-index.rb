class Skylab::Task

  class Actors_::Build_Index

    def initialize & oes_p
      @on_event_selectively = oes_p
    end

    attr_writer(
      :target_task,
      :parameter_box,
    )

    def execute

      index = Index___.new @target_task, & @on_event_selectively

      state_h = {}

      visit = -> task, & dependees do

        x = state_h.fetch task.name_symbol do | k |
          state_h[ k ] = false
          NIL_
        end

        if x
          ACHIEVED_  # the task is already resolved, do not descend

        elsif false == x
          self._COVER_ME_cycle

        else

          st = if dependees
            dependees[]
          else
            Callback_::Stream.the_empty_stream
          end

          ok = true
          de = st.gets
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

    # ~

    class Index___

      attr_reader(
        :box,
        :box_module,

        :dependants_on,
        :dependees_of,

        :on_event_selectively,
      )

      def initialize tsk, & p

        @box = Callback_::Box.new
        @box.add tsk.name_symbol, tsk

        @box_module = Home_.lib_.basic::Module.
          value_via_relative_path( tsk.class, '..' )  # DOT_DOT_

        @on_event_selectively = p

        @dependants_on = ::Hash.new { |h, k| h[k] = [] }
        @dependees_of = ::Hash.new { |h, k| h[k] = [] }
      end

      def add_subscription dependant_sym, dependee_sym

        @dependants_on[ dependee_sym ].push dependant_sym
        @dependees_of[ dependant_sym ].push dependee_sym

        NIL_
      end

      def receive_one_base_case_task_symbol sym

        @dependants_on[ :_NOTHING_ ].push sym
        @dependees_of[ sym ]
        NIL_
      end

      def finish

        remove_instance_variable :@box_module

        @dependants_on.default_proc = nil
        @dependees_of.default_proc = nil

        self
      end
    end
  end
end
