module Skylab::Snag

  class CLI  # read [#052]

    Snag_._lib.CLI_lib::Client[ self,
      :client_instance_methods, :three_streams_notify ]

    def initialize up, pay, info  # #storypoint-5 "strictify" the signature
      three_streams_notify up, pay, info
      super nil, nil, nil
    end

    def invoke argv
      Snag_._lib.path_tools.clear  # see
      x = super argv
      if UNABLE_ ==  x
        send_error_string "(a low-level error occured.)"
        NEUTRAL_
      else
        x
      end
    end

  private

    # ~ the narrative "order": [inside] string, [inside] event, line) [#031]

    public def receive_UI_line s
      send_UI_line s
    end

    def send_UI_line s
      infostream.puts s ; nil
    end

    # ~

    def handle_payload_line
      @handle_payload_line ||= method :receive_payload_line
    end

    public def receive_payload_line s
      send_payload_line s
      ACHIEVED_
    end

    def send_payload_line s
      paystream.puts s ; nil
    end

    def paystream  # (override attr_reader from [po])
      @IO_adapter.outstream
    end

    # ~

    def handle_inside_info_string
      method :receive_inside_info_string
    end

    def receive_inside_info_string s
      ev = Snag_::Model_::Event.inflectable_via_string s
      inflect_inflectable_event ev
      receive_info_event ev
    end

    def handle_info_string
      method :receive_info_string
    end

    public def receive_info_string s
      receive_info_line s
    end

    def handle_inside_info_event
      method :receive_inside_info_event
    end

    def receive_inside_info_event ev
      _ev = sign_event ev
      receive_info_event _ev
    end

    def handle_info_event
      @handle_info_event ||= method :receive_info_event
    end

    public def receive_info_event ev
      raw_s = render_event ev
      open, sp_s, close = unparenthesize_message_string raw_s
      vl = ev.verb_lexeme
      _enhanced_s = if vl
        _noun_s = ev.inflected_noun
        gerund_phrase = [ vl.progressive, _noun_s ].compact * SPACE_
        if HACK_IS_ONE_WORD_RX__ =~ sp_s  # done. finished. etc.
          "#{ sp_s } #{ gerund_phrase }"
        else
          "while #{ gerund_phrase }, #{ sp_s }"
        end
      else
        sp_s
      end
      _out_s = "#{ open }#{ _enhanced_s }#{ close }"
      send_info_line _out_s
      NEUTRAL_
    end
    HACK_IS_ONE_WORD_RX__ = /\A[a-z]+\z/

    def handle_info_line
      @handle_info_line ||= method :receive_info_line
    end

    public def receive_info_line s
      send_info_line s
      NEUTRAL_
    end

    def send_info_line s
      infostream.puts s ; nil
    end

    def infostream
      @IO_adapter.errstream
    end

    # ~

    def send_warning_line s
      infostream.puts s ; nil
    end

    # ~

    def handle_error_string
      @handle_error_string ||= method :receive_error_string
    end

    public def receive_error_string s
      receive_error_line s  # meh
    end

    def handle_inside_error_event
      @handle_inside_error_event ||= method :receive_inside_error_event
    end

    def receive_inside_error_event ev
      _ev = sign_event ev
      receive_error_event _ev
    end

    def handle_error_event
      @handle_error_event ||= method :receive_error_event
    end

    public def receive_error_event ev
      sp_a = nil
      begin
        v = ev.inflected_verb ; n = ev.inflected_noun
        if v || n
          ( sp_a ||= [] ).push "failed to #{ [ v, n ].compact * SPACE_ }"
        end
        if ev.respond_to? :ev
          ev = ev.ev
          ev.respond_to? :inflected_verb or break
        else
          break
        end
      end while true
      txt = render_event ev
      a, txt, z = unparenthesize_message_string txt
      if sp_a
        _s = "#{ sp_a * ' because ' } - "
      end
      _txt = "#{ a }#{ _s  }#{ txt }#{ z }"
      receive_error_line _txt
    end

    def receive_error_line s
      send_error_line s
      UNABLE_
    end

    def send_error_line s
      infostream.puts s ; nil
    end

    # ~ support for all of the above channel families

    def inflect_inflectable_event ev
      _v = @legacy_last_hot._sheet.slug
      ev.inflected_verb = _v ; nil
    end

    def unparenthesize_message_string s
      Snag_._lib.string_lib.unparenthesize_message_string s
    end

    def render_event ev
      y = []
      while ev.respond_to? :ev
        ev = ev.ev  # unwrap it eew/meh
      end
      expression_agent.calculate y, ev, & ev.message_proc
      y * LINE_SEP_
    end

    # ~ comport with invocation methods (#hook-out's, publifications)

    public :program_name

    def retrieve_param_for_expression_agent i
      @legacy_last_hot.fetch_param i
    end

    public def retrieve_unbound_act norm_name_a
      self.class.rtrv_unbound_action norm_name_a
    end

    def self.rtrv_unbound_action norm_name_a  #straddle
      # there is 1 level of legacy actions (which are now fine, it was cleaned)
      # but this nerk may be among the non-legacy too. hacklund
      if 1 == norm_name_a.length
        story.action_box[ norm_name_a.first ]
      else
        a = norm_name_a.dup  # [ 'a', 'b' ] => [ 'a', :Actions, 'b'] ..
        full_a = a.reduce( [ a.shift ] ) { |m, x| m << :Actions ; m << x ; m }
        Autoloader_.const_reduce full_a, CLI::Actions  # result in a class as sheet
      end
    end

    # ~ framework comportments & overrides [hl]

    def pen  # legacy [hl], will leave
      expression_agent
    end

    def invite_to_self
      if @legacy_last_hot
        _s_a = [ @legacy_last_hot._sheet.slug ]
        invite_via_mutable_slug_a _s_a
      else
        send_UI_line invite_line
        NEUTRAL_
      end
    end

    # ~ now entering DSL zone

    Snag_._lib.CLI_legacy_DSL self

    namespace :node, -> { CLI::Actions::Node }

    namespace :nodes, -> { CLI::Actions::Nodes }


    desc "emit all known issue numbers in descending order to stdout"
    desc "one number per line, with any leading zeros per the file."
    desc "(more of a plumbing than porcelain feature!)"

    def numbers
      call_API [ :nodes, :numbers, :list ],
        :working_dir, working_directory_path,
        :on_error_event, handle_inside_error_event,
        :on_info_event, handle_info_event,
        :on_info_string, handle_info_line,
        :on_output_line, handle_payload_line
    end


    desc "when no arguments provided, list open issues"
    desc "when one argument provided, is used as first line of new issue"
    desc "that will be tagged #open"

    option_parser do |o|
      param_h = @param_h

      o.on '-n', '--max-count <num>',
        "limit output to N nodes (list only)" do |n|
        @param_h[:max_count] = n
      end

      o.regexp_replace_tokens %r{\A-(?<num>\d+)\z} do |md|  # [#030]
        [ '--max-count', md[:num] ]
      end

      o.on '--dry-run', "don't actually add the node (add only)" do
        param_h[:dry_run] = true
      end

      o.on '-v', '--verbose', 'verbose output' do
        param_h[:be_verbose] = true
      end
    end

    Callback_::Autoloader[ self ]

    option_parser_class CLI::Option_Parser__

    argument_syntax '[<message>]'

    def open message=nil, param_h
      # for fun we do a tricky dynamic syntax
      pbox = Snag_._lib.old_box_lib.open_box.via_hash param_h ; param_h = nil
      msg_p = -> is_opening do                   # i hope you enjoyed this
        a_b = [ 'opening issues', 'listing open issues' ]
        is_opening and a_b.reverse!
        expression_agent.calculate do
          _s_a = pbox.names.map { |i| par i }
          "sorry - #{ and_ _s_a } #{ s :is } #{
           }used for #{ a_b.first}, not #{ a_b.last }"
        end
      end
      r = if message
        bx = pbox.partition_where_name_in! :dry_run, :be_verbose
        if pbox.length.zero?
          opn_node bx, message
        else
          receive_error_line msg_p[ true ]
        end
      else
        bx = pbox.partition_where_name_in! :max_count, :be_verbose
        if pbox.length.zero?
          rdc_nodes bx
        else
          receive_error_line msg_p[ false ]
        end
      end
      if UNABLE_ == r
        invite_via_normal_name [ :open ]
      else
        r
      end
    end

  private

    def opn_node bx, message
      bx.add :working_dir, working_directory_path
      _h = bx.to_hash.merge! do_prepend_open_tag: true, message: message
      call_API [ :nodes, :add ], _h, -> o do
        o.on_error_event handle_inside_error_event
        o.on_error_string handle_error_string
        o.on_info_event handle_inside_info_event
        o.on_info_line handle_info_line
        o.on_info_string handle_inside_info_string
        o.on_new_node { |_| }  # handled by manifest for now
      end
    end

    def rdc_nodes bx
      bx.add :working_dir, working_directory_path
      bx.has?( :be_verbose ) or bx.add :be_verbose, false  # decide dflt here
      bx.add :query_sexp, [ :and, [ :has_tag, :open ] ]
      call_API [ :nodes, :reduce ], bx.to_hash, -> o do
        o.on_error_event handle_inside_error_event
        o.on_error_string handle_error_string
        o.on_info_event handle_inside_info_event
        o.on_info_string handle_info_line
        o.on_invalid_node { |e| send_info_string invalid_node_message( e ) }
        o.on_output_line handle_payload_line
      end
    end

  public

    namespace :todo, -> { CLI::Actions::Todo }

    namespace :doc, -> { CLI::Actions::Doc }

    desc "pings snag (lowlevel)."   # #open [#064] - hide `ping` action

    def ping
      @IO_adapter.errstream.puts "hello from snag."
      :hello_from_snag
    end

    include module Invocation_Methods_  # shared b. root & child frames
    private

      def dry_run_option o
        o.on '-n', '--dry-run', 'dry run.' do
          @param_h[ :dry_run ] = true
        end
      end

      def verbose_option o
        o.on '-v', '--verbose', 'verbose output.' do
          @param_h[ :be_verbose ] = true
        end
      end

      # ~

      def call_API * a, & wire_p

        x = Snag_::API.bound_call_via_legacy_arglist a, & wire_p

        if x
          x = x.receiver.send x.method_name, * x.args
        end

        if UNABLE_ == x
          invite_to_self
          UNABLE_
        else
          x
        end
      end

      def sign_event ev
        ev_ = Snag_::Model_::Event.inflectable_via_event ev
        inflect_inflectable_event ev_
        ev_
      end

      def invite_via_bound_action live_action
        invite_via_unbound_action live_action.class
      end

      def invite_via_normal_name norm_name_a
        _cls = retrieve_unbound_act norm_name_a
        invite_via_unbound_action _cls
      end

      def invite_via_unbound_action unbound_action
        _s_a = if unbound_action.respond_to? :full_name_function
          unbound_action.full_name_function.map( & :as_slug )
        else
          [ unbound_action.slug ]
        end
        invite_via_mutable_slug_a _s_a
      end

      def invite_via_mutable_slug_a s_a
        s_a.unshift program_name
        s_a.push '-h'
        send_UI_line( expression_agent.calculate do
          "#{ kbd s_a * SPACE_ } might have more information"
        end )
        NEUTRAL_
      end

      def expression_agent
        @expression_agent ||= CLI::Expression_Agent_.
          new method :retrieve_param_for_expression_agent
      end

      # ~

      def working_directory_path
        ::Dir.pwd
      end

      def invalid_node_message node
        o = node.parse_failure_event
        ( expression_agent.calculate do
          "failed to parse line #{ o.line_number } because #{
           }expecting #{ ick o.expecting } near #{ ick o.near }#{
            } (in #{ pth o.pathname })"
        end )
      end

      self
    end

    Client = self  # #tmx-compat
  end

  module CLI::Actions  # avoid an #orphan
    Autoloader_[ self, :boxxy ]
  end
end
