const jwt = require('jsonwebtoken');
module.exports = (req, res, next) => {
  const token = req.headers.authorization?.replace(/^Bearer\s+/i, '');
  if (!token) return res.status(401).json({ success: false, message: 'Authentication required', errors: [] });
  try { req.user = jwt.verify(token, process.env.JWT_SECRET); next(); }
  catch (_) { return res.status(401).json({ success: false, message: 'Invalid or expired token', errors: [] }); }
};
