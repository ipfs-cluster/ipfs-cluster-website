const multihash = require('multihashes')
const multihashing = require('multihashing')

const buf = new Buffer('Merkle–Damgård', 'utf8')

const funcs = [
  ['sha1', 160],
  ['sha2-256', 256],
  ['sha2-512', 256],
  ['sha2-512', 512],
  ['blake2b-512', 512],
  ['blake2b-256', 256],
  ['blake2s-256', 256],
  ['blake2s-128', 128],
]

for (const i in funcs) {
  const encoded = multihashing(buf, funcs[i][0], funcs[i][1] / 8)
  const decoded = multihash.decode(encoded)

  console.log('### ' + decoded.name + ' - ' + (decoded.length * 8) + ' bits')
  console.log('')
  console.log('{{% multihash')
  console.log('  fnName="' + decoded.name + '"')
  console.log('  fnCode="' + decoded.code.toString(16) + '"')
  console.log('  length="' + decoded.length + '"')
  console.log('  lengthCode="' + decoded.length.toString(16) + '"')
  console.log('  digest="' + decoded.digest.toString('hex') + '"')
  console.log('  multihash="' + encoded.toString('hex') + '"')
  console.log('%}}')
  console.log('')
}
