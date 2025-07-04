#!/bin/bash
# Smart Git Push Script with Conflict Resolution

# Function to display colored output
print_color() {
    case $1 in
        "green")  echo -e "\033[32m$2\033[0m" ;;
        "blue")   echo -e "\033[34m$2\033[0m" ;;
        "yellow") echo -e "\033[33m$2\033[0m" ;;
        "red")    echo -e "\033[31m$2\033[0m" ;;
        *)        echo "$2" ;;
    esac
}

# Parse command line arguments
MESSAGE=""
FORCE=false

# If first argument doesn't start with -, treat it as message
if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
    MESSAGE="$1"
    shift
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--message)
            MESSAGE="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [message] [-m|--message 'commit message'] [-f|--force] [-h|--help]"
            echo "  message         Direct commit message (no flag needed)"
            echo "  -m, --message   Custom commit message"
            echo "  -f, --force     Force push (use with caution)"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 \"Fixed bug\"                    # Direct message"
            echo "  $0 -m \"Added feature\"             # With flag"
            echo "  $0                                 # Auto-generated message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

print_color "green" "=== Smart Git Push ==="

# Generate message if not provided
if [ -z "$MESSAGE" ]; then
    changed_files=$(git diff --name-only HEAD 2>/dev/null)
    if [ -n "$changed_files" ]; then
        file_count=$(echo "$changed_files" | wc -l | tr -d ' ')
        if [ "$file_count" -eq 1 ]; then
            MESSAGE="Update $file_count file: $(date '+%Y-%m-%d %H:%M')"
        else
            MESSAGE="Update $file_count files: $(date '+%Y-%m-%d %H:%M')"
        fi
    else
        MESSAGE="Auto commit: $(date '+%Y-%m-%d %H:%M:%S')"
    fi
fi

# Check if there are changes
changes=$(git status --porcelain 2>/dev/null)
if [ -z "$changes" ]; then
    print_color "yellow" "No changes to commit"
    exit 0
fi

print_color "blue" "Changes detected:"
git status --short

# Add all changes
print_color "blue" "Adding changes..."
git add -A

# Commit with message
print_color "blue" "Committing with message: $MESSAGE"
git commit -m "$MESSAGE"

# Try to push, handle conflicts
print_color "blue" "Pushing to GitHub..."
if git push origin main 2>/dev/null; then
    print_color "green" "✅ Successfully pushed to GitHub!"
else
    print_color "yellow" "⚠️ Push rejected, attempting to resolve..."
    
    # Pull and merge
    print_color "blue" "Pulling latest changes..."
    if git pull origin main --no-edit 2>/dev/null; then
        print_color "blue" "Attempting push again..."
        if git push origin main 2>/dev/null; then
            print_color "green" "✅ Successfully pushed after merge!"
        else
            print_color "red" "❌ Push still failed. Manual intervention required."
        fi
    else
        print_color "red" "❌ Merge conflicts detected. Please resolve manually:"
        print_color "yellow" "1. Fix conflicts in the files shown above"
        print_color "yellow" "2. Run: git add ."
        print_color "yellow" "3. Run: git commit -m 'Resolve conflicts'"
        print_color "yellow" "4. Run: git push origin main"
        exit 1
    fi
fi
