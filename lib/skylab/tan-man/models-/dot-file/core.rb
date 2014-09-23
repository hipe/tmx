module Skylab::TanMan

  module Models_::DotFile  # cannot be a model subclass because treetop

    extend TanMan_::Lib_::Name_function[].name_function_methods

    class << self

      def produce_document_via_parse & p
        DotFile_::Actors__::Produce_document_via_parse[ p ]
      end

      # ~

      def get_unbound_upper_action_scan
      end

      def is_silo
        true
      end

      # ~ the stack (we have to write them explicitly because treetop)

      def collection_controller
        Collection_Controller__
      end

      def silo_controller
        Silo_Controller__
      end

      def silo
        Silo__
      end

      # ~ support

      def node_identifier
        @nid ||= Brazen_::Node_Identifier_.via_symbol :dot_file
      end

      def preconditions
        # for *now* the buck stops here, maybe one day 'workspace'
      end

      def persist_to
        # same as above
      end
    end

    Actions = ::Module.new

    Collection_Controller__ = :_NONE_

    class Silo_Controller__ < Model_lib_[].silo_controller

      def provide_collection_controller_precon _id, graph
        DotFile_::Actors__::Build_Document_Controller::Via_action[ graph.action ]
      end
    end

    class Silo__ < Model_lib_[].silo

      def model_class
        DotFile_
      end
    end

    CONFIG_PARAM = 'using_dotfile'.freeze
    DotFile_ = self

    if false

    def currently_using
      res = nil
      begin
        if @currently_using                    # there is danger here in ..
          break( res = @currently_using )      # the distant future
        end
        break if ! ready? # emits info
        if ! using_pathname
          info "no using_pathname!" # strange
          break
        end
        # (at the time of this writing the controllers.dot_file seems to
        # be a sort of singleton, which might be dodgy. we want a controller
        # object that exists sort of one-to-one with a pathname.)
        cnt = Models::DotFile::Controller.new(
          request_client, # (the request_client for it is not me!)
          using_pathname )
        res = @currently_using = cnt
      end while nil
      res
    end

    config_param = CONFIG_PARAM

    define_method :ready? do |bad_conf=nil, no_param=nil, no_file=nil|
      res = false
      begin
        if ! using_pathname
          o = controllers.config
          if ! o.ready?( bad_conf )
            break
          end
          if ! o.known? config_param
            if no_param then no_param[ config_param ] else
              error "no '#{ config_param }' value is set in config(s)" # no inv.
            end
            break
          end
          relpath = o[ config_param ] or fail 'sanity'
          self.using_pathname = services.config.local.derelativize_path relpath
        end
        if using_pathname.exist?
          res = true
        else
          if no_file then no_file[ using_pathname ] else
            error "dotfile must exist: #{ escape_path using_pathname }"
          end
        end
      end while nil
      res
    end
    end
  end
end
