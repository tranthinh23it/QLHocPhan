# GiangVien Manager - Setup & Run Guide

## Prerequisites
- Node.js (v14+)
- MongoDB running locally (`mongodb://localhost:27017`)
- Flutter SDK
- Cloudinary account

## Backend Setup

1. **Navigate to backend folder:**
   ```bash
   cd mid_be
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure `.env` file:**
   ```
   PORT=5000
   MONGODB_URI=mongodb://localhost:27017/QLHocPhan
   ADMIN_EMAIL=admin@gmail.com
   ADMIN_PASSWORD=admin123
   CLOUDINARY_CLOUD_NAME=rcskgnvl
   CLOUDINARY_API_KEY=593932163956928
   CLOUDINARY_API_SECRET=11nN8sBtwjipjfaPJYVx4ZRm4QY
   ```

4. **Start backend:**
   ```bash
   npm run dev
   ```
   Server runs on `http://localhost:5000`

## Frontend Setup

1. **Navigate to app folder:**
   ```bash
   cd midterm_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run app:**
   - **Web:** `flutter run -d chrome`
   - **Real Device:** `flutter run` (ensure device IP is `192.168.51.103`)

## Login Credentials
- Email: `admin@gmail.com`
- Password: `admin123`

## Database
- **Name:** `QLHocPhan`
- **Collection:** `GiangVien`
- **Fields:** IDGV, Fullname, Image, SumClass

## Features
- ✅ Login/Register
- ✅ View all GiangVien
- ✅ Add new GiangVien
- ✅ Edit GiangVien (fullname, sumClass, image)
- ✅ Delete GiangVien
- ✅ Image upload to Cloudinary
