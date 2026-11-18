use std::env;

// Rust stop forcing me to use snake_case 
fn get_current_directory() -> String {
    match env::current_dir() {
        Ok(path) => path.display().to_string(),
        Err(e) => {
            eprintln!("rcd: {e}");
            std::process::exit(1);
        }
    }
}

fn change_directory(path: &str) {
    let target = if path == "-" {
        env::var("OLDPWD").unwrap_or_else(|_| {
            eprintln!("rcd: OLDPWD not set");
            std::process::exit(1);
        })
    } else {
        path.to_string()
    };
    if let Err(e) = env::set_current_dir(&target) {
        eprintln!("rcd: {target}: {e}");
        std::process::exit(1);
    }
}

fn main() {
    let args= env::args().skip(1).collect::<Vec<String>>();

    if args.len() > 1 {
        eprintln!("rcd: too many arguments");
        std::process::exit(1);
    }

    let path = if args.is_empty() {
        env::var("HOME")
            .or_else(|_| env::var("USERPROFILE")) // Windows usually has no HOME
            .unwrap_or_else(|_| {
                eprintln!("rcd: HOME not set");
                std::process::exit(1);
            })
    } else {
        args[0].clone()
    };
    change_directory(&path);
    println!("{}", get_current_directory()); // absolute path, for the shell wrapper to cd into
}