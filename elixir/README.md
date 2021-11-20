# Advent Of Code

Cloned from: https://github.com/lud/adventofcode. All the set up code is from that repo.

Solutions for a particular year and day can be found in the directory: 

`lib/solutions/<year>/day_{number}.ex`

### Configure your cookie

Create the config file:

    touch config/secret.exs

Retrieve your cookie from the AoC website and add the configuration in
`secret.exs`:

    import Config
    config :aoe, session_cookie: "53616c7465..."

### Create the files

    mix aoe.create

    OPTIONS
    --year <2015..2021>
    --day <1..25> 

### Run the test

    mix test test/#{year}/day_#{day}_test.exs

### Run the solution

    mix aoe.run

    OPTIONS
    --year <2015..2021>
    --day <1..25> 
    --part <1|2>
