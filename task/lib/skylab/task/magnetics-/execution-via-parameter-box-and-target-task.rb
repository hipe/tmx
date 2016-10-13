class Skylab::Task

  class Magnetics_::Execution_via_ParameterBox_and_TargetTask

    def initialize & oes_p
      @_oes_p = oes_p
      @parameter_box = nil
    end

    attr_writer(
      :target_task,
      :parameter_box,
    )

    attr_reader(
      :parameter_box,
    )

    def execute

      ok = __resolve_index
      ok &&= __resolve_plan
      ok &&= __do_magic
      ok && __execute_plan
    end

    def __resolve_index

      o = Home_::Magnetics_::Index_via_ParameterBox_and_TargetTask.new( & @_oes_p )
      o.parameter_box = @parameter_box
      o.target_task = @target_task
      index = o.execute
      if index
        @_index = index
        ACHIEVED_
      else
        index
      end
    end

    def __resolve_plan

      o = Home_::Magnetics_::Plan_via_Index.new( & @_oes_p )
      o.index = @_index  # remove_instance_variable :@_index
      plan = o.execute
      if plan
        @_plan = plan
        ACHIEVED_
      else
        plan
      end
    end

    def __do_magic

      # magic nodes must end up at the front of the sequence. internal.

      cache = @_plan.cache
      queue = @_plan.queue

      st = Common_::Stream.via_times queue.length do |d|
        cache.fetch queue.fetch d
      end

      begin
        tsk = st.gets
        tsk or break
        if tsk.respond_to? :accept_execution_graph__
          tsk.accept_execution_graph__ self
          redo
        end
        break
      end while nil

      ACHIEVED_
    end

    def __execute_plan

      plan = remove_instance_variable :@_plan

      queue, subscribers, cache = plan.to_a

      ok = ACHIEVED_
      st = Common_::Stream.via_nonsparse_array queue
      begin
        sym = st.gets
        sym or break

        task = cache.fetch sym

        ok = ___execute_task task
        ok or break

        a = subscribers[ sym ]

        if a
          dc = Dependency_Completion_.new task
          a.each do | sym_ |
            cache.fetch( sym_ ).receive_dependency_completion dc
          end
        end

        redo
      end while nil
      ok
    end

    def ___execute_task task
      x = task.synthies_
      if x
        x.execute_task__ task, @_index
      else
        task.execute
      end
    end
  end
end
