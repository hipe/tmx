def hello_game_server():
    return 0


def main():
    print("hello from the game server.")


cli_for_production = main


# #history-A.1: delete the entrypoint CLI file that did nothing but call us
# #born: what was once this file moved elsewhere, and took the DNA
