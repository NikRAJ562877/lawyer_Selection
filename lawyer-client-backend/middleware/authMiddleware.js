const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  // Log the authorization header for debugging
  console.log('Authorization Header:', req.headers['authorization']);

  // Extract token from the 'Authorization' header
  const token = req.headers['authorization']?.split(' ')[1];
  
  if (!token) {
    // If no token is found, return 401 Unauthorized
    return res.status(401).json({ message: 'Unauthorized' });
  }

  // Verify the token using JWT and your secret
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      // If token verification fails, return 403 Forbidden
      return res.status(403).json({ message: 'Forbidden' });
    }

    // Attach the decoded user to the req object
    req.user = user;
    
    // Proceed to the next middleware or route handler
    next();
  });
};

module.exports = authMiddleware;
