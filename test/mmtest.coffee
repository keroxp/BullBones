assert = require "assert"
path = require "path"
fs = require "fs"
crc32c = require("fast-crc32c")
describe "src32c1", ->
  it "should be same vaelue 1", ->
    for i in [0..9]
      a = crc32c.calculate("#{i}-#{i}") << 0
      console.log(a)
describe "crc32c2", ->
  lines = fs.readFileSync(path.resolve("tmp/mm_java.csv")).toString().split("\n")
  it "shuold has same value 0", ->
    for line in lines
      continue if line.length is 0
      vals = line.split(",")
      console.log(line)
      console.log(vals)
      seed = parseInt(vals[0])
      value = parseInt(vals[1])
      hash = crc32c.calculate("#{seed}-#{seed}") << 0
      console.log(value,hash)
      assert.equal(value , hash)
