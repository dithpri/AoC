import std/os
import std/strutils
import std/sequtils
import std/tables
import std/math
import std/algorithm
import std/stats

func median[T](l: openArray[T]): T =
  let m = sorted(l)
  if l.len mod 2 == 0:
    result = m[l.len div 2]
  else:
    result = T(m[(m.len div 2)..((m.len+1) div 2)].mean)

func partOne(input: seq[int]): int =
  let m = input.median
  input.mapIt(abs(m - it)).sum

func partTwo(input: seq[int]): int =
  result = -1
  for candidate in min(input)..max(input):
    let s = input.mapIt(abs(it - candidate)).mapIt(it*(it+1) div 2).sum
    if s < result or result < 0:
      result = s

let input = readFile(paramStr(1)).split(",").mapIt(
    it.strip.parseInt)

echo input.partOne
echo input.partTwo

