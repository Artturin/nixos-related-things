use std::{
    io::Write,
    process::{exit, Command, Stdio},
};

fn show_menu_get_answer(choices: String) -> Vec<String> {
    let mut child = Command::new("wofi")
        .args(["--show", "dmenu"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()
        .expect("failed to execute process");

    child
        .stdin
        .as_mut()
        .unwrap()
        .write_all(choices.as_bytes())
        .expect("fail");

    let output = child.wait_with_output().unwrap().stdout;

    (String::from_utf8_lossy(output.as_slice()))
        .trim()
        .to_owned()
        .split_whitespace()
        .map(str::to_string)
        .collect()
}

fn main() {
    let choices = vec!["iss", "notif", "opt", "pkg"].join("\n");

    let mut answer = show_menu_get_answer(choices);
    if answer.is_empty() {
        exit(0)
    }
    let mut url = String::new();
    match answer.remove(0).as_str() {
        "pkg" | "package" => {
            url = "https://search.nixos.org/packages?query=$searchstr&channel=unstable".to_string();
        }
        "opt" | "option" => {
            url = "https://search.nixos.org/options?query=$searchstr&channel=unstable".to_string();
        }
        "pr" | "pull" => {
            url = "https://github.com/NixOS/nixpkgs/pulls?q=is%3Apr+$searchstr".to_string();
        }
        "iss" | "issue" => {
            url = "https://github.com/NixOS/nixpkgs/issues?q=is%3Aissue+$searchstr".to_string();
        }
        "notif" | "notifications" => {}
        _ => exit(0),
    }

    if !url.is_empty() {
        print!("{}", url);
    }
}
