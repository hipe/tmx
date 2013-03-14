module Skylab::Porcelain::Legacy::Adapter::For::Face

  include ::Skylab  # i want it all
  MetaHell = MetaHell

  module Of
  end

  module Of::Sheet
    def self.[] mcc, a, b
      Conduit_Sheet[ mcc, a, b ]
    end
  end

  Conduit_Sheet = MetaHell::Proxy::Nice.new :respond_to?, :method_symbol,
    :name, :parent=, :summary, :aliases, :hot

  class Conduit_Sheet
    def self.[] mcc, (ns_slug_sym), b   # hashtag #wow
      parent = nil
      new(
        :respond_to? => -> _ { true },
        :method_symbol => -> {  },
        :name => -> do
          ns_slug_sym
        end,
        :parent= => -> x do
          parent = x
        end,
        :summary => -> do
          [
          "child actions: { #{ mcc.story.action_box.map(&:slug).join ' | ' } }"
          ]
        end,
        :aliases => -> do
          nil  # (yes it might be above near `wow` but you can't have it)
        end,
        :hot => -> mc, slug do
          Conduit_LiveBranch[ mcc, mc, ns_slug_sym, slug ]
        end
      )
    end
  end

  #         ~ the following abbreviations will be used ~
  #
  # `rc` = request client  `mc` = mode (root-ish) client `c` = client


  #         ~ the live branch is like a pre-live action ~

  Conduit_LiveBranch = MetaHell::Proxy::Nice.new :parse, :respond_to?,
    :find_command, :run_opts, :invoke

  class Conduit_LiveBranch
    def self.[] native_mcc, strange_mc, ns_slug_sym, slug
      build_la = -> do
        Conduit_LiveAction[ native_mcc, strange_mc, ns_slug_sym, slug ]
      end
      new(
        :parse => -> argv do
          fail 'where'
        end,
        :respond_to? => -> _ { true },
        :find_command => -> _ do
          build_la[]
        end,
        :run_opts => -> argv do
          build_la[].invoke argv
        end,
        :invoke => -> argv do
          build_la[].invoke argv
        end
      )
    end
  end

  #         ~ the live action is the thing you want, it does it ~

  Conduit_LiveAction = MetaHell::Proxy::Nice.new :respond_to?, :invoke

  class Conduit_LiveAction

    def self.[] native_mcc, strange_mc, ns_slug_sym, slug
      conduit = new(
        :respond_to? => -> m do
          :find_command != m
        end,
        :invoke => -> argv do
          rc_wrap = Conduit_RC[ strange_mc ]
          n, p, i = rc_wrap.instance_exec do
            [ normalized_invocation_string, paystream, infostream ]
          end
          real_mc = native_mcc.new nil, p, i
          # now, the real_mc has an @io_adapter with the correct 2 streams.
          # it is temptng to want to set its @request_client to the strange
          # mc (or more properly `rc_wrap`), because it is after all the
          # actual request clien BUT it will have no utility and just confuse
          # things: Using the sub-client pattern whole-hog is untenable accross
          # frameworks because sub-clients will be making requests of super-
          # clients that they do not necessarily honor.
          # Setting the 2 (3) streams right and a fully qualified invocation
          # string is not only sufficient, it is literally the best
          # we can do.
          real_mc.send :program_name=, "#{ n } #{ ns_slug_sym }"
          real_mc.invoke argv  # MONEY MONEY MONEY MONEY MONEY MONEY MONEY
        end
      )
    end
  end

  Conduit_RC = MetaHell::Proxy::Nice.new :paystream, :infostream, :send,
    :normalized_invocation_string

  class Conduit_RC
    def self.[] strange_c
      kls = self
      strange_c.instance_exec do
        conduit = kls.new(
          :paystream => -> { @out },
          :infostream => -> { @err },
          :send => ->( *a, &b ) { conduit.__send__( *a, &b ) },
          :normalized_invocation_string => -> { invocation_string }
        )
      end
    end
  end
end
