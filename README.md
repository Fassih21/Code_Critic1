# Code Critic

An AI-powered code review platform built with Ruby on Rails 7. Users organize their work into projects, upload or paste code files, and trigger an AI review that flags issues line-by-line — with a threaded commenting system on top for human follow-up.

## Goal

The goal of this project was to combine traditional code-collaboration features (projects, files, comments) with an AI reviewer, so that uploaded code gets automated feedback before — or alongside — human eyes on it.

## Features

- **Authentication (Devise)**
  - Sign up, log in, log out, password recovery
- **Projects**
  - Each user creates and owns projects with a name and description
  - Project list is cached per-user (`Rails.cache`, 12h expiry) for faster loads
- **Code Files**
  - Attach a code file (via Active Storage) or paste code directly per project
  - Supported types: plain text, JavaScript, Ruby, C++, Python
  - 200KB file size limit, enforced with custom validations
- **AI-Powered Reviews**
  - One-click review generation per code file via `AiReviewServices`
  - Calls a Hugging Face-hosted model (StarCoder) to analyze code and return structured issues (line number, issue, suggestion)
  - Old reviews are cleared and regenerated on each run, with graceful fallback if the AI response isn't parseable
- **Comments**
  - Reviewers can leave line-specific comments on a review
  - Comment create/destroy handled via Turbo Streams for a no-reload UX

## Design Decisions

- **Models**
  - `User` → has many projects and comments, enforces a strong password format (upper, lower, digit, symbol)
  - `Project` → belongs to a user, has many code files
  - `CodeFile` → belongs to a project, has one review, has an attached file *or* pasted content
  - `Review` → belongs to a code file, has many comments, stores AI results as JSON
  - `Comment` → belongs to a review and a user, tied to a specific line number
- **Nested Resources**
  - Routes are nested and shallow: `projects → code_files → review → comments`, keeping URLs clean without deeply nested paths on show/destroy actions
- **AI Integration**
  - Isolated in a service object (`AiReviewServices`) rather than the controller, so the HTTP call, prompt building, and response parsing are easy to test and swap out independently of the Rails request/response cycle
- **Frontend**
  - Hotwire (Turbo + Stimulus) for interactivity, styled with Tailwind CSS

## Setup Instructions

### 1. Clone the repository
```bash
git clone https://github.com/your-username/code-critic.git
cd code-critic
```

### 2. Install dependencies
```bash
bundle install
```

### 3. Configure credentials
This app calls the Hugging Face Inference API and expects an API key in Rails credentials:
```bash
bin/rails credentials:edit
```
Add:
```yaml
huggingface_api_key: your_huggingface_api_key
```

### 4. Setup the database
```bash
bin/rails db:create db:migrate
```

### 5. Run the server
```bash
bin/dev
```

### 6. Open in browser
```
http://localhost:3000
```

## Tech Stack

- Ruby 3.4.4, Rails 7
- PostgreSQL
- Devise (auth)
- Active Storage (file uploads)
- Turbo & Stimulus (Hotwire)
- Tailwind CSS
- Hugging Face Inference API (AI code review)
- Solid Queue / Solid Cache / Solid Cable

## Example User Flow

1. User signs up and logs in
2. User creates a new project
3. User adds a code file to the project (upload or paste)
4. User triggers an AI review on that file → issues are generated and displayed inline
5. User (or teammate) adds comments on specific lines of the review
6. Reviews can be regenerated at any time, replacing the previous result

## Notes

- Built with simplicity in mind: one review per code file, latest run always replaces the last
- AI parsing includes a fallback path for when the model doesn't return clean JSON, so a bad response doesn't break the flow
- Can be extended with: multi-file diffing, review history/versioning, role-based access for team projects, support for more languages

## Known Limitations / Next Steps

- `AiReviewServices` has no automated tests around API failure/timeout handling
- Only one review is kept per code file (older reviews are destroyed rather than versioned)

## Contact

Feel free to reach out for feedback, collaboration, or freelance/internship opportunities.

---
If you find this project useful or learned something from it, consider giving it a star.