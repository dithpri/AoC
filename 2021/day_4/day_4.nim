import std/sequtils
import std/strutils
import std/parseutils
import std/os
import std/sugar
import std/enumerate
import std/math

type
  BingoCell = tuple[Number: int, Marked: bool]
  BingoBoard = array[0..4, array[0..4, BingoCell]]

func transpose[M: static Natural, N: static Natural, T](mtx: array[0..M, array[
    0..N, T]]): array[0..N, array[0..M, T]] =
  for i in 0..mtx.high:
    for j in 0..mtx[i].high:
      result[j][i] = mtx[i][j]

func isRowComplete(row: array[0..4, BingoCell]): bool =
  row.filterIt(not it.Marked).len == 0

func isBoardComplete(board: BingoBoard): bool =
  board.any(isRowComplete) or board.transpose.any(isRowComplete)

func markNumber(board: var BingoBoard, number: int): void =
  for i in 0..board.high:
    for j in 0..board[i].high:
      if board[i][j].Number == number:
        board[i][j].Marked = true

func boardScore(board: BingoBoard, lastDrawnNumber: int): int =
  let nums = collect:
    for row in board:
      for elem in row:
        if not elem.Marked:
          elem.Number
  nums.sum*lastDrawnNumber


func partOne(numbersDrawn: seq[int], boards: seq[BingoBoard]): int =
  var workingSeq = boards
  var cur = -1
  while not workingSeq.any(isBoardComplete):
    inc cur
    workingSeq.applyIt(it.dup(markNumber(numbersDrawn[cur])))
  let completedBoard = workingSeq.filter(isBoardComplete)[0]
  completedBoard.boardScore(numbersDrawn[cur])

func partTwo(numbersDrawn: seq[int], boards: seq[BingoBoard]): int =
  var workingSeq = boards
  var lastnum = numbersDrawn[0]
  for number in numbersDrawn:
    lastnum = number
    workingSeq.applyIt(it.dup(markNumber(number)))
    if workingSeq.len == 1:
      if workingSeq.any(isBoardComplete):
        break
    workingSeq.keepIf(x => not x.isBoardComplete)
  let lastCompletedBoard = workingSeq[0]
  lastCompletedBoard.boardScore(lastnum)

let input = readFile(paramStr(1)).split("\n\n")

let numbersDrawn = input[0].split(",").map(parseInt)
let boards = collect:
  for board in input[1..^1]:
    var b: BingoBoard
    for (i, row) in enumerate(board.splitlines()):
      for (j, num) in enumerate(row.splitwhitespace()):
        b[i][j] = (parseint(num), false)
    b

echo partOne(numbersDrawn, boards)
echo partTwo(numbersDrawn, boards)
