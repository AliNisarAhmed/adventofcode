fn main() {
    if let Err(e) = aocrust::get_args().and_then(aocrust::run) {
        eprintln!("{}", e);
        std::process::exit(1)
    }
}
