util = require 'util'
_ = require 'lodash'
clone = _.cloneDeep
omit = _.reject
isArray = _.isArray

N = 4

idx = [ 0...N ]

log = (o) ->
  console.log util.inspect(o, { depth: null, colors: true })

buildOption = (i, j) ->
  letter = String.fromCharCode(65 + i)
  letter + (j + 1)

buildOptions = ->
  res = []
  for i in idx
    for j in idx
      res.push buildOption(i, j)
  return res

buildMatrix = ->
  for i in idx
    for j in idx
      buildOptions()

strictCompare = (e1, e2) -> e1 is e2

fuzzyCompare = (e1, e2) ->
  e1[0] is e2[0] or e1[1] is e2[1]

exclude = (matrix, i, j, item, fuzzy) ->
  if not isArray matrix[i][j]
    return matrix
  matrix = clone matrix
  compare = if fuzzy then fuzzyCompare else strictCompare
  matrix[i][j] = omit matrix[i][j], (element) ->
    compare(element, item)
  if not matrix[i][j].length
    throw new Error('invalid')
  return reduce matrix, i, j

reduce = (matrix, i, j) ->
  if not isArray(matrix[i][j]) or matrix[i][j].length > 1
    return matrix
  item = matrix[i][j][0]
  matrix = clone matrix
  matrix[i][j] = item

  for i_ in idx
    for j_ in idx
      continue if i_ is i and j_ is j
      matrix = exclude matrix, i_, j_, item
  for i_ in idx
    continue if i_ is i
    matrix = exclude matrix, i_, j, item, true
  for j_ in idx
    continue if j_ is j
    matrix = exclude matrix, i, j_, item, true

  return matrix

set = (matrix, i, j, item) ->
  matrix = clone matrix
  matrix[i][j] = [ item ]
  return reduce matrix, i, j

isCellComplete = (matrix, i, j) ->
  return not isArray matrix[i][j]

isMatrixComplete = (matrix) ->
  for i in idx
    for j in idx
      return false if not isCellComplete matrix, i, j
  return true

fork = (matrices) ->
  candidates = []

  for matrix in matrices
    minLength = Infinity
    i_ = 0
    j_ = 0
    for i in idx
      for j in idx
        if isArray(matrix[i][j]) and (l = matrix[i][j].length) < minLength
          i_ = i
          j_ = j
          minLength = l

    continue if minLength is Infinity

    for item in matrix[i_][j_]
      try
        matrix_ = set matrix, i_, j_, item
        if isMatrixComplete matrix_
          return found: true, matrix: matrix_
        candidates.push matrix_

  if candidates.length is 0
    throw new Error('nothing')

  return fork candidates


matrix = buildMatrix()

for i in idx
  matrix = set matrix, 0, i, buildOption(i, i)

foundMatrix = fork [ matrix ]
if foundMatrix?.found
  result = foundMatrix.matrix.map (row) ->
    row.join(' ')
  .join('\n')
  console.log result
