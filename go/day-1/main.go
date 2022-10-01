package main

import (
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
)

func main() {
	file, _ := os.Open("./input.txt")
	buf, _ := io.ReadAll(file)

	lines := strings.Split(string(buf), "\n")

	nums := []int{}
	for _, line := range lines {
		num, _ := strconv.Atoi(line)
		nums = append(nums, num)
	}

	var total int
	for idx := range nums {
		if idx < 3 {
			continue
		}

		curr := nums[idx] + nums[idx-1] + nums[idx-2]
		prev := nums[idx-1] + nums[idx-2] + nums[idx-3]

		if curr > prev {
			total++
		}
	}

	fmt.Println(total)
}
