util = require 'util'
_ = require 'lodash'
clone = _.cloneDeep
omit = _.without

N = 3

log = (o) ->
  console.log util.inspect(o, { depth: null, colors: true })

letters = ( String.fromCharCode(97 + i) for i in [ 0...N ] )
numbers = [ 1..N ]

buildOptions = ->
  letter: clone letters
  number: clone numbers

buildMatrix = ->
  ( ( buildOptions() for i in [ 1..N ] ) for j in [ 1..N ] )

exclude = (key, matrix, i, j, item) ->
  if not matrix[i][j][key]?
    return matrix
  matrix = clone matrix
  matrix[i][j][key] = omit matrix[i][j][key], item
  if not matrix[i][j][key]?.length
    throw new Error('invalid')
  return reduce key, matrix, i, j

reduce = (key, matrix, i, j) ->
  if matrix[i][j][key].length > 1
    return matrix
  item = matrix[i][j][key][0]
  matrix = clone matrix
  delete matrix[i][j][key]
  matrix[i][j]["_#{key}"] = item
  for j_ in [ 0...N ]
    continue if j_ is j
    matrix = exclude key, matrix, i, j_, item
  for i_ in [ 0...N ]
    continue if i_ is i
    matrix = exclude key, matrix, i_, j, item
  return matrix

set = (key, matrix, i, j, item) ->
  matrix = clone matrix
  matrix[i][j][key] = [ item ]
  return reduce key, matrix, i, j

isCellComplete = (matrix, i, j) ->
  cell = matrix[i][j]
  return cell._letter? and cell._number?

isMatrixComplete = ->
  for i in [ 0...N ]
    for j in [ 0...N ]
      return false if not isCellComplete matrix, i, j
  return true

forkByKey = (key, matrices) ->
  candidates = []

  if not matrices?.length
    return candidates

  for matrix in matrices
    minLength = Infinity
    i_ = 0
    j_ = 0
    for i in [ 0...N ]
      for j in [ 0...N ]
        if matrix[i][j][key]? and (l = matrix[i][j][key].length) < minLength
          i_ = i
          j_ = j
          minLength = l

    continue if minLength is Infinity

    for item in matrix[i_][j_][key]
      try
        matrix_ = set key, matrix, i_, j_, item
        if isMatrixComplete matrix_
          return found: true, matrix: matrix_
        candidates.push matrix_

  if candidates.length is 0
    throw new Error('nothing')

  return candidates

fork = (matrices) ->
  if not matrices?.length
    return null
  try
    matrices = forkByKey 'letter', matrices
    if matrices?.found
      return matrices
    matrices = forkByKey 'number', matrices
    if matrices?.found
      return matrices
    return fork matrices
  catch e
    console.log e, e.stack

matrix = buildMatrix()

for i in [ 0...N ]
  matrix = set 'letter', matrix, 0, i, letters[i]
  matrix = set 'number', matrix, 0, i, i + 1

log fork [ matrix ]
