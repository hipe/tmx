module Skylab::Cull

  class CLI::Namespace < Face::Namespace
    module InstanceMethods
    end
    include InstanceMethods  # built-out below

  protected

  end

  module CLI::Namespace::InstanceMethods

  protected

    def initialize( * )
      super
      @param_h = { }
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
end
