module Skylab::Headless

  module Action

    o = { }

    normify = -> str do           # for now we go '-' but me might go '_'
      Autoloader::Inflection::FUN.pathify[ str ].intern
    end

                                  # this is a bleeding, incomplete feature that
                                  # does something terrible but is also cheap.
    o[:build_normalized_name] = -> anchor_module, mod do
      a = mod.name[ anchor_module.name.length + 2 .. -1 ].split '::'
      a.map{ |x| normify[ x ] }.freeze
    end

    o[:normfiy] = normify

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end


  module Action::ModuleMethods
    extend MetaHell::Let          # we memoize things in the class object

    def actions_anchor_module
      x = const_get :ACTIONS_ANCHOR_MODULE, true
      x.respond_to?( :call ) and x = x.call
      x
    end

    attr_reader :desc_lines

    let :normalized_action_name do
      Action::FUN.build_normalized_name[ actions_anchor_module, self ]
    end

    def normalized_local_action_name
      normalized_action_name.last
    end
  end


  module Action::InstanceMethods
    include Headless::SubClient::InstanceMethods

  protected

    def desc_lines                # we want this DSL-y module-methods part of
      self.class.desc_lines if self.class.respond_to? :desc_lines # it to be
    end                           # opt-in

    def is_branch                 # brach == non terminal == box. bc it has far
      ! is_leaf                   # reaching consequences for request processing
    end                           # awareness of branchiness is baked-in deep.
                                  # it is recommended that you *not* redefine
                                  # this anywhere universe-wide, and rather hack
                                  # `is_leaf` if you need to, for reasons.
                                  # (it is this way and not the reverse
                                  # for reasons.)

    def is_leaf                   # out of the (heh) "box" we assume we are
      true                        # a terminal action and not a box action
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
