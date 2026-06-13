# DevOps Research & Assessment

## Objective
Create an automated DORA metrics pipeline and Grafana dashboard that records deployment events (success/failure) and visualizes Deployment Frequency, Lead Time for Changes, Change Failure Rate and Time to Restore.

This README summarizes the exercise; the full step-by-step notes and screenshots are in the project `WALKTHROUGH.md`.

## Prerequisites
- Docker and Docker Compose
- A running Prometheus + Pushgateway + Grafana stack (examples provided in `WALKTHROUGH.md`)
- (Optional) A small MySQL instance if you prefer storing events in a relational DB

## Quick start (local)
1. Follow the directions in the `WALKTHROUGH.md` to create the docker-compose setup and start Prometheus, Pushgateway and Grafana.

2. Start the stack (example):

```bash
docker-compose up -d
```

3. Test sending a metric to Pushgateway (example):

```bash
echo "dora_deployment_timestamp_seconds{project=\"my-app\",status=\"success\",run_id=\"manual-001\"} $(date +%s)" \
  | curl --data-binary @- http://localhost:9091/metrics/job/dora/project/my-app/run/manual-001
```

If you prefer a MySQL record instead of Pushgateway, insert a simple row into a small table `deployments` with columns like `project, status, run_id, ts`.

## GitHub Actions integration
- Update your Week 8 GitHub Actions workflow to emit a metric (HTTP push to a reachable Pushgateway or an API that writes to your MySQL) on deployment completion or failure.
- Example Action step (curl to Pushgateway — adapt URL and authentication to your environment):

```yaml
- name: Push DORA metric
  run: |
    TIMESTAMP=$(date +%s)
    echo "dora_deployment_timestamp_seconds{project=\"my-app\",status=\"${{ job.status }}\",run_id=\"${{ github.run_id }}\"} $TIMESTAMP" \
      | curl --data-binary @- https://your-pushgateway.example/metrics/job/dora/project/my-app/run/${{ github.run_id }}
```

Notes:
- If your Pushgateway runs inside a private network, expose a secure endpoint or use an intermediate API that the Action can call.
- Alternatively, call a small cloud function / API that writes the event to your MySQL database.

## Grafana — DORA Metrics dashboard
Create a dashboard with the following panels and PromQL queries (adjust `project` label as needed):

- Deployment Frequency (Stat)
  - PromQL: `count(dora_deployment_timestamp_seconds{project="my-app",status="success"})`

- Lead Time for Changes (Stat — minutes)
  - PromQL: `avg(dora_lead_time_seconds{project="my-app"}) / 60`

- Change Failure Rate (Gauge — percentage)
  - PromQL: `(count(dora_deployment_result{project="my-app",status="failed"}) / count(dora_deployment_result{project="my-app"})) * 100`

- Time to Restore (Stat — minutes)
  - PromQL: `avg(dora_restore_time_seconds{project="my-app"}) / 60`

Suggested thresholds (use panel thresholds to show colors):
- Green: good (example: Failure Rate < 15%)
- Yellow: warning (example: Failure Rate 15–45%)
- Red: bad (example: Failure Rate > 45%)

## Testing & validation
- Use the curl example above or your CI pipeline to push sample metrics and then confirm Prometheus is scraping Pushgateway and Grafana panels update.

## References
- Full step-by-step with screenshots: [WALKTHROUGH.md](week_10/DevOps%20Research%20&%20Assessment/WALKTHROUGH.md#L1)

---

If you want, I can also:
- add a ready-to-use GitHub Actions snippet that writes to Pushgateway or MySQL; or
- create a simple minimal API (Python/Flask) to receive Action webhooks and forward metrics to Pushgateway/MySQL.

Created to accompany the exercise notes in `WALKTHROUGH.md`.