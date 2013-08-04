module Skylab::SubTree

  SubTree::Services.kick :Shellwords

  class Find_Command_  # [#sl-118]

    def initialize
      @error_p ||= -> msg { raise msg }
      @pattern_s = nil
      @path_a = [ ] ; @type_i = :file
      nil
    end

    def add_path path_s
      @path_a.push path_s
      nil
    end

    def concat_paths path_a
      @path_a.concat path_a
      nil
    end

    def get_path_a
      @path_a.dup
    end

    def set_pattern_s s
      @pattern_s and raise ::ArgumentError, "pattern_s is write once"
      @pattern_s = s
      nil
    end

    attr_reader :pattern_s

    def string
      if is_valid
        y = [ "find #{ @path_a.map { |p| p.to_s.shellescape } * ' ' }" ]
        if @type_i
          y << "-type #{ @type_i }"
        end
        if @pattern_s
          y << "-name #{ pattern_s.shellescape }"
        end
        y * ' '
      end
    end

    def is_valid
      if @path_a.length.zero?
        bork "find command has no paths"
      else
        true  # note we don't set the ivar
      end
    end

    def bork msg
      @error_p[ msg ]
      false
    end
  end
end
