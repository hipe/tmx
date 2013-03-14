module Skylab::Porcelain::Legacy::Adapter::For::Legacy

  # eroborus

  module Of
  end

  module Of::Action_Subclient

    def self.[] ac, rc, nss  # action_class, request_client, namespace_sheet
      ac.new rc, nss
    end
  end

  # the legacy adapter for legacy of an action subclient is simply
  # to make an instance of the action class, but pass it the namespace
  # sheet, which is sheer brilliant genius.
  #
  # (i think in the future, face/cli.rb will expand on this)
  #

end
