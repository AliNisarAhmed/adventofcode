## Download input and create solution files
- `cargo run -- create -y <year> -d <day>`
  - creates `src/solutions/year<year>/day<day>/mod.rs` folders and files if they do not already exist
  - downloads the input to `src/solutions/year<year>/day<day>/input.txt`


## Run solution
- `cargo run -- run -y <year> -d <day> -p <part>`
  - calls the solution function (e.g. `year2023::day1::part_one`) in `lib.rs` with input
  - if run with `--test` flag, supplies the test input in `sample<part>.txt` file in `day<day>` folder
