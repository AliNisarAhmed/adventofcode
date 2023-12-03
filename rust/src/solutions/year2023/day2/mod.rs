use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{multispace0, multispace1},
    combinator::{eof, opt},
    multi::many_till,
    IResult,
};

pub fn part_one(input: String) -> u32 {
    input
        .lines()
        .map(line_parser)
        .filter_map(|game| {
            if is_game_possible(&game) {
                Some(game.id)
            } else {
                None
            }
        })
        .sum()
}

pub fn part_two(input: String) -> u32 {
    input
        .lines()
        .map(line_parser)
        .map(|g| calc_max_for_round(g.rounds.iter().flatten().collect::<Vec<&Ball>>()))
        .sum()
}

// ----------------------------------------------------------------------------------------
fn calc_max_for_round(round: Vec<&Ball>) -> u32 {
    let mut red_max = Ball::Red(0);
    let mut blue_max = Ball::Blue(0);
    let mut green_max = Ball::Green(0);

    for ball in round {
        match ball {
            Ball::Red(v) if *v > red_max.val() => {
                red_max = Ball::Red(*v);
            }
            Ball::Green(v) if *v > green_max.val() => {
                green_max = Ball::Green(*v);
            }
            Ball::Blue(v) if *v > blue_max.val() => {
                blue_max = Ball::Blue(*v);
            }
            _ => continue,
        }
    }

    red_max.val() * blue_max.val() * green_max.val()
}

fn is_game_possible(game: &Game) -> bool {
    game.rounds.iter().all(is_round_possible)
}
fn is_round_possible(round: &Round) -> bool {
    round.iter().all(|ball| ball.is_valid())
}

#[derive(Debug, PartialEq, Eq, Ord, PartialOrd)]
enum Ball {
    Green(u32),
    Blue(u32),
    Red(u32),
}

impl Ball {
    fn val(&self) -> u32 {
        match self {
            Self::Red(v) => *v,
            Self::Green(v) => *v,
            Self::Blue(v) => *v,
        }
    }
    fn is_valid(&self) -> bool {
        match self {
            Self::Red(v) => *v <= 12,
            Self::Green(v) => *v <= 13,
            Self::Blue(v) => *v <= 14,
        }
    }

    fn is_red(&self) -> bool {
        match self {
            Self::Red(_) => true,
            _ => false,
        }
    }

    fn is_blue(&self) -> bool {
        match self {
            Self::Blue(_) => true,
            _ => false,
        }
    }

    fn is_green(&self) -> bool {
        match self {
            Self::Green(_) => true,
            _ => false,
        }
    }
}

type Round = Vec<Ball>;

#[derive(Debug, PartialEq)]
struct Game {
    id: u32,
    rounds: Vec<Round>,
}

fn line_parser(input: &str) -> Game {
    game_parser(input).unwrap().1
}

fn game_parser(input: &str) -> IResult<&str, Game> {
    let (rem, id) = game_id_parser(input)?;
    let (rem, rounds) = rounds_parser(rem)?;

    Ok((rem, Game { id, rounds }))
}

fn game_id_parser(input: &str) -> IResult<&str, u32> {
    let (rem, _) = tag("Game ")(input)?;
    let (rem, id) = nom::character::complete::u32(rem)?;
    let (rem, _) = tag(":")(rem)?;

    Ok((rem, id))
}

fn rounds_parser(input: &str) -> IResult<&str, Vec<Round>> {
    let (rem, (rounds, _)) = many_till(round_parser, eof)(input)?;
    Ok((rem, rounds))
}
fn round_parser(input: &str) -> IResult<&str, Round> {
    let (rem, (round, _)) = many_till(ball_parser, alt((tag(";"), eof)))(input)?;
    Ok((rem, round))
}

fn ball_parser(input: &str) -> IResult<&str, Ball> {
    ball_parser_with_color(input, "green")
        .or_else(|_| ball_parser_with_color(input, "blue"))
        .or_else(|_| ball_parser_with_color(input, "red"))
}

fn ball_parser_with_color<'a>(input: &'a str, color: &str) -> IResult<&'a str, Ball> {
    let (rem, _) = multispace0(input)?;
    let (rem, number) = nom::character::complete::u32(rem)?;
    let (rem, _) = multispace1(rem)?;
    let (rem, _) = tag(color)(rem)?;
    let (rem, _) = opt(tag(","))(rem)?;

    match color {
        "green" => Ok((rem, Ball::Green(number))),
        "blue" => Ok((rem, Ball::Blue(number))),
        _ => Ok((rem, Ball::Red(number))),
    }
}

#[cfg(test)]
mod tests {
    use crate::solutions::year2023::day2::{
        ball_parser_with_color, game_parser, round_parser, Ball, Game,
    };

    #[test]
    pub fn parses_ball_2023_02() {
        assert_eq!(
            Ball::Green(12),
            ball_parser_with_color(" 12 green, abc123", "green")
                .unwrap()
                .1
        );

        assert_eq!(
            Ball::Blue(100),
            ball_parser_with_color(" 100 blue, 12 green", "blue")
                .unwrap()
                .1
        );
    }

    #[test]
    pub fn parses_round_2023_02() {
        assert_eq!(
            vec![Ball::Green(12), Ball::Blue(5)],
            round_parser("12 green, 5 blue; 1 red").unwrap().1
        )
    }

    #[test]
    pub fn parses_game_2023_02() {
        let round_1 = vec![Ball::Green(12), Ball::Blue(5)];
        let round_2 = vec![Ball::Red(17), Ball::Green(50)];
        assert_eq!(
            Game {
                id: 1,
                rounds: vec![round_1, round_2]
            },
            game_parser("Game 1: 12 green, 5 blue; 17 red, 50 green")
                .unwrap()
                .1
        )
    }
}
