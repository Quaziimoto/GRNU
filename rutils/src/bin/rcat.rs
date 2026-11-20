use std::env;

// gets path of desired file from command line arguments
fn get_file_path() -> Result<String, std::io::Error> {
    let args: Vec<String> = env::args().skip(1).collect();
    if args.len() != 1 {
        eprintln!("rcat: expected one argument, got {}", args.len());
        std::process::exit(1);
    }
    Ok(args[0].clone())
}

// reads the content of the file given by get_file_path and returns it as a String
fn get_file_content() -> Result<String, std::io::Error> {
    let path = get_file_path()?;
    std::fs::read_to_string(path)
}

fn main() {
    match get_file_content() {
        Ok(content) => print!"{}", content),
        Err(e) => {
            eprintln!("rcat: {e}");
            std::process::exit(1);
        }   
    }
}