module Skylab::Snag
  class Models::ToDo::Command # #todo see if we can unify find commands org wide

    attr_reader :names

    def render
      Snag::Services::Shellwords || nil

      [ "find #{ paths.map(&:shellescape).join ' ' }",
        "\\( #{ names.map { |n| "-name #{ n.shellescape }" }.join ' -o ' } \\)",
        "-exec grep --line-number --with-filename #{ pattern.shellescape } {} +"
      ].join ' '

    # find lib/skylab/snag -name '*.rb' -exec grep --line-number '@t0d0\>' {} +
    end

    alias_method :to_s, :render

    attr_reader :paths

    attr_reader :pattern

  protected

    def initialize paths, names, pattern
      paths.respond_to?( :each ) or raise ::ArgumentError.new "no: #{ paths }"
      names.respond_to?( :each ) or raise ::ArgumentError.new "no: #{ names }"
      ::String === pattern or raise ::ArgumentError.new "no: #{ pattern }"
      @pattern, @names, @paths = [ pattern, names, paths ]
    end
  end
end
