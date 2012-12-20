module Skylab::TanMan

  class CLI::NamespaceRuntime < Bleeding::NamespaceInferred
    # to be refactored at [#023]

    include Core::SubClient::InstanceMethods
    # or core action i.m's
    #

  protected

    def initialize request_client, module_with_actions
      # this was the site of a lot of blood
      block_given?       and fail 'sanity - blocks?'
      _headless_sub_client_init! request_client
      _namespace_inferred_init! module_with_actions
      parent              or fail 'sanity - parent?'
      self.request_client or fail 'sanity - req cli?'
    end

    def normalized_invocation_string # #compat-headless #compat-bleeding
      program_name
    end
  end
end
