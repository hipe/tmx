# from slackclient import SlackClient
import time
import re
import os


def _run_forever_newschool(environ, **kwargs):

    _normalize_sys_path()

    from upload_bot._magnetics import (
            secrets_via_environment_variables,
            behavior_via_secrets,
            webserver_via_behavior,
            )

    _secrets = secrets_via_environment_variables(environ)
    _behavior = behavior_via_secrets(_secrets)
    webserver_via_behavior(_behavior, **kwargs)


# instantiate Slack client
# slack_client = SlackClient(os.environ.get('SLACK_BOT_TOKEN'))
slack_client = None
# starterbot's user ID in Slack: value is assigned after the bot starts up
starterbot_id = None

# constants
RTM_READ_DELAY = 1  # 1 second delay between reading from RTM
EXAMPLE_COMMAND = "do"
MENTION_REGEX = "^<@(|[WU].+?)>(.*)"


def parse_bot_commands(slack_events):
    """
    Parses a list of events coming from the Slack RTM API to find bot commands.
    If a bot command is found, this function returns a tuple of command and
    channel. If its not found, then this function returns None, None.
    """
    for event in slack_events:
        if event["type"] == "message" and "subtype" not in event:
            user_id, message = parse_direct_mention(event["text"])
            if user_id == starterbot_id:
                return message, event["channel"]
    return None, None


def parse_direct_mention(message_text):
    """
    Finds a direct mention (a mention that is at the beginning) in message text
    and returns the user ID which was mentioned. If there is no direct mention,
    returns None
    """

    matches = re.search(MENTION_REGEX, message_text)
    # the first group contains the username,
    # the second group contains the remaining message
    if matches:
        return (matches.group(1), matches.group(2).strip())
    else:
        return (None, None)


def handle_command(command, channel):
    """
        Executes bot command if the command is known
    """

    # Default response is help text for the user
    _tmpl = "Not sure what you mean. Try *{}*."
    default_response = _tmpl.format(EXAMPLE_COMMAND)

    # Finds and executes the given command, filling in response
    response = None
    # This is where you start to implement more commands!
    if command.startswith(EXAMPLE_COMMAND):
        response = "Sure...write some more code then I can do that!"

    # Sends the response back to the channel
    slack_client.api_call(
        "chat.postMessage",
        channel=channel,
        text=response or default_response
    )


def _run_forever_oldschool():

    global starterbot_id
    if slack_client.rtm_connect(with_team_state=False):
        print("Starter Bot connected and running!")
        # Read bot's user ID by calling Web API method `auth.test`
        starterbot_id = slack_client.api_call("auth.test")["user_id"]
        while True:
            command, channel = parse_bot_commands(slack_client.rtm_read())
            if command:
                handle_command(command, channel)
            else:
                print('looping..')
            time.sleep(RTM_READ_DELAY)
    else:
        print("Connection failed. Exception traceback printed above.")


def _normalize_sys_path():

    path = os.path
    dirname = path.dirname
    sub_project_dir = dirname(path.abspath(__file__))
    project_dir = dirname(sub_project_dir)

    from sys import path as a
    current_head_path = a[0]

    if sub_project_dir == current_head_path:
        """CLOBBER the path that python automatically added - we don't want
        it to be there (lest we make unstable assumptions). #[#204]
        """
        print('thing one')
        a[0] = project_dir
    elif project_dir == current_head_path:
        print('thing two - HELLO already did this')
    else:
        raise Exception('strange - what is up with sys.path')


class Exception(Exception):

    def __init__(self, s, *items):
        if 0 == len(items):
            msg = s
        else:
            msg = s.format(*items)
        super().__init__(msg)


if __name__ == "__main__":
    _run_forever_newschool(
            os.environ,
            use_reloader=False,  # reloader is annoying a.f
            )


# #history-A.1: begin to transition from implementing bot to running webserver
# #born.
