module Skylab::TanMan

  class CLI::Action::Box < CLI::Action

    # MetaHell::Boxxy[ self ]::ModuleMethods when we need it it is here

    include Headless::CLI::Box::InstanceMethods

    def self.inherited klass
      klass.send :init_autoloader, caller_locations( 1, 1 )[ 0 ]
    end

    # `unbound_action_box` - this is the centerpiece of this class: this load
    # hack allows us to define only the barebones stuff in cli.rb and then
    # load the contents only lazily. (to be clear, we could do the above
    # with the autoloader alone but then we would have a deep, narrow
    # filetree (?).)

    def self.unbound_action_box
      if ! const_defined? :Actions, false
        require dir_pathname.to_s
      end
      const_get :Actions, false
    end

    alias_method :tan_man_original_help, :help

    def help x=nil # #compat-bleeding, ignore this
      case x
      when ::NilClass ; tan_man_original_help
      when ::Hash     ; tan_man_help_adapter x
      else            ; tan_man_original_help x
      end
    end

  private

    def build_option_parser       # #frontier, tracked by [#hl-037]
      o = TanMan::Services::OptionParser.new
      o.on '-h', '--help', 'this screen, or help for particular sub-action' do
        enqueue_help_as_box
      end
      o
    end
  end
end
