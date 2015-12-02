crc32c = require "fast-crc32c"
module.exports = (value) -> crc32c.calculate(value) << 0
