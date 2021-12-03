import std/sequtils
import std/strutils
import std/os


type
  Position = tuple[Horizontal: int, Depth: int, Aim: int]

func foldl[T, U](s: seq[T], f: proc(accumulator: U, value: T): U {.closure.},
    startValue: U): U =
  result = startValue
  for element in s:
    result = f(result, element)

func calcNextPos(current: Position, orders: (string, int)): Position =
  let (instruction, units) = orders
  result = current
  case instruction:
    of "forward":
      result.Horizontal += units
      result.Depth += result.Aim * units
    of "down":
      result.Aim += units
    of "up":
      result.Aim -= units

func calcPos(input: seq[(string, int)]): Position =
  input.foldl(calcNextPos, startValue = (0, 0, 0))


let input = readFile(paramStr(1))
  .splitLines()
  .filterIt(it.len > 0)
  .map do (x: string) -> (string, int):
    let y = x.splitWhitespace()
    result = (y[0], parseInt(y[1]))

let tmp = input.calcPos
echo tmp.Horizontal*tmp.Aim
echo tmp.Horizontal*tmp.Depth

