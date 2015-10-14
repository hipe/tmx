class Skylab::Task

  Sessions = ::Module.new
  class Sessions::Execute_Graph

    # ~ OLDSCHOOL:

    require 'rake' # for fun and as an implementation detail we use it
    include Home_::Parenthood
    include ::Rake::TaskManager
    def []=(name, task)
      name = name.to_s
      name.empty? and raise RuntimeError.new("added tasks cannot have an empty name (had: #{name.inspect})")
      task.name != '' and task.name != name and
        raise RuntimeError.new("must use the same name as task (task name: #{task.name.inspect}, key: #{name.inspect})")
      @tasks.key?(name) and raise RuntimeError.new("won't clobber existing task #{name.inspect} (for now)")
      # should be atomic below!
      task.name == '' and task.name = name
      @order.push name
      @tasks[name] = task # we would want to use invoke() but .. etc
    end
    def add_task task
      self[task.name] = task
    end
    def build_task attributes, name
      fail("implement me")
    end
    alias_method :rake_task_manager_initialize, :initialize
    def initialize opts=nil
      @order = []
      @target = nil
      init_parenthood
      rake_task_manager_initialize
      opts and update_attributes opts
    end
    def invoke *args
      @target or raise RuntimeError.new('Cannot invoke. Graph does not have a "target" attribute.')
      t = self[@target] or raise RuntimeError.new("#{@target.inspect} task is not defined.")
      t.invoke(*args)
    end
    attr_accessor :name
    def nodes
      @order.map { |name| @tasks[name] }
    end

    # (this implementation is identical to that of rake/application.rb attotw)
    def options
      @options ||= ::OpenStruct.new  # e.g `dryrun`, `trace`, `always_multitask`
    end

    SPECIAL_KEYS = [:name, :target]
    attr_accessor :target
    def update_attributes opts
      (SPECIAL_KEYS & opts.keys).each { |k| send("#{k}=", opts[k]) }
      (opts.keys - SPECIAL_KEYS).each do |k|
        task = opts[k]
        if task.respond_to?(:invoke)
          task.name = k
          task.application == ::Rake.application or fail('nerp')
          task.application = self
        else
          task = build_task(task, k)
        end
        self[k] = task
      end
      nil
    end

    # NEWSCHOOL:
    # <-
  class Newschool


    def initialize & oes_p
      @on_event_selectively = oes_p
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

      o = Home_::Actors_::Build_Index.new( & @on_event_selectively )
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

      o = Home_::Actors_::Build_Plan.new( & @on_event_selectively )
      o.index = remove_instance_variable :@_index
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

      st = Callback_::Stream.via_times queue.length do | d |
        cache.fetch queue.fetch d
      end

      begin
        tsk = st.gets
        tsk or break
        if tsk.respond_to? :accept_execution_graph__
          tsk.accept_execution_graph__ self
          redo
        else
          break
        end
      end while nil

      ACHIEVED_
    end

    def __execute_plan

      plan = remove_instance_variable :@_plan

      queue, subscribers, cache = plan.to_a

      ok = ACHIEVED_
      st = Callback_::Stream.via_nonsparse_array queue
      begin
        sym = st.gets
        sym or break

        task = cache.fetch sym

        ok = task.execute
        ok or break

        a = subscribers[ sym ]

        if a
          dc = Dependency_Completion___.new( task )
          a.each do | sym_ |
            cache.fetch( sym_ ).receive_dependency_completion dc
          end
        end

        redo
      end while nil
      ok
    end

    class Dependency_Completion___

      attr_reader(
        :task,
      )

      def initialize task
        @task = task
      end

      def derived_ivar
        @task.derived_ivar_
      end
    end
  end
# ->
  end
end
