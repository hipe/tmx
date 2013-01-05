module Skylab::TanMan

  class CLI::Action::Box < CLI::Action
    # extend MetaHell::Boxxy::ModuleMethods when we need it it is here

    include Headless::CLI::Box::InstanceMethods

    def self.action_box_module # compat hl:cli:box, centerpiece of this class:
      if ! const_defined? :Actions, false      # this load hack allows us to
        require dir_path                       # define only the barebones
      end                                      # stuff in cli.rb and load the
      const_get :Actions, false                # contents only lazily
    end                                        # (to be clear, we could do
                                               # the above just with the auto-
                                               # loader alone but then we would
                                               # have a deep narrow filetree)

    def self.inherited klass
      klass._autoloader_init! caller[0]
      # klass._boxxy_init! caller[0]
    end


    alias_method :tan_man_original_help, :help

    def help x=nil # #compat-bleeding, ignore this
      case x
      when ::NilClass ; tan_man_original_help
      when ::Hash     ; tan_man_help_adapter x
      else            ; tan_man_original_help x
      end
    end

  protected

    def build_option_parser       # #frontier, tracked by [#hl-037]
      o = TanMan::Services::OptionParser.new
      o.on '-h', '--help', 'this screen, or help for particular sub-action' do
        box_enqueue_help!
      end
      o
    end
  end
end
