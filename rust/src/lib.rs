use std::{
    error::Error,
    fs::{self, File},
    io::Write,
    path::Path,
};

mod solutions;

use clap::{Parser, Subcommand, ValueEnum};

use crate::solutions::year2021::day13;

type MyResult<T> = Result<T, Box<dyn Error>>;

pub fn run_solution() {
    // execute solution here
    day13::part_one(String::from("abc"));
}

// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------

const SECRET_FILE_NAME: &str = ".secret";

#[derive(Debug, Parser)]
pub struct Config {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Debug, Clone, ValueEnum)]
enum Part {
    One,
    Two,
    Both,
}

#[derive(Debug, Subcommand)]
enum Commands {
    Create {
        #[arg(short = 'y', long)]
        year: u32,

        #[arg(short = 'd', long)]
        day: u32,
    },
    Run,
}

pub fn get_args() -> MyResult<Config> {
    Ok(Config::parse())
}

pub fn run(config: Config) -> MyResult<()> {
    let secret = fs::read_to_string(SECRET_FILE_NAME).expect(&format!(
        "Please make sure {} file exists in project root",
        SECRET_FILE_NAME
    ));
    let secret = secret.trim();
    println!("{}", secret);
    println!("{:?}", &config);

    match config.command {
        None => {}
        Some(Commands::Create { year, day }) => create(year, day, &secret)?,
        Some(Commands::Run) => run_solution(),
    }

    Ok(())
}

// -----------------------------------------------------------------------------

fn create(year: u32, day: u32, secret: &str) -> Result<(), String> {
    let year_dir_name: String = format!("year{}", year);
    let year_string: String = format!("./src/solutions/{}", year_dir_name);
    let year_path = Path::new(&year_string);

    let client = reqwest::blocking::Client::new();
    let input_file = client
        .get(format!(
            "https://adventofcode.com/{}/day/{}/input",
            year, day
        ))
        .header("Cookie", format!("session={}", secret))
        .send()
        .map_err(|e| format!("Could not download input: {}", e))?
        .text()
        .map_err(|e| format!("Could not parse input file: {}", e))?;
    dbg!(input_file);

    if !year_path.exists() {
        fs::create_dir(year_path).map_err(|_| "failed to create year directory")?;
        println!("created directory");
        let solutions_file_path = Path::new("./src/solutions.rs");
        let mut solutions_file = File::options()
            .append(true)
            .open(solutions_file_path)
            .map_err(|e| format!("could not open solutions file: {}", e))?;
        solutions_file
            .write(format!("\npub mod {};", year_dir_name).as_bytes())
            .map_err(|e| format!("could not write to solutions file: {}", e))?;
    }

    let day_file_name = format!("day{}", day);
    let day_string: String = format!("./src/solutions/{}/{}.rs", year_dir_name, day_file_name);
    let day_path = Path::new(&day_string);
    if day_path.exists() {
        return Err(format!(
            "The file \"{}\" already exists, delete it to continue",
            day_string
        ));
    }
    let mut day_file =
        File::create(day_path).map_err(|e| format!("could not create file: {}", e))?;

    let mod_file_name = "mod";
    let mod_file_path_string = format!("./src/solutions/{}/{}.rs", year_dir_name, mod_file_name);
    let mod_file_path = Path::new(&mod_file_path_string);

    let mut mod_file = if !mod_file_path.exists() {
        File::create(mod_file_path)
            .map_err(|e| format!("could not create mod file: {}", e))
            .unwrap()
    } else {
        File::options()
            .append(true)
            .open(mod_file_path)
            .map_err(|e| format!("could not open mod file: {}", e))
            .unwrap()
    };
    mod_file
        .write(format!("\npub mod {};", day_file_name).as_bytes())
        .map_err(|e| format!("could not write to mod file: {}", e))?;

    let file_contents = format!(
        "
pub fn part_one(input: String) {{ }}

pub fn part_two(input: String) {{ }}
    "
    );

    day_file
        .write_all(&file_contents.as_bytes())
        .map_err(|_| "could not write to file")?;

    Ok(())
}
