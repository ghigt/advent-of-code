const data = await Deno.readTextFile("./input.txt");

const lines = data.split("\n");

const nums = lines.map((l) => parseInt(l));

const three = nums.map((num, i) => {
  if (i < 2) return 0;

  return num + nums[i - 1] + nums[i - 2];
});

const changes = three.map((num, i) => {
  if (i < 3) return "N/A";

  if (num > three[i - 1]) {
    return "increased";
  } else if (num === three[i - 1]) {
    return "no change";
  } else {
    return "decreased";
  }
});

const count = changes.filter((c) => c === "increased").length;

console.log(count);
