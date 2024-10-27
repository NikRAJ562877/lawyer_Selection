// server.js
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const authRoutes = require('./routes/auth'); // Your existing auth routes
const caseRoutes = require('./routes/cases'); // Import your case routes
const cors = require('cors'); // Enable CORS for cross-origin requests

const app = express();
app.use(cors());
app.use(bodyParser.json()); // Parse JSON bodies

const PORT = process.env.PORT || 5000;

// Connect to MongoDB without deprecated options
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('MongoDB connection error:', err));

// Use routes
app.use('/api/auth', authRoutes);
app.use('/api/cases', caseRoutes); // Use your case routes

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
