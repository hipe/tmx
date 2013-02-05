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
          last_fetch_result.usage_and_invite
        else
          usage_and_invite
        end
      end
      if ::Fixnum === res then res else false == res ? 1 : 0 end # cute
    end

  protected

    def initialize *a, &b
      _treemap_sub_client_init nil
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

    def actions                   # compat, was kind kewl
      @actions ||= begin
        # Bleeding::Constants[ action_anchor_module ] (just local no adapters)
        Bleeding::Actions[
          Treemap::Adapter::Mote::Actions.new( self ),
          Bleeding::Officious.actions
        ]
      end
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

    def porcelain # [#042] - 100.200 not here
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
    extend MetaHell::Boxxy
  end

  class << CLI
    def build_client_instance request_client, slug # [#045] - - audit legacy ..
      new do |c|
        c.program_name = slug
        c.on_error   { |e| request_client.emit(:error, e) }
        c.on_help    { |e| request_client.emit(:help,  e) }
        c.on_info    { |e| request_client.emit(:info, e) }
        c.on_payload { |e| request_client.emit(:payload, e) }
        c.do_stylize = request_client.err.tty?
        if runtime_instance_setting
          runtime_instance_settings.call c # [#046] - #100.200 pure eyeblood
        end
      end
    end

    def porcelain # [#047] - #100.200 we do not want this here
      self
    end

    attr_accessor :runtime_instance_settings
  end
end
