import text from "../inputs/01.txt";

export const part1 = (input: string) => {
	const [_, zero] = input
		.trim()
		.split("\n")
		.reduce(
			([acc, zero], block) => {
				const num = Number(block.slice(1));
				switch (block[0]) {
					case "L":
						acc -= num;
						break;
					case "R":
						acc += num;
						break;
				}

				const ret = acc >= 100 ? acc : acc < 0 ? 100 + acc : acc;
				const toMod = ret % 100;

				zero += toMod === 0 ? 1 : 0;

				return [toMod, zero];
			},
			[50, 0],
		);

	return zero;
};

export const part2 = (input: string) => {
	const [, zero] = input
		.trim()
		.split("\n")
		.reduce(
			([acc, zero], block) => {
				const num = Number(block.slice(1));

				for (let i = num; i > 0; i--) {
					acc += block[0] === "L" ? -1 : 1;
					if (acc === 100) {
						acc = 0;
					}
					if (acc === -1) {
						acc = 99;
					}
					if (acc === 0) {
						zero += 1;
					}
				}

				return [acc, zero];
			},
			[50, 0],
		);

	return zero;
};

console.log(part1(text));
console.log(part2(text));
