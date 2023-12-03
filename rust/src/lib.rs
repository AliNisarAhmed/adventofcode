use std::error::Error;

mod aoc;
mod solutions;

use clap::{Parser, Subcommand, ValueEnum};
use crate::solutions::year2023::day2;

type MyResult<T> = Result<T, Box<dyn Error>>;

pub fn run_solution(year: u32, day: u32, part: u32, test: bool) {
    let input = aoc::get_input(year, day, part, test);

    // RUN SOLUTION FUNCTION HERE
    // dbg!(day1::part_two(input));
    dbg!(day2::part_two(input));
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
    Run {
        #[arg(short = 'y', long)]
        year: u32,
        #[arg(short = 'd', long)]
        day: u32,
        #[arg(short = 'p', long)]
        part: u32,
        #[arg(short, long, default_value_t = false, help = "when present, runs the test input")]
        test: bool,
    },
}

pub fn get_args() -> MyResult<Config> {
    Ok(Config::parse())
}

pub fn run(config: Config) -> MyResult<()> {
    let secret = std::fs::read_to_string(SECRET_FILE_NAME).expect(&format!(
        "Please make sure {} file exists in project root",
        SECRET_FILE_NAME
    ));
    let secret = secret.trim();

    match config.command {
        None => {
            println!("No command specified, use --help to see commands")
        }
        Some(Commands::Create { year, day }) => create_solution(year, day, &secret)?,
        Some(Commands::Run {
            year,
            day,
            part,
            test,
        }) => run_solution(year, day, part, test),
    }

    Ok(())
}

// -----------------------------------------------------------------------------

fn create_solution(year: u32, day: u32, secret: &str) -> Result<(), String> {
    let input = aoc::download_input(year, day, secret)?;
    let year_dir_name = aoc::create_year_dir(year)?;
    let day_dir_name = aoc::create_day_dir(&year_dir_name, day)?;
    aoc::create_day_file(&year_dir_name, &day_dir_name)?;

    aoc::write_input_file(input, &year_dir_name, &day_dir_name)?;

    aoc::write_solutions_mod_file(&year_dir_name, &day_dir_name)
}
