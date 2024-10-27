const express = require('express');
const Case = require('../models/Case');
const authMiddleware = require('../middleware/authMiddleware');
const router = express.Router();

// Submit case
router.post('/', authMiddleware, async (req, res) => {
  const { title, description, caseType } = req.body;

  if (!title || !description || !caseType) {
    return res.status(400).json({ message: 'All fields are required.' });
  }


  try {
    const newCase = new Case({
      title,
      description,
      caseType,
      clientId: req.user.id // Get client ID from token
    });
    await newCase.save();
    res.status(201).json(newCase);
  } catch (error) {
    console.error(error);
    res.status(400).json({ message: 'Failed to submit case', error });
  }
});

// Lock case
router.post('/cases/lock', authMiddleware, async (req, res) => {
  const { caseId } = req.body;
  const userId = req.user.id; // Get user ID from token

  try {
    const caseToLock = await Case.findById(caseId);

    if (!caseToLock) {
      return res.status(404).json({ message: 'Case not found' });
    }

    if (caseToLock.locked) {
      return res.status(400).json({ message: 'Case is already locked' });
    }

    // Lock the case and track who locked it
    caseToLock.locked = true;
    caseToLock.lockedBy = userId;
    await caseToLock.save();

    res.status(200).json({ message: 'Case locked successfully', case: caseToLock });
  } catch (error) {
    console.error(error);
    res.status(400).json({ message: 'Failed to lock case', error });
  }
});

module.exports = router;
