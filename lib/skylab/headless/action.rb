module Skylab::Headless

  module Action
  end


  module Action::ModuleMethods
    extend MetaHell::Let          # we memoize things in the class object

    def desc_lines
      @desc_lines ||= nil
    end

    normify = -> str do           # for now we go '-' but me might go '_'
      Autoloader::Inflection::FUN.pathify[ str ].intern
    end

    let :normalized_action_name do
      a = name[ self::ANCHOR_MODULE.name.length + 2 .. -1].split '::' # terrible
      a.map{ |x| normify[ x ] }.freeze              # but also cheaper
    end

    def normalized_local_action_name
      normalized_action_name.last
    end
  end


  module Action::InstanceMethods
    include Headless::SubClient::InstanceMethods

  protected

    def branch?
      false
    end

    def normalized_action_name
      self.class.normalized_action_name
    end

    def normalized_local_action_name
      self.class.normalized_local_action_name
    end

    def summary_line              # simple, modality-agnostic nerk
      res = nil
      begin
        if self.class.desc_lines
          res = self.class.desc_lines.first
          break
        else
          res = "the #{ normalized_local_action_name } action."
        end
      end while nil
      res
    end
  end
end
