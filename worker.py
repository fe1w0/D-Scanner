from scanner import scan_ports

TARGETS_PORTS = '22,23,80,888,443,8000,8888,8080'
MASSCAN_RATE = 3

# 读取文件中的 IP 地址
def read_ip_addresses_from_file(file_path):
    ip_ranges = []
    with open(file_path, 'r') as file:
        for line in file:
            ip = line.strip()
            if ip:
                ip_ranges.append(ip)
    return ip_ranges

# 指定文件路径
file_path = 'targets.txt'

# 从文件读取 IP 地址并添加到 ip_ranges
ip_ranges = read_ip_addresses_from_file(file_path)

results = []
for ip in ip_ranges:
    result = scan_ports.delay(ip, ports=TARGETS_PORTS, rate=MASSCAN_RATE)
    results.append(result)

# 可选：等待所有结果完成
for result in results:
    print(result.get())