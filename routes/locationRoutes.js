const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const { saveLocation, getLocationHistory } = require('../controllers/locationController');

const router = express.Router();

router.route('/')
    .post(protect, saveLocation)
    .get(protect, getLocationHistory);

router.route('/:driverId')
    .get(protect, getLocationHistory);

module.exports = router;
