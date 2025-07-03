.
Challenge 1: Perform an interactive rebase to modify commit history (rename, squash, reorder commits).
Answer: 
We can use interactive rebase (git rebase -i) to rename, squash, and reorder commits in your Git history.
Step 1: View Recent Commits
First, check the last few commits:
git log --oneline -n 5
Example output:
a1b2c3d (HEAD -> feature-branch) Added new feature
e4f5g6h Fixed API issue
i7j8k9l Updated documentation
m0n1o2p Initial commit

Step 2: Start an Interactive Rebase
To modify the last 3 commits, run:
git rebase -i HEAD~3
This opens an editor with commit history:
pick a1b2c3d Added new feature
pick e4f5g6h Fixed API issue 
pick i7j8k9l Updated documentation
Step 3: Modify Commits
1 Rename a Commit Message
Change pick to reword for the commit you want to rename

reword a1b2c3d Added new feature
pick e4f5g6h Fixed API issue
pick i7j8k9l Updated documentation
•	Save and close the editor.
•	Git will prompt you to edit the commit message.
2 Squash Commits (Combine Multiple Commits)
If you want to merge multiple commits into one, change:
pick a1b2c3d Added new feature
pick e4f5g6h Fixed API issue
squash i7j8k9l Updated documentation
•	Save and close the editor.
•	Git will show a new editor where you can combine commit messages.
3 Reorder Commits
To reorder commits, simply change their order:
pick e4f5g6h Fixed API issue
pick i7j8k9l Updated documentation
pick a1b2c3d Added new feature
•	Save and close the editor.
•	Git will replay commits in the new order.
Step 4: Continue and Push Changes
After making changes:
git rebase --continue
If you've already pushed the commits, force push is required:
git push origin feature-branch --force
Use caution when force-pushing, especially in shared branches.

✅ Challenge 2: Use git cherry-pick to apply a specific commit from another branch to your current branch.
Answer:
Step 1: Check the Commit History of the Source Branch
Switch to the branch where the commit exists and list recent commits:
git checkout feature-branch
git log --oneline --graph -n 5
Example output:
a1b2c3d (HEAD -> feature-branch) Added feature X
e4f5g6h Fixed API issue
i7j8k9l Updated documentation

Step 2: Switch to the Target Branch
Move to the branch where you want to apply the commit:
git checkout main
Step 3: Apply the Specific Commit
Pick a commit from feature-branch (e.g., e4f5g6h) and apply it to main:
git cherry-pick e4f5g6h
If successful, you’ll see:
[main a9d8e7c] Fixed API issue
 1 file changed, 2 insertions(+), 1 deletion(-)

Step 4: Handle Cherry-Pick Conflicts (If Needed)
If there's a conflict:
1.	Resolve the conflict manually in the affected files.
2.	Mark the conflict as resolved:
git add <resolved-file>
3.	Continue cherry-picking:
git cherry-pick --continue
To abort the cherry-pick and restore the previous state:
git cherry-pick --abort
Step 5: Push the Changes
git push origin main

✅ Challenge 3: Create a merge conflict scenario and manually resolve it using git merge and git rebase.
Answer:
You can create a merge conflict scenario and resolve it using both git merge and git rebase.
Step 1: Setup a Repository (or Use an Existing One)
git init merge-conflict-demo
cd merge-conflict-demo
echo "Line 1" > conflict.txt
git add conflict.txt
git commit -m "Initial commit"

Step 2: Create a Feature Branch and Modify the File
git checkout -b feature-branch
echo "Feature branch change" > conflict.txt
git commit -am "Modified conflict.txt in feature-branch"

Step 3: Modify the File in main (Causing a Conflict)
git checkout main
echo "Main branch change" > conflict.txt
git commit -am "Modified conflict.txt in main"

Step 4: Merge Feature Branch (Causing a Conflict)
git merge feature-branch
You’ll see:
Auto-merging conflict.txt

CONFLICT (content): Merge conflict in conflict.txt
Automatic merge failed; fix conflicts and then commit the result.
Step 4.
Resolve Merge Conflict Manually
Open conflict.txt, which looks like:
<<<<<<< HEAD
Main branch change
=======
Feature branch change
>>>>>>> feature-branch
Edit the file to keep both changes:


Main and Feature branch merged successfully.
Mark the conflict as resolved:
git add conflict.txt
git commit -m "Resolved merge conflict"

Step 5: Reset and Use git rebase to Handle the Conflict
If you prefer rebase, reset, and use:
git checkout main
git reset --hard HEAD~1  # Undo the merge
git rebase feature-branch
•	If conflicts occur, Git will stop and prompt you to resolve them manually.
•	Follow Step 4.1 to edit the file, then run:
git add conflict.txt
git rebase --continue
Step 6: Push Changes
If you modified history using rebase, force push is needed:
git push origin main --force

✅ Challenge 4: Undo a commit using git reset (soft, mixed, and hard) and git revert – understand the differences.
Answer:
You can undo a commit using git reset (soft, mixed, hard) or git revert. Below is a step-by-step guide to understand their differences.
Step 1: Create a Sample Repository and Make Commits
git init undo-demo 
cd undo-demo 
echo "First commit" > file.txt 
git add file.txt 
git commit -m "First commit" 
echo "Second commit" >> file.txt 
git commit -am "Second commit" 
echo "Third commit" >> file.txt 
git commit -am "Third commit"
Now, we have 3 commits.
Check commit history:
git log --oneline --graph --decorate -n 3
Example output:
abc1234 (HEAD -> main)  Third commit def5678  Second commit ghi7890 First commit
Option 1: Undo a Commit Using git reset
1 Git reset --soft (Undo Commit, Keep Changes Staged)
git reset --soft HEAD~1
•	Moves HEAD back one commit.
•	Keeps changes in the staging area (can be re-committed).
•	Example Use Case: You committed too early and want to edit before recommitting.
✅ Commit undone, but changes remain staged (git status will show staged files).
2 git reset --mixed (Undo Commit, Keep Changes Unstaged)
git reset --mixed HEAD~1
•	Moves HEAD back one commit.
•	Keeps changes in working directory, but unstaged (must git add again).
•	Example Use Case: You committed but forgot to stage some files.
Commit undone, but changes remain unstaged (git status will show modified files).
3 git reset --hard (Undo Commit and Discard Changes)
git reset --hard HEAD~1
🚨 WARNING: This deletes the commit and all changes in your working directory.
•	Moves HEAD back one commit.
•	Deletes all changes (cannot be recovered unless backed up).
•	Example Use Case: You made a bad commit and want to completely remove it.
✅Commit undone, and changes are lost.
Reset Summary:
Command	Effect
git reset --soft HEAD~1	Undo commit, keep changes staged
git reset --mixed HEAD~1	Undo commit, keep changes unstaged
git reset --hard HEAD~1	Undo commit and delete all changes
Option 2: Undo a Commit Using git revert (Safer)
Unlike reset, git revert does not delete history. Instead, it creates a new commit that cancels the previous commit.
git revert HEAD
•	This creates a new commit that undoes the last commit.
•	Safe for shared repositories (does not rewrite history).
•	Example Use Case: You already pushed the commit and need to undo it without force-pushing.
It' creates a new commit with reversed changes.
Step 3: Push Changes (If Reset or Revert Was Used)
If you've already pushed commits to GitHub, you might need a force push after git reset:
git push origin main --force
🚨 Caution: This rewrites history and can affect others working on the branch.
If using git revert, just push normally:
git push origin main
It’s safer because it does not require force-pushing.

✅ Challenge 5: Amend the last commit message and add a forgotten file to the last commit using git commit --amend.
We can amend the last commit message and add a forgotten file using git commit --amend. Here’s how:
Step 1: Check Your Last Commit
git log --oneline -n 1
Example output:
a1b2c3d (HEAD -> main) Initial commit
Step 2: Modify the Last Commit Message
If you only want to change the commit message, run:
git commit --amend -m "Updated commit message"
This replaces the last commit message without modifying any files.
Step 3: Add a Forgotten File to the Last Commit
1.	Create or modify the file:
echo "New content" > forgotten.txt
Stage the new file:
git add forgotten.txt
Amend the last commit to include this file:
git commit --amend --no-edit
•	--no-edit keeps the same commit message.
•	The commit is now updated to include forgotten.txt.
Step 4: Push the Amended Commit
If you have already pushed the commit to GitHub, you need to force push:
git push origin main --force
🚨 Caution: Force-pushing rewrites history and can affect collaborators.

✅ Challenge 6: Set up Git hooks (pre-commit or post-commit) to automate a simple check before committing changes.
We can set up Git hooks to automate checks before committing changes. Below is a step-by-step guide to creating a pre-commit hook that checks for trailing whitespace before allowing a commit.
Step 1: Navigate to the Git Hooks Directory
Each Git repository has a .git/hooks/ directory containing sample hooks. Move into your repository:
cd /path/to/your-repo

cd .git/hooks
Step 2: Create a Pre-Commit Hook
Create a new pre-commit script:
nano pre-commit
#Paste the following script:
#!/bin/bash
# Check for trailing whitespace
if git diff --cached --check | grep -q "trailing whitespace"; then
    echo "❌ Commit rejected: Trailing whitespace found!"
    exit 1  # Prevent commit
fi
echo "✅ Pre-commit check passed!"
exit 0  # Allow commit
Explanation:
•	Uses git diff --cached --check to find trailing whitespace.
•	If found, aborts the commit (exit 1).
•	If no issues, commit proceeds (exit 0).
Step 3: Make the Hook Executable
chmod +x pre-commit
Step 4: Test the Hook
1.	Make a change with trailing whitespace: 
echo "Hello, world!   " >> file.txt  # Extra spaces at the end
git add file.txt
git commit -m "Test commit"

2.	If there’s trailing whitespace, the commit will be rejected:

❌ Commit rejected: Trailing whitespace found!
3.	Fix the issue by removing trailing spaces, then commit again.
Step 5: (Optional) Create a Post-Commit Hook
If you want to log commit details after every commit, create a post-commit hook:
nano post-commit
Add the following:
#!/bin/bash
echo "✅ Commit successful! Commit Hash: $(git rev-parse HEAD)"
Make it executable:
chmod +x post-commit
Make it executable:
chmod +x post-commit
Now, every time you commit, it will log:
✅ Commit successful! Commit Hash: a1b2c3d
Bonus: Share Hooks Across Team
To share hooks across a team:
1.	Move them to a version-controlled directory:
mkdir -p .githooks
mv .git/hooks/pre-commit .githooks/
2.	Configure Git to use this directory:
git config core.hooksPath .githooks

✅ Challenge 7: Rebase a feature branch on top of the main branch without creating unnecessary merge commits.
Answer:
We can rebase a feature branch on top of the main branch without creating unnecessary merge commits by following these steps.
Step 1: Switch to the Feature Branch
git checkout feature-branch
Ensure you're on the correct branch that needs to be rebased.
Step 2: Fetch the Latest Changes from Remote
Before rebasing, update your local main branch:
git fetch origin
git checkout main
git pull origin main
Now, your main branch is up-to-date.
Step 3: Rebase feature-branch on main
git checkout feature-branch
git rebase main
•	This moves all commits from feature-branch to start from the latest main commit.
•	It avoids unnecessary merge commits and keeps a clean history.
Step 4: Handle Conflicts (If Any)
If there are conflicts, Git will pause the rebase and show:
CONFLICT (content): Merge conflict in file.txt
1.	Manually resolve conflicts in the affected files.
2.	Mark conflicts as resolved:
git add <resolved-file>
3.	Continue the rebase:
git rebase --continue
4.	If needed, abort the rebase:
git rebase --abort
Step 5: Push the Rebasing Changes
If the feature branch is already pushed to GitHub, you need to force push:
git push origin feature-branch --force
🚨 Caution: This rewrites history. Be careful when working in a shared branch.
Example Scenario
Before Rebase (git log --oneline --graph)
commit C (feature-branch)
commit B (feature-branch)
 commit M2 (main)
commit M1 (main)



 Commit A (common ancestor)
After Rebase
Commit C' (feature-branch, rebased)
commit B' (feature-branch, rebased)
commit M2 (main)
 commit M1 (main)
commit A (common ancestor)
 No extra merge commits. A cleaner history!

✅ Challenge 8: Create a branch, make multiple commits, then squash them into a single commit using git rebase -i.
Answer:
We can create a branch, make multiple commits, and squash them into a single commit using git rebase -i by following these steps.
Step 1: Create a New Branch
git checkout -b feature-branch
Step 2: Make Multiple Commits
echo "First change" > file.txt
git add file.txt
git commit -m "First commit"


echo "Second change" >> file.txt
git commit -am "Second commit"
echo "Third change" >> file.txt
git commit -am "Third commit"
Now, we have three separate commits.
Check commit history:
git log --oneline -n 3
Example output:
abc1234 (HEAD -> feature-branch) Third commit
def5678 Second commit
ghi7890 First commit
Step 3: Start an Interactive Rebase
To squash the last 3 commits into one, run:
git rebase -i HEAD~3
Step 4: Modify the Rebase Commands
The editor will open with:
pick abc1234 Third commit
pick def5678 Second commit
pick ghi7890 First commit
Change it to:
pick abc1234 Third commit
squash def5678 Second commit
squash ghi7890 First commit
•	pick → Keeps the first commit.
•	squash → Merges the next commits into the first one.
Save and close the editor.
Step 5: Edit the Commit Message
Git will prompt you to edit the commit message:
# This is a combination of 3 commits.
First commit
Second commit
Third commit
Edit this into a single meaningful commit message:
Combined all feature changes into one commit
Save and close the editor.
Step 6: Push the Squashed Commit
If you already pushed the previous commits, force push is needed:
git push origin feature-branch --force
🚨 Caution: This rewrites history, so be careful in shared branches.
Step 7: Verify the Squash
Check commit history:
git log --oneline -n 3
#Expected output:
xyz5678 (HEAD -> feature-branch) Combined all feature changes into one commit


