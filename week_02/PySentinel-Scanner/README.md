# PySentinel-Scanner

## Project Overview
PySentinel-Scanner is a professional CLI security scanner designed to perform basic local host assessments and generate a polished PDF report.

The tool is intended as a reusable security utility that checks network exposure, file permission hygiene, and produces a single-document summary for review.

## Features
- Port scan for critical services on `localhost`
  - SSH: `22`
  - HTTP: `80`
  - HTTPS: `443`
  - MariaDB/MySQL: `3306`
- File permission checks for sensitive system files
  - `/etc/shadow`
  - `/etc/passwd`
- Risk scoring with color-coded categories
  - Green: low risk
  - Yellow: medium risk
  - Red: high risk
- PDF report generation using `fpdf`
  - timestamped scan metadata
  - findings table
  - risk score summary

## Requirements
- Python 3.x
- `fpdf` Python package
- Linux environment for `/etc` permission checks
- Local network access for scanning `localhost`

## Repository Structure
- `pysentinel_scanner.py` — main CLI application
- `README.md` — project overview and usage
- `WALKTHROUGH.md` — step-by-step development and execution notes
- `reports/` — generated PDF scan reports
- `tests/` — optional unit tests for scanner functionality

## Usage
1. Install dependencies:
   ```bash
   pip install fpdf
   ```
   
2. Run the scanner:
    ```bash
    python3 main.py
    ```

3. Review the generated PDF report in reports/ or the output summary printed to the terminal.

## Output
The scanner produces:

- A terminal summary of open ports and insecure permissions
- A risk assessment score
- A PDF report with:
    - date and time of scan
    - findings table
    - risk rating

## Security Assessment
PySentinel-Scanner is designed for initial local host security checks and can be extended with:

    - additional port ranges
    - more filesystem checks
    - vulnerability classification
    - integration with CI pipelines

## Notes
Use this tool as a learning and automation exercise in security scanning. Keep the code version-controlled and document any enhancements in `WALKTHROUGH.md`.