module Skylab::Headless
  module CLI::Client::DSL
    def self.extended mod # [#sl-111] twistedly
      mod.extend CLI::Box::DSL::ModuleMethods  # #reach-up!
      mod.send :include, CLI::Client::DSL::InstanceMethods
      mod._autoloader_init! caller[0]
      nil
    end
  end

  module CLI::Client::DSL::InstanceMethods
    include CLI::Client::InstanceMethods       #  not all clients are boxen
                                               # (not all boxen are clients)..

                                               # watch this steaming pile of
                                               # smell: hello my future self
                                               # save the *original* *client*
                                               # definitions of these methods

    alias_method :cli_client_dsl_original_argument_syntax, :argument_syntax
    alias_method :cli_client_dsl_original_invite_line, :invite_line
    alias_method :cli_client_dsl_original_normalized_invocation_string,
      :normalized_invocation_string

                                               # now pull in the nonterminal
    include CLI::Box::DSL::InstanceMethods     # (not all boxen are clients.)

                                               # now, *reassign the box dsl*
                                               # method name to point to the
                                               # ones we "saved" above - remem.
                                               # client is the ternminal, but
                                               # it includes action, which is
                                               # nonterminal and relies upon
                                               # terminating with client. we
                                               # need to duplicate that here ick

    alias_method :cli_box_dsl_original_argument_syntax,
      :cli_client_dsl_original_argument_syntax
    alias_method :cli_box_dsl_original_invite_line,
      :cli_client_dsl_original_invite_line
    alias_method :cli_box_dsl_original_normalized_invocation_string,
      :cli_client_dsl_original_normalized_invocation_string

  end
end
