module Skylab::Snag
  class Models::ToDo::Command < ::Struct.new :paths, :names, :pattern

    def string
      Snag::Services::Shellwords || nil

      [ "find #{ paths.map(&:shellescape).join ' ' }",
        "\\(#{ names.map { |n| "-name #{ n.shellescape }" }.join ' -o ' }\\)",
        "-exec grep --line-number #{ pattern.shellescape } {} +"
      ].join ' '

    # find lib/skylab/issue -name '*.rb' -exec grep --line-number '@todo\>' {} +
    end

    alias_method :to_s, :string

  protected

    # (no protected methods defined here)

  end
end
