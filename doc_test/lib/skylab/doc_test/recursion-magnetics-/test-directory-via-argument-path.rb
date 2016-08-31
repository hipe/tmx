module Skylab::DocTest

  class RecursionMagnetics_::TestDirectory_via_ArgumentPath

    # exactly [#005]

    class << self

      def call path
        new( path ).execute
      end
      alias_method :[], :call
      private :new
    end  # >>

    def initialize path
      @argument_path = path
    end

    def execute
      @filesystem ||= ::File
      @name_conventions ||= RecursionModels_::NameConventions.instance_
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
