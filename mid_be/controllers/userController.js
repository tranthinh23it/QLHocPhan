const GiangVien = require('../models/GiangVien');
const mongoose = require('mongoose');
const cloudinary = require('../config/cloudinary');

const giangVienController = {
  //get all giangvien
  getAllGiangVien: async (req, res) => {
    try {
      console.log('🔍 getAllGiangVien called');
      
      // Get raw MongoDB collection without schema
      const collection = mongoose.connection.collection('GiangVien');
      console.log('📍 Collection name:', collection.collectionName);
      
      const giangvien = await collection.find({}).toArray();
      
      console.log('📊 Raw from DB:', JSON.stringify(giangvien, null, 2));
      console.log('📊 Total records:', giangvien.length);
      
      if (!giangvien || giangvien.length === 0) {
        console.log('⚠️ No documents found in collection');
        return res.status(200).json({
          success: true,
          message: 'GiangVien retrieved successfully',
          data: []
        });
      }
      
      // Normalize field names to lowercase
      const normalized = giangvien.map(gv => {
        const item = {
          idgv: gv.idgv || gv.IDGV || '',
          fullname: gv.fullname || gv.Fullname || '',
          image: gv.image || gv.Image || '',
          sumClass: parseInt(gv.sumClass || gv.SumClass || 0),
          _id: gv._id
        };
        console.log('📝 Normalized item:', JSON.stringify(item));
        return item;
      });
      
      console.log('✅ Final normalized data:', JSON.stringify(normalized, null, 2));
      
      return res.status(200).json({
        success: true,
        message: 'GiangVien retrieved successfully',
        data: normalized
      });
    } catch (error) {
      console.error('❌ getAllGiangVien error:', error);
      console.error('❌ Error stack:', error.stack);
      return res.status(500).json({
        success: false,
        message: 'Server error: ' + error.message
      });
    }
  },
  //get giangvien by id
  getGiangVienById: async (req, res) => {
    try {
      const { id } = req.params;
      console.log('🔍 getGiangVienById - id:', id);

      const gv = await GiangVien.findOne({ 
        $or: [
          { idgv: id.trim() },
          { IDGV: id.trim() }
        ]
      }).lean();

      if (!gv) {
        console.log('❌ GiangVien not found - id:', id);
        return res.status(404).json({
          success: false,
          message: 'GiangVien not found'
        });
      }

      // Normalize field names
      const normalized = {
        idgv: gv.idgv || gv.IDGV,
        fullname: gv.fullname || gv.Fullname,
        image: gv.image || gv.Image || '',
        sumClass: gv.sumClass || gv.SumClass || 0,
        _id: gv._id
      };

      return res.status(200).json({
        success: true,
        message: 'GiangVien retrieved successfully',
        data: normalized
      });
    } catch (error) {
      console.error('getGiangVienById error:', error);
      return res.status(500).json({
        success: false,
        message: 'Server error'
      });
    }
  },
  //add giangvien
  createGiangVien: async (req, res) => {
    try {
      const { idgv, fullname, sumClass } = req.body;
      if (!idgv || !fullname) {
        return res.status(400).json({
          success: false,
          message: 'IDGV and fullname are required'
        });
      }
      // Check if IDGV already exists
      const existingGiangVien = await GiangVien.findOne({ idgv: idgv.trim() });
      if (existingGiangVien) {
        return res.status(400).json({
          success: false,
          message: 'IDGV already exists'
        });
      }
      let image = '';
      if (req.file) {
        try {
          console.log('📤 Uploading image to Cloudinary...');
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
          console.log('✅ Image uploaded successfully');
        } catch (error) {
          console.error('❌ Image upload error:', error);
          // Log but don't fail - continue without image
          console.log('⚠️ Continuing without image');
        }
      }
      const newGiangVien = new GiangVien({
        idgv: idgv.trim(),
        fullname,
        image: image,
        sumClass: parseInt(sumClass) || 0
      });

      await newGiangVien.save();

      // Normalize response field names
      const normalized = {
        idgv: newGiangVien.idgv,
        fullname: newGiangVien.fullname,
        image: newGiangVien.image || '',
        sumClass: newGiangVien.sumClass || 0,
        _id: newGiangVien._id
      };

      return res.status(201).json({
        success: true,
        message: 'GiangVien created successfully',
        data: normalized
      });
    } catch (error) {
      console.error('createGiangVien error:', error);
      return res.status(500).json({
        success: false,
        message: 'Server error'
      });
    }
  },
  // update giangvien
  updateGiangVien: async (req, res) => {
    try {
      const { id } = req.params;
      const { fullname, sumClass } = req.body;

      console.log('🔍 updateGiangVien - id:', id);

      if (!id) {
        return res.status(400).json({
          success: false,
          message: 'IDGV parameter is required'
        });
      }

      // Query both lowercase and uppercase field names
      let giangvien = await GiangVien.findOne({ 
        $or: [
          { idgv: id.trim() },
          { IDGV: id.trim() }
        ]
      });

      if (!giangvien) {
        console.log('❌ GiangVien not found - id:', id);
        return res.status(404).json({
          success: false,
          message: `GiangVien not found`
        });
      }

      console.log('✅ Found giangvien');

      // Update fields
      if (fullname !== undefined && fullname !== null && fullname !== '') {
        giangvien.fullname = fullname;
      }

      if (sumClass !== undefined && sumClass !== null) {
        giangvien.sumClass = parseInt(sumClass) || 0;
      }

      // Upload file lên Cloudinary nếu có
      if (req.file) {
        try {
          console.log('📤 Uploading image to Cloudinary...');
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
          giangvien.image = result.secure_url;
          console.log('✅ Image uploaded successfully');
        } catch (error) {
          console.error('❌ Image upload error:', error);
          console.log('⚠️ Continuing without image update');
        }
      }

      await giangvien.save();
      console.log('✅ GiangVien saved successfully');

      // Normalize response field names
      const normalized = {
        idgv: giangvien.idgv || giangvien.IDGV,
        fullname: giangvien.fullname,
        image: giangvien.image || '',
        sumClass: giangvien.sumClass || 0,
        _id: giangvien._id
      };

      return res.status(200).json({
        success: true,
        message: 'GiangVien updated successfully',
        data: normalized
      });
    } catch (error) {
      console.error('❌ updateGiangVien error:', error);
      return res.status(500).json({
        success: false,
        message: 'Server error: ' + error.message
      });
    }
  },
  // delete giangvien
  deleteGiangVien: async (req, res) => {
    try {
      const { id } = req.params;
      console.log('🔍 deleteGiangVien - id:', id);

      let giangvien = await GiangVien.findOneAndDelete({ 
        $or: [
          { idgv: id.trim() },
          { IDGV: id.trim() }
        ]
      });

      if (!giangvien) {
        console.log('❌ GiangVien not found for deletion - id:', id);
        return res.status(404).json({
          success: false,
          message: 'GiangVien not found'
        });
      }

      console.log('✅ GiangVien deleted successfully');
      return res.status(200).json({
        success: true,
        message: 'GiangVien deleted successfully'
      });
    } catch (error) {
      console.error('deleteGiangVien error:', error);
      return res.status(500).json({
        success: false,
        message: 'Server error'
      });
    }
  }
};

module.exports = giangVienController;
