module Skylab::Treemap
  class CLI < Bleeding::Runtime
    include Treemap::Core::SubClient::InstanceMethods

    desc "experiments with R."

    extend PubSub::Emitter

    emits Bleeding::EVENT_GRAPH
    emits payload: :all, info: :all, error: :all
    event_class Treemap::API::Event

    def invoke *a
      # (the engine doesn't and shouldn't assume this..)
      res = super
      if false == res
        if last_fetch_result
          last_fetch_result.help_invite
        else
          help_invite
        end
      end
      if ::Fixnum === res then res else false == res ? 1 : 0 end # cute
    end

  protected

    def initialize *a, &b
      @error_count = 0
      @stylus = Stylus.new # let's have this be the only place this is built
      if a.length.nonzero?
        3 == a.length or raise ::ArgumentError.new "expecting sin, sout, serr"
        b and raise ::ArgumentError.new "can't have both block and args"
        _, @stdout, @stderr = a
        @stylus.do_stylize = @stderr.tty?
        on_error   { |e| @stdout.puts e }
        on_help    { |e| @stderr.puts e }
        on_info    { |e| @stderr.puts e }
        on_payload { |e| @stdout.puts e }
      elsif b
        b[ self ]
      else
        fail "sanity - are you sure you .."
      end
      @plugin_action_box_flip = nil
      nil
    end

    include API::Action::AdapterInstanceMethods

    def actions                   # compat - legacy and kewl
      a = [ Bleeding::Constants[ action_anchor_module ] ]
      a << plugin_action_box_flip_box
      a << Bleeding::Officious.actions
      Bleeding::Actions[ * a ]
    end

                                  # (be ready to pivot the below design,
                                  # singletons are bad (read the blogs)
                                  # so we might make it a property of the
                                  # mode client.)
    api_client = nil
    define_method :api_client do
      api_client ||= Treemap::API::Client.instance
    end

    parens_rx = %r{\A (?<open>\()  (?<message>.*)  (?<close>\))  \z}x

    define_method :format do |prefix, e|
      s = e.message
      p = s.match parens_rx
      s = p[:message] if p
      s = "#{ prefix } #{ s }"
      if ::Hash === e.payload && e.payload[:path]
        s = "#{ s }: #{ escape_path e.path }"
      end
      s = "#{ p[:open] }#{ s }#{ p[:close] }" if p
      s
    end

    def normalized_invocation_string # #forward-fit #buck-stop
      program_name
    end

    def plugin_action_box_flip_box
      @plugin_action_box_flip ||= Treemap::Adapter::BoxFlip.new self
      a = [ ]
      @plugin_action_box_flip.visit a
      a
    end

    def porcelain # @todo 100.200 not here
      fail 'i will find you and i will kill you'
      self.class
    end

    attr_accessor :stylus   # you have an obligation to make the buck stop here

    def wire_api_action action
      verb = action.class.inflection.stems.verb
      inflected = action.class.inflection.inflected
      action.on_info_line { |e| emit :info, e }
      action.on_payload { |e| emit e }
      action.on_info do |e|
        emit :info, format(
          "#{ em 'o' } #{ inflected.noun } #{ verb.progressive }", e )
      end
      action.on_error do |e|
        emit :error, format(
          "#{ stylize 'o', :red } couldn't #{ verb } #{ inflected.noun }:", e )
      end
    end
  end

  module CLI::Actions
    extend Bleeding::Stubs
  end

  class CLI::Action # #todo consider moving this
    extend Bleeding::Action

    include Treemap::Core::SubClient::InstanceMethods

    def options                   # used by stylus ick to impl. `param`
      option_syntax.options
    end

    def option_syntax             # used all over the place by documentors
      @option_syntax ||= build_option_syntax
    end

  protected

    def initialize                # you get nothing
      super
      @error_count = 0
    end

    def error msg                 # #todo
      emit :error, msg
      false
    end

    def request_client            # away at [#012]
      @parent
    end

    def wire_api_action api_action
      request_client.send :wire_api_action, api_action
      stylus = request_client.send :stylus     # [#011] unacceptable
      api_action.stylus = stylus
      stylus.set_last_actions api_action, self # **TOTALLY** unacceptable
      nil
    end
  end

  class << CLI
    def build_client_instance request_client, slug # #todo - wat where
      fail 'wat i hate you'
      new do |c|
        c.program_name = slug
        c.on_error   { |e| request_client.emit(:error, e) }
        c.on_help    { |e| request_client.emit(:help,  e) }
        c.on_info    { |e| request_client.emit(:info, e) }
        c.on_payload { |e| request_client.emit(:payload, e) }
        c.do_stylize = request_client.err.tty?
        if runtime_instance_setting
          runtime_instance_settings.call c # @todo #100.200
        end
      end
    end

    def porcelain # @todo #100.200 not here
      fail 'wat i hate you'
      self
    end

    attr_accessor :runtime_instance_settings
  end
end
