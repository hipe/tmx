module Skylab::TaskExamples

  class TaskTypes::MoveTo < Home_::Task

    include Home_.lib_.path_tools.instance_methods_module
    include Home_::Library_::FileUtils

    # @todo look below etc
    attribute :move_to, :required => true
    attribute :from, :required => true

    listeners_digraph  :all, :error => :all, :shell => :all

    def fu_output_message msg
      md = /\Amv ([^ ]+) ([^ ]+)\z/.match msg # #cosmetic-shell wat hack
      if md
        msg = "mv #{ pretty_path md[1] } #{ pretty_path md[2] }"
      end
      call_digraph_listeners :shell, msg
    end

    remove_method :from= # -w, #todo
    def from= p
      _set_path :from, p
    end

    def execute args
      @context ||= (args[:context] || {})
      valid? or fail(invalid_reason)
      if ! from.exist?
        call_digraph_listeners(:error, "file not found: #{pretty_path from.to_s}")
        return false
      end
      if move_to.exist?
        call_digraph_listeners(:error, "file exists: #{pretty_path move_to.to_s}")
        return false
      end
      status = mv from, move_to, :verbose => true
      0 == status
    end

    remove_method :move_to= # -w, #todo
    def move_to= p
      _set_path :move_to, p
    end

    def _set_path name, path
      val = case path
            when ::NilClass ; nil
            when ::String   ; ::Pathname.new(path)
            when ::Pathname ; path
            else          ; raise ::ArgumentError.new("no: #{path}")
            end
      instance_variable_set("@#{name}", val)
      path
    end
  end
end
