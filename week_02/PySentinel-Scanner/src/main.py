from scanner import check_ports, check_permissions
from reporter import generate_pdf

def run_pysentinel():
    # 1. Scan
    puertos = check_ports()
    permisos = check_permissions()
    
    # 2. Report
    generate_pdf(puertos, permisos)
    print("¡Reporte generado con éxito!")

if __name__ == "__main__":
    run_pysentinel()