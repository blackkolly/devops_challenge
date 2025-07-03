#!/usr/bin/env python3
"""
Project Validation Script
Validates that all components of the Flask E-Commerce CI/CD project are properly set up.
"""

import os
import sys
import subprocess
import json
from pathlib import Path

class ProjectValidator:
    def __init__(self):
        self.project_root = Path.cwd()
        self.errors = []
        self.warnings = []
        self.successes = []

    def log_success(self, message):
        self.successes.append(f"✅ {message}")
        print(f"✅ {message}")

    def log_warning(self, message):
        self.warnings.append(f"⚠️  {message}")
        print(f"⚠️  {message}")

    def log_error(self, message):
        self.errors.append(f"❌ {message}")
        print(f"❌ {message}")

    def check_file_exists(self, file_path, description=""):
        """Check if a file exists"""
        full_path = self.project_root / file_path
        if full_path.exists():
            self.log_success(f"{description or file_path} exists")
            return True
        else:
            self.log_error(f"{description or file_path} is missing")
            return False

    def check_directory_exists(self, dir_path, description=""):
        """Check if a directory exists"""
        full_path = self.project_root / dir_path
        if full_path.exists() and full_path.is_dir():
            self.log_success(f"{description or dir_path} directory exists")
            return True
        else:
            self.log_error(f"{description or dir_path} directory is missing")
            return False

    def check_python_imports(self):
        """Check if all required Python modules can be imported"""
        required_modules = [
            'flask', 'werkzeug', 'sqlite3', 'pytest', 'gunicorn'
        ]
        
        for module in required_modules:
            try:
                __import__(module)
                self.log_success(f"Python module '{module}' is available")
            except ImportError:
                self.log_error(f"Python module '{module}' is not available")

    def check_flask_app(self):
        """Check if Flask app can be imported and initialized"""
        try:
            import app
            self.log_success("Flask app can be imported")
            
            # Check if app has required routes
            routes = []
            for rule in app.app.url_map.iter_rules():
                routes.append(rule.rule)
            
            required_routes = ['/', '/products', '/health', '/api/products']
            for route in required_routes:
                if route in routes:
                    self.log_success(f"Route '{route}' is defined")
                else:
                    self.log_error(f"Route '{route}' is missing")
                    
        except Exception as e:
            self.log_error(f"Cannot import Flask app: {e}")

    def check_tests(self):
        """Check if tests can run successfully"""
        try:
            result = subprocess.run(
                [sys.executable, '-m', 'pytest', 'tests/', '--tb=short', '-q'],
                capture_output=True,
                text=True,
                cwd=self.project_root
            )
            
            if result.returncode == 0:
                self.log_success("All tests pass successfully")
            else:
                self.log_error(f"Tests failed: {result.stdout}")
                
        except Exception as e:
            self.log_error(f"Cannot run tests: {e}")

    def check_docker_config(self):
        """Check Docker configuration"""
        if self.check_file_exists('Dockerfile', 'Dockerfile'):
            # Check if Dockerfile has required instructions
            dockerfile_content = (self.project_root / 'Dockerfile').read_text()
            required_instructions = ['FROM', 'WORKDIR', 'COPY', 'RUN', 'EXPOSE', 'CMD']
            
            for instruction in required_instructions:
                if instruction in dockerfile_content:
                    self.log_success(f"Dockerfile contains '{instruction}' instruction")
                else:
                    self.log_warning(f"Dockerfile missing '{instruction}' instruction")

    def check_ci_cd_config(self):
        """Check CI/CD configuration"""
        if self.check_file_exists('Jenkinsfile', 'Jenkins pipeline'):
            try:
                # Try different encodings
                jenkinsfile_content = None
                jenkinsfile_path = self.project_root / 'Jenkinsfile'
                
                for encoding in ['utf-8', 'latin-1', 'cp1252']:
                    try:
                        jenkinsfile_content = jenkinsfile_path.read_text(encoding=encoding)
                        break
                    except UnicodeDecodeError:
                        continue
                
                if jenkinsfile_content:
                    required_stages = ['Checkout', 'Test', 'Build', 'Deploy']
                    
                    for stage in required_stages:
                        if stage.lower() in jenkinsfile_content.lower():
                            self.log_success(f"Jenkins pipeline has '{stage}' stage")
                        else:
                            self.log_warning(f"Jenkins pipeline missing '{stage}' stage")
                else:
                    self.log_warning("Could not read Jenkinsfile due to encoding issues")
            except Exception as e:
                self.log_warning(f"Error reading Jenkinsfile: {e}")

    def check_project_structure(self):
        """Check overall project structure"""
        required_files = [
            ('app.py', 'Main Flask application'),
            ('requirements.txt', 'Python dependencies'),
            ('Dockerfile', 'Docker configuration'),
            ('Jenkinsfile', 'Jenkins pipeline'),
            ('README.md', 'Project documentation'),
        ]
        
        required_directories = [
            ('templates', 'HTML templates'),
            ('static', 'Static files'),
            ('tests', 'Test files'),
            ('scripts', 'Deployment scripts'),
        ]
        
        for file_path, description in required_files:
            self.check_file_exists(file_path, description)
            
        for dir_path, description in required_directories:
            self.check_directory_exists(dir_path, description)

    def check_template_files(self):
        """Check if all required template files exist"""
        required_templates = [
            'base.html', 'home.html', 'products.html', 'product_detail.html',
            'login.html', 'register.html', 'cart.html', 'checkout.html',
            'orders.html', 'order_confirmation.html', '404.html', '500.html'
        ]
        
        for template in required_templates:
            self.check_file_exists(f'templates/{template}', f'Template {template}')

    def check_static_files(self):
        """Check if static file directories exist"""
        static_dirs = ['css', 'js']
        
        for static_dir in static_dirs:
            self.check_directory_exists(f'static/{static_dir}', f'Static {static_dir}')

    def check_environment_setup(self):
        """Check if environment is properly set up"""
        # Check if virtual environment is active
        if hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
            self.log_success("Virtual environment is active")
        else:
            self.log_warning("Virtual environment is not active")

    def generate_report(self):
        """Generate validation report"""
        print("\n" + "="*60)
        print("PROJECT VALIDATION REPORT")
        print("="*60)
        
        print(f"\n✅ SUCCESSES ({len(self.successes)}):")
        for success in self.successes:
            print(f"  {success}")
            
        if self.warnings:
            print(f"\n⚠️  WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  {warning}")
                
        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            for error in self.errors:
                print(f"  {error}")
        
        print("\n" + "="*60)
        print("SUMMARY")
        print("="*60)
        print(f"✅ Successes: {len(self.successes)}")
        print(f"⚠️  Warnings: {len(self.warnings)}")
        print(f"❌ Errors: {len(self.errors)}")
        
        if len(self.errors) == 0:
            print("\n🎉 PROJECT VALIDATION PASSED!")
            print("Your Flask E-Commerce CI/CD project is ready for deployment!")
        else:
            print("\n❌ PROJECT VALIDATION FAILED!")
            print("Please fix the errors above before proceeding.")
            
        return len(self.errors) == 0

    def run_validation(self):
        """Run all validation checks"""
        print("🔍 Starting Flask E-Commerce Project Validation...")
        print("="*60)
        
        # Check project structure
        self.check_project_structure()
        
        # Check template files
        self.check_template_files()
        
        # Check static files
        self.check_static_files()
        
        # Check Python environment
        self.check_environment_setup()
        self.check_python_imports()
        
        # Check Flask app
        self.check_flask_app()
        
        # Check tests
        self.check_tests()
        
        # Check Docker configuration
        self.check_docker_config()
        
        # Check CI/CD configuration
        self.check_ci_cd_config()
        
        # Generate report
        return self.generate_report()

def main():
    """Main validation function"""
    validator = ProjectValidator()
    success = validator.run_validation()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
