module Skylab::Treemap

  class CLI::Client < Bleeding::Runtime

    desc "experiments with R."

    include Treemap::Core::Action::InstanceMethods  # a lot of these are
                                  # up-delegators which we must implement

    Callback_[ self, :employ_DSL_for_digraph_emitter ]
      # something like the above once overwrite s.c version of `emit`

    taxonomic_streams :all

    listeners_digraph Bleeding::EVENT_GRAPH.merge(
      ::Hash[ CLI::Event::CANON_STREAMS.map { |sn| [ sn, :all ] } ]
    )                             # your best friend right now is:
                                  # `tmx-callback viz cli/client.rb --open`

    event_factory CLI::Event::FACTORY

    extend Headless::NLP::EN::API_Action_Inflection_Hack  # have `inflection`
                                  # this is for when calls come
                                  # from inside the house

    inflection.lexemes.noun = 'treemap'
    inflection.lexemes.verb = 'run'

    def invoke( * )
      res = super
      if false == res
        # (the engine doesn't and shouldn't assume this following behavior)
        a = @last_hot_action
        if a
          a.usage_and_invite  # this is [#035], annotated invite
        else
          help_usage( {} ) ; help_invite # (legacy mess, change to `usage_and_invite` then)
        end
      end
      cute_exit_code = case res
      when ::Fixnum, ::Symbol ; res
      else  false == res ? 1 : 0
      end
      if a and a.has_formal_parameter :be_verbose and  # jus greasing the wheels
          a.fetch_actual_parameter :be_verbose do end then
        emit :info, "(resulted in exit status of #{ cute_exit_code })"
      end
      cute_exit_code
    end

    def actions_const_get k
      CLI::Actions.const_get k, false
    end

  private

    -> do

      signature_h = {
        0 => -> blk do
          blk[ self ]
        end,
        3 => -> _, sout, serr, blk do
          blk and raise ::ArgumentError.new "can't have both block and args"
          @paystream, @infostream = sout, serr

          on_payload_line do |txt|
            @paystream.puts txt
          end
          on_info_line on_help -> txt do  # catches everthing from cli f.w
            @infostream.puts txt
          end
          on_error do |e|
            @infostream.puts e.text
          end

          on_info do |x|  # the calls come from inside the house..
            handle( :info )[ x ]  # my head is boggled
          end
        end
      }

      define_method :initialize do |*a, &b|
        init_treemap_sub_client nil
        instance_exec( *a, b, & signature_h.fetch( a.length ) )
        if_unhandled_non_taxonomic_streams do |msg|
          raise ::ArgumentError, msg
        end
        @stylus = CLI::Stylus.new              # never build one anywhere else
        @stylus.do_stylize = @infostream.tty?  # iff interactive terminals.
        @plugin_action_box_flip = nil
        nil
      end
    end.call

    #         ~ the below is in a roughly outside-in order ~

    #         ~ legacy (bleeding) compat ~

    def actions                   # compat, was kind kewl
      @actions ||= begin
        # Bleeding::Constants_[ actions_box_module ] (just local no adapters)
        Bleeding::Actions[
          # actions_box_module,  # if you uncomment this, it hiccups the names # #todo
          Treemap::Adapter::Mote::Actions.new( self ),
          Bleeding::Officious.actions
        ]
      end
    end
    protected :actions  # #protected-not-private

    def normalized_invocation_string # #forward-fit #buck-stop
      program_name
    end

    def porcelain # [#042] - 100.200 not here
      fail 'i will find you and i will kill you'
      self.class
    end

  public
    attr_reader :stylus
    private :stylus
    attr_writer :stylus
  private

    #         ~ fun with events ~

    define_method :build_event, & CLI::Action::FUN.build_event

    #                ~ "hotwiring" [#056] (EXPERIMENTAL) ~
    #
    #                        ~ EXPERIMENTAL!! ~

    -> do

      handle_h = -> do
        o = { }

        identity = -> stream_name do
          -> event_x do
            call_digraph_listeners stream_name, event_x
          end
        end

        o[:help] = o[:info_line] = identity[ :info_line ]

        o[:payload_line] = identity[ :payload_line ]

        prefix = split_rx = nil  # scope

        cycle = nil

        o[:info] = -> e do  # #randomness
          cycle ||= Headless::NLP::EN::Tricks::Cycle::Terminal[[
            'while',  # 2x
            'though the course of',
            'during the process of',
            'during',
            'while' ], rand: 3 ]
          verb_lexeme = e.action_sheet.inflection.lexemes.verb
          noun = e.action_sheet.inflection.inflected.noun
          msg = render_emission e
          a, inner, z = split_rx.match( msg ).captures
          a ||= "#{ em 'o' } "  # bullet only when no paren
          body = "#{ cycle[] } #{ verb_lexeme.progressive }, #{ noun } #{inner}"
          text = [ a, body, z ].join ''
          emit :info_line, text
          nil
        end

        o[:error] = -> e do
          @error_count += 1  # (we are overriding something that does same.)
          verb = e.action_sheet.inflection.lexemes.verb.lemma
          noun = e.action_sheet.inflection.inflected.noun
          msg = render_emission e
          emit :error,
            prefix[ msg, "#{ stylize 'o', :red } couldn't #{ verb } #{ noun }:"]
              # (if we go thru `error` it also increments our error count..)
        end

        prefix = -> msg, prfx do  # assumes prefix is nonzero-lenth string
          a, inner, z = split_rx.match( msg ).captures
          "#{ a }#{ prfx } #{ inner }#{ z }"
        end

        split_rx = /\A
          ( \( )?                    # any opening paren
          ( (?:   (?! \)\z ) . )* )  # zero or more of (the nonzero space that
                                     # is not followed by the closing paren,
                                     # then any character)
          ( \) )?                    # any closing paren
        \z/mx                        # this matches all strings and
                                     # is infallible and cannot fail (but does
                                     # not enforce balanced parens meh)
        o
      end.call

      define_method :handle do |name|
        ( @handle_h ||= { } ).fetch name do
          func = handle_h.fetch name
          @handle_h[name] = -> event_x do
            instance_exec event_x, & func
          end
        end
      end
      public :handle
    end.call

    # `render_emission`, well within the scope of responsibility of this nerk,
    # identify certain patterns of emissions and render them a certain way.
    # (called above)

    def render_emission e
      if ! e.has_metadata then e.text else
        msg = e.message  # fancy nerks must always have this
        if e.has_metadata_element :path
          msg = "#{ msg } - #{ escape_path e.path }"
        end
        msg
      end
    end

    #         ~ api services for subclients ~

                                  # (be ready to pivot the below design,
                                  # singletons are bad (read the blogs)
                                  # so we might make it a property of the
                                  # mode client.) # #todo
    -> do
      api_client = nil
      define_method :api_client do
        api_client ||= Treemap::API::Client.instance
      end
      public :api_client
    end.call

  public
    attr_reader :infostream
  private

    #         ~ adapter services & buckstop experiments ~

    -> do

      actions_box_module = CLI::Actions

      define_method :actions_box_module do actions_box_module end
      public :actions_box_module

    end.call


    def build_wired_adapter_action adapter_cli_action_class
      adapter_cli_action_class.new self
        # (fow now the nerk is responsible for wiring itself!)
    end

    public :build_wired_adapter_action
  end

  class CLI::Action_Sheet  # goof around with mote-like

    def aliases
      [ @name.as_slug ]
    end

    def build mc
      kls = @host_module.const_get @name.as_const, false
      kls.new mc
    end

    def is_visible
      true
    end

    def initialize host_module, const
      @host_module = host_module
      @name = Callback_::Name.via_const const
    end
  end

  module CLI::Actions

    # #was-boxxy

    def self.each &blk            # have some fun with lots of things
      @story ||= begin
        # story = Porcelain::Legacy::Story.new self
        story = MetaHell::Formal::Box.open_box.new
        constants.each do |const|  # use boxxy, not necessarily loaded!
          story.add const, CLI::Action_Sheet.new( self, const )
        end
        story
      end
      @story.each(& blk )
    end
  end
end
