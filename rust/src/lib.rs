use std::{error::Error, fs, path::Path};

use clap::{Parser, Subcommand};

type MyResult<T> = Result<T, Box<dyn Error>>;

const SECRET_FILE_NAME: &str = ".secret";

#[derive(Debug, Parser)]
pub struct Config {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Debug, Subcommand)]
enum Commands {
    Create {
        #[arg(short = 'y', long)]
        year: u32,

        #[arg(short = 'd', long)]
        day: u32,
    },
    Run {
        #[arg(short = 'y', long)]
        year: u32,

        #[arg(short = 'd', long)]
        day: u32,
    },
}

pub fn get_args() -> MyResult<Config> {
    Ok(Config::parse())
}

pub fn run(config: Config) -> MyResult<()> {
    let secret = fs::read_to_string(SECRET_FILE_NAME).expect(&format!(
        "Please make sure {} file exists in project root",
        SECRET_FILE_NAME
    ));
    println!("{}", secret);
    println!("{:?}", &config);

    match config.command {
        None => {}
        Some(Commands::Create { year, day }) => create(year, day, &secret)?,
        Some(Commands::Run { year, day }) => {}
    }

    Ok(())
}

// -----------------------------------------------------------------------------

fn create(year: u32, day: u32, secret: &str) -> Result<(), String> {
    let year_string: String = format!("./src/solutions/{}", year);
    let year_path = Path::new(&year_string);
    if let Err(_) = year_path.try_exists() {
        fs::create_dir(year_path).map_err(|_| "failed to create year directory")?;
    };

    let day_string: String = format!("day_{}.rs", day);


    Ok(())
}
