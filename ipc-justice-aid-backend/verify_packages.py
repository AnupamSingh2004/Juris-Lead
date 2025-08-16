#!/usr/bin/env python3
"""
Verify that all required packages from requirements.txt are installed
"""

import subprocess
import sys
import pkg_resources
from packaging import requirements

def check_requirements():
    """Check if all packages in requirements.txt are installed"""
    
    print("🔍 Checking requirements.txt package installation...")
    
    try:
        with open('requirements.txt', 'r') as f:
            requirements_content = f.read()
            
        req_lines = [line.strip() for line in requirements_content.split('\n') 
                    if line.strip() and not line.startswith('#')]
        
        missing_packages = []
        installed_packages = []
        
        for req_line in req_lines:
            if req_line.startswith('#') or not req_line.strip():
                continue
                
            try:
                req = requirements.Requirement(req_line)
                pkg_resources.require(str(req))
                installed_packages.append(req.name)
                print(f"✅ {req.name}")
            except (pkg_resources.DistributionNotFound, pkg_resources.VersionConflict, Exception) as e:
                missing_packages.append(req_line)
                print(f"❌ {req_line} - {e}")
        
        print(f"\n📊 Summary:")
        print(f"✅ Installed: {len(installed_packages)}")
        print(f"❌ Missing: {len(missing_packages)}")
        
        if missing_packages:
            print(f"\n🚨 Missing packages:")
            for pkg in missing_packages:
                print(f"  - {pkg}")
            return False
        else:
            print(f"\n🎉 All requirements are satisfied!")
            return True
            
    except Exception as e:
        print(f"❌ Error checking requirements: {e}")
        return False

def install_missing_packages():
    """Install missing packages"""
    print("\n🔧 Installing missing packages...")
    try:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt'])
        print("✅ Package installation completed!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Package installation failed: {e}")
        return False

if __name__ == "__main__":
    print("🚀 Railway Package Verification")
    print("=" * 50)
    
    if not check_requirements():
        print("\n🔧 Attempting to install missing packages...")
        if install_missing_packages():
            print("\n✅ Re-checking after installation...")
            check_requirements()
        else:
            print("\n❌ Failed to install missing packages")
            sys.exit(1)
    
    # Test critical imports
    print("\n🧪 Testing critical imports...")
    critical_imports = [
        ('django', 'Django'),
        ('rest_framework', 'Django REST Framework'),
        ('psycopg2', 'PostgreSQL adapter'),
        ('corsheaders', 'CORS headers'),
        ('dj_database_url', 'Database URL parser'),
        ('gunicorn', 'Gunicorn WSGI server'),
    ]
    
    for module, name in critical_imports:
        try:
            __import__(module)
            print(f"✅ {name}")
        except ImportError as e:
            print(f"❌ {name} - {e}")
    
    print("\n🎯 Package verification completed!")
