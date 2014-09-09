module Skylab::TanMan

  module Models_::DotFile

    class << self

      def build_collections kernel
        Collections__.new kernel
      end

      def get_unbound_upper_action_scan
      end

      def produce_document_via_parse & p
        DotFile_::Produce_document_via_parse__[ p ]
      end
    end

    module Document_Resolver_Methods
      # you need @delgate (action), @kernel
    private
      def resolve_document
        @input_s = @delegate.action_property_value :input_string
        if @input_s
          via_input_string_resolve_document
        else
          via_path_resolve_document
        end
      end

      def via_input_string_resolve_document
        doc = @kernel.models.dot_files.produce_document_via_string @input_s,
          :delegate, @delegate
        if doc
          @document = doc ; OK_
        else
          doc
        end
      end
    end

    class Collections__
      def initialize k
        @kernel = k
      end
      def produce_document_via_string s, * x_a
        x_a.push :string, s
        DotFile_::Produce_Document__::Via_string.execute_via_iambic x_a
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
