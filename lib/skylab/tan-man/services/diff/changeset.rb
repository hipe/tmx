module Skylab::TanMan

  class Services::Diff::Changeset  < ::Struct.new :command, :num # (do *not*
                                  # rely on these members not changing! rely
                                  # instead on the public methods.)
    def << line
      chr = nil
      if line
       chr = line[0]
      end
      case chr
      when '>' ; num.lines_added += 1
      when '<' ; num.lines_removed += 1
      end
      nil
    end

    def num_lines_added
      num.lines_added
    end

    def num_lines_removed
      num.lines_removed
    end

  protected

    num_struct = ::Struct.new :lines_removed, :lines_added

    define_method :initialize do |command|
      self[:command] = command
      self[:num] = num_struct.new 0, 0
    end
  end
end
