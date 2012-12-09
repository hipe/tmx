# This started as just a proof of concept of the very basics of what a loadable
# service can look like / work like.  In this case the 'service'
# it does for us is simply centralizing where and how to load something
# and how we want to interface with it.  #experimental!
#
# Fortunately for us this turned out to be a good idea, this also centralizes
# our customized `fu_output_message` behavior, which provides a stunning,
# extraordinary and transcendent yet lithe display of how powerful and elegant
# headless can be, done right.

require 'fileutils'               # one main point of this is to have
                                  # exactly 1 place where this happens

module Skylab::TanMan

  class Services::FileUtils       # creates the services.file_utils object sing.

    extend ::FileUtils            # so you can call Svcs::FU.pwd (nec.)

    class << self
      ::FileUtils::METHODS.each do |m| # you can see this pattern in fu itself
        public m                  # *this* is what actually lets you say
      end                         # FU.pwd
    end

    include ::FileUtils           # so the service instance will have it
    ::FileUtils::METHODS.each { |m| public m } # so, `pwd` for example
  end


  module Services::FileUtils::InstanceMethods
    # Something really crazy and magical happens here - whoever (probably
    # api action instances) wants the file utils instance methods, they grab
    # this, and then they get pen-aware yet safe implementation of things
    # that operate on filesystem paths yet output appropriate messages
    # based on the modality.  This is basically *the* quintessence of
    # headless et. al.

    include ::FileUtils


    alias_method :tanman_original_fu_output_message, :fu_output_message
    # (if someone ever needs this.  we don't)



    # The tiny jumble below deserves some explanation so we don't forget why
    # we are going thru all this:
    #
    # 1) In the interest of avoiding tedius, superflous and noisy code, it
    # seems prudent to rely on ::FileUtils to generate the appropriate verbose
    # error messages for the various of its operations we use (for what
    # audience is the question..)
    #
    # 2) It would of course be stupid not to use absolute pathnames as arguments
    # to the ::FileUtils functions.
    #
    # 3) Finally, (and here is the big "if") it seems reasonable that sometimes
    # under various modalities we will want to emit to the ui messages that
    # contain those pathnames *BUT* depending on the modality we may or may
    # not want to use the absolute path (reasons for this may become clear
    # in the future..)
    #
    # `escape_path` is the function we use to hook into the specific behavior
    # of the specific modality in question.  The only icky part of all this is
    # that the source data is not structured - it is a string that starts
    # from ::FileUtils.  So we foolishly try to match all strings that look
    # like absolute paths to replace them with something that gets run
    # through `escape_path`.  This is probably not robust enough for
    # "production" (for the appropriate definition of "production") but
    # hopefully our regex is tight enough to catch all strings that matter
    # and none that don't for the sake of this zany proof of concept.



    # overriding fu_output_message is the right way to customize
    # (usually 'verbose'-style messages) from ::FileUtils.  Here we hook
    # into our ridiculous path sanitization and prettification logic
    #
    rx = Face::PathTools::FUN.absolute_path_hack_rx
    define_method :fu_output_message do |msg|
      s = msg.gsub rx do
        escape_path "#{ $~[0] }" # (delegates to the modality-specific pen)
      end
      emit :info, s
      nil
    end
  end
end
