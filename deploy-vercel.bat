@echo off
echo 🚀 Vercel Deployment Helper for Dwelly

echo.
echo 📋 Pre-deployment Checklist:
echo [ ] GitHub repository created and code pushed
echo [ ] Vercel account created at vercel.com
echo [ ] PlanetScale database created at planetscale.com
echo [ ] Cloudinary account created at cloudinary.com
echo.

set /p continue="Continue with deployment setup? (y/n): "
if /i "%continue%" neq "y" (
    echo Deployment cancelled.
    exit /b 0
)

echo.
echo 📦 Installing Vercel CLI...
npm install -g vercel

echo.
echo 📁 Navigating to DWELLY directory...
cd DWELLY

echo.
echo 📦 Installing new dependencies...
npm install cloudinary multer-storage-cloudinary

echo.
echo 🔧 Ready for Vercel deployment!
echo.
echo Next steps:
echo 1. Set up your accounts (PlanetScale, Cloudinary)
echo 2. Push your code to GitHub
echo 3. Connect GitHub to Vercel
echo 4. Set environment variables in Vercel dashboard
echo 5. Deploy!
echo.
echo For detailed instructions, see: vercel-deployment-guide.md
echo.

set /p deploy_now="Deploy to Vercel now? (y/n): "
if /i "%deploy_now%" equ "y" (
    echo.
    echo 🚀 Starting Vercel deployment...
    vercel
) else (
    echo.
    echo 📚 Manual deployment: Run 'vercel' in the DWELLY directory when ready
)

echo.
echo ✅ Setup complete! Happy deploying! 🎉
pause 