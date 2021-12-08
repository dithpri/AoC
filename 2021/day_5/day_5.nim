import std/sequtils
import std/strutils
import std/parseutils
import std/os
import std/enumerate
import std/tables
import std/typetraits
import std/math

type
  Point2D = tuple[x: int, y: int]

func tuppy[T: tuple](s: seq): T =
  for (i, f) in enumerate(result.fields):
    f = s[i]

func `+`[T: Point2D](a: T, b: T): T =
  (a.x + b.x, a.y + b.y)

func `+=`[T: Point2D](res: var T, b: T): void =
  res = res + b

iterator linePixels(start: Point2D, `end`: Point2D): Point2D =
  var c = start
  let d: Point2D = (sgn(`end`.x - start.x), sgn(`end`.y - start.y))
  while c != `end`:
    yield c
    c += d
  yield c


func partOne(input: seq[(Point2D, Point2D)]): int =
  var counts = newCountTable[Point2D]()
  for vent in input:
    let (p1, p2) = vent
    if p1.x == p2.x or p1.y == p2.y:
      for point in linePixels(p1, p2):
        counts.inc(point)
  result = 0
  for (k, v) in counts.mpairs:
    if v > 1:
      result += 1

func partTwo(input: seq[(Point2D, Point2D)]): int =
  var counts = newCountTable[Point2D]()
  for vent in input:
    let (p1, p2) = vent
    for point in linePixels(p1, p2):
      counts.inc(point)
  result = 0
  for (k, v) in counts.mpairs:
    if v > 1:
      result += 1


let input = readFile(paramStr(1)).splitLines().filterIt(it.len > 0).map do (
  line: string) -> (Point2D, Point2D):
  let c = line.split(" -> ").mapIt(tuppy[Point2D](it.split(",").map(parseInt)))
  tuppy[(Point2D, Point2D)](c)

echo input.partOne
echo input.partTwo
