const mongoose = require('mongoose');

const giangVienSchema = new mongoose.Schema(
  {
    idgv: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },
    fullname: {
      type: String,
      required: true
    },
    image: {
      type: String,
      default: ''
    },
    sumClass: {
      type: Number,
      default: 0
    }
  },
  { timestamps: false }
);

module.exports = mongoose.model('GiangVien', giangVienSchema, 'GiangVien');
