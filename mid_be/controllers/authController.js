const bcrypt = require('bcryptjs');
const GiangVien = require('../models/GiangVien');
const cloudinary = require('../config/cloudinary');

const authController = {
  login: async (req, res) => {
    try {
      const { email, matkhau } = req.body;

      if (!email || !matkhau) {
        return res.status(400).json({
          success: false,
          message: 'Email and password are required'
        });
      }

      if (email === process.env.ADMIN_EMAIL && matkhau === process.env.ADMIN_PASSWORD) {
        return res.status(200).json({
          success: true,
          message: 'Login successful',
          data: {
            email: email
          }
        });
      }

      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Server error'
      });
    }
  },

  register: async (req, res) => {
    try {
      const { fullname } = req.body;

      if (!fullname) {
        return res.status(400).json({
          success: false,
          message: 'Fullname is required'
        });
      }

      const hashedPassword = await bcrypt.hash('temp123', 10);

      let image = '';

      if (req.file) {
        try {
          const result = await new Promise((resolve, reject) => {
            const stream = cloudinary.uploader.upload_stream(
              {
                folder: 'midterm_app/giangvien',
                resource_type: 'auto'
              },
              (error, result) => {
                if (error) reject(error);
                else resolve(result);
              }
            );
            stream.end(req.file.buffer);
          });
          image = result.secure_url;
        } catch (error) {
          return res.status(400).json({
            success: false,
            message: 'Image upload failed'
          });
        }
      }

      const newGiangVien = new GiangVien({
        fullname,
        image: image,
        sumClass: 0
      });

      await newGiangVien.save();

      const giangvienResponse = newGiangVien.toObject();

      return res.status(201).json({
        success: true,
        message: 'GiangVien registered successfully',
        data: giangvienResponse
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Server error'
      });
    }
  }
};

module.exports = authController;
