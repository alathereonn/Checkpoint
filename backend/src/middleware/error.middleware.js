module.exports = (err, req, res, next) => {
  console.error(err);
  if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ success:false, message:'Resource already exists', errors:[] });
  if (err.code === 'LIMIT_FILE_SIZE') return res.status(422).json({ success:false, message:'Cover must be smaller than 5 MB', errors:[] });
  res.status(err.status || 500).json({ success:false, message: err.status ? err.message : 'Internal server error', errors:[] });
};
