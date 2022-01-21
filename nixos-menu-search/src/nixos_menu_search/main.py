"""
a script to display a menu with choices
"""

import os
import subprocess
import sys
import webbrowser

from github import Github


def get_gh_notif_dict() -> dict[str, str]:
    """get a dictionary of github notification titles and urls"""
    g_h = Github(os.getenv("GITHUB_TOKEN"))
    notifications = g_h.get_user().get_notifications()
    notif_dict: dict[str, str] = {}
    for notif in notifications:
        issue = notif.get_issue()
        title = issue.title
        html_url = issue.html_url
        notif_dict[title] = html_url

    return notif_dict


def get_gh_notif_url(notif_dict: dict[str, str]) -> str:
    """get notification html url"""
    choices: str = "\n".join(tuple(notif_dict))
    choice: str = " ".join(show_menu_get_answer(choices))
    return notif_dict[choice]


def show_menu_get_answer(choices: str) -> list[str]:
    """get answer"""

    menucommand: list[str] = ["wofi", "--show", "dmenu", "-W", "400", "-L", "20"]

    try:
        answer: list[str] = (
            (subprocess.check_output(menucommand, input=choices, text=True, stderr=subprocess.DEVNULL)).strip()
        ).split(" ")
    except subprocess.CalledProcessError:  # if the menu is exited then exit
        sys.exit(0)

    return answer


def main() -> None:
    """main"""
    choices: str = "\n".join(
        (
            "iss",
            "notif",
            "opt",
            "pkg",
            "pr",
        )
    )

    answer: list[str] = show_menu_get_answer(choices)
    choice: str = answer.pop(0)
    url: str = ""
    notif_url: str = ""
    match choice:
        case "pkg" | "package":
            url = "https://search.nixos.org/packages?query=$searchstr&channel=unstable"
        case "opt" | "option":
            url = "https://search.nixos.org/options?query=$searchstr&channel=unstable"
        case "pr" | "pull":
            url = "https://github.com/NixOS/nixpkgs/pulls?q=is%3Apr+$searchstr"
        case "iss" | "issue":
            url = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+$searchstr"
        case "notif" | "notifications":
            notif_url = get_gh_notif_url(get_gh_notif_dict())

    if url or notif_url:
        if url:
            url = url.replace("$searchstr", "+".join(answer))
        else:
            url = notif_url
        print(url)
        webbrowser.open(url)


if __name__ == "__main__":
    main()
