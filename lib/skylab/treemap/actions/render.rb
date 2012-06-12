module Skylab::Treemap
  class Actions::Render < Action
    attribute :char, required: true, regex: [/^.$/, 'must be a single character']
    attribute :path, path: true, required: true

    def advance_to_first_line
      file = path.open('r')
      @lines = Enumerator.new { |y| file.each_line { |line| y << line.chomp } }
      regex = /\A[[:space:]]*#{Regexp.escape(char)}/
      found = false
      loop do
        (found = regex.match(@lines.peek)) ? break : @lines.next
      end rescue StopIteration
      found or error("#{pre attributes[:char].label}" <<
        " not found at the start of any line in #{path.pretty}.")
    end

    def clear!
      super
      (@tree ||= Skylab::Treemap::Models::Node.build_root).clear!
      self
    end

    def execute_with_parameters params
      set_parameters_for_execution(params) or return false
      r.ready? or return error(r.not_ready_reason)
      path.exist? or return error("input file not found: #{path.pretty}")
      advance_to_first_line or return false
      info "here is the first line: #{@lines.peek.inspect}"
    end
  end
end

