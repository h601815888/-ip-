import ipaddress
import re
import os

def merge_rsc_files():
    all_networks = set()
    # 匹配 address= 后面直到空格或结尾的 IP 掩码内容
    ip_pattern = re.compile(r'address=([0-9a-fA-F\.:/]+)')
    
    # 查找目录下所有的 rsc 文件
    files = [f for f in os.listdir('.') if f.endswith('.rsc')]
    print(f"检测到文件: {files}")

    for file_name in files:
        with open(file_name, 'r', encoding='utf-8') as f:
            for line in f:
                match = ip_pattern.search(line)
                if match:
                    try:
                        # strict=False 自动处理非网络边界的 IP（如 1.1.1.1/24 转为 1.1.1.0/24）
                        net = ipaddress.ip_network(match.group(1), strict=False)
                        all_networks.add(net)
                    except ValueError:
                        continue

    # 核心步骤：聚合网段（包含去重和连续网段合并）
    merged = list(ipaddress.collapse_addresses(all_networks))
    
    # 写入结果
    with open('CN_Final.rsc', 'w', encoding='utf-8') as f:
        f.write("/ip firewall address-list\n")
        for net in merged:
            f.write(f"add list=CN address={net} comment=AS4809\n")
    
    print(f"处理完成：原始条目约 {len(all_networks)}，合并后条目 {len(merged)}")

if __name__ == "__main__":
    merge_rsc_files()
