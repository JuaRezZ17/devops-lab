# Infrastructure Update Pipeline

## Overview
This project demonstrates a CI/CD pipeline that builds and secures a Docker image, pushes it to GitHub Container Registry (GHCR), and updates a Helm Chart repository to trigger a GitOps-style deployment flow.

The pipeline uses three main jobs:
1. **CI**: run linter and tests.
2. **Build**: build the Docker image, scan it with Trivy, and push it to GHCR using a dynamic version tag.
3. **GitOps Update**: update the `image.tag` field in a Helm Chart `values.yaml` file, commit the change, and push it to the infrastructure repository.

## Key Workflow
### Job 1 — CI
- Checks out the application repository.
- Runs the linter.
- Executes the test suite.
- Prevents further pipeline execution if any check fails.

### Job 2 — Build
- Runs only if the CI job succeeds.
- Builds the Docker image for the application.
- Scans the image with Trivy to detect vulnerabilities.
- Pushes the image to GitHub Container Registry using a tag like `v1.0.${{ github.run_number }}`.

### Job 3 — GitOps Update
- Checks out the separate Helm Chart repository that stores deployment config.
- Updates `values.yaml` with the new image tag.
- Uses `yq` or a YAML-safe tool to modify `image.tag` automatically.
- Commits and pushes the updated values file back to the infrastructure repository.
- Uses `[skip ci]` in the commit message to avoid retriggering the same GitHub Actions workflow.

## Why this project matters
- Demonstrates a minimal GitOps-style flow without a full GitOps operator.
- Shows how to connect container build pipelines with infrastructure configuration.
- Protects deployable artifacts using vulnerability scanning before publishing.
- Illustrates safe automated commits to an infrastructure repo from a pipeline.

## Project Structure
```
Infrastructure Update Pipeline/
├── README.md
├── WALKTHROUGH.md
└── img/
    ├── job1.png
    ├── job2.png
    ├── job3_1.png
    ├── job3_2.png
    └── job3_3.png
```

## Prerequisites
- GitHub repository for the application source code.
- GitHub Actions enabled in the repository.
- GitHub Container Registry (GHCR) access.
- A Helm Chart repository to store `values.yaml` and deployment manifests.
- `yq` available on the runner (GitHub-hosted Ubuntu runners already include it).
- A valid GitHub token with write permissions for the Helm Chart repository.

## Notes
- The dynamic image tag uses GitHub-native variables such as `github.run_number` to generate a new version on every run.
- The pipeline should use the GitHub token with repository write access and include `permissions: contents: write` for the GitOps update job.
- The commit must include `[skip ci]` to avoid infinite workflow loops when pushing changes back to the infra repository.

## How to Use
1. Copy the workflow from `WALKTHROUGH.md` into `.github/workflows/` in your application repository.
2. Configure the repository name, GHCR package path, and Helm repo path in the workflow.
3. Ensure the Helm Chart `values.yaml` file contains an `image.tag` field.
4. Push a change to trigger the pipeline.
5. Verify that the application image is built, scanned, pushed, and the Helm repo is updated.

## References
- `WALKTHROUGH.md`: step-by-step explanation of the pipeline.
- `img/`: visual diagrams for each pipeline job.