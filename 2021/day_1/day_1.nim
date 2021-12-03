import std/sequtils
import std/strutils
import std/os

func slidingComparison(input: seq[int], window: Natural = 1): int =
  zip(input, input[window..^1])
    .mapIt(int(it[1] > it[0]))
    .foldl(a + b)

func partOne(input: seq[int]): int =
  input.slidingComparison(1)

func partTwo(input: seq[int]): int =
  input.slidingComparison(3)

let input = readFile(paramStr(1)).splitWhitespace().mapIt(parseInt(it))
echo input.partOne
echo input.partTwo

