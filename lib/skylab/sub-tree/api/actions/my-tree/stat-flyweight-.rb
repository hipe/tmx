module Skylab::MyTree

  module Models
  end

  module Models::Node
  end


  class Models::Node::Flyweight

    def file?
      stat.file?
    end

    def now
      @now ||= MyTree::Services::Time.now # doesn't get cleared automatically!
    end

    attr_writer :now

    attr_reader :path

    def seconds_old
      now - stat.mtime
    end

    def set! path
      @stat = nil
      @path = path
      nil
    end

    def stat
      @stat ||= ::File::Stat.new @path
    end

  private

    # (no private methods yet defined for this class)

  end
end
