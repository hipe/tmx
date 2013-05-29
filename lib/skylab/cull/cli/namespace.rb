module Skylab::Cull

  # this file is the embodiment of [#fa-042].

  class CLI::Namespace < Face::Namespace
  end

  module CLI::Namespace::InstanceMethods

  private

    def initialize *a
      @param_h = { }
      super
    end

    def dry_run_option o
      @param_h[:is_dry_run] = false
      o.on '-n', '--dry-run', 'dry-run.' do
        @param_h[:is_dry_run] = true
      end
      nil
    end

    def verbose_option o
      @param_h[ :be_verbose ] = false
      o.on '-v', '--verbose', 'be verbose.' do
        @param_h[ :be_verbose ] = true
      end
      nil
    end
  end

  class CLI::Namespace
    prepend InstanceMethods
  end
end
