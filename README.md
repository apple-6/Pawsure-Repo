## Development Workflow: Linking Code to Jira Tasks

To ensure we can track progress effectively, it's essential to link your code changes directly to the corresponding tasks in Jira. We do this by including the **Jira Issue Key** (e.g., `APPLE-16`, `APPLE-19`) in your branch names and commit summaries using GitHub Desktop.

---

### Step-by-Step Tutorial (Using GitHub Desktop)

#### 1. Get the Jira Issue Key

* Go to our Jira project board or backlog: [`https://apple-6.atlassian.net/jira/software/projects/APPLE/boards/1/backlog`](https://apple-6.atlassian.net/jira/software/projects/APPLE/boards/1/backlog).
* Find the task or story you are working on (e.g., "Setup: Backend - Create NestJS + PostgreSQL boilerplate").
* Note down its unique key (e.g., `APPLE-16`). 
#### 2. Create a New Branch in GitHub Desktop

* Open the `Pawsure-Repo` repository in GitHub Desktop.
* Make sure your "Current branch" is `main` (or your primary development branch). Click **"Fetch origin"** to ensure you have the latest updates.
* Click on the **"Current branch"** button (where it says `main`).
* Click the blue **"New branch"** button.
* In the "Name" field, type the Jira key followed by a short description (use hyphens, no spaces).
    * Example: `APPLE-16-setup-backend-boilerplate`
* Click **"Create branch"**.
* Click **"Publish branch"** to push the new branch to GitHub.


*Jira will automatically detect this new branch and link it to the `APPLE-16` issue.*

#### 3. Write Your Code

* Use Cursor IDE (or your preferred editor) to make the code changes for the task. Save your files.

#### 4. Commit Changes in GitHub Desktop

* Switch back to GitHub Desktop. You will see your changed files listed in the "Changes" tab.
* Review the changes.
* In the **"Summary"** field (bottom left), **start your commit message with the Jira Issue Key**, followed by a concise description of the changes.
    * Example: `APPLE-16: Add initial NestJS module setup`
* Optionally, add more details in the "Description" field.
* Click the blue **"Commit to `APPLE-16-setup-backend-boilerplate`"** button.


*Jira will detect this commit and link it to the `APPLE-16` issue.*

#### 5. Push Commits

* After making one or more commits, click the **"Push origin"** button at the top of GitHub Desktop to upload your commits to GitHub.

#### 6. (Optional) Create a Pull Request

* If your team uses Pull Requests (PRs) for review:
    * Click the **"Create Pull Request"** button that often appears after pushing a new branch in GitHub Desktop, or go to the repository on GitHub.com.
    * When creating the PR on GitHub, **include the Jira Issue Key (`APPLE-16`) in the PR title**.
    * Example Title: `APPLE-16: Setup Backend Boilerplate`
* *Jira will detect the PR and link it.*

---

### Seeing the Results in Jira

Go back to the specific issue (e.g., `APPLE-16`) in Jira. You should now see a "Development" panel showing the linked branch, commits, and pull request (if created). This confirms the integration is working! 
By consistently following these steps, we ensure all code changes are traceable back to their original tasks in Jira.

Jira detects the link automatically because:

Scanning: Jira continuously scans the linked GitHub repository (Pawsure-Repo) for new activity (commits, branches, pull requests).

Pattern Recognition: It specifically looks for text in branch names, commit messages, and pull request titles that matches the pattern of your project's issue keys. In your case, it looks for APPLE- followed by numbers (e.g., APPLE-16, APPLE-19).

Matching: When it finds a piece of text that matches this pattern (like APPLE-16 in a commit message), it knows which specific issue in your Jira project to link that code activity to.
