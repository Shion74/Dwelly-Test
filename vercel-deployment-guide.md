# 🚀 Vercel Deployment Guide for Dwelly

## Overview
Deploy your Dwelly student housing marketplace on Vercel with free database and storage solutions.

## 🌟 Why Vercel?

- ✅ **Free Tier**: Generous limits for personal projects
- ✅ **Zero Configuration**: Deploy with Git integration
- ✅ **Global CDN**: Fast loading worldwide
- ✅ **Automatic HTTPS**: SSL certificates included
- ✅ **Easy Domain Setup**: Custom domains supported
- ✅ **Environment Variables**: Secure config management

## 📋 Prerequisites

1. **GitHub Account** (to connect your repository)
2. **Vercel Account** (free at [vercel.com](https://vercel.com))
3. **PlanetScale Account** (free MySQL database)
4. **Cloudinary Account** (free image storage)

## 🗄️ Step 1: Database Setup (PlanetScale - Free MySQL)

### Create PlanetScale Database
1. **Sign up** at [planetscale.com](https://planetscale.com)
2. **Create new database**:
   - Name: `dwelly-db`
   - Region: Choose closest to your users
   - Plan: **Hobby** (Free - 1 database, 1GB storage, 1 billion row reads)

3. **Get Connection Details**:
   - Go to your database → **Connect**
   - Select **Node.js** 
   - Copy the connection string

4. **Database Schema Setup**:
   - Use PlanetScale's web console or connect via MySQL client
   - Run your existing SQL migration files

### Alternative: Railway (Free PostgreSQL/MySQL)
- **Sign up** at [railway.app](https://railway.app)
- **Create MySQL database**
- **Free tier**: $5 credit monthly (usually enough for small apps)

## 🖼️ Step 2: File Storage Setup (Cloudinary)

### Create Cloudinary Account
1. **Sign up** at [cloudinary.com](https://cloudinary.com)
2. **Free tier includes**:
   - 25GB storage
   - 25GB bandwidth/month
   - 1000 transformations/month

3. **Get API Credentials**:
   - Dashboard → **Settings** → **Security**
   - Copy: `Cloud Name`, `API Key`, `API Secret`

## 📦 Step 3: Update Your Application

### Add Dependencies
```bash
cd DWELLY
npm install cloudinary multer-storage-cloudinary
```

### Update package.json
Add to your `DWELLY/package.json`:
```json
{
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js",
    "vercel-build": "echo 'Building for Vercel'"
  }
}
```

## 🔧 Step 4: Configure File Uploads for Cloudinary

### Create Cloudinary Config
Create `DWELLY/config/cloudinary.js`:
```javascript
const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Configure multer with Cloudinary storage
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'dwelly/listings',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
    transformation: [
      { width: 1200, height: 800, crop: 'limit', quality: 'auto' }
    ]
  },
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: function (req, file, cb) {
    const filetypes = /jpeg|jpg|png|webp/;
    const mimetype = filetypes.test(file.mimetype);
    
    if (mimetype) {
      return cb(null, true);
    }
    cb(new Error('Only image files are allowed!'));
  }
});

module.exports = { upload, cloudinary };
```

### Update app.js for Cloudinary
Replace the existing multer configuration in `DWELLY/app.js`:

```javascript
// Remove the existing multer configuration and replace with:
const { upload } = require('./config/cloudinary');

// Make upload middleware available globally
app.locals.upload = upload;
```

## 🚀 Step 5: Deploy to Vercel

### Method 1: Git Integration (Recommended)
1. **Push to GitHub**:
   ```bash
   git add .
   git commit -m "Prepare for Vercel deployment"
   git push origin main
   ```

2. **Connect to Vercel**:
   - Go to [vercel.com](https://vercel.com) → **Dashboard**
   - Click **New Project**
   - **Import** your GitHub repository
   - Select your **Dwelly-Test** repository

3. **Configure Build Settings**:
   - Framework Preset: **Other**
   - Root Directory: `DWELLY`
   - Build Command: `npm run vercel-build`
   - Output Directory: (leave empty)

### Method 2: Vercel CLI
```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy from DWELLY directory
cd DWELLY
vercel

# Follow the prompts:
# - Set up and deploy? Y
# - Which scope? (your account)
# - Link to existing project? N
# - Project name: dwelly
# - Directory: ./ (current)
```

## ⚙️ Step 6: Environment Variables

### Set Environment Variables in Vercel
1. **Vercel Dashboard** → Your Project → **Settings** → **Environment Variables**

2. **Add these variables**:
```env
# Database Configuration (PlanetScale)
DB_HOST=your-planetscale-host
DB_USER=your-planetscale-username
DB_PASSWORD=your-planetscale-password
DB_NAME=dwelly-db
DATABASE_URL=mysql://username:password@host/database?sslaccept=strict

# Session Secret
SESSION_SECRET=your-super-secure-random-string-here

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# Node Environment
NODE_ENV=production
```

### For PlanetScale Connection String
Instead of individual DB variables, you can use:
```env
DATABASE_URL=mysql://username:password@host/database?sslaccept=strict&ssl={"rejectUnauthorized":true}
```

## 🔄 Step 7: Update Database Configuration

### Update `DWELLY/config/database.js`:
```javascript
const mysql = require('mysql2/promise');
require('dotenv').config();

// Parse DATABASE_URL if provided (for PlanetScale)
let dbConfig;

if (process.env.DATABASE_URL) {
  const url = new URL(process.env.DATABASE_URL);
  dbConfig = {
    host: url.hostname,
    port: url.port || 3306,
    user: url.username,
    password: url.password,
    database: url.pathname.slice(1), // Remove leading slash
    ssl: {
      rejectUnauthorized: true
    }
  };
} else {
  dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'dwelly_db',
  };
}

const pool = mysql.createPool({
  ...dbConfig,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  connectTimeout: 30000, // 30 seconds for serverless
  dateStrings: true
});

// Test the connection
pool.getConnection()
  .then(connection => {
    console.log('Database connected successfully');
    connection.release();
  })
  .catch(err => {
    console.error('Error connecting to the database:', err);
  });

module.exports = pool;
```

## 🌐 Step 8: Custom Domain (Optional)

### Add Custom Domain
1. **Vercel Dashboard** → Your Project → **Settings** → **Domains**
2. **Add Domain**: Enter your domain name
3. **Configure DNS**:
   - Add CNAME record pointing to `cname.vercel-dns.com`
   - Or use Vercel's nameservers

### Free Domain Options
- **Freenom**: Free domains (.tk, .ml, .ga, .cf)
- **Use Vercel subdomain**: `your-app.vercel.app` (always free)

## 💰 Free Tier Limits

### Vercel Free Tier:
- **100GB bandwidth** per month
- **Unlimited** personal projects
- **6 hours** of serverless function execution time
- **Custom domains** included

### PlanetScale Free Tier:
- **1 database**
- **1GB storage**
- **1 billion row reads** per month
- **10 million row writes** per month

### Cloudinary Free Tier:
- **25GB storage**
- **25GB bandwidth** per month
- **1000 transformations** per month

## 🔧 Deployment Commands

### Automatic Deployments
- **Push to GitHub** → Automatic deployment to Vercel
- **Production URL**: Updates automatically
- **Preview URLs**: Created for pull requests

### Manual Deployments
```bash
# Deploy to production
vercel --prod

# Deploy preview
vercel

# Check deployment status
vercel ls

# View logs
vercel logs
```

## 📊 Monitoring & Maintenance

### Vercel Analytics
- **Enable Analytics** in project settings
- **Monitor** page views, performance, and errors
- **Free tier** includes basic analytics

### Essential Monitoring
```bash
# Check function execution
vercel logs your-deployment-url

# Monitor database performance
# Use PlanetScale dashboard for query insights

# Check Cloudinary usage
# Monitor storage and bandwidth in Cloudinary dashboard
```

## ⚠️ Important Notes

### Serverless Limitations
1. **Stateless**: No persistent file storage on Vercel
2. **Cold starts**: First request may be slower
3. **Timeout**: Functions timeout after 10s (free) / 60s (pro)
4. **Memory**: 1024MB limit on free tier

### Database Considerations
1. **Connection pooling** is handled differently
2. **SSL required** for PlanetScale
3. **Connection limits** apply

### File Upload Changes
1. **Images stored** in Cloudinary (not local filesystem)
2. **URLs returned** by Cloudinary
3. **Automatic optimization** and CDN delivery

## 🎯 Success Checklist

- [ ] Repository connected to Vercel
- [ ] PlanetScale database created and connected
- [ ] Cloudinary configured for image uploads
- [ ] Environment variables set in Vercel
- [ ] Database schema migrated
- [ ] First deployment successful
- [ ] Custom domain configured (optional)
- [ ] SSL certificate active (automatic)

## 🆘 Troubleshooting

### Common Issues:

1. **Database Connection Errors**:
   - Check DATABASE_URL format
   - Verify SSL configuration
   - Ensure IP whitelist includes 0.0.0.0/0 for Vercel

2. **File Upload Issues**:
   - Verify Cloudinary credentials
   - Check file size limits
   - Ensure proper CORS settings

3. **Build Failures**:
   - Check Node.js version compatibility
   - Verify all dependencies in package.json
   - Review build logs in Vercel dashboard

4. **Function Timeouts**:
   - Optimize database queries
   - Reduce image processing
   - Consider caching strategies

---

🎉 **Your Dwelly application is now live on Vercel with global CDN, automatic SSL, and professional hosting - all for free!** 