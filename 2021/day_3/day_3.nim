import std/sequtils
import std/strutils
import std/parseutils
import std/os
import std/enumerate
import std/tables
import std/math

iterator binaryDigits(i: int): int =
  var x = i
  while x != 0:
    yield x mod 2
    x = x div 2

func `[]`(i: SomeInteger, pos: Natural): range[0..1] =
  (i div (1 shl pos)) mod 2

func `[]=`(i: var SomeInteger, pos: Natural, val: range[0..1]): void =
  i = i and not (1 shl pos) or (val shl pos)

func `[]=`(i: var SomeInteger, pos: Natural, val: bool): void =
  i[pos] = int(val)

func log2(i: SomeInteger): float64 {.inline.} =
  log2(float64(i))

func commonBits(input: seq[int], mostCommon = true): int =
  var counts = newTable[int, int]()
  result = 0
  for num in input:
    for (pos, digit) in enumerate(num.binaryDigits):
      counts.mgetOrPut(pos, 0) += digit
  for x in countdown(counts.keys.toSeq.max, 0):
    if mostCommon:
      result[x] = counts.getOrDefault(x, 0) * 2 >= input.len
    else:
      result[x] = counts.getOrDefault(x, 0) * 2 < input.len

func getRatings(input: seq[int], mostCommon = true): int =
  var workingSeq = input
  var pos: int = Natural(log2(input.foldl(a or b)))
  while workingSeq.len > 1 and pos >= 0:
    let common = workingSeq.commonBits(mostCommon)
    workingSeq = workingSeq.filterIt(it[pos] == common[pos]).deduplicate
    pos -= 1
  if mostCommon:
    max(workingSeq)
  else:
    min(workingSeq)

func partOne(input: seq[int]): int =
  input.commonBits * input.commonBits(mostCommon = false)

func partTwo(input: seq[int]): int =
  input.getRatings() * input.getRatings(mostCommon = false)

let input = readFile(paramStr(1)).splitWhitespace().map do (s: string) -> (int):
  var x: int
  discard parseBin(s, x)
  return x

echo input.partOne
echo input.partTwo
