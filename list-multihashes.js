const multihash = require('multihashes')
const multihashing = require('multihashing')

const buf = new Buffer('Merkle–Damgård', 'utf8')

const funcs = ['sha1', 'sha2-256', 'sha2-512', 'blake2b-512', 'blake2b-256']

for (const i in funcs) {
  const encoded = multihashing(buf, funcs[i])
  const decoded = multihash.decode(encoded)

  console.log('### ' + decoded.name)
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
