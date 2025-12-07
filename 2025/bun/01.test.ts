import { expect, test } from "bun:test";
import { part1, part2 } from "./01";

const testInput = `L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
`;

test("part1", () => {
	expect(part1(testInput)).toBe(3);
});

test("part2", () => {
	expect(part2(testInput)).toBe(6);
});
