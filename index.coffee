util = require 'util'
_ = require 'lodash'
clone = _.cloneDeep
omit = _.reject
isArray = _.isArray

N = 3

log = (o) ->
  console.log util.inspect(o, { depth: null, colors: true })

buildOption = (i, j) ->
  letter = String.fromCharCode(65 + i)
  letter + (j + 1)

buildOptions = ->
  res = []
  for i in [ 0...N ]
    for j in [ 0...N ]
      res.push buildOption(i, j)
  return res

buildMatrix = ->
  for i in [ 0...N ]
    for j in [ 0...N ]
      buildOptions()

exclude = (matrix, i, j, item) ->
  if not isArray matrix[i][j]
    return matrix
  matrix = clone matrix
  matrix[i][j] = omit matrix[i][j], (element) ->
    element[0] is item[0] or element[1] is item[1]
  if not matrix[i][j].length
    throw new Error('invalid')
  return reduce matrix, i, j

reduce = (matrix, i, j) ->
  if matrix[i][j].length > 1
    return matrix
  item = matrix[i][j][0]
  matrix = clone matrix
  matrix[i][j] = item
  for i_ in [ 0...N ]
    for j_ in [ 0...N ]
      continue if i_ is i and j_ is j
      matrix = exclude matrix, i_, j_, item
  return matrix

set = (matrix, i, j, item) ->
  matrix = clone matrix
  matrix[i][j] = [ item ]
  return reduce matrix, i, j

isCellComplete = (matrix, i, j) ->
  return not isArray matrix[i][j]

isMatrixComplete = (matrix) ->
  for i in [ 0...N ]
    for j in [ 0...N ]
      return false if not isCellComplete matrix, i, j
  return true

fork = (matrices) ->
  candidates = []

  for matrix in matrices
    minLength = Infinity
    i_ = 0
    j_ = 0
    for i in [ 0...N ]
      for j in [ 0...N ]
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

for i in [ 0...N ]
  matrix = set matrix, 0, i, buildOption(i, i)

log matrix

foundMatrix = fork [ matrix ]
if foundMatrix?.found
  result = foundMatrix.matrix.map (row) ->
    row.join(' ')
  .join('\n')
  console.log result
