require 'rake' # for fun and as an implementation detail we use it

module Skylab::Slake
  class Graph
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
  end
end
