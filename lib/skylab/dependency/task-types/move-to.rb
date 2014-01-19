module Skylab::Dependency
  class TaskTypes::MoveTo < Dependency::Task
    include Headless::CLI::PathTools::InstanceMethods
    include Dependency::Library_::FileUtils

    # @todo look below etc
    attribute :move_to, :required => true
    attribute :from, :required => true

    emits :all, :error => :all, :shell => :all

    def fu_output_message msg
      md = /\Amv ([^ ]+) ([^ ]+)\z/.match msg # #cosmetic-shell wat hack
      if md
        msg = "mv #{ pretty_path md[1] } #{ pretty_path md[2] }"
      end
      emit :shell, msg
    end

    remove_method :from= # -w, #todo
    def from= p
      _set_path :from, p
    end

    def execute args
      @context ||= (args[:context] || {})
      valid? or fail(invalid_reason)
      if ! from.exist?
        emit(:error, "file not found: #{pretty_path from.to_s}")
        return false
      end
      if move_to.exist?
        emit(:error, "file exists: #{pretty_path move_to.to_s}")
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
