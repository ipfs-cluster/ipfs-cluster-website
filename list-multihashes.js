const multihashes = require('multihashes')
const buf = new Buffer('hello world')

const funcs = ['sha1', 'sha2-256', 'blake2b', 'blake2s']

for (const i in funcs) {
  const encoded = multihashes.encode(buf, funcs[i])
  const decoded = multihashes.decode(encoded)
  console.log('HASH: ' + encoded.toString('hex'))
  console.log('name: ' + decoded.name)
  console.log('code: ' + decoded.code)
  console.log('length: ' + decoded.length)
  console.log('digest: ' + decoded.digest.toString('hex'))
  console.log('=======')
}
