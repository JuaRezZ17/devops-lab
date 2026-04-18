import socket
import os
import stat

def check_ports(host="127.0.0.1"):
    ports = [22, 80, 443, 3306]
    results = {}
    for port in ports:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = s.connect_ex((host, port))
        results[port] = "Open" if result == 0 else "Closed"
        s.close()
    return results

def check_permissions():
    files_to_check = ['/etc/passwd', '/etc/shadow']
    results = {}
    for file_path in files_to_check:
        if os.path.exists(file_path):
            mode = os.stat(file_path).st_mode
            permissions = oct(mode & 0o777)
            is_safe = (permissions == '0o644' and 'passwd' in file_path) or \
                      (permissions in ['0o640', '0o600'] and 'shadow' in file_path)
            results[file_path] = (permissions, "Safe" if is_safe else "Unsafe")
        else:
            results[file_path] = ("N/A", "Not found")
    return results