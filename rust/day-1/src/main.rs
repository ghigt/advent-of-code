use std::{
    fs::File,
    io::{BufRead, BufReader},
};

fn main() {
    let file = File::open("./input.txt").unwrap();
    let lines: Vec<String> = BufReader::new(file).lines().map(|f| f.unwrap()).collect();

    let nums: Vec<i32> = lines
        .into_iter()
        .map(|line| line.parse::<i32>().unwrap())
        .collect();

    let total: i32 = nums
        .iter()
        .enumerate()
        .map(|(idx, _)| {
            if idx < 3 {
                return 0;
            }

            let curr = nums[idx] + nums[idx - 1] + nums[idx - 2];
            let prev = nums[idx - 1] + nums[idx - 2] + nums[idx - 3];

            match curr > prev {
                true => 1,
                false => 0,
            }
        })
        .sum();

    println!("{}", total);
}
