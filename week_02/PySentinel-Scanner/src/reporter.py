from fpdf import FPDF
from datetime import datetime

class SentinelReport(FPDF):
    def header(self):
        self.set_font("Arial", "B", 15)
        self.cell(0, 10, "PySentinel-Scanner - Security report", 0, 1, "C")
        self.ln(10)

def generate_pdf(port_results, file_results):
    pdf = SentinelReport()
    pdf.add_page()
    
    # Datetime
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    pdf.set_font("Arial", "", 12)
    pdf.cell(0, 10, f"Date of scan: {now}", 0, 1)
    
    # Scoring logic
    insecure_count = list(port_results.values()).count("Open") + \
                     sum(1 for p, s in file_results.values() if s == "Unsafe")
    
    risk_level = "Green (Low)"
    color = (0, 128, 0)
    if insecure_count > 3:
        risk_level = "Red (High)"
        color = (255, 0, 0)
    elif insecure_count > 0:
        risk_level = "Yellow (Medium)"
        color = (255, 165, 0)

    pdf.set_text_color(*color)
    pdf.cell(0, 10, f"Risk Level: {risk_level}", 0, 1)
    pdf.set_text_color(0, 0, 0)
    
    # Findings Table (Simplified)
    pdf.ln(5)
    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 10, "Findings Details:", 0, 1)
    pdf.set_font("Arial", "", 10)
    
    for port, state in port_results.items():
        pdf.cell(0, 10, f"Port {port}: {state}", 0, 1)
    for file, info in file_results.items():
        pdf.cell(0, 10, f"File {file}: {info[0]} ({info[1]})", 0, 1)
    
    pdf.output("reporte_pysentinel.pdf")