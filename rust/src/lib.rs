use std::{
    error::Error,
    fs::{self, File},
    io::Write,
    path::Path,
};

mod solutions;

use clap::{Parser, Subcommand, ValueEnum};

type MyResult<T> = Result<T, Box<dyn Error>>;

pub fn run_solution() {
    // execute solution here
    // dbg!(day13::part_one(String::from("abc")));

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

    match config.command {
        None => {}
        Some(Commands::Create { year, day }) => create(year, day, &secret)?,
        Some(Commands::Run) => run_solution(),
    }

    Ok(())
}

// -----------------------------------------------------------------------------

fn download_input(year: u32, day: u32, secret: &str) -> Result<String, String> {
    let client = reqwest::blocking::Client::new();
    client
        .get(format!(
            "https://adventofcode.com/{}/day/{}/input",
            year, day
        ))
        .header("Cookie", format!("session={}", secret))
        .send()
        .map_err(|e| format!("failed to download input: {}", e))?
        .text()
        .map_err(|e| format!("failed to parse input: {}", e))
}

fn create_year_dir(year: u32) -> Result<String, String> {
    let year_dir_name: String = format!("year{}", year);
    let year_dir_string: String = format!("./src/solutions/{}", year_dir_name);
    let year_path = Path::new(&year_dir_string);

    if !year_path.exists() {
        fs::create_dir(year_path).map_err(|e| format!("failed to create year directory: {}", e))?;
        println!("created year directory");

        let solutions_file_path = Path::new("./src/solutions.rs");
        let mut solutions_file = File::options()
            .append(true)
            .open(solutions_file_path)
            .map_err(|e| format!("could not open solutions file: {}", e))?;
        solutions_file
            .write(format!("\npub mod {};", year_dir_name).as_bytes())
            .map_err(|e| format!("could not write to solutions file: {}", e))?;
    }

    Ok(year_dir_name)
}

fn create_day_dir(year_dir_name: &str, day: u32) -> Result<String, String> {
    let day_dir_name = format!("day{}", day);
    let day_string: String = format!("./src/solutions/{}/{}", year_dir_name, day_dir_name);
    let day_dir_path = Path::new(&day_string);
    if !day_dir_path.exists() {
        fs::create_dir(day_dir_path)
            .map_err(|e| format!("failed to create day directory: {}", e))?;
    }

    Ok(day_dir_name)
}

fn create_day_file(year_dir_name: &str, day_dir_name: &str) -> Result<String, String> {
    let day_file_name = String::from("mod");
    let day_file_string: String = format!(
        "./src/solutions/{}/{}/{}.rs",
        year_dir_name, day_dir_name, day_file_name
    );
    let day_file_path = Path::new(&day_file_string);
    if day_file_path.exists() {
        return Err(format!(
            "The file \"{}\" already exists, delete it to continue",
            day_file_string
        ));
    }
    let mut day_file =
        File::create(day_file_path).map_err(|e| format!("could not create mod.rs file: {}", e))?;
    let file_contents = format!(
        "
pub fn part_one(input: String) {{ }}

pub fn part_two(input: String) {{ }}
    "
    );

    day_file
        .write_all(&file_contents.as_bytes())
        .map_err(|e| format!("could not write to file: {}", e))?;

    Ok(day_file_name)
}

fn write_input_file(input: String, year_dir_name: &str, day_dir_name: &str) -> Result<(), String> {
    let input_file_string = format!(
        "./src/solutions/{}/{}/input.txt",
        year_dir_name, day_dir_name
    );
    let input_file_path = Path::new(&input_file_string);

    let mut input_file = if !input_file_path.exists() {
        File::create(input_file_path)
            .map_err(|e| format!("failed to create input.txt file: {}", e))?
    } else {
        File::options()
            .append(true)
            .open(input_file_path)
            .map_err(|e| format!("could not open input.txt file: {}", e))?
    };

    input_file
        .write(input.as_bytes())
        .map_err(|e| format!("failed to write to input.txt file: {}", e))?;

    Ok(())
}

fn write_solutions_mod_file(year_dir_name: &str, day_dir_name: &str) -> Result<(), String> {
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
        .write(format!("\npub mod {};", day_dir_name).as_bytes())
        .map_err(|e| format!("could not write to mod file: {}", e))?;

    Ok(())
}

fn create(year: u32, day: u32, secret: &str) -> Result<(), String> {
    let input = download_input(year, day, secret)?;
    let year_dir_name = create_year_dir(year)?;
    let day_dir_name = create_day_dir(&year_dir_name, day)?;
    let day_file_name = create_day_file(&year_dir_name, &day_dir_name)?;

    write_input_file(input, &year_dir_name, &day_dir_name)?;

    write_solutions_mod_file(&year_dir_name, &day_dir_name)
}
