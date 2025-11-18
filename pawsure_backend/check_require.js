try {
  console.log('resolved:', require.resolve('@nestjs/platform-express'))
} catch (err) {
  console.error('err', err && err.stack ? err.stack : err)
  process.exit(1)
}
