pub fn part_one(input: String) -> u32 {
    input
        .lines()
        .map(|line| {
            let mut it = line.chars().filter_map(|character| character.to_digit(10));
            let first = it.next().expect("Should be a number");
            let last = it.last();

            match last {
                None => first * 10 + first,
                Some(n) => first * 10 + n,
            }
        })
        .sum()
}

pub fn part_two<'a>(mut input: String) -> u32 {
    let numbers = vec![
        ("one", "o1e"),
        ("two", "t2o"),
        ("three", "t3e"),
        ("four", "f4r"),
        ("five", "f5e"),
        ("six", "s6x"),
        ("seven", "s7n"),
        ("eight", "e8t"),
        ("nine", "n9e"),
        ("zero", "z0o")
    ];

    for (text, replacement) in numbers {
        input = input.replace(text, replacement);
    }

    part_one(input)
}
