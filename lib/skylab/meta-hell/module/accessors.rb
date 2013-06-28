module Skylab::MetaHell

  module Module::Accessors

    # `Module::Accessors` is a concise, lightweight enhancement that is a totes
    # awesome way to generate instance methods on a module that each access a
    # different "neighbor module" based on the *relative path* (in the sense of
    # constant names, in the sense of the constant tree in a ruby runtime) of
    # each significant neighbor module.
    #
    # imagine a constant tree with the below five modules:
    #
    # MyApp
    #   CLI
    #     Client
    #   API
    #     Client
    #
    # There is a class MyApp::CLI::Client and a class MyApp::API::Client.
    # There are the modules MyApp, MyApp::CLI and MyApp::API.
    #
    # Let's say that the CLI Client *instance* for some reason (and watch for
    # smells here!) wanted to access the API Client *class*. This enhancement
    # library would facilitate that thus:
    #
    #     module MyApp
    #       class CLI::Client
    #         MetaHell::Module::Accessors.enhance self do
    #           private_methods do
    #             module_reader :api_client, '../../API/Client'
    #           end
    #         end
    #       end
    #     end
    #
    # The above says, "define on MyAppp::CLI::Client a private instance method
    # called `api_client` that when called will result in the class
    # `MyApp::API::Client`."
    #
    # There are also undocumented facilities for auto-vivifying the constants
    # (that is, creating them when they don't already exist (or aren't
    # loaded!)); *and* */* *or* "initializing" them (*super*-sketchy!!)
    # the first time they are accessed by that instance (egads!).
    # ("initializing" a module might mean enhancing it with some nonsense
    # before you use it, e.g boxxy-fying it.)

    def self.enhance host_mod, &enhance_blk

      cnd = Conduit_.new -> access, meth, path, create_blk=nil, extend_blk=nil do

        ivar = "@#{ meth }".intern

        f = -> mod do
          -> do
            if instance_variable_defined? ivar
              instance_variable_get ivar
            else
              md = FUN.resolve[ mod[ self ], path, create_blk ]
              if extend_blk
                md.module_exec( & extend_blk )  # future i am sorry
              end
              instance_variable_set ivar, md
            end
          end
        end

        if ::Class === host_mod
          host_mod.send :define_method, meth do
            self.class.send meth
          end
          host_mod.send :define_singleton_method, meth, & f[ IDENTITY_ ]
          host_mod.send access, meth if access
        else
          host_mod.send :define_method, meth, & f[ -> x { x.class } ]
        end

        nil
      end

      if enhance_blk
        cnd.instance_exec( & enhance_blk  )
        nil
      else
        Conduit_::OneShot_.new cnd  # (custom)
      end
    end

    o = { }

    o[:resolve] = -> mod, path, create_blk=nil do
      path_a = mod.name.split '::'
      delt_a = path.split '/'
      while part = delt_a.shift
        if '..' == part
          path_a.pop
        else
          path_a.push part
        end
      end
      if path_a.length.nonzero?
        path_a.reduce ::Object do |m, s|
          if m.const_defined? s, false
            m.const_get s, false
          elsif m.const_probably_loadable? s  # etc
            m.const_get s, false
          elsif create_blk
            m.const_set s, create_blk.call
          else
            m.const_get s, false  # trigger the error, presumably
          end
        end
      end
    end

    class Conduit_

      def initialize mod_bumper
        @stack = []
        @mod_bumper = mod_bumper
      end

      A__ = [ ]   # (expose only these for the custom OneShot_)

      def module_reader meth, path, &blk
        @mod_bumper[ @stack.last, meth, path, nil, blk ]
      end

      def private_module_reader meth, path, &blk
        @mod_bumper[ :private, meth, path, nil, blk ]
      end
      A__ << :private_module_reader

      def module_autovivifier meth, path, &blk
        @mod_bumper[ @stack.last, meth, path, blk, nil ]
      end

      def module_autovivifier_reader meth, path, viv, init
        @mod_bumper[ @stack.last, meth, path, viv, init ]
      end

      def private_module_autovivifier_reader meth, path, viv, init
        @mod_bumper[ :private, meth, path, viv, init ]
      end
      A__ << :private_module_autovivifier_reader

      def private_methods &blk
        with_access :private, blk
      end

      def protected_methods &blk
        with_access :protected, blk
      end

      def public_methods &blk
        with_access :public, blk
      end

      def with_access i, blk
        @stack.push i
        instance_exec( &blk )
        @stack.pop
        nil
      end
    end

    class Conduit_::OneShot_

      # (it's easier and clearer to just implement this "by hand" here.)

      def initialize cnd
        @cnd = cnd
      end

      Conduit_::A__.each do |i|
        define_method i do |*a, &b|
          @mutex = i
          freeze
          @cnd.send i, *a, &b
        end
      end
    end

    # `puff` - experimental simplification of meta hell (class | module) creator

    o[:puff] = -> do

      puff = -> mod, i, build_it do
        if ! mod.respond_to? :const_probably_loadable?
          MAARS::Upwards[ mod ]
        end
        mod_ = if mod.const_defined? i, false
          mod.const_get i, false
        elsif mod.const_probably_loadable? i
          mod.const_get i, false
        else
          mod.const_set i, build_it.call
        end
        if ! mod_.instance_variable_defined? :@dir_pathname
          n = mod_.name
          mod_.instance_variable_set :@dir_pathname, mod.dir_pathname.join(
            ::Skylab::Autoloader::Inflection::FUN.
              pathify[ n[ n.rindex( ':' ) + 1 .. -1 ] ] )
          mod_.extend MAARS
        end
        mod_
      end

      -> mod, i, build_it, with_it=nil do
        mod_ = puff[ mod, i, build_it ]
        if with_it then mod_.module_exec( & with_it ) else mod_ end
      end
    end.call

    FUN = ::Struct.new( * o.keys ).new( * o.values )
  end
end
