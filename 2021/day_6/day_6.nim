import std/os
import std/strutils
import std/sequtils
import std/tables
import std/math

func simulateGrowth(fishCounts: CountTable[int], days = 1): CountTable[int] =
  result = fishCounts
  for i in 0..<days:
    #debugEcho i, ": ", result, "\t", result.values.toSeq.sum
    var nextFishCounts = initCountTable[int]()
    for (stage, num) in result.pairs:
      if stage == 0:
        nextFishCounts.inc(8, num)
        nextFishCounts.inc(6, num)
      else:
        nextFishCounts.inc(stage - 1, num)
    result = nextFishCounts

func partOne(input: CountTable[int]): int =
  input.simulateGrowth(80).values.toSeq.sum

func partTwo(input: CountTable[int]): int =
  input.simulateGrowth(256).values.toSeq.sum

let input = readFile(paramStr(1)).split(",").mapIt(
    it.strip.parseInt).toCountTable

echo input.partOne
echo input.partTwo
