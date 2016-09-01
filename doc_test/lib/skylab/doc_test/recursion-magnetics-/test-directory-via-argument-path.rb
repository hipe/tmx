module Skylab::DocTest

  class RecursionMagnetics_::TestDirectory_via_ArgumentPath

    # exactly [#005]

    # non-declared parameters: filesystem, name_conventions
    # of filesystem calls only `exist?`

    class << self

      def of rsx
        call rsx.argument_path, rsx.name_conventions, rsx.filesystem
      end

      def call *a
        new( *a ).execute
      end

      alias_method :[], :call
    end  # >>

    def initialize ap, nc, fs
      @argument_path = ap
      @filesystem = fs
      @name_conventions = nc
    end

    def execute
      @_entry = @name_conventions.test_directory_entry_name

      base = @argument_path

      begin
        try = ::File.join base, @_entry
        if @filesystem.exist? try
          x = try
          break
        end
        base_ = ::File.dirname base
        if base_ == base
          self._EMIT
          break
        end
        base = base_
        redo
      end while nil
      x
    end
  end
end
