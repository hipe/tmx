module Skylab::Treemap
  class API::Tempdir < API::Path
    extend Skylab::PubSub::Emitter
    emits :create

    def error msg
      @invalid_reason = msg
      false
    end
    def initialize path
      super(path, &nil)
      yield(self) if block_given?
    end
    attr_accessor :invalid_reason
    def ready?
      @invalid_reason = nil
      if exist?
        if directory?
          true
        else
          error('not a directory')
        end
      else
        begin
          mkdir()
          emit(:create, tempdir: self)
          true
        rescue SystemCallError => e
          msg = if md = /^([^-]+) - /.match(e.to_s)
            md[1]
          else
            "a system call error occured when trying to make the directory"
          end
          error msg
        end
      end
    end
  end
end

