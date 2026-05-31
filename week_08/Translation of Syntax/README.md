# Translation of Syntax

## Overview
This exercise teaches how to translate a GitHub Actions CI workflow into GitLab CI/CD syntax.
The focus is on using `stages` instead of explicit job dependencies, and on running jobs inside isolated Docker containers managed by GitLab Runners.

## Objective
- Learn how GitLab CI uses a single `.gitlab-ci.yml` file at the repository root.
- Understand the `stages:` execution model and how it differs from GitHub Actions `needs`.
- Use a Docker-based GitLab Runner environment with `image: python:3.11-slim`.
- Rewrite the existing lint + test pipeline for the GitLab CI syntax.
- Push the code to GitLab and inspect the pipeline execution in the CI/CD menu.

## Key Files
- `WALKTHROUGH.md` — step-by-step guide for the exercise.
- `src/.gitlab-ci.yml` — example GitLab CI configuration for linting and tests.
- `src/app.py` — sample Python application.
- `src/requirements.txt` — Python dependencies.
- `src/test_app.py` — test suite for the Python application.

## GitLab CI Concepts
- `image:` tells GitLab Runner to run each job inside a Docker container with the specified runtime.
- `stages:` defines the ordered pipeline phases.
- `stage:` assigns a job to a specific phase.
- `before_script:` runs setup commands before each job’s `script:`.
- Jobs in the same stage run in parallel, and the next stage starts only after the current stage completes successfully.

## How to Use
1. Create a free account at GitLab.com.
2. Create a new repository and push this project to GitLab.
3. Ensure the GitLab pipeline file is placed at the repository root as `.gitlab-ci.yml`.
4. Visit the project’s CI/CD > Pipelines page to watch the pipeline run.

## Local Validation
To run the same checks locally:

```bash
cd week_08/Translation\ of\ Syntax/src
python -m pip install -r requirements.txt
python -m pytest
python -m flake8 app.py
```

## Project Structure
```
Translation of Syntax/
├── README.md
├── WALKTHROUGH.md
├── img/
└── src/
    ├── .gitlab-ci.yml
    ├── app.py
    ├── requirements.txt
    └── test_app.py
```

## Notes
The `WALKTHROUGH.md` file contains the full exercise narrative and screenshots showing GitLab account creation, repository upload, `.gitlab-ci.yml` creation, and pipeline execution.