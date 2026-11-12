const express = require('express');
const giangVienController = require('../controllers/userController');

const router = express.Router();

router.get('/', giangVienController.getAllGiangVien);
router.get('/:id', giangVienController.getGiangVienById);
router.post('/', giangVienController.createGiangVien);
router.put('/:id', giangVienController.updateGiangVien);
router.delete('/:id', giangVienController.deleteGiangVien);

module.exports = router;
