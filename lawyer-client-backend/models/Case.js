const mongoose = require('mongoose');

const caseSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  caseType: { type: String, required: true },
  clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  locked: { type: Boolean, default: false }, // Field to track if the case is locked
  lockedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' } // Field to track the user who locked it
});

module.exports = mongoose.model('Case', caseSchema);
